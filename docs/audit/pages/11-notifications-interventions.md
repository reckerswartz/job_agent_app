# Notifications & Interventions Pages Audit

## Notifications (`/notifications`)

**Title:** Notifications — Job Agent  
**Layout:** Dashboard

### Structure

- **Page Header:** "Notifications" / "8 total"
- **Table:** Title, Body (truncated), Category badge, Action link, When (relative time)
- Auto-marks unread notifications as read on page visit

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Page load | Navigate | All 8 notifications shown, unread marked as read | PASS |
| Category badges | Display | Shows scan, application, intervention badges | PASS |
| Timestamps | Display | Relative times shown correctly | PASS |
| Bell dropdown (topbar) | Click from dashboard | Shows recent notifications with "View all" link | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| N-1 | Medium | No category filter tabs | Unlike Activity Logs, notifications have no category filter — all shown in one list |
| N-2 | Medium | Notification action_url not clickable in table | The action_url column shows the path text but doesn't render it as a clickable link in the table view |
| N-3 | Low | No "Mark all as read" button on the page | The bell dropdown has it, but the full notifications page doesn't — auto-read on visit may be unexpected |
| N-4 | Low | No delete/dismiss individual notifications | Users can't remove old notifications |

---

## Interventions (`/interventions`)

**Title:** Interventions — Job Agent  
**Layout:** Dashboard

### Structure

- **Page Header:** "Interventions" / "Items requiring your attention"
- **Filter Tabs:** All (3), Pending (1), Resolved (1), Dismissed (1)
- **Intervention Cards:** Each shows type icon + label, status badge, parent description, context message, action buttons (Resolve/Dismiss for pending)

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Filter tabs | Click "Pending" | Shows only pending intervention | PASS |
| Filter tabs | Click "Resolved" | Shows only resolved intervention | PASS |
| Resolve button | Display on pending | Shows "Resolve" button for pending items | PASS |
| Dismiss button | Display on pending | Shows "Dismiss" button with turbo_confirm | PASS |
| Intervention detail | Click card link | Navigates to `/interventions/:id` detail | PASS |
| Sidebar badge | Display | Shows "1" badge for pending count | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| I-1 | Low | Resolved/dismissed interventions have no timestamp in list view | The list shows when they were created but not when they were resolved/dismissed |
| I-2 | Info | Type icons may not render in accessibility tree | Bootstrap Icon `<i>` elements have no alt text for screen readers |
