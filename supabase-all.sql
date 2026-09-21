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
  '+880 1778-015313', 'Moulvibazar Sadar, Sylhet, Bangladesh', '10:00 AM - 10:00 PM',
  '', '', '8801778015313')
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

-- ======== supabase-v4.sql ========
-- Supabase > SQL Editor এ paste করে Run চাপুন  (Manager login: শুধু অর্ডার দেখা/প্রিন্ট/সম্পন্ন করা)

-- কে manager সেটা জানার function (login token এ role লেখা থাকে)
create or replace function public.is_manager()
returns boolean language sql stable as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') = 'manager';
$$;

-- Admin (manager নয় এমন লগইন) সব বদলাতে পারবে
drop policy if exists "admin settings" on settings;
create policy "admin settings" on settings for all to authenticated
  using (not public.is_manager()) with check (not public.is_manager());

drop policy if exists "admin dishes" on dishes;
create policy "admin dishes" on dishes for all to authenticated
  using (not public.is_manager()) with check (not public.is_manager());

drop policy if exists "admin gallery" on gallery;
create policy "admin gallery" on gallery for all to authenticated
  using (not public.is_manager()) with check (not public.is_manager());

drop policy if exists "admin posts" on posts;
create policy "admin posts" on posts for all to authenticated
  using (not public.is_manager()) with check (not public.is_manager());

drop policy if exists "admin manage orders" on orders;
create policy "admin manage orders" on orders for all to authenticated
  using (not public.is_manager()) with check (not public.is_manager());

-- Manager শুধু অর্ডার দেখতে ও আপডেট (সম্পন্ন/পেমেন্ট নিশ্চিত) করতে পারবে, মুছতে পারবে না
drop policy if exists "manager read orders" on orders;
create policy "manager read orders" on orders for select to authenticated
  using (public.is_manager());

drop policy if exists "manager update orders" on orders;
create policy "manager update orders" on orders for update to authenticated
  using (public.is_manager()) with check (public.is_manager());

-- Manager ছবি আপলোড/মোছা করতে পারবে না
drop policy if exists "admin upload images" on storage.objects;
create policy "admin upload images" on storage.objects for insert to authenticated
  with check (bucket_id = 'images' and not public.is_manager());

drop policy if exists "admin update images" on storage.objects;
create policy "admin update images" on storage.objects for update to authenticated
  using (bucket_id = 'images' and not public.is_manager());

drop policy if exists "admin delete images" on storage.objects;
create policy "admin delete images" on storage.objects for delete to authenticated
  using (bucket_id = 'images' and not public.is_manager());

-- ============================================================
-- Manager user বানানোর নিয়ম:
-- 1) Authentication > Users > Add user (Auto Confirm tick) দিয়ে manager এর email/password দিয়ে user বানান
-- 2) তারপর নিচের লাইনটা (ইমেইল বদলে) আলাদাভাবে Run করুন:
--
-- update auth.users
--   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"manager"}'::jsonb
--   where email = 'manager@example.com';
--
-- 3) Manager কে logout করে আবার login করতে হবে (নতুন role পেতে)
-- ============================================================

-- ======== supabase-v5.sql ========
-- Supabase > SQL Editor এ paste করে Run চাপুন  (Order page: অর্ডার কোড, ডেলিভারি/পিকআপ, ডেলিভারি চার্জ, অর্ডার ট্র্যাকিং)

alter table settings add column if not exists delivery_fee int default 0;

alter table orders add column if not exists order_code text;
alter table orders add column if not exists order_type text default 'delivery';
alter table orders add column if not exists delivery_fee int default 0;

do $$ begin
  alter table orders add constraint orders_type_check check (order_type in ('delivery', 'pickup'));
exception when duplicate_object then null; end $$;

-- প্রতিটি অর্ডার কোড আলাদা হতে হবে
create unique index if not exists orders_code_unique on orders (order_code) where order_code is not null;

-- গ্রাহক নিজের অর্ডারের অবস্থা দেখতে পারবে (অর্ডার কোড + ফোন নম্বর মিললে তবেই)
create or replace function public.track_order(p_code text, p_phone text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'order_code', o.order_code,
    'status', o.status,
    'paid', o.paid,
    'payment_method', o.payment_method,
    'total', o.total,
    'delivery_fee', o.delivery_fee,
    'order_type', o.order_type,
    'items', o.items,
    'created_at', o.created_at,
    'name', o.name
  )
  from orders o
  where upper(o.order_code) = upper(trim(p_code))
    and right(regexp_replace(o.phone, '\D', '', 'g'), 10) = right(regexp_replace(p_phone, '\D', '', 'g'), 10)
  limit 1;
$$;

revoke all on function public.track_order(text, text) from public;
grant execute on function public.track_order(text, text) to anon, authenticated;
