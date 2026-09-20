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
