const functions = require('firebase-functions');
const { initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const express = require('express');
const cors = require('cors');
const twilio = require('twilio');
require('dotenv').config();

initializeApp();
const db = getFirestore();
const app = express();

app.disable('x-powered-by');
app.use(cors({ origin: true }));
app.use(express.urlencoded({ extended: false, limit: '100kb' }));
app.use(express.json({ limit: '100kb' }));

const asyncHandler = (handler) => (req, res, next) =>
  Promise.resolve(handler(req, res, next)).catch(next);

function getRequestUrl(req) {
  if (process.env.TWILIO_WEBHOOK_URL) return process.env.TWILIO_WEBHOOK_URL;
  const forwardedProtocol = req.get('x-forwarded-proto');
  const protocol = forwardedProtocol ? forwardedProtocol.split(',')[0] : req.protocol;
  return `${protocol}://${req.get('host')}${req.originalUrl}`;
}

function isValidTwilioRequest(req) {
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  const allowUnsignedLocalRequest =
    process.env.ALLOW_UNSIGNED_WEBHOOKS === 'true' &&
    process.env.NODE_ENV !== 'production';

  if (!authToken) return allowUnsignedLocalRequest;

  const signature = req.get('x-twilio-signature');
  if (!signature) return false;

  return twilio.validateRequest(
    authToken,
    signature,
    getRequestUrl(req),
    req.body,
  );
}

function sendTwiml(res, message) {
  const response = new twilio.twiml.MessagingResponse();
  if (message) response.message(message);
  res.status(200).type('text/xml').send(response.toString());
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'maisuchat-functions' });
});

app.post('/whatsapp/webhook', asyncHandler(async (req, res) => {
  if (!isValidTwilioRequest(req)) {
    res.status(403).send('Invalid webhook signature');
    return;
  }

  const incoming = req.body || {};
  const messageSid = typeof incoming.MessageSid === 'string'
    ? incoming.MessageSid.trim()
    : '';
  const from = typeof incoming.From === 'string' ? incoming.From.trim() : '';

  if (!messageSid || !from) {
    res.status(400).send('Invalid payload');
    return;
  }

  const messageRef = db.collection('whatsapp_messages').doc(messageSid);
  const messageData = {
    messageSid,
    from,
    to: incoming.To || null,
    body: typeof incoming.Body === 'string' ? incoming.Body.trim() : '',
    numMedia: Number.parseInt(incoming.NumMedia || '0', 10) || 0,
    timestamp: FieldValue.serverTimestamp(),
    direction: 'inbound',
  };

  try {
    await messageRef.create(messageData);
    console.log(`WhatsApp message stored: ${messageSid}`);
  } catch (error) {
    if (error.code !== 6 && error.code !== 'already-exists') {
      console.error('Firestore write error:', error.message);
      res.status(500).send('Could not store message');
      return;
    }
    console.log(`Duplicate WhatsApp message ignored: ${messageSid}`);
  }

  sendTwiml(
    res,
    'Obrigado por sua mensagem! Em breve você receberá uma resposta.',
  );
}));

app.use((error, req, res, next) => {
  if (res.headersSent) {
    next(error);
    return;
  }
  console.error('Unhandled function error:', error.stack || error.message);
  res.status(500).send('Internal server error');
});

exports.api = functions.https.onRequest(app);
