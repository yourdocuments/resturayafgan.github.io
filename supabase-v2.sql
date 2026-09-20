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
