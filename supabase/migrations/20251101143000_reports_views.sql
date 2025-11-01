-- Reports aggregation views for reproduction, growth and finances
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- ------------------------------------------------------------------
-- Reproduction metrics (monthly)
-- ------------------------------------------------------------------
DROP VIEW IF EXISTS public.view_reports_reproduction CASCADE;

CREATE VIEW public.view_reports_reproduction AS
WITH base AS (
  SELECT
    br.profile_id,
    date_trunc('month', COALESCE(br.kindling_date, br.mating_date))::date AS period_start,
    br.id,
    br.doe_id,
    br.mating_date,
    br.kindling_date,
    br.palpation_positive,
    COALESCE(br.kits_born_alive, 0) AS kits_born_alive,
    COALESCE(br.kits_born_dead, 0) AS kits_born_dead,
    COALESCE(br.kits_weaned, 0) AS kits_weaned,
    br.average_weaning_weight
  FROM public.breeding_records br
  WHERE br.deleted_at IS NULL
),
aggregated AS (
  SELECT
    base.profile_id,
    base.period_start,
    COUNT(*) AS total_matings,
    COUNT(*) FILTER (
      WHERE base.palpation_positive IS TRUE OR base.kindling_date IS NOT NULL
    ) AS confirmed_matings,
    COUNT(*) FILTER (
      WHERE base.kindling_date IS NOT NULL
    ) AS kindlings,
    SUM(base.kits_born_alive) AS kits_born_alive,
    SUM(base.kits_born_dead) AS kits_born_dead,
    SUM(base.kits_weaned) AS kits_weaned,
    AVG(NULLIF(base.average_weaning_weight, 0)) AS average_weaning_weight
  FROM base
  GROUP BY base.profile_id, base.period_start
),
kindling_intervals AS (
  SELECT
    br.profile_id,
    date_trunc('month', br.kindling_date)::date AS period_start,
    EXTRACT(
      day FROM br.kindling_date
      - LAG(br.kindling_date) OVER (
        PARTITION BY br.profile_id, br.doe_id
        ORDER BY br.kindling_date
      )
    ) AS interval_days
  FROM public.breeding_records br
  WHERE br.deleted_at IS NULL
    AND br.kindling_date IS NOT NULL
)
SELECT
  agg.profile_id,
  agg.period_start,
  (agg.period_start + INTERVAL '1 month - 1 day')::date AS period_end,
  agg.total_matings,
  agg.confirmed_matings,
  agg.kindlings,
  agg.kits_born_alive,
  agg.kits_born_dead,
  agg.kits_weaned,
  agg.average_weaning_weight,
  CASE
    WHEN agg.total_matings = 0 THEN 0
    ELSE agg.confirmed_matings::numeric / agg.total_matings
  END AS fertility_rate,
  CASE
    WHEN agg.confirmed_matings = 0 THEN 0
    ELSE agg.kindlings::numeric / agg.confirmed_matings
  END AS kindling_success_rate,
  CASE
    WHEN agg.kindlings = 0 THEN NULL
    ELSE agg.kits_born_alive::numeric / agg.kindlings
  END AS average_litter_size,
  CASE
    WHEN agg.kits_born_alive = 0 THEN NULL
    ELSE agg.kits_weaned::numeric / agg.kits_born_alive
  END AS weaning_rate,
  CASE
    WHEN agg.kits_born_alive = 0 THEN NULL
    ELSE GREATEST(agg.kits_born_alive - agg.kits_weaned, 0)::numeric
      / agg.kits_born_alive
  END AS preweaning_mortality_rate,
  AVG(kindling_intervals.interval_days) AS average_kindling_interval_days
FROM aggregated agg
LEFT JOIN kindling_intervals
  ON kindling_intervals.profile_id = agg.profile_id
  AND kindling_intervals.period_start = agg.period_start
GROUP BY
  agg.profile_id,
  agg.period_start,
  agg.total_matings,
  agg.confirmed_matings,
  agg.kindlings,
  agg.kits_born_alive,
  agg.kits_born_dead,
  agg.kits_weaned,
  agg.average_weaning_weight
ORDER BY agg.profile_id, agg.period_start;

COMMENT ON VIEW public.view_reports_reproduction IS
  'Monthly reproduction metrics combining breeding_records (fertility, litter size, weaning success).';

-- ------------------------------------------------------------------
-- Growth metrics (monthly)
-- ------------------------------------------------------------------
DROP VIEW IF EXISTS public.view_reports_growth CASCADE;

CREATE VIEW public.view_reports_growth AS
WITH reproduction AS (
  SELECT
    profile_id,
    period_start,
    period_end,
    kits_weaned
  FROM public.view_reports_reproduction
),
weaning_base AS (
  SELECT
    br.profile_id,
    date_trunc('month', COALESCE(br.weaning_date, br.kindling_date))::date AS period_start,
    CASE
      WHEN br.weaning_date IS NOT NULL AND br.kindling_date IS NOT NULL
        THEN EXTRACT(day FROM br.weaning_date - br.kindling_date)
      ELSE NULL
    END AS weaning_age_days,
    br.average_weaning_weight
  FROM public.breeding_records br
  WHERE br.deleted_at IS NULL
    AND (
      br.weaning_date IS NOT NULL
      OR br.average_weaning_weight IS NOT NULL
    )
),
weaning_agg AS (
  SELECT
    profile_id,
    period_start,
    AVG(weaning_age_days) AS average_weaning_age_days,
    AVG(NULLIF(average_weaning_weight, 0)) AS average_weaning_weight_kg,
    COUNT(*) FILTER (WHERE weaning_age_days IS NOT NULL) AS weaning_samples
  FROM weaning_base
  GROUP BY profile_id, period_start
),
weight_events AS (
  SELECT
    e.profile_id,
    ae.animal_id,
    date_trunc('month', e.event_date)::date AS period_start,
    e.event_date::date AS event_date,
    NULLIF(
      COALESCE(
        (e.details ->> 'weightKg')::numeric,
        (e.details ->> 'weight')::numeric
      ),
      0
    ) AS weight_kg
  FROM public.events e
  JOIN public.animal_events ae ON ae.event_id = e.id
  WHERE e.deleted_at IS NULL
    AND (ae.deleted_at IS NULL OR ae.deleted_at > e.event_date)
    AND e.event_type = 'weight'
),
weight_enriched AS (
  SELECT
    w.profile_id,
    w.period_start,
    w.event_date,
    w.weight_kg,
    DATE_PART('day', w.event_date - a.birth_date) AS age_days
  FROM weight_events w
  JOIN public.animals a
    ON a.id = w.animal_id
  WHERE a.deleted_at IS NULL
),
weight_agg AS (
  SELECT
    profile_id,
    period_start,
    COUNT(*) FILTER (WHERE weight_kg IS NOT NULL) AS weight_samples,
    AVG(weight_kg) AS average_weight_kg,
    AVG(
      CASE
        WHEN age_days IS NULL OR age_days <= 0 THEN NULL
        ELSE weight_kg / age_days
      END
    ) AS average_daily_gain_kg
  FROM weight_enriched
  GROUP BY profile_id, period_start
),
retention AS (
  SELECT
    a.profile_id,
    date_trunc('month', a.birth_date)::date AS period_start,
    COUNT(*) AS total_kits,
    COUNT(*) FILTER (
      WHERE
        (CURRENT_DATE - a.birth_date) >= 84
        AND LOWER(a.status) IN ('active', 'breeding', 'growing')
    ) AS retained_12_weeks
  FROM public.animals a
  WHERE a.deleted_at IS NULL
    AND a.birth_date IS NOT NULL
  GROUP BY a.profile_id, date_trunc('month', a.birth_date)::date
),
periods AS (
  SELECT DISTINCT profile_id, period_start FROM reproduction
  UNION
  SELECT DISTINCT profile_id, period_start FROM weaning_agg
  UNION
  SELECT DISTINCT profile_id, period_start FROM weight_agg
  UNION
  SELECT DISTINCT profile_id, period_start FROM retention
)
SELECT
  p.profile_id,
  p.period_start,
  (p.period_start + INTERVAL '1 month - 1 day')::date AS period_end,
  COALESCE(weaning_agg.weaning_samples, 0) AS weaning_samples,
  weaning_agg.average_weaning_age_days,
  weaning_agg.average_weaning_weight_kg,
  COALESCE(weight_agg.weight_samples, 0) AS weight_samples,
  weight_agg.average_weight_kg,
  weight_agg.average_daily_gain_kg,
  COALESCE(reproduction.kits_weaned, 0) AS kits_weaned,
  COALESCE(retention.retained_12_weeks, 0) AS retained_12_weeks,
  CASE
    WHEN reproduction.kits_weaned IS NULL OR reproduction.kits_weaned = 0
      THEN NULL
    ELSE COALESCE(retention.retained_12_weeks, 0)::numeric
      / reproduction.kits_weaned
  END AS twelve_week_retention_rate
FROM periods p
LEFT JOIN weaning_agg
  ON weaning_agg.profile_id = p.profile_id
  AND weaning_agg.period_start = p.period_start
LEFT JOIN weight_agg
  ON weight_agg.profile_id = p.profile_id
  AND weight_agg.period_start = p.period_start
LEFT JOIN reproduction
  ON reproduction.profile_id = p.profile_id
  AND reproduction.period_start = p.period_start
LEFT JOIN retention
  ON retention.profile_id = p.profile_id
  AND retention.period_start = p.period_start
ORDER BY p.profile_id, p.period_start;

COMMENT ON VIEW public.view_reports_growth IS
  'Monthly growth indicators (weaning age/weight, weight samples, retention at 12 weeks).';

-- ------------------------------------------------------------------
-- Finance metrics (monthly + helper function)
-- ------------------------------------------------------------------
DROP VIEW IF EXISTS public.view_reports_finances CASCADE;

CREATE VIEW public.view_reports_finances AS
WITH transactions AS (
  SELECT
    ft.profile_id,
    date_trunc('month', ft.occured_on)::date AS period_start,
    ft.flow,
    ft.amount,
    COALESCE(tc.code, '') AS category_code
  FROM public.financial_transactions ft
  LEFT JOIN public.transaction_categories tc
    ON tc.id = ft.category_id
),
aggregated AS (
  SELECT
    profile_id,
    period_start,
    SUM(CASE WHEN flow = 'income' THEN amount ELSE 0 END) AS income_total,
    SUM(CASE WHEN flow = 'expense' THEN amount ELSE 0 END) AS expense_total,
    SUM(CASE WHEN flow = 'neutral' THEN amount ELSE 0 END) AS neutral_total,
    SUM(
      CASE
        WHEN flow = 'expense' AND category_code = 'feed' THEN amount
        ELSE 0
      END
    ) AS feed_expense,
    SUM(
      CASE
        WHEN flow = 'income' AND category_code = 'sales' THEN amount
        ELSE 0
      END
    ) AS sales_income
  FROM transactions
  GROUP BY profile_id, period_start
),
periods AS (
  SELECT profile_id, period_start FROM aggregated
),
female_counts AS (
  SELECT
    p.profile_id,
    p.period_start,
    COUNT(*) AS female_active
  FROM periods p
  JOIN public.animals a
    ON a.profile_id = p.profile_id
  WHERE a.deleted_at IS NULL
    AND LOWER(a.sex) LIKE 'f%'
    AND LOWER(a.status) IN ('active', 'breeding')
    AND a.birth_date <= (p.period_start + INTERVAL '1 month - 1 day')::date
  GROUP BY p.profile_id, p.period_start
),
reproduction AS (
  SELECT
    profile_id,
    period_start,
    kits_weaned
  FROM public.view_reports_reproduction
)
SELECT
  agg.profile_id,
  agg.period_start,
  (agg.period_start + INTERVAL '1 month - 1 day')::date AS period_end,
  agg.income_total,
  agg.expense_total,
  agg.neutral_total,
  agg.feed_expense,
  agg.sales_income,
  agg.income_total - agg.expense_total AS net_margin,
  COALESCE(reproduction.kits_weaned, 0) AS kits_weaned,
  COALESCE(female_counts.female_active, 0) AS female_active,
  CASE
    WHEN COALESCE(reproduction.kits_weaned, 0) = 0 THEN NULL
    ELSE agg.feed_expense / NULLIF(reproduction.kits_weaned, 0)
  END AS feed_cost_per_weaned,
  CASE
    WHEN COALESCE(female_counts.female_active, 0) = 0 THEN NULL
    ELSE agg.sales_income / NULLIF(female_counts.female_active, 0)
  END AS revenue_per_active_doe
FROM aggregated agg
LEFT JOIN reproduction
  ON reproduction.profile_id = agg.profile_id
  AND reproduction.period_start = agg.period_start
LEFT JOIN female_counts
  ON female_counts.profile_id = agg.profile_id
  AND female_counts.period_start = agg.period_start
ORDER BY agg.profile_id, agg.period_start;

COMMENT ON VIEW public.view_reports_finances IS
  'Monthly finance KPIs (income, expense, margin, feed cost per litter, revenue per active doe).';

DROP FUNCTION IF EXISTS public.fn_report_finance_summary(uuid, date, date);

CREATE FUNCTION public.fn_report_finance_summary(
  p_profile_id uuid,
  p_start_date date,
  p_end_date date
) RETURNS TABLE (
  income_total numeric,
  expense_total numeric,
  neutral_total numeric,
  feed_expense numeric,
  sales_income numeric,
  net_margin numeric
) AS $$
  SELECT
    COALESCE(SUM(CASE WHEN ft.flow = 'income' THEN ft.amount END), 0)::numeric AS income_total,
    COALESCE(SUM(CASE WHEN ft.flow = 'expense' THEN ft.amount END), 0)::numeric AS expense_total,
    COALESCE(SUM(CASE WHEN ft.flow = 'neutral' THEN ft.amount END), 0)::numeric AS neutral_total,
    COALESCE(SUM(
      CASE
        WHEN ft.flow = 'expense' AND tc.code = 'feed' THEN ft.amount
      END
    ), 0)::numeric AS feed_expense,
    COALESCE(SUM(
      CASE
        WHEN ft.flow = 'income' AND tc.code = 'sales' THEN ft.amount
      END
    ), 0)::numeric AS sales_income,
    COALESCE(SUM(CASE WHEN ft.flow = 'income' THEN ft.amount END), 0)::numeric
      - COALESCE(SUM(CASE WHEN ft.flow = 'expense' THEN ft.amount END), 0)::numeric
      AS net_margin
  FROM public.financial_transactions ft
  LEFT JOIN public.transaction_categories tc
    ON tc.id = ft.category_id
  WHERE ft.profile_id = p_profile_id
    AND ft.occured_on BETWEEN p_start_date AND p_end_date;
$$ LANGUAGE sql STABLE;

COMMENT ON FUNCTION public.fn_report_finance_summary(uuid, date, date) IS
  'Return finance totals (income, expense, margin) for a profile within a given date range.';
