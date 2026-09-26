# Lab Rat – instalacija na mobitel i laptop

Ovo je verzija aplikacije koja ne ovisi o Claudeu. Radi offline, instalira se na mobitel i laptop kao prava aplikacija, a podaci se sinkroniziraju preko tvoje vlastite (besplatne) Supabase baze.

## Što je u paketu

| Datoteka | Čemu služi |
|---|---|
| `index.html` | cijela aplikacija |
| `config.js` | ovdje upisuješ podatke svoje Supabase baze (korak 3) |
| `manifest.webmanifest`, `sw.js`, `icons/` | instalacija, ikona i rad bez interneta |
| `supabase-setup.sql` | naredbe koje jednom pokreneš u Supabaseu (korak 2) |
| `moji-podaci-iz-claudea.json` | tvoji dosadašnji podaci iz Claude verzije (eksperimenti, gelovi, Lowry) za uvoz (korak 7) |

Ukupno ti treba oko 20–30 minuta, samo prvi put.

---

## 1. Napravi Supabase projekt

1. Otvori **supabase.com** → *Start your project* → prijavi se (najlakše preko GitHub računa, koji ti treba i za korak 4).
2. *New project*:
   - Name: `lab-rat`
   - Database password: izmisli jaku lozinku i spremi je (neće ti trebati svakodnevno)
   - Region: **Central EU (Frankfurt)**
3. Pričekaj 1–2 minute da se projekt napravi.

## 2. Napravi tablicu

1. U lijevom izborniku otvori **SQL Editor** → *New query*.
2. Otvori datoteku `supabase-setup.sql`, kopiraj cijeli sadržaj i zalijepi ga.
3. Pritisni **Run**. Treba pisati *Success. No rows returned*.

Ova tablica je zaštićena: svaki korisnik vidi i mijenja samo svoje podatke.

## 3. Upiši podatke baze u `config.js`

1. U Supabaseu otvori **Project Settings** (zupčanik) → **API** (ili *Data API* / *API Keys*).
2. Kopiraj:
   - **Project URL** (izgleda kao `https://abcdefghijkl.supabase.co`)
   - ključ **anon public** (dugi niz znakova). Ako vidiš kartice *Publishable* i *Legacy*, uzmi ključ `anon` iz kartice **Legacy API keys**.
3. Otvori `config.js` u bilo kojem uređivaču teksta (npr. Notepad ili gedit) i zamijeni `YOUR_SUPABASE_URL` i `YOUR_SUPABASE_ANON_KEY` tim vrijednostima. Navodnici ostaju.

Ključ `anon` smije biti javan, jer baza ionako dopušta pristup samo prijavljenom korisniku i samo njegovim podacima. **Nikad** ne upisuj ključ `service_role`.

## 4. Objavi aplikaciju na GitHub Pages (besplatno)

1. Otvori **github.com**, prijavi se ili napravi račun.
2. Gore desno **+** → *New repository*:
   - Repository name: `lab-rat`
   - **Public**
   - *Create repository*
3. Na stranici novog repozitorija klikni **uploading an existing file**.
4. Povuci u prozor **sve datoteke iz paketa, zajedno s mapom `icons`**. Datoteku `moji-podaci-iz-claudea.json` nemoj uploadati, jer bi tada bila javno dostupna.
5. Dolje klikni **Commit changes**.
6. U repozitoriju otvori **Settings** → **Pages**:
   - Source: *Deploy from a branch*
   - Branch: `main`, mapa `/ (root)` → **Save**
7. Nakon 1–2 minute aplikacija je na adresi:
   **`https://TVOJE-KORISNIČKO-IME.github.io/lab-rat/`**

## 5. Poveži adresu sa Supabaseom

U Supabaseu: **Authentication** → **URL Configuration** → *Site URL*: upiši adresu iz koraka 4.7 → *Save*.

Tako linkovi u emailu za potvrdu računa vode na tvoju aplikaciju.

Ako ne želiš potvrđivati email: **Authentication** → **Sign In / Providers** → **Email** → isključi *Confirm email* → *Save*. To je u redu za laboratorijsku upotrebu.

## 6. Instaliraj aplikaciju

- **Android (Chrome):** otvori adresu → izbornik ⋮ → **Instaliraj aplikaciju** (ili *Dodaj na početni zaslon*).
- **Laptop (Chrome ili Edge):** otvori adresu → ikona za instalaciju desno u adresnoj traci → *Instaliraj*.
- **iPhone (Safari):** otvori adresu → gumb za dijeljenje → **Dodaj na početni zaslon**.

## 7. Prijavi se i prebaci dosadašnje podatke

1. Otvori aplikaciju na laptopu i dodirni oznaku stanja **gore desno** („Not signed in · tap to sync“).
2. Upiši email i lozinku (najmanje 6 znakova) → **Create account**. Ako je potvrda emaila uključena, potvrdi je i zatim se prijavi s **Sign in**.
3. U istom prozoru klikni **Import backup** i odaberi `moji-podaci-iz-claudea.json`. Tvoji eksperimenti (WB Pancreas i Lowry), gelovi i mjerenje pojavit će se u aplikaciji i poslati u bazu. Slike iz Claude verzije ne prenose se automatski; dodaj ih ponovno u karticu Images.
4. Na mobitelu otvori aplikaciju i prijavi se **istim emailom i lozinkom** (*Sign in*). Svi podaci se preuzmu.

Od tada: što pripremiš na laptopu, vidiš na mobitelu i obrnuto. Ako su oba uređaja otvorena, promjene stižu gotovo odmah. Ako nemaš internet, aplikacija radi normalno i sinkronizira se čim se veza vrati. Oznaka gore desno uvijek pokazuje stanje (*Synced*, *Syncing…*, *Offline*).

---

## Kolege

Pošalji im adresu iz koraka 4.7. Svatko napravi svoj račun u aplikaciji i vidi samo svoje podatke. Besplatni Supabase plan je dovoljan za cijeli laboratorij.

## Nova verzija aplikacije

Kad dobiješ novi `index.html`, u repozitoriju na GitHubu klikni *Add file* → *Upload files*, povuci novu datoteku i *Commit changes*. Aplikacija se na uređajima osvježi pri sljedećem otvaranju (ponekad treba zatvoriti i ponovno otvoriti dvaput). `config.js` ne diraj, on ostaje isti.

## Sigurnosna kopija

U prozoru *Sync & backup* gumb **Export backup** sprema sve podatke u datoteku. Dobro je to napraviti povremeno.

## Google Play (kasnije)

Kad aplikacija bude gotova, otvori **pwabuilder.com**, upiši adresu aplikacije i odaberi *Android*. Dobit ćeš paket za Google Play Console. Za nove osobne račune Google traži zatvoreno testiranje s najmanje 12 testera tijekom 14 dana prije javne objave.

## Ako nešto ne radi

- **„Invalid API key“ ili nema prijave:** provjeri `config.js` (cijeli ključ, navodnici, bez razmaka) i jesi li uzeo ključ *anon*, a ne *service_role*.
- **„relation docs does not exist“:** nije pokrenut `supabase-setup.sql` (korak 2).
- **„Email not confirmed“:** potvrdi email ili isključi *Confirm email* (korak 5).
- **„Email rate limit exceeded“:** Supabase besplatno šalje samo nekoliko emailova na sat. Pričekaj ili isključi potvrdu emaila.
- **Stranica 404 na GitHubu:** pričekaj par minuta nakon koraka 4.6 i provjeri je li `index.html` u glavnoj mapi repozitorija, a ne u podmapi.

## Slike

Slike se spremaju uz eksperiment i sinkroniziraju s računom. Aplikacija ih pri spremanju smanji na najviše oko 1600 px po duljoj strani (do ~230 KB), da sinkronizacija bude brza. Originale s ChemiDoca i dalje čuvaj na računalu ili disku.
