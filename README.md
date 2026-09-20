# Restaurant Website Template (GitHub Pages + Supabase)

Ekta restaurant/hotel-er jonno ready website: menu, order form, blog, gallery, Google Map,
Special Offer bar, khola/bondho button, ar client-er nijer admin panel (kono coding lage na).

Free hosting (GitHub Pages) + free database (Supabase). Notun client-er jonno ~15-20 minute.

---------------------------------------------------------------------
## NOTUN CLIENT-ER JONNO CHECKLIST (ei order-e korun)
---------------------------------------------------------------------

### Step 1: Client-er naam bosan (Ctrl+H, Find and Replace, sob file-e)
Kono editor (VS Code / Notepad++) e pura folder khule ei gulo replace korun:
- `Afghan`                          ->  client-er restaurant-er naam (jemon `Kabul`)
- `Moulvibazar Sadar, Sylhet`       ->  client-er ठिकाना
- `Sylhet` / `Moulvibazar`          ->  client-er shohor/elaka (baki jaygay)
- `https://YOUR-DOMAIN.com`         ->  client-er site-er asol link (index.html, robots.txt, sitemap.xml)
- `+880 1700-000000` / `8801700000000` -> client-er asol phone / WhatsApp (880 diye)
- Menu-r sample khabar (Pulao, Korma...): `supabase-all.sql` ar `demo-db.js`-e bodlan ba pore admin theke muchun.
- `og.jpg` ta client-er khabar-er chobi (1200x630) diye replace korun (same naam).

### Step 2: Supabase project (supabase.com, free)
1. New project -> naam din, database password din, Region: Singapore, Create.
   (Security-r 3 ta option default-i rakhun.)
2. Left-e SQL Editor -> New query -> `supabase-all.sql` er pura lekha paste -> Run.
   "Success. No rows returned" dekhale thik.
3. Authentication -> Users -> Add user -> Create new user:
   - client-er email + password (Auto Confirm User tick)
   - nijer email + password (Auto Confirm User tick)
4. Authentication -> Sign In / Providers -> "Allow new users to sign up" OFF, Save.
5. Project Settings -> API Keys -> "Publishable key" (sb_publishable_...) copy korun.
   Project URL: https://PROJECT-ID.supabase.co
   *** `sb_secret_...` / service_role key KOKHONO kothao dibena. ***

### Step 3: config.js
```
const SUPABASE_URL = "https://PROJECT-ID.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_....";
```
(Key na boshale site "DEMO MODE"-e thake: data shudhu oi browser-e thake.)
Demo login (shudhu DEMO MODE-e): admin@demo.com / demo123

### Step 4: developer.js
Niche "Connect with Developer" button-er link. Ekhon https://snkbp.com dewa ache.
(link-e XXXX thakle button dekhay na.)

### Step 5: GitHub-e upload
1. github.com -> New repository. Naam: `client-naam.github.io` (ba je kono naam).
   Public rakhun.
2. Add file -> Upload files -> pura folder-er sob file/folder drag kore chhere din -> Commit.
3. Settings -> Pages -> Branch: main, Folder: / (root) -> Save.
4. 1-2 minute por site live.

### Step 6: Check
- Site: DEMO MODE note nei, menu dekhay.
- Site-link + `?debug=1` -> upore `Mode: LIVE | settings: ok | dishes: ...`
- Admin: SITE-LINK/admin/ -> login -> upore "Supabase connected".
- Ekta test order dia admin-er "অর্ডার" tab-e dekhun. Tarpor test data muchun.

### Step 7: Client-ke dewar age
- Admin > Site Settings: naam, tagline, phone, WhatsApp, ठिकाना, logo, favicon, hero chobi.
- Menu-te asol khabar-chobi-dam-category. Gallery-te chobi.
- bKash: Site Settings-e "bKash nomber" din (customer ei number-e Send Money korbe). Khali rakhle bKash option dekhay na.
  Customer TrxID dey, admin-er "orders" tab-e bKash app-e mile dekhe "payment nishchit" button chapte hoy.
- Client-ke dekhan: khabar add, offer dewa, khola/bondho, order dekha, blog post.

### Step 8 (optional): client-er nijer domain
- Domain kinun -> DNS-e 4 ta A record:
  185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153
  ar `www` CNAME -> USERNAME.github.io
- GitHub -> Settings -> Pages -> Custom domain e domain likhe Save, "Enforce HTTPS" tick.
- Tarpor Google Search Console-e sitemap.xml submit, Google Business Profile banan.

---------------------------------------------------------------------
## LINK GULO
- Site:   /
- Admin:  /admin/
- Blog:   /blog/

## FILE-ER KAJ
- index.html / blog/ / admin/ : public site, blog, admin panel
- config.js      : Supabase URL + publishable key (client bodle bodle eta alada)
- developer.js   : "Connect with Developer" button
- demo-db.js     : DEMO MODE (Supabase chhara test)
- supabase-all.sql : database setup (ekbar Run korle hoy, bKash payment shoho)
- supabase-v3.sql  : shudhu bKash part (ager project-e pore bKash add korte hole)
- style.css, favicon*, og.jpg, robots.txt, sitemap.xml

## SHOMOSHYA HOLE
- Admin-e change public-e dekhay na  -> config.js e key boshe ni (DEMO MODE) ba Ctrl+Shift+R korun.
- Admin-e "Supabase shomoshya"       -> supabase-all.sql Run hoy ni ba key/URL bhul.
- Site-e `?debug=1` dile Supabase-er status upore likha ashe.

## NIRAPOTTA
- Publishable key public-e thakle shomoshya nei (database-e RLS niyom ache).
- Secret/service_role key kothao dibena.
- Sign up bondho rakhun (Step 2.4).
