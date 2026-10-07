# Deploying to Netlify

**Live site:** https://neesarg-darji.netlify.app
(claimed into `neesargd@gmail.com`, site id `b0e3c395-90c8-4530-aadf-5b87750107e4`, no password)

**Update the live site (same URL every time):**

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
cmd.exe /c "flutter build web --release"
netlify deploy --dir build/web --no-build --prod
```

---

This is a **Flutter web** app. `flutter build web` produces static files in `build/web/`,
which Netlify serves directly. There are two ways to deploy.

---

## Prerequisites / environment gotchas

- **Flutter lives on a Windows path** (`/mnt/c/.../flutter/bin/flutter`). Calling it from WSL
  bash fails with `$'\r': command not found` because the wrapper script has CRLF line endings.
  **Fix:** build via the Windows binary instead:

  ```bash
  cmd.exe /c "flutter build web --release"
  ```

- **Netlify CLI** is installed to a user prefix (no sudo). A plain `npm i -g` fails with
  EACCES, so it was installed like this:

  ```bash
  npm config set prefix "$HOME/.npm-global"
  npm i -g netlify-cli
  ```

  The PATH line is already in `~/.bashrc`. If `netlify` isn't found in a new shell:

  ```bash
  export PATH="$HOME/.npm-global/bin:$PATH"
  ```

---

## Option A — Quick anonymous deploy (no login)

Fast, but the site **expires in 60 minutes unless claimed**, and it's password-protected
with an auto-generated password.

```bash
cmd.exe /c "flutter build web --release"          # build first
export PATH="$HOME/.npm-global/bin:$PATH"
netlify deploy --allow-anonymous --dir build/web --no-build --prod
```

Output gives a **Site URL**, a **Password**, and a **Claim** link.
Open the claim link while logged into Netlify to make the site permanent.

---

## Option B — Permanent, Git-connected auto-deploy (recommended)

Deploys automatically on every push. Requires a one-time browser login.

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
netlify login            # opens browser
netlify init             # or: netlify link  (connect this folder to a site)
```

Then connect the GitHub repo in the Netlify UI. Builds are driven by **`netlify.toml`**
(committed in this repo), which:

- clones Flutter stable in CI and runs `flutter build web --release`
- publishes `build/web`
- adds an SPA redirect (`/* -> /index.html`) so deep links work

> Note: `build/` is gitignored, so the Git flow relies on Netlify building Flutter itself
> (that's exactly what `netlify.toml` handles).

---

## Renaming the site subdomain

This CLI version has no `sites:update --name`; use the raw API:

```bash
netlify api updateSite --data '{"site_id":"<site-id>","body":{"name":"new-name"}}'
```

---

## Removing the password / changing settings

The auto-generated password on an anonymous deploy **cannot be removed until the site is
claimed into a logged-in account**. After `netlify login` + claim/link, remove it in the
Netlify UI: **Site settings → Access & security → Visitor access → Password protection**.

---

## Verify a deploy is live

```bash
curl -sL -o /dev/null -w "%{http_code}\n" https://<your-site>.netlify.app
# 200 = open, 401 = up but password-protected (both mean the deploy exists)
```
