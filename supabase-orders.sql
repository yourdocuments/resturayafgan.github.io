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
