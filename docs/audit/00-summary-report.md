# Job Agent App — Full QA/UX Audit Report

**Date:** 2026-04-04  
**Auditor:** Playwright MCP automated walkthrough  
**Test Users:** `demo@jobagent.dev` (regular), `admin@jobagent.dev` (admin)  
**Environment:** Development (`localhost:3000`)

---

## Executive Summary

The application is well-structured with a consistent sidebar + topbar layout, good empty states, working auth flows, and a comprehensive admin section. The main issues are: incorrect browser tab titles across all dashboard pages, missing form validation feedback on auth pages, and several UX polish opportunities.

**Pages Audited:** 25+  
**Issues Found:** 21  
**Critical:** 2 | **High:** 5 | **Medium:** 8 | **Low:** 6

---

## Issues by Severity

### Critical (P0)

| # | Page | Issue | Details |
|---|------|-------|---------|
| 1 | All dashboard pages | **Browser tab title stuck on "Dashboard — Job Agent"** | Only auth/error pages set `content_for(:title)`. Every other page (Job Listings, Profile, Analytics, Settings, Admin, etc.) shows "Dashboard — Job Agent" in the browser tab. |
| 2 | Sign In / Sign Up | **Empty form submission shows no error** | Submitting Sign In or Sign Up with empty fields silently reloads — no validation feedback at all. HTML5 `required` attributes appear to be missing. |

### High (P1)

| # | Page | Issue | Details |
|---|------|-------|---------|
| 3 | Sign Up | **Devise error banner uses generic styling** | Password mismatch shows `h2` + bullet list ("1 error prohibited this user from being saved:") — should use inline field-level errors or styled alert matching the app's design system. |
| 4 | Home (authenticated) | **"Get Started" CTA still visible when signed in** | The home page shows the same hero CTA ("Get Started" → `/dashboard`) even for authenticated users. Should either redirect or show a different CTA. |
| 5 | Job Listings (admin) | **Admin sees 0 listings despite 21 system-wide** | Admin dashboard shows 21 listings, but `/job_listings` scopes to current user only. Admin should have a way to see all listings or the admin dashboard stat should clarify scope. |
| 6 | Sign Out | **GET `/sign_out` shows Rails exception** | Navigating directly to `/sign_out` throws `ActionController::Exception` because Devise expects DELETE method. Should redirect gracefully. |
| 7 | Mobile | **Sidebar visible by default on mobile** | At 375px width, the sidebar is still rendered in the DOM (all items visible in accessibility tree). It should be collapsed/hidden by default on mobile with the hamburger toggle. |

### Medium (P2)

| # | Page | Issue | Details |
|---|------|-------|---------|
| 8 | Profile Edit | **"Structure with AI" button has no loading state** | Clicking "Structure with AI" on the profile page has no visual feedback indicating processing. |
| 9 | Analytics | **All charts show "No data" with no guidance** | When there's no data, each chart just says "No data" — should suggest actions (e.g., "Run a scan to generate analytics"). |
| 10 | Job Listings | **Filter panel always visible** | The filter panel with Remote/Type/Source/Match/Easy Apply is always expanded. On pages with many filters, a collapsible panel or "Show Filters" toggle would improve UX. |
| 11 | Pipeline Board | **Empty board columns show "Drop here"** | All 7 kanban columns show "Drop here" text — with 0 applications, this is confusing. Should show a more informative empty state. |
| 12 | Dashboard | **Header search bar ("Search jobs...") is non-functional** | The topbar search input doesn't appear to be connected to any search action — typing and pressing Enter does nothing. |
| 13 | Notifications | **No "Mark all read" button on empty state** | The notifications page shows "0 total" but doesn't have the "Mark All Read" button visible (which exists in routes). |
| 14 | Activity Logs | **Only shows "All (0)" tab** | Activity logs should show category filter tabs (like audit logs do) even when empty, so users know what types of activity are tracked. |
| 15 | Admin LLM Logs | **No filters or search** | The LLM Interactions page shows raw table data with no ability to filter by user, feature, status, or date range. |

### Low (P3)

| # | Page | Issue | Details |
|---|------|-------|---------|
| 16 | Home | **Footer is minimal** | Just "© 2026 Job Agent App" — could include links to docs, support, or about. |
| 17 | Profile Show | **Extracted Resume Text is raw/unformatted** | The extracted text block is a wall of unformatted text. Should be in a scrollable container with better formatting or hidden behind a collapsible section. |
| 18 | Job Sources (new) | **Credentials section always visible** | The "Credentials (optional)" section is always shown even for platforms that don't require login. Could be conditionally shown. |
| 19 | Settings | **Auto-Apply toggle switch has no confirmation** | Enabling auto-apply is a significant action that should probably have a confirmation dialog. |
| 20 | Admin Users | **No pagination** | With only 3 users, not an issue yet, but no pagination component is present for when the user count grows. |
| 21 | All pages | **Emoji icons instead of proper icon library** | Navigation uses emoji (📊, 🔍, 📋, etc.) instead of a proper icon library. This can render inconsistently across platforms. |

---

## Page-by-Page Findings

### Phase A — Authentication & Entry Points

#### Home Page (`/`)
- **Status:** Working
- **Layout:** Clean hero section with stats (6+ Job Boards, 24/7, Smart) and 3 feature cards
- **Issues:** #4 (CTA for authenticated users), #16 (minimal footer)
- **Good:** Responsive, clear value proposition, anchor link (`#features`) works

#### Sign In (`/sign_in`)
- **Status:** Functional with issues
- **Layout:** Centered card with email/password/remember me
- **Issues:** #2 (empty form no errors), wrong-credentials error works well (styled alert)
- **Good:** Clean design, "Don't have an account? Sign up" link, title set correctly

#### Sign Up (`/sign_up`)
- **Status:** Functional with issues
- **Layout:** Centered card with email/password/confirm
- **Issues:** #2 (empty form no errors), #3 (Devise error banner styling)
- **Good:** Password mismatch validation works server-side, "Sign in" link present

### Phase B — Core User Pages

#### Dashboard (`/dashboard`)
- **Status:** Working
- **Layout:** 4 stat cards (Jobs Found, High Matches, Applied, Needs Attention) + Recent Listings + Recent Activity
- **Issues:** #1 (page title), #12 (search bar non-functional)
- **Good:** Clean empty states with CTAs, stat cards well-designed

#### Job Listings (`/job_listings`)
- **Status:** Working
- **Layout:** Search bar + filter panel + status tabs + listing table/cards
- **Issues:** #1 (page title), #10 (filters always visible)
- **Good:** Comprehensive filters (Remote, Type, Source, Match range, Easy Apply), clean empty state

#### Job Applications (`/job_applications`)
- **Status:** Working
- **Layout:** Status tabs + application list
- **Issues:** #1 (page title)
- **Good:** Clean empty state with CTA to browse listings

#### Pipeline Board (`/job_applications/board`)
- **Status:** Working
- **Layout:** 7 kanban columns (Applied → Withdrawn) with drag-drop zones
- **Issues:** #1 (page title), #11 (empty board columns confusing)
- **Good:** "Table View" toggle link, column headers with counts

#### Job Sources (`/job_sources`)
- **Status:** Working
- **Layout:** Source list with Add Source button
- **Issues:** #1 (page title)
- **Good:** Clean empty state, "Add Your First Source" CTA

#### Add Job Source (`/job_sources/new`)
- **Status:** Working
- **Layout:** Platform dropdown, name, URL, scan frequency, optional credentials
- **Issues:** #1 (page title), #18 (credentials always visible)
- **Good:** Auto-fill hint for known platforms, Cancel button

#### Job Search Criteria (`/job_search_criteria`)
- **Status:** Working
- **Layout:** Criteria list with Add button
- **Issues:** #1 (page title)
- **Good:** Clean empty state with descriptive CTA

### Phase C — Profile & Resume

#### Profile Show (`/profile`)
- **Status:** Working
- **Layout:** Header (name, headline, status badge) + Contact + Summary + Work Experience + Education + Skills + Certifications + Extracted Text
- **Issues:** #1 (page title), #17 (raw extracted text)
- **Good:** Rich content display, "Structure with AI" button, "Edit Profile" link, LinkedIn link works

#### Profile Edit (`/profile/edit`)
- **Status:** Working
- **Layout:** 6 tabs (Resume, Contact, Experience, Education, Skills, Other)
- **Issues:** #1 (page title), #8 (no loading state for AI)
- **Good:** Tab navigation works, resume upload with file indicator, all contact fields populated, Cancel links

### Phase D — Activity, Notifications, Interventions

#### Activity Logs (`/activity`)
- **Status:** Working
- **Issues:** #1 (page title), #14 (no category tabs)
- **Good:** Clean empty state

#### Notifications (`/notifications`)
- **Status:** Working
- **Issues:** #1 (page title), #13 (no mark-all-read on empty)
- **Good:** Bell dropdown in topbar works, "View all notifications" link

#### Interventions (`/interventions`)
- **Status:** Working
- **Issues:** #1 (page title)
- **Good:** Positive empty state ("Everything is running smoothly")

### Phase E — Analytics & Settings

#### Analytics (`/analytics`)
- **Status:** Working
- **Layout:** 10 chart sections (Listings Over Time, Match Distribution, Applications by Status, Listings by Source, Scan Activity, Top Companies, Salary Distribution, Avg Salary by Source, Application Pipeline, Scan Success Rate)
- **Issues:** #1 (page title), #9 (no guidance on empty charts)
- **Good:** Comprehensive chart coverage, Scan Success Rate shows percentage

#### Settings (`/settings/edit`)
- **Status:** Working
- **Layout:** Automations section (auto-apply toggle + match score) + Email Notifications section (4 toggles)
- **Issues:** #1 (page title), #19 (no auto-apply confirmation)
- **Good:** Well-organized, clear descriptions for each toggle, separate save buttons per section

### Phase F — Admin Pages

#### Admin Dashboard (`/admin`)
- **Status:** Working
- **Layout:** 6 stat cards (Users, Listings, Applications, Scans, Pending, LLM Calls) + Recent Users table + Recent Scans table + LLM Usage summary
- **Issues:** #5 (admin listing scope mismatch)
- **Good:** Rich real data, "View All" links, LLM usage stats

#### Admin Users (`/admin/users`)
- **Status:** Working
- **Layout:** Search + sortable table (Email, Role, Sign-ins, Last Sign-in, Sources, Listings, Joined)
- **Issues:** #20 (no pagination for growth)
- **Good:** Column sorting works, email links to user detail

#### Admin API Keys (`/admin/api_keys`)
- **Status:** Working
- **Layout:** Provider status card + API key form + security note
- **Issues:** None significant
- **Good:** Connected status indicator, masked key display, "Test Connection" button

#### Admin LLM Models (`/admin/llm_models`)
- **Status:** Working
- **Layout:** Filter tabs (All/Active/Tested/Inactive) + search + per-page + sortable table + pagination + "How It Works" guide
- **Issues:** None significant
- **Good:** Excellent feature set — inline role assignment, priority spinners, per-model test, sync/verify-all buttons, pagination

#### Admin LLM Logs (`/admin/llm_interactions`)
- **Status:** Working
- **Layout:** Table with ID, User, Feature, Model, Status, Tokens, Latency, When
- **Issues:** #15 (no filters/search)
- **Good:** Clickable IDs for detail view, latency display

#### Admin Scan Monitor (`/admin/scan_runs`)
- **Status:** Working
- **Layout:** Sortable table (ID, Source, Platform, Status, Duration, Found, New, Started)
- **Issues:** None significant
- **Good:** Sortable columns, status badges, duration display

#### Admin Audit Log (`/admin/audit_logs`)
- **Status:** Working
- **Layout:** Category filter tabs + sortable table (When, User, Action, Description, Category, IP)
- **Issues:** None significant
- **Good:** Category filtering, sortable columns

### Phase G — Cross-Cutting

#### Dark Mode
- **Status:** Working
- Toggle switches between 🌙/☀️, persists via localStorage
- **Issues:** None observed in snapshot-based testing

#### Mobile Responsiveness (375px)
- **Status:** Partially working
- Hamburger toggle (☰) appears, header search hidden
- **Issues:** #7 (sidebar not collapsed by default)

#### Error Pages
- **Status:** Dev mode shows Rails exception page for 404
- Custom error pages exist but only render in production mode
- **Issues:** None (expected dev behavior)

---

## Fix Phases

### Phase 1 — Critical Bugs (2 issues)
1. **Add `content_for(:title)` to all dashboard views** — Set proper page-specific titles
2. **Add `required` attribute to auth form fields** — Prevent empty submissions

### Phase 2 — High Priority UX (5 issues)
3. **Restyle Devise error messages** — Use app's alert/toast system instead of default Devise error format
4. **Conditional home page CTA** — Show "Go to Dashboard" or different content for authenticated users
5. **Admin listing scope clarity** — Either let admin view all listings or clarify dashboard stats scope
6. **Handle GET `/sign_out` gracefully** — Redirect to sign-in instead of throwing exception
7. **Collapse sidebar on mobile by default** — Only show when hamburger is clicked

### Phase 3 — Medium UX Polish (8 issues)
8. Add loading spinner for "Structure with AI" button
9. Add guidance text to empty analytics charts
10. Make filter panel collapsible on Job Listings
11. Improve empty Pipeline Board column messaging
12. Wire up or remove the topbar search bar
13. Show "Mark All Read" button on notifications page (conditionally)
14. Add category filter tabs to Activity Logs (even when empty)
15. Add filters/search to Admin LLM Logs

### Phase 4 — Low Priority Polish (6 issues)
16. Enhance home page footer with useful links
17. Format/collapse extracted resume text on Profile Show
18. Conditionally show credentials section on Add Source form
19. Add confirmation dialog for auto-apply toggle
20. Add pagination to Admin Users
21. Consider replacing emoji icons with proper icon library (Lucide/Bootstrap Icons)
