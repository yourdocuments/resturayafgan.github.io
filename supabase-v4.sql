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
