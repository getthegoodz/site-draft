# Goodz Site Draft

Static HTML, no build. Two themes coexist: standard (`*.html`, `style.css`) and warm (`*-warm.html`, `style-warm.css`).
Live preview: https://getthegoodz.github.io/site-draft/

## Contact form / email (Resend + Turnstile)

`contact.html` posts to `api/contact.js` (and the footer/newsletter path, if added, to `api/newsletter.js`). The flow: the page fetches the Turnstile sitekey from `api/public-config.js`, renders the Cloudflare Turnstile widget, then POSTs `{firstName,lastName,email,message,company(honeypot),turnstileToken}`. The function verifies the token server-side and sends the email via Resend.

The static frontend calls these cross-origin at `API_BASE` (`https://goodz-site-draft.vercel.app`), so the functions set CORS `*` (mirrors `api/custom-goodz-order.js`).

**Required Vercel env vars** on the `goodz-site-draft` project (none of these live in git):
- `TURNSTILE_SITE_KEY` (public; currently `0x4AAAAAACszrg0jgW25CH8Y`)
- `TURNSTILE_SECRET_KEY`
- `RESEND_API_KEY`
- `CONTACT_TO_EMAIL` (where messages are delivered)
- `CONTACT_FROM_EMAIL` (must be on a Resend-verified sending domain)

Also: the Turnstile sitekey is hostname-restricted in Cloudflare — the deploy domain (`goodz-site-draft.vercel.app`, `getthegoodz.github.io`) must be in its allowed hostnames.

**⚠️ If the form returns "Email service is not configured" — this is the #1 recurring failure.** It is NOT a code bug. It means `RESEND_API_KEY` / `CONTACT_TO_EMAIL` / `CONTACT_FROM_EMAIL` are missing from the Vercel project at runtime. **Fix: re-add them in Vercel → Settings → Environment Variables, then redeploy.** The function also logs exactly which var is missing to the Vercel function logs.

History (2026-06-02): the *live* getthegoodz.com form (separate repo `getthegoodz/website`, deployed by the `website-migration` Vercel project) silently broke around April 2026 with this exact error. Full git archaeology proved the email code never changed since it was written March 18 — the three Resend env vars had simply dropped out of Vercel (most likely when deploys switched from the Vercel CLI to GitHub→Vercel auto-deploy on Apr 6). Re-adding the three vars fixed it. **Whenever email "breaks," check Vercel env vars first, not the code.**
