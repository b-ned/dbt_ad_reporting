{% set include_list = [] %}
{% do include_list.append('facebook_ads') if var('facebook_ads__using_demographics_region', false) %}
{% do include_list.append('linkedin_ads') if var('linkedin_ads__using_geo', true) and var('linkedin_ads__using_monthly_ad_analytics_by_member_region', true) %}
{% do include_list.append('microsoft_ads') if var('microsoft_ads__using_geographic_daily_report', false) %}
{% do include_list.append('pinterest_ads') if var('pinterest__using_pin_promotion_targeting_report', true) and var('pinterest__using_targeting_geo_region', true) %}
{% do include_list.append('snapchat_ads') if var('snapchat_ads__using_campaign_region_report', false) %}
{% do include_list.append('twitter_ads') if var('twitter_ads__using_campaign_regions_report', false) %}

{% set enabled_packages = get_enabled_packages(include=include_list) %}
{{ config(enabled=is_enabled(enabled_packages)) }}

with 
{% if 'facebook_ads' in enabled_packages %}
facebook_ads as (

    {{ get_query(
        platform='facebook_ads', 
        report_type='region', 
        field_mapping={
                'campaign_id': 'null',
                'campaign_name': "'Account-level'",
                'conversions_value': 'null'
            },
        relation=ref('facebook_ads__region_report')
    ) }}
),
{% endif %}


{% if 'microsoft_ads' in enabled_packages %}
microsoft_ads as (

    {{ get_query(
        platform='microsoft_ads', 
        report_type='region',
        relation=ref('microsoft_ads__campaign_region_report')
    ) }}
),
{% endif %}

unioned as (

    {{ union_ctes(ctes=enabled_packages) }}
)

select *
from unioned