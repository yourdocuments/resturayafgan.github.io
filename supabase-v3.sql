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
