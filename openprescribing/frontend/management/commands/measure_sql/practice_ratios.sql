 WITH practices_with_months AS (
 -- Return a row for every practice in every month, even where
 -- there is no denominator value
  SELECT prescribing.month AS month,
         practices.code AS practice_id,
         ccg_id
  FROM {hscic}.practices AS practices
  CROSS JOIN (
    SELECT month
    FROM {denominator_from}
    GROUP BY month
  ) prescribing
  WHERE
    practices.setting = 4 AND
    DATE(month) >= '{start_date}' AND
    DATE(month) <= '{end_date}'
),

denom AS (
  SELECT month, practice, {denominator_columns}
  FROM
    {denominator_from}
  WHERE
    DATE(month) >= '{start_date}' AND DATE(month) <= '{end_date}'
    AND
      {denominator_where}
  GROUP BY
    practice,
    month
),

num AS (
  SELECT month, practice, {numerator_columns}
  FROM
    {numerator_from}
  WHERE
    DATE(month) >= '{start_date}' AND DATE(month) <= '{end_date}'
    AND
      {numerator_where}
  GROUP BY
    practice,
    month
)

SELECT
  numerator,
  denominator,
  practice_id,
  pct_id,
  month,
  IF(IS_INF(calc_value) OR IS_NAN(calc_value), NULL, calc_value) AS calc_value
  {aliased_denominators}
  {aliased_numerators}
FROM (
  SELECT
    -- Compute ratios
    *,
    IEEE_DIVIDE(numerator, denominator) AS calc_value
    FROM (
      SELECT
        -- a missing numerator or denominator means zero items
        -- prescribed
        COALESCE(num.numerator, 0) AS numerator,
        COALESCE(denom.denominator, 0) AS denominator,
        practices_with_months.practice_id,
        practices_with_months.ccg_id AS pct_id,
        DATE(practices_with_months.month) AS month
        {numerator_aliases}
        {denominator_aliases}
      FROM num
      RIGHT JOIN denom
      ON num.practice = denom.practice AND num.month = denom.month
      RIGHT JOIN practices_with_months
      ON practices_with_months.practice_id = denom.practice
        AND practices_with_months.month = denom.month
   )
)
