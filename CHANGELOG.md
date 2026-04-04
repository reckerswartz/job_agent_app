# Changelog

## v1.0.0 (2026-04-04)

### Core Features
- **Auth & Onboarding** — Devise auth, 4-step resume-first wizard, LinkedIn URL import, AI profile suggestions, auto first scan
- **Profile** — Resume upload/parse (PDF/text/image), AI structuring via NVIDIA LLM, contact details, work experience, education, skills, certifications
- **Job Scanning** — LinkedIn (25 listings via HTTP), Indeed (16 via HTTP), Naukri (browser-only), dual-mode fallback with 10s Playwright timeout
- **Scan Pipeline** — Scan → Enrich descriptions (HTTP) → Deduplicate across sources → LLM match analysis (top 3) → Notify
- **Job Matching** — Keyword matcher with per-category breakdown storage, LLM semantic analysis, skill gap detection, match score 0-100
- **Applications** — Manual + auto-apply (configurable threshold for Easy Apply), LinkedIn applier, step tracking, retry
- **Interventions** — Login required, CAPTCHA detection, polymorphic queue with type-specific forms

### AI & LLM
- **NVIDIA Build API** — Dynamic model sync (186 models), primary text/vision/verification roles, fallback on failure, health verification
- **Resume Structuring** — LLM parses resume text into structured sections (work, education, skills, etc.)
- **Cover Letter Generation** — AI-powered per-job cover letters with PDF export (Prawn)
- **Resume Tailoring** — LLM generates tailored summary + highlighted skills per job listing
- **Match Analysis** — Semantic relevance scoring, reasons, skill gaps, salary estimation

### UI/UX
- **Shared Components** — Page header, empty state, stat card, filter tabs partials
- **Data Tables** — Sortable columns, search, per-page selector via Stimulus + Turbo
- **Dark Mode** — Full theme with WCAG focus states, skip-to-content link, ARIA labels
- **Responsive** — Mobile sidebar (swipe-to-close), table scroll hints, 44px touch targets
- **Loading States** — Spinner buttons for all async actions
- **Advanced Filters** — Remote type, employment type, platform, match range, Easy Apply toggle

### Notifications & Communication
- **Real-Time** — Action Cable WebSocket with notification bell (unread badge) in topbar
- **Email** — Branded HTML layout, text alternatives, List-Unsubscribe headers, 4 notification types
- **Webhooks** — HMAC-SHA256 signed delivery for scan.completed events
- **Activity Log** — Polymorphic tracking of all user actions, admin audit log

### API
- **REST API v1** — 11 endpoints with Bearer token auth, paginated JSON responses
- **Endpoints** — Job listings, applications, sources, scan triggers, profile, scan runs

### Admin
- **Dashboard** — System stats with colored icons, recent users/scans, LLM usage
- **User Management** — Search, sort, role toggle
- **API Keys** — Encrypted storage, provider status, test connection
- **LLM Models** — Sync from API, verify health, role assignment, priority, filter tabs
- **Scan Monitor** — Sortable scan history
- **Audit Log** — All user activity across the system

### Automations
- **Auto-Apply** — Scheduled every 4h for high-match Easy Apply jobs
- **Stale Cleanup** — Daily expiry of 30+ day old listings
- **Scheduled Scans** — Every 6h via Solid Queue recurring
- **Daily Digest** — Email with new high-match listings

### DevOps
- **Docker Compose** — Local dev with PostgreSQL 17 + Valkey Redis
- **Kamal** — Production deploy with SSL, PostgreSQL + Redis accessories, separate job worker
- **Health Endpoint** — GET /health with database, LLM, uptime status
- **CI** — Brakeman, bundler-audit, RuboCop, RSpec (319 specs), Playwright E2E (11 files)

### Error Handling
- **Custom Error Pages** — Branded 404/422/500 via ErrorsController
- **Rescue Handlers** — RecordNotFound → friendly redirect with flash
- **Job Retry** — Deadlock (3x), timeout/network (2x) with polynomial backoff
- **LLM ApiError** — Custom exception with user-friendly messages per HTTP status
