-- ============================================================
-- NotificationLog — Supabase Schema
-- Run this in your Supabase SQL editor (Dashboard > SQL Editor)
-- ============================================================

create table if not exists notifications (
    notification_id uuid        primary key default gen_random_uuid(),
    app_id          text        not null,
    title           text        not null,
    icon            text,
    thumbnail       text,
    date_added      timestamptz not null default now(),
    details         jsonb       -- { "description": "...", "image_url": "..." }
);

create index if not exists notifications_app_id_date_idx
    on notifications (app_id, date_added desc);

alter table notifications enable row level security;

-- Anyone with the anon key can read
create policy "Public read"
    on notifications for select
    using (true);

-- Only service role can insert (use service role key in your admin app)
create policy "Service insert"
    on notifications for insert
    with check (auth.role() = 'service_role');

-- ============================================================
-- Example rows (optional)
-- ============================================================

insert into notifications (app_id, title, icon, thumbnail, date_added, details)
values
    (
        'com.example.myapp',
        'Welcome to MyApp 2.0!',
        'https://picsum.photos/seed/icon1/64/64',
        'https://picsum.photos/seed/thumb1/80/80',
        now() - interval '2 hours',
        '{"description": "We shipped a major update. Tap to learn more.", "image_url": "https://picsum.photos/seed/hero1/800/400"}'
    ),
    (
        'com.example.myapp',
        'Scheduled maintenance this weekend',
        null,
        null,
        now() - interval '1 day',
        '{"description": "Maintenance Saturday 2–4 AM PST. The app may be briefly unavailable.", "image_url": null}'
    );
