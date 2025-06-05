{% set include_list = [] %}
{% do include_list.append('facebook_ads') if var('facebook_ads__using_demographics_country', false) %}
{% do include_list.append('linkedin_ads') if var('linkedin_ads__using_geo', true) and var('linkedin_ads__using_monthly_ad_analytics_by_member_country', true) %}
{% do include_list.append('microsoft_ads') if var('microsoft_ads__using_geographic_daily_report', false) %}
{% do include_list.append('pinterest_ads') if var('pinterest__using_pin_promotion_targeting_report', true) and var('pinterest__using_targeting_geo', true) %}
{% do include_list.append('reddit_ads') if var('reddit_ads__using_campaign_country_report', true) %}
{% do include_list.append('snapchat_ads') if var('snapchat_ads__using_campaign_country_report', false) %}
{% do include_list.append('tiktok_ads') if var('tiktok_ads__using_campaign_country_report', true) %}
{% do include_list.append('twitter_ads') if var('twitter_ads__using_campaign_locations_report', false) %}

{% set enabled_packages = get_enabled_packages(include=include_list) %}
{{ config(enabled=is_enabled(enabled_packages)) }}

with 
{% if 'facebook_ads' in enabled_packages %}
facebook_ads as (

    {{ get_query(
        platform='facebook_ads', 
        report_type='country', 
        field_mapping={
                'campaign_id': 'null',
                'campaign_name': "'Account-level'",
                'conversions_value': 'null',
                'country': 'null',
                'country_code': "replace(country, 'unknown', 'Unknown')"
            },
        relation=ref('facebook_ads__country_report')
    ) }}
),
{% endif %}

{% if 'microsoft_ads' in enabled_packages %}
microsoft_ads as (

    {{ get_query(
        platform='microsoft_ads', 
        report_type='country', 
        field_mapping={
                'country_code': 'null'
            },
        relation=ref('microsoft_ads__campaign_country_report')
    ) }}
),
{% endif %}


unioned as (

    {{ union_ctes(ctes=enabled_packages) }}
)

select *
from unioned