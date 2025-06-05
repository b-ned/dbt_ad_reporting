{% set include_list = [] %}
{% do include_list.append('facebook_ads') if var('facebook_ads__using_demographics_region', false) %}

{% do include_list.append('microsoft_ads') if var('microsoft_ads__using_geographic_daily_report', false) %}


{% set enabled_packages = get_enabled_packages(include=include_list)%}
{{ config(enabled=is_enabled(enabled_packages)) }}

with base as (

    select *
    from {{ ref('int_ad_reporting__monthly_campaign_region_report') }}
),

aggregated as (
    
    select
        source_relation,
        cast({{ dbt.date_trunc("month", "date_day") }} as date) as date_month,
        platform,
        account_id,
        account_name,
        campaign_id,
        campaign_name,
        region,
        sum(coalesce(clicks, 0)) as clicks,
        sum(coalesce(impressions, 0)) as impressions,
        sum(coalesce(spend, 0)) as spend,
        sum(coalesce(conversions, 0)) as conversions,
        sum(coalesce(conversions_value, 0)) as conversions_value

        {{ ad_reporting_persist_pass_through_columns(pass_through_variable='ad_reporting__country_passthrough_metrics', transform = 'sum', alias_fields=['conversions', 'conversions_value']) }}

    from base
    {{ dbt_utils.group_by(8) }}
)

select *
from aggregated