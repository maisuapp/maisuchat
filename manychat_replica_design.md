# ManyChat Replica – Detailed Component & API Specification

> **Goal**: Outline all major components, services, and public/internal APIs required to build a clone of the ManyChat platform.

---

## 1. High‑Level Architecture

```mermaid
graph TD
    subgraph Frontend
        UI[Web UI (React/Vue)] -->|REST/GraphQL| API_Gateway
        MobileApp[Mobile Apps (iOS/Android)] -->|REST| API_Gateway
    end
    subgraph Backend
        API_Gateway --> Auth_Service
        API_Gateway --> Bot_Service
        API_Gateway --> Flow_Service
        API_Gateway --> Integration_Service
        API_Gateway --> Analytics_Service
        API_Gateway --> Billing_Service
        Bot_Service --> Message_Queue[(Redis / Kafka)]
        Flow_Service --> DB[(PostgreSQL)]
        Auth_Service --> DB
        Integration_Service --> External_Channels[External Messaging APIs]
    end
    subgraph Data
        DB[(PostgreSQL)]
        Cache[(Redis)]
        Object_Store[(S3 / Azure Blob)]
    end
    subgraph External
        FB[Facebook Graph API]
        IG[Instagram Messaging API]
        WA[WhatsApp Business API]
        Twilio[Twilio SMS/Voice]
        Email[SendGrid / Mailgun]
        WebWidget[Web Widget (iframe)]
    end
    Integration_Service --> FB
    Integration_Service --> IG
    Integration_Service --> WA
    Integration_Service --> Twilio
    Integration_Service --> Email
    Integration_Service --> WebWidget
```

---

## 2. Core Components

| Component | Responsibility | Tech Suggestions |
|-----------|----------------|-------------------|
| **Web UI** | Drag‑and‑drop flow editor, channel configuration, analytics dashboard. | React (TypeScript) + Vite, Tailwind CSS, Monaco editor for code snippets. |
| **Mobile Apps** | Optional native apps for bot owners. | React Native / Flutter. |
| **API Gateway** | Single entry point, routing, rate‑limiting, authentication. | Node.js (NestJS) or Go (Gin) + OpenAPI spec. |
| **Auth Service** | User registration, OAuth (Google, Facebook), JWT issuance, RBAC. | Auth0 or custom OIDC provider, JWT + Refresh tokens. |
| **Bot Runtime** | Executes flows, handles inbound/outbound messages, maintains state. | Node.js workers, durable functions, or Go microservice. |
| **Flow Engine** | Stores/executes visual flow graphs (nodes, conditions, actions). | Directed‑acyclic graph stored in PostgreSQL JSONB, evaluated by Bot Runtime. |
| **Integration Service** | Connects to external messaging platforms, manages webhooks, handles retries. | Adapter pattern; each channel has its own microservice (e.g., `fb‑adapter`, `whatsapp‑adapter`). |
| **Analytics Service** | Event tracking, funnel reports, audience segmentation. | ClickHouse or TimescaleDB for time‑series, ELK stack for logs. |
| **Billing Service** | Subscription plans, usage metering, payment processing. | Stripe integration, usage stored in PostgreSQL, background jobs for invoicing. |
| **Message Queue** | Decouples inbound messages from processing, ensures reliability. | Redis Streams or Apache Kafka. |
| **Database** | Multi‑tenant relational storage (users, bots, flows, messages). | PostgreSQL with row‑level security. |
| **Cache** | Fast look‑ups for bot state, auth tokens. | Redis. |
| **Object Store** | Media assets (images, videos, files). | AWS S3 / Azure Blob + CDN. |
| **CI/CD & Infra** | Automated testing, deployments, scaling. | GitHub Actions, Docker, Kubernetes (EKS/GKE). |

---

## 3. Public REST API (External Consumers)

| Resource | Endpoints (example) | Description |
|----------|---------------------|-------------|
| **Authentication** | `POST /api/v1/auth/login` <br> `POST /api/v1/auth/register` <br> `POST /api/v1/auth/refresh` | Email/password or OAuth login, returns JWT. |
| **Bots** | `GET /api/v1/bots` <br> `POST /api/v1/bots` <br> `GET /api/v1/bots/{botId}` <br> `PATCH /api/v1/bots/{botId}` <br> `DELETE /api/v1/bots/{botId}` | CRUD for bot containers (name, branding, default flow). |
| **Flows** | `GET /api/v1/bots/{botId}/flows` <br> `POST /api/v1/bots/{botId}/flows` <br> `GET /api/v1/flows/{flowId}` <br> `PATCH /api/v1/flows/{flowId}` <br> `DELETE /api/v1/flows/{flowId}` | Manage visual flow JSON structures. |
| **Subscribers / Audience** | `GET /api/v1/bots/{botId}/subscribers` <br> `POST /api/v1/bots/{botId}/subscribers` <br> `GET /api/v1/subscribers/{id}` | Contact list, tags, custom fields. |
| **Messages** | `POST /api/v1/bots/{botId}/messages` (send outbound) <br> `GET /api/v1/bots/{botId}/messages?since=...` | Send a one‑off message, fetch message history. |
| **Campaigns** | `GET /api/v1/bots/{botId}/campaigns` <br> `POST /api/v1/bots/{botId}/campaigns` <br> `GET /api/v1/campaigns/{id}` | Broadcasts / drip sequences. |
| **Analytics** | `GET /api/v1/bots/{botId}/stats` <br> `GET /api/v1/bots/{botId}/funnels` | Aggregate metrics (open rates, click‑through, conversion). |
| **Webhooks** | `POST /api/v1/webhooks` (register) <br> `DELETE /api/v1/webhooks/{id}` | Register URLs for events (message received, flow entered). |
| **Billing** | `GET /api/v1/account/plans` <br> `POST /api/v1/account/subscribe` | Retrieve plans, initiate subscription. |

*All endpoints should be documented with OpenAPI 3.0 and secured via Bearer JWT.*

---

## 4. Internal Microservice APIs (gRPC / HTTP)

1. **Bot Runtime ↔ Flow Service** (gRPC)
   - `ExecuteFlow(request: ExecuteFlowRequest) -> ExecuteFlowResponse`
   - `GetNode(nodeId)` – fetch node definition.
2. **Integration Service ↔ Bot Runtime** (HTTP)
   - `POST /incoming/{channel}` – inbound webhook entry point.
   - `POST /outgoing/{channel}` – send message to external channel.
3. **Analytics Service ↔ Bot Runtime** (Kafka topics)
   - `bot.events` – publish events (`message_sent`, `user_entered_flow`).
   - `bot.metrics` – aggregated counters.
4. **Billing Service ↔ Bot Service** (REST)
   - `GET /usage/{botId}` – retrieve usage for invoicing.
   - `POST /charge` – trigger payment.
5. **Auth Service ↔ All Services** (JWT verification middleware).

---

## 5. External Channel Integrations (APIs you must implement)

| Channel | API Used | Typical Flow |
|---------|----------|--------------|
| **Facebook Messenger** | Facebook Graph API (`/me/messages`, webhook `messenger_profile`) | Subscribe to `messenger` webhook, verify token, forward inbound messages to Bot Runtime, send outbound via `POST /messages`. |
| **Instagram Direct** | Instagram Graph API (similar to Messenger) | Same webhook mechanism, requires Instagram Business Account. |
| **WhatsApp Business** | WhatsApp Cloud API (`/messages`, webhook `message_status`) | Webhook for inbound, POST for outbound, handle template messages. |
| **SMS/Voice** | Twilio REST API (`/Messages`, `/Calls`) | Webhook receives `incoming` SMS, Bot Runtime processes, Twilio POST to send. |
| **Email** | SendGrid / Mailgun API (`/mail/send`) | Event webhook for replies (via inbound email processing). |
| **Web Widget** | Custom iframe + WebSocket or REST polling | Embedded JS SDK that opens a WebSocket to the Bot Service for real‑time chat. |
| **Telegram** | Telegram Bot API (`/sendMessage`, webhook) | Optional channel; similar pattern. |
| **Custom API** | Generic HTTP POST/GET | Allows developers to plug any webhook‑compatible service. |

---

## 6. Data Model (Key Tables)

| Table | Columns (simplified) |
|-------|----------------------|
| `users` | `id`, `email`, `password_hash`, `role`, `created_at` |
| `bots` | `id`, `owner_id`, `name`, `default_flow_id`, `status`, `created_at` |
| `flows` | `id`, `bot_id`, `name`, `json_graph`, `version`, `created_at` |
| `nodes` | `id`, `flow_id`, `type`, `payload`, `next_node_ids` |
| `subscribers` | `id`, `bot_id`, `channel`, `external_id`, `first_name`, `last_name`, `custom_fields JSONB` |
| `messages` | `id`, `bot_id`, `subscriber_id`, `direction`, `content`, `metadata JSONB`, `timestamp` |
| `campaigns` | `id`, `bot_id`, `name`, `schedule_cron`, `status` |
| `webhooks` | `id`, `bot_id`, `event_type`, `url`, `secret` |
| `usage` | `bot_id`, `month`, `messages_sent`, `messages_received` |
| `billing` | `id`, `bot_id`, `plan_id`, `period_start`, `period_end`, `status` |

---

## 7. Security & Compliance

- **OAuth2 / OpenID Connect** for third‑party logins.
- **TLS everywhere** (HTTPS, WSS).
- **Rate limiting** per API key/IP.
- **Data isolation** using PostgreSQL row‑level security; each tenant can only see its own rows.
- **GDPR**: data export & deletion endpoints (`GET /api/v1/users/{id}/export`, `DELETE /api/v1/users/{id}`).
- **PCI‑DSS** compliance when handling credit‑card data (use Stripe tokenization, never store raw card data).

---

## 8. Scaling Considerations

| Concern | Strategy |
|---------|----------|
| **Stateless Services** | Deploy Bot Runtime, API Gateway, Integration Service as containers behind a load balancer; scale horizontally. |
| **Stateful Data** | PostgreSQL cluster (Patroni), Redis cluster, S3 for media. |
| **Message Throughput** | Use Kafka partitions per bot; consumer groups for Bot Workers. |
| **Burst Traffic** | Autoscaling policies on CPU/Queue length; burst queue in Redis. |
| **Observability** | Prometheus metrics, Grafana dashboards, OpenTelemetry tracing across microservices. |

---

## 9. Example Request Flow (Facebook Messenger)

1. **User sends message** → Facebook POST to `https://your.domain/webhooks/facebook`.
2. **Integration Service** validates signature, extracts `sender.id` and `message.text`.
3. Looks up **Subscriber** record (`channel='facebook', external_id=sender.id`). If missing, creates a new subscriber.
4. Calls **Bot Runtime** `ExecuteFlow(botId, subscriberId, inboundMessage)`.
5. Bot Runtime evaluates the current node in the flow graph, decides next action (e.g., send text, ask quick reply).
6. Bot Runtime publishes an **outbound event** to the `outgoing` Kafka topic.
7. Integration Service consumes the event, translates to Facebook API payload, POST `/me/messages` with page access token.
8. **Analytics Service** records `message_sent` and `message_received` events for dashboards.

---

## 10. Roadmap Enhancements (Optional)

- **AI‑assisted replies** – integrate Gemini API for fallback natural‑language generation.
- **Live chat escalation** – handoff to human agents via a ticketing system.
- **Multilingual support** – store locale per subscriber, automatic translation via Google Cloud Translation.
- **Plugin marketplace** – allow third‑party actions (e.g., Google Sheets, CRM) via sandboxed Lambda functions.

---

## 11. Reference Documentation

- **Facebook Graph API** – https://developers.facebook.com/docs/messenger-platform
- **WhatsApp Cloud API** – https://developers.facebook.com/docs/whatsapp/cloud-api
- **Twilio SMS API** – https://www.twilio.com/docs/sms
- **Stripe Billing** – https://stripe.com/docs/billing
- **OpenAPI 3.0 Specification** – https://swagger.io/specification/
- **Kafka Architecture** – https://kafka.apache.org/documentation/

---

*This document is intended as a high‑level design guide. Specific implementation details (e.g., exact JSON schema for flow nodes) should be iteratively refined during development.*
