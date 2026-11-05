-- JuinLoks · tabla de datos con acceso privado por usuario.
-- Pega todo este texto en Supabase → SQL Editor → New query y pulsa "Run".

create table if not exists public.entries (
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  col        text not null,
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  deleted    boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, col, id)
);

-- Cada persona solo puede ver y cambiar sus propios datos.
alter table public.entries enable row level security;

create policy "leer mis datos"     on public.entries for select using (auth.uid() = user_id);
create policy "crear mis datos"    on public.entries for insert with check (auth.uid() = user_id);
create policy "cambiar mis datos"  on public.entries for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "borrar mis datos"   on public.entries for delete using (auth.uid() = user_id);

-- La hora de cada cambio la pone el servidor, así todos los dispositivos coinciden.
create or replace function public.entries_touch() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists entries_touch on public.entries;
create trigger entries_touch before insert or update on public.entries
  for each row execute function public.entries_touch();

create index if not exists entries_user_updated on public.entries (user_id, updated_at);

-- Cambios en tiempo real entre dispositivos.
alter publication supabase_realtime add table public.entries;
