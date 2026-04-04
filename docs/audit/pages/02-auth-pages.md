# Auth Pages Audit

## Sign In (`/sign_in`)

**Title:** Sign In — Job Agent  
**Layout:** Centered auth card

### Structure
- Brand icon (Bootstrap Icon briefcase) + "Job Agent" heading
- "Welcome back" / "Sign in to your account" subtext
- Email field (placeholder: you@example.com, required, autofocus)
- Password field (placeholder: Your password, required)
- Remember me checkbox
- Sign In button
- "Don't have an account? Sign up" link
- Footer: © 2026

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Valid credentials | Submit | Redirects to `/dashboard` | PASS |
| Invalid credentials | Submit | Shows "Invalid Email or password." alert | PASS |
| Empty form submit | Click Sign In | HTML5 validation prevents submission (required attrs) | PASS |
| "Sign up" link | Click | Navigates to `/sign_up` | PASS |
| Remember me | Toggle | Checkbox toggles | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| A-1 | Medium | No "Forgot Password?" link | Devise recoverable is enabled but no link to password reset is shown |
| A-2 | Low | No password visibility toggle | Users can't verify what they typed in the password field |

---

## Sign Up (`/sign_up`)

**Title:** Sign Up — Job Agent  
**Layout:** Centered auth card

### Structure
- Brand icon + "Job Agent" heading
- "Create your account" / "Start automating your job search" subtext
- Email field (required)
- Password field (placeholder: Minimum 6 characters, required)
- Confirm Password field (required)
- Create Account button
- "Already have an account? Sign in" link

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Valid sign up | Submit | Creates account, redirects to `/onboarding` | PASS |
| Password mismatch | Submit | Shows Bootstrap alert "Password confirmation doesn't match Password" | PASS |
| Duplicate email | Submit | Shows error for existing email | PASS |
| "Sign in" link | Click | Navigates to `/sign_in` | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| A-3 | Low | No password strength indicator | Users only see "Minimum 6 characters" placeholder but no visual strength meter |
| A-4 | Info | Brand icon renders empty in accessibility tree | `<i class="bi bi-briefcase-fill">` has no text content for screen readers |
