-- ============================================
-- FIX: Remove duplicate stock triggers
-- ============================================
-- Run this in Supabase SQL Editor to fix the double stock decrease issue

-- Drop ALL possible trigger names that might exist
DROP TRIGGER IF EXISTS on_sale_change ON public.sales;
DROP TRIGGER IF EXISTS on_sale_created ON public.sales;
DROP TRIGGER IF EXISTS handle_sale_stock ON public.sales;

-- Recreate ONLY ONE trigger for sales
CREATE TRIGGER on_sale_change
  AFTER INSERT OR UPDATE OR DELETE ON public.sales
  FOR EACH ROW EXECUTE PROCEDURE public.handle_sale_stock();

-- Verify: List all triggers on sales table
SELECT tgname, tgrelid::regclass, tgenabled 
FROM pg_trigger 
WHERE tgrelid = 'public.sales'::regclass 
AND tgisinternal = false;
