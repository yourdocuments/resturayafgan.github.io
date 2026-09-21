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
