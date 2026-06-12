-- Hot Takes Wall — Supabase schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query

create table takes (
  id             uuid                     default gen_random_uuid() primary key,
  text           varchar(120)             not null,
  tag            varchar(50)              not null,
  agree_count    integer                  default 0 not null,
  disagree_count integer                  default 0 not null,
  spicy_count    integer                  default 0 not null,
  created_at     timestamp with time zone default timezone('utc', now()) not null
);

-- Row Level Security
alter table takes enable row level security;

create policy "Anyone can read takes"
  on takes for select using (true);

create policy "Anyone can insert takes"
  on takes for insert with check (true);

create policy "Anyone can update reaction counts"
  on takes for update using (true);

-- Atomic reaction increment (avoids race conditions)
create or replace function increment_reaction(take_id uuid, reaction text)
returns void language plpgsql as $$
begin
  if reaction = 'agree' then
    update takes set agree_count = agree_count + 1 where id = take_id;
  elsif reaction = 'disagree' then
    update takes set disagree_count = disagree_count + 1 where id = take_id;
  elsif reaction = 'spicy' then
    update takes set spicy_count = spicy_count + 1 where id = take_id;
  end if;
end;
$$;
