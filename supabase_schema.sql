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

-- Bug report / Feature suggestion addition

create table if not exists feedback (
    feedback_id  uuid        primary key default gen_random_uuid(),
    app_id       text        not null,
    type         text        not null check (type in ('bug', 'suggestion')),
    title        text        not null,
    description  text,
    sender_name  text,
    app_version  text,
    device_info  text,
    date_added   timestamptz not null default now()
);

create index if not exists feedback_app_id_idx
    on feedback (app_id, date_added desc);

alter table feedback enable row level security;

create policy "Public insert"
    on feedback for insert
    with check (true);

create policy "Service read"
    on feedback for select
    using (auth.role() = 'service_role');
