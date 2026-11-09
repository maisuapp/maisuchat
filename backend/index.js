require('dotenv').config();

const crypto = require('node:crypto');
const express = require('express');
const cors = require('cors');
const { initializeApp, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const app = express();
app.disable('x-powered-by');

const port = Number.parseInt(process.env.PORT || '3000', 10);
const allowedOrigins = (process.env.CORS_ORIGINS ||
  'http://localhost:3000,http://localhost:5000,http://localhost:5173,http://localhost:8080,http://127.0.0.1:3000,http://127.0.0.1:5000,http://127.0.0.1:5173,http://127.0.0.1:8080')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

let firestore = null;
let firebaseStatus = 'not-configured';

function tryInitializeFirebase() {
  const shouldInitialize = Boolean(
    process.env.FIREBASE_PROJECT_ID ||
      process.env.GOOGLE_APPLICATION_CREDENTIALS ||
      process.env.FIREBASE_CONFIG ||
      process.env.FIRESTORE_EMULATOR_HOST ||
      process.env.K_SERVICE ||
      process.env.GCLOUD_PROJECT,
  );

  if (!shouldInitialize) return;

  try {
    if (!getApps().length) {
      const config = process.env.FIREBASE_PROJECT_ID
        ? { projectId: process.env.FIREBASE_PROJECT_ID }
        : undefined;
      if (config) {
        initializeApp(config);
      } else {
        initializeApp();
      }
    }
    firestore = getFirestore();
    firebaseStatus = 'ready';
  } catch (error) {
    firebaseStatus = 'error';
    console.error('Firebase initialization failed:', error.message);
  }
}

tryInitializeFirebase();

app.use((req, res, next) => {
  req.requestId = req.get('x-request-id') || crypto.randomUUID();
  res.setHeader('x-request-id', req.requestId);
  next();
});

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(new Error('Origin not allowed by CORS'));
    },
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Workspace-Id', 'X-Request-Id'],
    maxAge: 86400,
  }),
);
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: false, limit: '1mb' }));

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'maisuchat-backend',
    firebase: firebaseStatus,
    timestamp: new Date().toISOString(),
    requestId: req.requestId,
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    name: 'MaisuChat API',
    version: process.env.npm_package_version || '0.1.0',
    environment: process.env.NODE_ENV || 'development',
    firebase: firebaseStatus,
    requestId: req.requestId,
  });
});

app.get('/api/ready', (req, res) => {
  const isReady = firebaseStatus !== 'error';
  res.status(isReady ? 200 : 503).json({
    status: isReady ? 'ready' : 'degraded',
    dependencies: {
      firestore: firestore ? 'available' : 'not-configured',
    },
    requestId: req.requestId,
  });
});

app.use((req, res) => {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: 'Rota não encontrada.',
    },
    requestId: req.requestId,
  });
});

app.use((error, req, res, next) => {
  if (res.headersSent) {
    next(error);
    return;
  }

  const isCorsError = error.message === 'Origin not allowed by CORS';
  const status = isCorsError ? 403 : Number(error.statusCode || 500);
  if (status >= 500) {
    console.error(`[${req.requestId}]`, error.stack || error.message);
  }

  res.status(status).json({
    error: {
      code: isCorsError ? 'CORS_FORBIDDEN' : 'INTERNAL_ERROR',
      message: isCorsError ? 'Origem não autorizada.' : 'Erro interno do servidor.',
    },
    requestId: req.requestId,
  });
});

function startServer() {
  const server = app.listen(port, () => {
    console.log(`MaisuChat API listening on port ${port}`);
  });

  const shutdown = (signal) => {
    console.log(`${signal} received, shutting down HTTP server.`);
    server.close(() => process.exit(0));
  };

  process.once('SIGINT', () => shutdown('SIGINT'));
  process.once('SIGTERM', () => shutdown('SIGTERM'));
  return server;
}

if (require.main === module) {
  startServer();
}

module.exports = { app, startServer };
