# Playwright E2E Test Report

> **Generated:** 2026-03-23T16:38:38.704Z

## Test Summary

| Metric | Value |
|--------|-------|
| Total tests | 8 |
| Passed | 8 |
| Failed | 0 |
| Skipped | 0 |
| Duration | 6.7s |

## Captured URLs

_28 total requests across 4 unique endpoints._

| Method | URL | Status | Hits | First Seen |
|--------|-----|--------|------|------------|
| `GET` | `http://localhost:3000/up` | 200 | 4 | Mar 23, 2026, 4:38 PM |
| `GET` | `http://localhost:3000/` | 200 | 8 | Mar 23, 2026, 4:38 PM |
| `GET` | `http://localhost:3000/assets/application-231c63cf.css` | 200 | 8 | Mar 23, 2026, 4:38 PM |
| `GET` | `http://localhost:3000/assets/application-374143a7.js` | 200 | 8 | Mar 23, 2026, 4:38 PM |

## Screenshots

_13 screenshots captured._

### chromium desktop health check spec ts Health check GET up returns 200

![chromium desktop health check spec ts Health check GET up returns 200](../test-results/screenshots/chromium-desktop--health-check-spec-ts-Health-check-GET-up-returns-200.png)

### chromium desktop home spec ts Home page page has correct title

![chromium desktop home spec ts Home page page has correct title](../test-results/screenshots/chromium-desktop--home-spec-ts-Home-page-page-has-correct-title.png)

### chromium desktop home spec ts Home page shows the welcome heading and captures the landing state

![chromium desktop home spec ts Home page shows the welcome heading and captures the landing state](../test-results/screenshots/chromium-desktop--home-spec-ts-Home-page-shows-the-welcome-heading-and-captures-the-landing-state.png)

### chromium desktop navigation spec ts Navigation URL tracking navigating between pages records all URLs

![chromium desktop navigation spec ts Navigation URL tracking navigating between pages records all URLs](../test-results/screenshots/chromium-desktop--navigation-spec-ts-Navigation-URL-tracking-navigating-between-pages-records-all-URLs.png)

### chromium mobile health check spec ts Health check GET up returns 200

![chromium mobile health check spec ts Health check GET up returns 200](../test-results/screenshots/chromium-mobile--health-check-spec-ts-Health-check-GET-up-returns-200.png)

### chromium mobile home spec ts Home page page has correct title

![chromium mobile home spec ts Home page page has correct title](../test-results/screenshots/chromium-mobile--home-spec-ts-Home-page-page-has-correct-title.png)

### chromium mobile home spec ts Home page shows the welcome heading and captures the landing state

![chromium mobile home spec ts Home page shows the welcome heading and captures the landing state](../test-results/screenshots/chromium-mobile--home-spec-ts-Home-page-shows-the-welcome-heading-and-captures-the-landing-state.png)

### chromium mobile navigation spec ts Navigation URL tracking navigating between pages records all URLs

![chromium mobile navigation spec ts Navigation URL tracking navigating between pages records all URLs](../test-results/screenshots/chromium-mobile--navigation-spec-ts-Navigation-URL-tracking-navigating-between-pages-records-all-URLs.png)

### health check up

![health check up](../test-results/screenshots/health-check-up.png)

### home page loaded

![home page loaded](../test-results/screenshots/home-page-loaded.png)

### nav step 1 home

![nav step 1 home](../test-results/screenshots/nav-step-1-home.png)

### nav step 2 health

![nav step 2 health](../test-results/screenshots/nav-step-2-health.png)

### nav step 3 home return

![nav step 3 home return](../test-results/screenshots/nav-step-3-home-return.png)

## Full URL Log

<details>
<summary>Click to expand the full request log</summary>

```json
[
  {
    "timestamp": "2026-03-23T16:38:31.823Z",
    "test": "health-check.spec.ts > Health check > GET /up returns 200",
    "method": "GET",
    "url": "http://localhost:3000/up",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.813Z",
    "test": "home.spec.ts > Home page > shows the welcome heading and captures the landing state",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.840Z",
    "test": "home.spec.ts > Home page > shows the welcome heading and captures the landing state",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.866Z",
    "test": "home.spec.ts > Home page > shows the welcome heading and captures the landing state",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.830Z",
    "test": "health-check.spec.ts > Health check > GET /up returns 200",
    "method": "GET",
    "url": "http://localhost:3000/up",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.812Z",
    "test": "home.spec.ts > Home page > shows the welcome heading and captures the landing state",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.839Z",
    "test": "home.spec.ts > Home page > shows the welcome heading and captures the landing state",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.865Z",
    "test": "home.spec.ts > Home page > shows the welcome heading and captures the landing state",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.611Z",
    "test": "home.spec.ts > Home page > page has correct title",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.616Z",
    "test": "home.spec.ts > Home page > page has correct title",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.624Z",
    "test": "home.spec.ts > Home page > page has correct title",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.731Z",
    "test": "home.spec.ts > Home page > page has correct title",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.739Z",
    "test": "home.spec.ts > Home page > page has correct title",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.752Z",
    "test": "home.spec.ts > Home page > page has correct title",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.814Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.837Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.873Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.444Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/up",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:33.004Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:33.009Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:33.009Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.840Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.863Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:31.873Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:32.488Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/up",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:33.271Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:33.275Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-231c63cf.css",
    "status": 200
  },
  {
    "timestamp": "2026-03-23T16:38:33.275Z",
    "test": "navigation.spec.ts > Navigation & URL tracking > navigating between pages records all URLs",
    "method": "GET",
    "url": "http://localhost:3000/assets/application-374143a7.js",
    "status": 200
  }
]
```

</details>

---

_This report is auto-generated by `scripts/generate-report.js`. Do not edit manually._