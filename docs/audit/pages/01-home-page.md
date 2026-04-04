# Home Page Audit

**URL:** `/`  
**Title:** Job Agent App  
**Layout:** Public landing page (no sidebar)

## Structure

- **Navbar:** Brand link, Home, Sign In / Sign Up (unauthenticated) or Dashboard / Sign Out (authenticated)
- **Hero:** H1 headline, subtitle paragraph, two CTA buttons
- **Stats Bar:** 3 stats (6+ Job Boards, 24/7 Automated Search, Smart Match Ranking)
- **Feature Cards:** 3 cards with Bootstrap Icons (globe, bar-chart, lightning)
- **Footer:** © 2026 Job Agent App

## Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| "Get Started" (unauthenticated) | Click | Navigates to `/sign_in` | PASS |
| "Go to Dashboard" (authenticated) | Click | Navigates to `/dashboard` | PASS |
| "How It Works" anchor | Click | Scrolls to `#features` section | PASS |
| Sign Out button | Click | Signs out, shows flash, shows Sign In/Sign Up links | PASS |
| Flash dismiss button | Click | Dismisses "Signed out successfully." alert | PASS |
| Brand "Job Agent" link | Click | Returns to `/` | PASS |

## UI/UX Findings

### Positive
- Clean, professional hero with clear value proposition
- CTA is contextual — shows "Get Started" for guests, "Go to Dashboard" for signed-in users
- Stats bar provides quick social proof
- Feature cards have Bootstrap Icons (consistent with sidebar)
- Page title correctly set to "Job Agent App"

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| H-1 | Low | Feature card icons render as empty boxes in accessibility snapshot | The `<i class="bi bi-*">` elements show empty text. Icons likely render visually via CSS font but have no `aria-label` or `sr-only` text |
| H-2 | Low | Footer is minimal | Only shows copyright. The dashboard layout has enhanced footer with Status/GitHub/Shortcuts links — inconsistency between layouts |
| H-3 | Info | No "Forgot Password" link | Sign In page accessible from home, but no password reset link visible on home page |
