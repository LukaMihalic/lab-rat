# Lab Rat

A lab companion for the bench: experiments with step-by-step protocols and timers, protein assays, gel loading plans, a recipe library for buffers and solutions, a shared chemical storage list for the whole lab, calculators, alarms and notes.

It runs in the browser and installs on a phone or computer like a normal app. It works offline and syncs between your devices through a free Supabase database.

**Open the app:** https://lukamihalic.github.io/lab-rat/

---

## Using the app

### Install it

- **Android (Chrome):** open the link → menu ⋮ → **Install app** (or *Add to Home screen*).
- **Computer (Chrome or Edge):** open the link → install icon on the right of the address bar → **Install**.
- **iPhone (Safari):** open the link → Share button → **Add to Home Screen**.

### Sign in or use it without an account

On the first start you can **sign in / create an account**, or tap **Use without an account**.

- **With an account**, your data syncs between your phone and computer, and you can share a storage list with your lab and share projects with others.
- **Without an account**, everything stays on that one device. You can sign in later in **Settings**, and what you made comes with you.

After the first start, a short tour shows the main buttons. You can run it again any time from **? → Take the quick tour**. The **?** button also has a searchable help for everything the app does.

### Main parts

| Tab | What it is for |
|---|---|
| **Experiments** | Start an experiment from a method (Western blot, BCA/Lowry, ELISA, IHC, qPCR…). The methods are ready-made default protocols that you can adapt and save as your own default. Group experiments into projects and folders. |
| **Recipes** | Buffers and solutions. Set the volume and every amount is recalculated. Each component shows where it is kept in Storage. |
| **Storage** | Where each chemical is kept (lab, fridge or cabinet, shelf), with type and tags, filters, moving many items at once and an order list. It can be shared with your whole lab. |
| **Calcs** | Gel casting, antibody dilution, C₁V₁ = C₂V₂, molar mass. |
| **Clock** | Timers, stopwatch and alarms. |
| **Notes** | Quick notes. |

Other things worth knowing:

- **Print a bench sheet** from an experiment (Steps → Print).
- **Mark an experiment** as worked or didn't work (Report tab).
- **Share a project read-only** with your mentor: open the project → **🔗 Share** → **Create link**. Whoever has the link can view it without an account. **Stop sharing** turns the link off.
- **Backups:** Settings → **Export backup** / **Import backup**.
- **Sign out** first uploads anything not yet synced, then removes your data from that device.
- **Delete my account** (Settings) removes your account and all your data.

---

## Setting up your own copy

You only need this if you want to run your own copy of Lab Rat with your own database. It takes about 20–30 minutes, once.

### 1. Create a Supabase project

1. Go to **supabase.com** → *Start your project* and sign in (a GitHub account is easiest).
2. *New project*: give it a name, set a strong database password and save it, and choose a region close to you (for Europe, e.g. **Central EU (Frankfurt)**).
3. Wait a minute or two until the project is ready.

### 2. Create the tables

In Supabase open **SQL Editor** → **New query**. For each file below, paste its whole content and press **Run**. Use a new query for each one, in this order. Running a file again later is safe.

| File | What it sets up |
|---|---|
| `supabase-setup.sql` | Your experiments, recipes, notes and images, private to each user. |
| `supabase-storage.sql` | Shared lab storage lists (labs, members, items). |
| `supabase-account.sql` | **Delete my account**. |
| `supabase-share.sql` | Sharing a project read-only with a link. |

Row Level Security is on for every table, so each person only sees and changes their own data, and their lab's storage list.

### 3. Put your project's address and key into `config.js`

1. In Supabase open **Project Settings** → **API** (or *Data API* / *API Keys*).
2. Copy the **Project URL** (looks like `https://abcdefghijkl.supabase.co`) and the **anon public** key. If you see *Publishable* and *Legacy* tabs, take the `anon` key from **Legacy API keys**.
3. Put them into `config.js`, keeping the quotes:

```js
window.BLOT_CONFIG = {
  SUPABASE_URL: "https://your-project.supabase.co",
  SUPABASE_ANON_KEY: "your-anon-key"
};
```

The `anon` key is meant to be public: the database only lets signed-in users reach their own data. **Never** put the `service_role` key here.

### 4. Publish the app on GitHub Pages

1. Create a **public** repository on GitHub, e.g. `lab-rat`.
2. Upload all files from this repository, including the `icons` folder.
3. **Settings** → **Pages** → Source: *Deploy from a branch*, Branch: `main`, folder `/ (root)` → **Save**.
4. After a minute or two the app is at `https://YOUR-USERNAME.github.io/lab-rat/`.

Don't upload personal backup files (`.json` exports) to a public repository.

### 5. Tell Supabase the app's address

**Authentication** → **URL Configuration**:

- **Site URL:** the address from step 4
- **Redirect URLs:** **Add URL** → the same address

This makes the links in confirmation and *Forgot password* emails open your app.

If you don't want people to confirm their email: **Authentication** → **Sign In / Providers** → **Email** → turn off *Confirm email*.

### 6. Email for colleagues (recommended)

Supabase's built-in email sends only a few messages per hour and only to members of your Supabase team, so colleagues may not get confirmation or password-reset emails. Set up your own SMTP in **Authentication** → **Emails** → **SMTP Settings**, using a service with a free plan such as Resend or Brevo.

---

## Updating the app

Upload the new `index.html` and `sw.js` to the repository (*Add file* → *Upload files* → *Commit changes*). Devices pick up the new version the next time the app is opened; sometimes it needs to be closed and opened twice. `config.js` stays the same.

## Troubleshooting

- **"Invalid API key" or you can't sign in:** check `config.js` (the whole key, quotes, no spaces) and that you used the `anon` key, not `service_role`.
- **"relation … does not exist":** one of the SQL files from step 2 hasn't been run.
- **"… isn't set up in the database yet"** when deleting an account or sharing a project: run `supabase-account.sql` or `supabase-share.sql`.
- **"Email not confirmed":** confirm the email, or turn off *Confirm email* (step 5).
- **"Email rate limit exceeded":** the built-in email limit was reached; wait, or set up SMTP (step 6).
- **A *Forgot password* link opens the wrong page:** set the Site URL and Redirect URL (step 5).
- **404 on GitHub Pages:** wait a few minutes after step 4 and check that `index.html` is in the main folder of the repository, not a subfolder.

## Privacy

Data is stored in the Supabase project of whoever runs this copy of the app. Each user can export their data (Export backup) and delete their account with all their data (Delete my account). The app has no analytics or ads. Don't store personal data about patients or study participants in it.

## Images

Images are stored with their experiment and sync with the account. When saved they are scaled down to about 1600 px on the longer side (up to ~230 KB) so syncing stays fast. Keep the originals elsewhere.
