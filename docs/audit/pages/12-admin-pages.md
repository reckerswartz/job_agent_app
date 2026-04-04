# Admin Pages Audit

**Access:** Admin users only (sidebar shows Admin section with Dashboard, Users, Configuration, Monitoring groups)

---

## Admin Dashboard (`/admin`)

**Title:** Admin Dashboard — Job Agent

### Structure
- **6 Stat Cards:** Users (3), Listings (39), Applications (7), Scans (6), Pending (1), LLM Calls (2)
- **Recent Users table:** Email, Role badge, Sign-ins, Joined
- **Recent Scans table:** Source, Status badge, Found, New, When
- **LLM Usage summary:** Total Calls, Completed, Failed counts

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Stat cards | Display | All 6 show correct system-wide counts | PASS |
| "View All" users link | Click | Navigates to `/admin/users` | PASS |
| "View All" scans link | Click | Navigates to `/admin/scan_runs` | PASS |
| "View Logs" LLM link | Click | Navigates to `/admin/llm_interactions` | PASS |
| User email links | Click | Navigate to `/admin/users/:id` detail | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AD-1 | Medium | Admin stat cards show system-wide counts but user pages are scoped per-user | Admin sees "39 Listings" in dashboard but `/job_listings` shows 0 for admin's own listings — confusing |
| AD-2 | Low | No refresh/reload button for real-time data | Dashboard data is static on load — no auto-refresh for monitoring |

---

## Admin Users (`/admin/users`)

**Title:** Admin — Users — Job Agent

### Structure
- **Page Header:** "Users" / "3 total users"
- **Search input:** "Search by email..."
- **Sortable Table:** Email (linked), Role badge, Sign-ins, Last Sign-in, Sources, Listings, Joined

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Search by email | Type + filter | Filters users by email | PASS |
| Sort by Email | Click header | Sorts alphabetically | PASS |
| Sort by Sign-ins | Click header | Sorts by count | PASS |
| User email link | Click | Navigates to user detail | PASS |
| Role badges | Display | "admin" (red), "user" (grey) badges | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AU-1 | Low | No pagination | Only 3 users, but no paginator for growth |
| AU-2 | Info | No "Add User" or "Invite" functionality | Admin can view but not create users |

---

## Admin API Keys (`/admin/api_keys`)

**Title:** Admin — API Keys — Job Agent

### Structure
- **Page Header:** "API Keys" + "Test Connection" button
- **Provider Status Card:** NVIDIA Build — Connected status with active model count
- **API Keys Form:** Key input (masked), Save button, security note about encryption

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| "Test Connection" button | Click | Tests API connection with loading state | PASS |
| Provider status | Display | Shows "Connected" with 186 active models | PASS |
| API key input | Display | Masked with last 4 chars visible | PASS |
| "Save API Keys" | Click | Saves encrypted key | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AK-1 | Info | Only 1 provider (NVIDIA) | No ability to add additional providers from the UI |

---

## Admin LLM Models (`/admin/llm_models`)

**Title:** Admin — LLM Models — Job Agent

### Structure
- **Page Header:** "LLM Model Configuration" + "Sync Models from API" + "Verify All" buttons
- **Filter Tabs:** All (186), Active (186), Tested (0), Inactive (0)
- **Search + per-page controls**
- **Table:** Model name + identifier, Type badge, Status badge, Active toggle, Role dropdown, Priority spinbutton, Test button
- **Pagination:** 10 pages at 20 per page
- **"How It Works" guide:** Definition list explaining Sync, Primary Text/Vision, Verification, Priority, Verify

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| "Sync Models from API" | Click | Syncs models from NVIDIA API | PASS |
| "Verify All" | Click | Queues verification jobs for all active models | PASS |
| Filter tabs | Click Active/All | Filters model list | PASS |
| Search models | Type in search | Filters by model name | PASS |
| Per-page dropdown | Change to 50 | Shows 50 models per page | PASS |
| Active toggle | Click | Toggles model active state | PASS |
| Role dropdown | Select "Primary Text" | Updates model role | PASS |
| Priority spinbutton | Change value | Updates model priority | PASS |
| "Test" button | Click | Queues individual model verification | PASS |
| Pagination | Click page 2 | Shows next set of models | PASS |
| Sort by columns | Click headers | Sorts by Model/Type/Active/Priority | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| LM-1 | Low | Changing role/priority requires full page reload | Each change submits the form — could use AJAX/Turbo for inline updates |
| LM-2 | Info | 186 models is a lot | No way to batch-disable unused models |

---

## Admin LLM Interactions (`/admin/llm_interactions`)

**Title:** Admin — LLM Interactions — Job Agent

### Structure
- **Page Header:** "LLM Interactions" / "2 total interactions"
- **Filter Dropdowns:** Feature (All Features / cover_letter), Status (All Statuses / Completed / Failed / Pending) + Clear link
- **Table:** ID (linked), User, Feature badge, Model, Status badge, Tokens, Latency (ms), When

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Feature filter | Select "Cover letter" | Filters to cover_letter interactions | PASS |
| Status filter | Select "Completed" | Filters to completed interactions | PASS |
| "Clear" link | Click | Removes filters | PASS |
| ID link | Click | Navigates to interaction detail | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| LI-1 | Low | No date range filter | Can't filter by time period |
| LI-2 | Info | Only 2 interactions — limited data for meaningful analysis |

---

## Admin Scan Monitor (`/admin/scan_runs`)

**Title:** Admin — Scan Runs — Job Agent

### Structure
- **Page Header:** "Scan Runs" / "6 total scans"
- **Table:** ID (linked), Source, Platform badge, Status badge (sortable), Duration, Found (sortable), New (sortable), Started (sortable)

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Sort by Status | Click | Sorts by status | PASS |
| Sort by Found | Click | Sorts by listings found count | PASS |
| ID link | Click | Navigates to scan run detail | PASS |
| Platform badges | Display | Color-coded (Linkedin=primary) | PASS |
| Duration display | Display | Shows "—" or formatted time | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| SR-1 | Low | No status filter tabs | Unlike other list pages, no filter tabs for Completed/Failed/Running |

---

## Admin Audit Log (`/admin/audit_logs`)

**Title:** Admin — Audit Log — Job Agent

### Structure
- **Page Header:** "Audit Log" / "All user activity across the system"
- **Category Tabs:** All (1), Application (1)
- **Table:** When (sortable), User, Action (sortable), Description, Category badge, IP

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Category tabs | Click "Application" | Filters to application category | PASS |
| Sort by When | Click | Sorts by timestamp | PASS |
| Sort by Action | Click | Sorts by action name | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AL-1 | Info | Only 1 audit log entry | Audit logging may not be capturing all admin actions |
