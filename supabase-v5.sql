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
