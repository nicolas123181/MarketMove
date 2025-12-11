-- =====================================================
-- OPTIMIZED RLS POLICIES (v4 - Fixed Dependencies)
-- Run this script in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- STEP 1: Drop ALL policies first (before dropping functions)
-- =====================================================

-- Profiles policies
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;

-- Categories policies
DROP POLICY IF EXISTS "categories_select" ON public.categories;

-- Sales policies
DROP POLICY IF EXISTS "sales_select" ON public.sales;

-- Expenses policies
DROP POLICY IF EXISTS "expenses_select" ON public.expenses;

-- Products policies
DROP POLICY IF EXISTS "products_select" ON public.products;
DROP POLICY IF EXISTS "products_update" ON public.products;
DROP POLICY IF EXISTS "products_delete" ON public.products;

-- =====================================================
-- STEP 2: Now drop old helper functions
-- =====================================================

DROP FUNCTION IF EXISTS public.get_my_role();
DROP FUNCTION IF EXISTS public.get_my_business_id();

-- =====================================================
-- STEP 3: Create indexes for better performance
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_profiles_id ON public.profiles(id);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_business_id ON public.profiles(business_id);

-- =====================================================
-- STEP 4: Recreate profiles policies (simple, no functions)
-- =====================================================

CREATE POLICY "profiles_select" ON public.profiles
FOR SELECT USING (
  id = (select auth.uid())
  OR
  (
    (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
    AND role = 'owner'
  )
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

CREATE POLICY "profiles_insert_own" ON public.profiles
FOR INSERT WITH CHECK (
  id = (select auth.uid())
);

CREATE POLICY "profiles_update_own" ON public.profiles
FOR UPDATE USING (
  id = (select auth.uid())
  OR
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
);

-- =====================================================
-- STEP 5: Recreate other table policies
-- =====================================================

CREATE POLICY "categories_select" ON public.categories
FOR SELECT USING (
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

CREATE POLICY "sales_select" ON public.sales
FOR SELECT USING (
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

CREATE POLICY "expenses_select" ON public.expenses
FOR SELECT USING (
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

CREATE POLICY "products_select" ON public.products
FOR SELECT USING (
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

CREATE POLICY "products_update" ON public.products
FOR UPDATE USING (
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

CREATE POLICY "products_delete" ON public.products
FOR DELETE USING (
  (select role from public.profiles where id = (select auth.uid())) = 'superadmin'
  OR
  business_id = (select business_id from public.profiles where id = (select auth.uid()))
);

-- =====================================================
-- Done! Verify
-- =====================================================
SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename;
