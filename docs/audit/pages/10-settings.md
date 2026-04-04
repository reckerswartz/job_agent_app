# Settings Page Audit

**URL:** `/settings/edit`  
**Title:** Settings — Job Agent  
**Layout:** Dashboard

## Structure

- **Page Header:** "Settings" / "Manage your preferences and automations"
- **Automations Card:**
  - Auto-Apply toggle switch (with confirm dialog on enable)
  - Minimum Match Score input (50-100, default 80%)
  - "Save Automations" button
- **Email Notifications Card:**
  - 4 toggle switches: Scan Completed, New Matches, Application Status, Interventions
  - Each with strong label + description text
  - "Save Notifications" button

## Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Auto-apply toggle | Enable | Shows native confirm dialog | PASS |
| Auto-apply toggle | Cancel confirm | Reverts to off | PASS |
| Match threshold | Change to 90 | Updates input value | PASS |
| "Save Automations" | Click | Saves, redirects with success toast | PASS |
| Notification toggles | Toggle each | Each switch toggles independently | PASS |
| "Save Notifications" | Click | Saves, redirects with success toast | PASS |

## UI/UX Findings

### Positive
- Clean two-section layout separating automations from notifications
- Auto-apply has confirmation dialog to prevent accidental enabling
- Match threshold has min/max constraints (50-100)
- Each notification toggle has clear label + description

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| ST-1 | Medium | Two separate save buttons | Automations and Notifications have separate save buttons — user might expect a single "Save All" at the bottom |
| ST-2 | Low | No visual indication of current saved state | After changing a toggle, there's no "unsaved changes" indicator before clicking save |
| ST-3 | Low | Match threshold doesn't validate on blur | Invalid values (e.g., 200) are only caught on form submission, not inline |
| ST-4 | Info | No account/password change section | Settings page only covers automations and notifications — no way to change email/password from here (would need to go through Devise) |
