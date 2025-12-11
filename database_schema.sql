-- ============================================================================
-- MarketMove Database Schema
-- Consolidated SQL Script for Supabase
-- ============================================================================
-- This file contains all database schema, RLS policies, functions, and triggers
-- Run this script in Supabase SQL Editor for initial setup or reference
-- ============================================================================

-- ============================================================================
-- PART 1: EXTENSIONS
-- ============================================================================
create extension if not exists "uuid-ossp";

-- ============================================================================
-- PART 2: TABLES
-- ============================================================================

-- Profiles Table (for Roles and Business Logic)
create table if not exists public.profiles (
  id uuid references auth.users(id) primary key,
  role text check (role in ('owner', 'employee', 'superadmin')) not null,
  business_id uuid not null,
  full_name text,
  phone text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Products Table
create table if not exists public.products (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) not null,
  business_id uuid,
  name text not null,
  stock integer default 0,
  price decimal(10,2) default 0.00,
  barcode text,
  category_id uuid,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Categories Table
create table if not exists public.categories (
  id uuid default uuid_generate_v4() primary key,
  business_id uuid not null,
  name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add foreign key after categories is created
alter table public.products 
  add constraint products_category_fk 
  foreign key (category_id) references public.categories(id);

-- Sales Table
create table if not exists public.sales (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) not null,
  business_id uuid,
  product_id uuid references public.products(id),
  amount decimal(10,2) not null,
  quantity integer default 1,
  description text,
  payment_method text,
  comments text,
  date timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Expenses Table
create table if not exists public.expenses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) not null,
  business_id uuid,
  product_id uuid references public.products(id),
  amount decimal(10,2) not null,
  quantity integer default 1,
  description text,
  payment_method text,
  comments text,
  photo_url text,
  date timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ============================================================================
-- PART 3: ENABLE ROW LEVEL SECURITY
-- ============================================================================
alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.sales enable row level security;
alter table public.expenses enable row level security;
alter table public.categories enable row level security;

-- ============================================================================
-- PART 4: HELPER FUNCTIONS (SECURITY DEFINER - bypasses RLS)
-- ============================================================================

-- Get current user's business_id
create or replace function get_my_business_id()
returns uuid as $$
  select business_id from public.profiles where id = auth.uid();
$$ language sql security definer stable;

-- Get current user's role
create or replace function get_my_role()
returns text as $$
  select role from public.profiles where id = auth.uid();
$$ language sql security definer stable;

-- Check if profile belongs to current user's business (for owners/superadmins)
create or replace function is_my_employee(profile_business_id uuid)
returns boolean as $$
declare
  my_role text;
  my_business uuid;
begin
  select role, business_id into my_role, my_business 
  from public.profiles 
  where id = auth.uid();
  
  -- Superadmin can view ALL profiles
  if my_role = 'superadmin' then
    return true;
  end if;
  
  -- Owners can view profiles in their business
  if my_role = 'owner' and profile_business_id = my_business then
    return true;
  end if;
  
  return false;
end;
$$ language plpgsql security definer stable;

-- Get employees for current user (bypasses RLS for employees screen)
create or replace function get_my_employees()
returns setof public.profiles as $$
declare
  my_role text;
  my_business uuid;
begin
  select role, business_id into my_role, my_business 
  from public.profiles 
  where id = auth.uid();
  
  -- If superadmin, return all owners
  if my_role = 'superadmin' then
    return query select * from public.profiles where role = 'owner';
  end if;
  
  -- If owner, return all employees in their business
  if my_role = 'owner' then
    return query 
      select * from public.profiles 
      where business_id = my_business 
      and role = 'employee';
  end if;
  
  return;
end;
$$ language plpgsql security definer stable;

-- ============================================================================
-- PART 5: RLS POLICIES FOR PROFILES
-- ============================================================================

-- Users can view their own profile OR if is_my_employee returns true
create policy "profiles_select" on public.profiles
  for select using (
    auth.uid() = id
    or is_my_employee(business_id)
  );

-- Users can update their own profile
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- Users can insert their own profile (registration)
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

-- Superadmin can delete any profile
create policy "profiles_delete_superadmin" on public.profiles
  for delete using (
    (select role from public.profiles where id = auth.uid()) = 'superadmin'
  );

-- Superadmin can update any profile
create policy "profiles_update_superadmin" on public.profiles
  for update using (
    (select role from public.profiles where id = auth.uid()) = 'superadmin'
  );

-- ============================================================================
-- PART 6: RLS POLICIES FOR PRODUCTS (business_id based)
-- ============================================================================
create policy "products_select" on public.products
  for select using (business_id = get_my_business_id());

create policy "products_insert" on public.products
  for insert with check (business_id = get_my_business_id());

create policy "products_update" on public.products
  for update using (business_id = get_my_business_id());

create policy "products_delete" on public.products
  for delete using (business_id = get_my_business_id());

-- ============================================================================
-- PART 7: RLS POLICIES FOR SALES (business_id based)
-- ============================================================================
create policy "sales_select" on public.sales
  for select using (business_id = get_my_business_id());

create policy "sales_insert" on public.sales
  for insert with check (business_id = get_my_business_id());

create policy "sales_update" on public.sales
  for update using (business_id = get_my_business_id());

create policy "sales_delete" on public.sales
  for delete using (business_id = get_my_business_id());

-- ============================================================================
-- PART 8: RLS POLICIES FOR EXPENSES (business_id based)
-- ============================================================================
create policy "expenses_select" on public.expenses
  for select using (business_id = get_my_business_id());

create policy "expenses_insert" on public.expenses
  for insert with check (business_id = get_my_business_id());

create policy "expenses_update" on public.expenses
  for update using (business_id = get_my_business_id());

create policy "expenses_delete" on public.expenses
  for delete using (business_id = get_my_business_id());

-- ============================================================================
-- PART 9: RLS POLICIES FOR CATEGORIES (business_id based)
-- ============================================================================
create policy "categories_select" on public.categories
  for select using (business_id = get_my_business_id());

create policy "categories_insert" on public.categories
  for insert with check (business_id = get_my_business_id());

create policy "categories_update" on public.categories
  for update using (business_id = get_my_business_id());

create policy "categories_delete" on public.categories
  for delete using (business_id = get_my_business_id());

-- ============================================================================
-- PART 10: STOCK TRIGGERS
-- ============================================================================

-- Function to update stock on Sale (Decrease Stock)
create or replace function public.handle_sale_stock()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    if new.product_id is not null then
      update public.products
      set stock = stock - new.quantity
      where id = new.product_id;
    end if;
    return new;
  elsif (TG_OP = 'DELETE') then
    if old.product_id is not null then
      update public.products
      set stock = stock + old.quantity
      where id = old.product_id;
    end if;
    return old;
  elsif (TG_OP = 'UPDATE') then
    if old.product_id is not null then
      update public.products
      set stock = stock + old.quantity
      where id = old.product_id;
    end if;
    if new.product_id is not null then
      update public.products
      set stock = stock - new.quantity
      where id = new.product_id;
    end if;
    return new;
  end if;
  return null;
end;
$$ language plpgsql security definer;

-- Trigger for Sales
drop trigger if exists on_sale_change on public.sales;
create trigger on_sale_change
  after insert or update or delete on public.sales
  for each row execute procedure public.handle_sale_stock();

-- Function to update stock on Expense (Increase Stock)
create or replace function public.handle_expense_stock()
returns trigger as $$
begin
  if (TG_OP = 'INSERT') then
    if new.product_id is not null then
      update public.products
      set stock = stock + new.quantity
      where id = new.product_id;
    end if;
    return new;
  elsif (TG_OP = 'DELETE') then
    if old.product_id is not null then
      update public.products
      set stock = stock - old.quantity
      where id = old.product_id;
    end if;
    return old;
  elsif (TG_OP = 'UPDATE') then
    if old.product_id is not null then
      update public.products
      set stock = stock - old.quantity
      where id = old.product_id;
    end if;
    if new.product_id is not null then
      update public.products
      set stock = stock + new.quantity
      where id = new.product_id;
    end if;
    return new;
  end if;
  return null;
end;
$$ language plpgsql security definer;

-- Trigger for Expenses
drop trigger if exists on_expense_change on public.expenses;
create trigger on_expense_change
  after insert or update or delete on public.expenses
  for each row execute procedure public.handle_expense_stock();

-- Updated_at trigger
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists handle_products_updated_at on public.products;
create trigger handle_products_updated_at
  before update on public.products
  for each row execute procedure public.handle_updated_at();

-- ============================================================================
-- PART 11: STORAGE BUCKET FOR EXPENSES PHOTOS
-- ============================================================================
-- insert into storage.buckets (id, name, public)
-- values ('expenses', 'expenses', true);

-- Policy to allow authenticated users to upload files
-- create policy "Authenticated users can upload expenses"
-- on storage.objects for insert
-- to authenticated
-- with check ( bucket_id = 'expenses' );

-- Policy to allow authenticated users to view files
-- create policy "Authenticated users can view expenses"
-- on storage.objects for select
-- to authenticated
-- using ( bucket_id = 'expenses' );

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
