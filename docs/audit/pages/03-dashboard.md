# Dashboard Page Audit

**URL:** `/dashboard`  
**Title:** Dashboard — Job Agent  
**Layout:** Dashboard (sidebar + topbar + content)

## Structure

### Sidebar
- Brand: Bootstrap Icon briefcase + "Job Agent"
- Main nav: Dashboard, Job Sources, Job Listings, Applications, Analytics, Activity, Interventions (with badge "1")
- Settings nav: Profile, Settings
- Footer: User avatar "D" + "Demo"

### Topbar
- Hamburger toggle (mobile only)
- Page title "Dashboard"
- Search input "Search jobs..." (Enter → `/job_listings?q=`)
- Dark mode toggle (moon/sun Bootstrap Icon)
- Notification bell (with unread count badge)
- User avatar dropdown (display name, email, Sign Out)

### Content
- **4 Stat Cards:** Jobs Found (18), High Matches (10), Applied (6), Needs Attention (1)
- **Recent Job Listings table:** 5 rows with Position, Company, Location, Match %, Source badge, Posted
- **Upcoming Interviews card:** 2 rows (Basecamp Technical · Video, Zendesk Behavioral · Video)
- **Recent Activity feed:** 10 items with icons, descriptions, timestamps

### Footer
- © 2026 Job Agent App · Status · GitHub · Shortcuts ?

## Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Stat card "Jobs Found" | Display | Shows "18" | PASS |
| Stat card "High Matches" | Display | Shows "10" | PASS |
| Stat card "Applied" | Display | Shows "6" | PASS |
| Stat card "Needs Attention" | Display | Shows "1" | PASS |
| "View All" link | Click | Navigates to `/job_listings` | PASS |
| Job listing link | Click | Navigates to `/job_listings/:id` | PASS |
| Search input | Type + Enter | Navigates to `/job_listings?q=query` | PASS |
| Dark mode toggle | Click | Toggles `data-theme="dark"`, icon changes moon↔sun | PASS |
| Notification bell | Click | Opens dropdown with notifications | PASS |
| User avatar | Click | Opens dropdown with name, email, Sign Out | PASS |
| "Shortcuts ?" footer button | Click | Opens keyboard shortcuts modal | PASS |
| "Status" footer link | Click | Navigates to `/health` | PASS |
| "GitHub" footer link | Click | Opens GitHub repo in new tab | PASS |
| Skip to content link | Focus | Visible on tab, targets `#main-content` | PASS |
| Sidebar nav links | Click each | All navigate correctly | PASS |
| Interventions badge | Display | Shows "1" in warning badge | PASS |

## UI/UX Findings

### Positive
- Rich dashboard with real data — stat cards, table, interviews, activity
- Bootstrap Icons render consistently in sidebar and stat cards
- Notification bell shows unread count badge
- Keyboard shortcuts accessible via `?` key or footer button
- Skip-to-content link for accessibility
- Footer has useful links (Status, GitHub, Shortcuts)

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| D-1 | Medium | Stat cards are not clickable | Users expect to click "18 Jobs Found" to navigate to listings, but stat cards have no link/action |
| D-2 | Medium | Recent Activity icons show empty in accessibility tree | Bootstrap Icon `<i>` elements have no accessible text — screen readers skip them |
| D-3 | Low | Upcoming Interviews not linked | Interview rows don't link to the application detail page |
| D-4 | Low | No "View All" for Recent Activity | Activity feed shows 10 items but no link to full `/activity` page |
| D-5 | Info | Topbar search placeholder says "Search jobs..." | Could be more specific: "Search listings by title, company..." |
