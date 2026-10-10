-- ระบบจัดการหอพัก: ตารางข้อมูลและสิทธิ์การเข้าถึง
-- วิธีใช้: Supabase > SQL Editor > New query > วางทั้งไฟล์ > แก้อีเมลบรรทัดล่างสุด > Run

-- รายชื่ออีเมลที่ใช้ระบบได้
create table if not exists public.allowed_users (
  email text primary key,
  note  text,
  created_at timestamptz not null default now()
);

-- ข้อมูลทั้งหมดของหอ (ห้อง ผู้เช่า มิเตอร์ บิล งานซ่อม ตั้งค่า)
create table if not exists public.docs (
  col  text not null,
  id   text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (col, id)
);

-- ตรวจว่าอีเมลของคนที่ล็อกอินอยู่ในรายชื่อหรือไม่
create or replace function public.is_allowed()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.allowed_users
    where lower(email) = lower(auth.jwt() ->> 'email')
  );
$$;

alter table public.allowed_users enable row level security;
alter table public.docs enable row level security;

drop policy if exists "see own allow entry" on public.allowed_users;
create policy "see own allow entry" on public.allowed_users
  for select to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'));

drop policy if exists "allowed read" on public.docs;
drop policy if exists "allowed insert" on public.docs;
drop policy if exists "allowed update" on public.docs;
drop policy if exists "allowed delete" on public.docs;
create policy "allowed read"   on public.docs for select to authenticated using (public.is_allowed());
create policy "allowed insert" on public.docs for insert to authenticated with check (public.is_allowed());
create policy "allowed update" on public.docs for update to authenticated using (public.is_allowed()) with check (public.is_allowed());
create policy "allowed delete" on public.docs for delete to authenticated using (public.is_allowed());

-- อัปเดตหน้าจอทันทีเมื่อมีคนอื่นแก้ข้อมูล
alter table public.docs replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- ใส่อีเมลของคนที่ใช้ระบบได้ (แก้เป็นอีเมลจริง เพิ่มกี่บรรทัดก็ได้)
insert into public.allowed_users (email, note) values
  ('your.email@gmail.com', 'เจ้าของหอ')
on conflict (email) do nothing;
