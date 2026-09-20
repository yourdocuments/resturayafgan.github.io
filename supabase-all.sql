-- Supabase SQL Editor এ পুরোটা paste করে একবার Run করুন (নতুন project এর জন্য)
-- এতে সব আছে: সেটিংস, খাবার, গ্যালারি, অর্ডার, ব্লগ, খোলা/বন্ধ, ক্যাটাগরি

-- ======== supabase-setup.sql ========
-- Supabase > SQL Editor এ পুরোটা paste করে Run চাপুন

create table if not exists settings (
  id int primary key default 1,
  name text, tagline text, about_title text, about_text text,
  phone text, address text, hours text,
  facebook text, instagram text, whatsapp text,
  hero_image text, logo text, favicon text,
  constraint single_row check (id = 1)
);

insert into settings (id, name, tagline, about_title, about_text, phone, address, hours, facebook, instagram, whatsapp)
values (1, 'Afghan Restaurant',
  'Delicious food, warm hospitality and a memorable experience — all in one place.',
  'Good Food, Great Moments',
  'Afghan Restaurant is a small and cozy place where we serve delicious and healthy food with the best quality ingredients. Our goal is to make every meal a memorable experience for our guests.',
  '+880 1700-000000', 'Moulvibazar Sadar, Sylhet, Bangladesh', '10:00 AM - 10:00 PM',
  '', '', '8801700000000')
on conflict (id) do nothing;

create table if not exists dishes (
  id bigint generated always as identity primary key,
  name text not null,
  price int default 0,
  image text,
  created_at timestamptz default now()
);

insert into dishes (name, price) values
  ('Afghan Beef Pulao', 250), ('Chicken Korma', 220), ('Afghan Chicken Pulao', 200),
  ('Beef Karahi', 280), ('Chicken Roast', 180);

create table if not exists gallery (
  id bigint generated always as identity primary key,
  image text not null,
  created_at timestamptz default now()
);

-- সবাই পড়তে পারবে, শুধু লগইন করা admin বদলাতে পারবে
alter table settings enable row level security;
alter table dishes   enable row level security;
alter table gallery  enable row level security;

create policy "read settings" on settings for select using (true);
create policy "read dishes"   on dishes   for select using (true);
create policy "read gallery"  on gallery  for select using (true);
create policy "admin settings" on settings for all to authenticated using (true) with check (true);
create policy "admin dishes"   on dishes   for all to authenticated using (true) with check (true);
create policy "admin gallery"  on gallery  for all to authenticated using (true) with check (true);

-- ছবি রাখার জায়গা (bucket)
insert into storage.buckets (id, name, public) values ('images', 'images', true)
on conflict (id) do nothing;

create policy "read images" on storage.objects for select using (bucket_id = 'images');
create policy "admin upload images" on storage.objects for insert to authenticated with check (bucket_id = 'images');
create policy "admin update images" on storage.objects for update to authenticated using (bucket_id = 'images');
create policy "admin delete images" on storage.objects for delete to authenticated using (bucket_id = 'images');

-- ======== supabase-orders.sql ========
-- Supabase > SQL Editor এ paste করে Run চাপুন (অর্ডার সেভ করার টেবিল)

create table if not exists orders (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 80),
  phone text not null check (char_length(phone) between 6 and 20),
  address text not null check (char_length(address) between 1 and 300),
  note text check (char_length(note) <= 300),
  items jsonb not null check (jsonb_array_length(items) between 1 and 30),
  total int not null check (total >= 0),
  status text not null default 'new',
  created_at timestamptz default now()
);

alter table orders enable row level security;

-- যে কেউ অর্ডার দিতে পারবে (কিন্তু অন্যের অর্ডার দেখতে পারবে না)
create policy "anyone can order" on orders for insert to anon, authenticated
  with check (status = 'new');

-- শুধু লগইন করা admin অর্ডার দেখতে/বদলাতে/মুছতে পারবে
create policy "admin manage orders" on orders for all to authenticated
  using (true) with check (true);

-- ======== supabase-blog.sql ========
-- Supabase > SQL Editor এ paste করে Run চাপুন (ব্লগ + খাবারের দিন + "New" ট্যাগ)

-- খাবারে দিন ও New ট্যাগ
alter table dishes add column if not exists days text default '';
alter table dishes add column if not exists is_new boolean default false;

-- ব্লগ পোস্ট
create table if not exists posts (
  id bigint generated always as identity primary key,
  title text not null,
  body text not null,
  image text,
  created_at timestamptz default now()
);

alter table posts enable row level security;
create policy "read posts" on posts for select using (true);
create policy "admin posts" on posts for all to authenticated using (true) with check (true);

-- একটা নমুনা পোস্ট (চাইলে admin থেকে মুছে দিতে পারবেন)
insert into posts (title, body) values (
  'Welcome to our new website',
  E'We are happy to share our new website with you.\n\nNow you can see our menu, follow our news and order online, all in one place.'
);

-- ======== supabase-v2.sql ========
-- Supabase > SQL Editor এ paste করে Run চাপুন
-- (খোলা/বন্ধ, ঘোষণা, Google Map, খাবারের ক্যাটাগরি)

alter table settings add column if not exists is_open boolean default true;
alter table settings add column if not exists announcement text default '';
alter table settings add column if not exists map_query text default '';
alter table dishes   add column if not exists category text default '';

-- রেস্টুরেন্ট বন্ধ থাকলে অর্ডার নেওয়া বন্ধ (server এও আটকায়)
drop policy if exists "anyone can order" on orders;
create policy "anyone can order" on orders for insert to anon, authenticated
  with check (status = 'new' and coalesce((select is_open from settings where id = 1), true));


-- ======== supabase-v3.sql ========
-- Supabase > SQL Editor এ paste করে Run চাপুন  (bKash পেমেন্ট)

alter table settings add column if not exists bkash_number text default '';

alter table orders add column if not exists payment_method text default 'cod' check (payment_method in ('cod', 'bkash'));
alter table orders add column if not exists payment_number text default '' check (char_length(payment_number) <= 20);
alter table orders add column if not exists trx_id text default '' check (char_length(trx_id) <= 20);
alter table orders add column if not exists paid boolean default false;

-- bKash অর্ডারে TrxID থাকতেই হবে
do $$ begin
  alter table orders add constraint bkash_needs_trx check (payment_method <> 'bkash' or char_length(trx_id) >= 8);
exception when duplicate_object then null; end $$;

-- একই TrxID দিয়ে দুইবার অর্ডার করা যাবে না
create unique index if not exists orders_trx_unique on orders (upper(trx_id)) where trx_id <> '';

-- গ্রাহক নিজে "paid = true" দিয়ে অর্ডার করতে পারবে না
drop policy if exists "anyone can order" on orders;
create policy "anyone can order" on orders for insert to anon, authenticated
  with check (status = 'new' and paid = false and coalesce((select is_open from settings where id = 1), true));
