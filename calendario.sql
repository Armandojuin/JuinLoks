-- JuinLoks · calendario para suscribirse desde el Calendario de Apple (o Google Calendar).
-- Pega todo este texto en Supabase → SQL Editor → New query y pulsa "Run". Solo hace falta una vez.

-- 1. Un enlace secreto por persona
create table if not exists public.calendar_feeds (
  user_id    uuid primary key default auth.uid() references auth.users on delete cascade,
  token      text not null unique,
  created_at timestamptz not null default now()
);
alter table public.calendar_feeds enable row level security;
drop policy if exists "mi enlace de calendario" on public.calendar_feeds;
create policy "mi enlace de calendario" on public.calendar_feeds
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 2. Tipo de respuesta «calendario» (para que el Calendario de Apple lo entienda)
do $$ begin
  create domain "text/calendar" as text;
exception when duplicate_object then null;
end $$;

-- 3. Texto seguro dentro de un evento
create or replace function public.jl_ics_esc(x text) returns text
language sql immutable as $$
  select replace(replace(replace(replace(replace(coalesce(x, ''), '\', '\\'), ';', '\;'), ',', '\,'), chr(13), ''), chr(10), '\n')
$$;

-- 4. El calendario: tareas con fecha y hábitos con hora de quien tenga el enlace
create or replace function public.jl_ics(t text) returns "text/calendar"
language plpgsql stable security definer set search_path = public as $$
declare
  uid   uuid;
  r     record;
  st    timestamp;
  dur   int;
  days  int[];
  d     date;
  rule  text;
  wd    text[] := array['SU','MO','TU','WE','TH','FR','SA'];
  stamp text := to_char(now() at time zone 'utc', 'YYYYMMDD"T"HH24MISS"Z"');
  l     text[] := array['BEGIN:VCALENDAR','VERSION:2.0','PRODID:-//JuinLoks//ES','CALSCALE:GREGORIAN','METHOD:PUBLISH',
                        'X-WR-CALNAME:JuinLoks','REFRESH-INTERVAL;VALUE=DURATION:PT1H','X-PUBLISHED-TTL:PT1H'];
begin
  select user_id into uid from calendar_feeds where token = t;
  if uid is null or t is null or length(t) < 20 then
    raise exception 'Enlace de calendario no válido';
  end if;

  -- Tareas con fecha (desde hace 60 días)
  for r in
    select id, data from entries
    where user_id = uid and col = 'tasks' and not deleted
      and coalesce(data->>'date', '') ~ '^\d{4}-\d{2}-\d{2}$'
      and (data->>'date')::date >= current_date - 60
  loop
    l := l || array['BEGIN:VEVENT', 'UID:jl-task-' || r.id || '@juinloks', 'DTSTAMP:' || stamp,
                    'SUMMARY:' || jl_ics_esc(case when coalesce((r.data->>'done')::boolean, false) then '✓ ' else '' end
                                             || coalesce(r.data->>'title', 'Tarea'))];
    if coalesce(r.data->>'time', '') ~ '^\d{1,2}:\d{2}$' then
      st  := (r.data->>'date')::date + (r.data->>'time')::time;
      dur := coalesce(nullif(r.data->>'dur', '')::int, 60);
      l := l || array['DTSTART:' || to_char(st, 'YYYYMMDD"T"HH24MISS'),
                      'DTEND:'   || to_char(st + make_interval(mins => dur), 'YYYYMMDD"T"HH24MISS')];
    else
      l := l || array['DTSTART;VALUE=DATE:' || to_char((r.data->>'date')::date, 'YYYYMMDD'),
                      'DTEND;VALUE=DATE:'   || to_char((r.data->>'date')::date + 1, 'YYYYMMDD')];
    end if;
    l := l || array['DESCRIPTION:Tarea de JuinLoks', 'END:VEVENT'];
  end loop;

  -- Hábitos con hora (se repiten los días elegidos)
  for r in
    select id, data from entries
    where user_id = uid and col = 'habits' and not deleted
      and coalesce(data->>'time', '') ~ '^\d{1,2}:\d{2}$'
  loop
    select coalesce(array_agg(x::int order by x::int), array[0,1,2,3,4,5,6]) into days
    from jsonb_array_elements_text(
      case when jsonb_typeof(r.data->'days') = 'array' then r.data->'days' else '[]'::jsonb end) x;
    d := coalesce(nullif(left(r.data->>'created', 10), '')::date, current_date);
    for i in 1..7 loop
      exit when extract(dow from d)::int = any(days);
      d := d + 1;
    end loop;
    st   := d + (r.data->>'time')::time;
    dur  := coalesce(nullif(r.data->>'dur', '')::int, 30);
    rule := case when array_length(days, 1) = 7 then 'RRULE:FREQ=DAILY'
                 else 'RRULE:FREQ=WEEKLY;BYDAY=' || (select string_agg(wd[x + 1], ',') from unnest(days) x) end;
    l := l || array['BEGIN:VEVENT', 'UID:jl-habit-' || r.id || '@juinloks', 'DTSTAMP:' || stamp,
                    'SUMMARY:' || jl_ics_esc(coalesce(r.data->>'name', 'Hábito')),
                    'DTSTART:' || to_char(st, 'YYYYMMDD"T"HH24MISS'),
                    'DTEND:'   || to_char(st + make_interval(mins => dur), 'YYYYMMDD"T"HH24MISS'),
                    rule, 'DESCRIPTION:Hábito de JuinLoks', 'END:VEVENT'];
  end loop;

  l := l || array['END:VCALENDAR'];
  return array_to_string(l, chr(13) || chr(10)) || chr(13) || chr(10);
end $$;

revoke all on function public.jl_ics(text) from public;
grant execute on function public.jl_ics(text) to anon, authenticated;
