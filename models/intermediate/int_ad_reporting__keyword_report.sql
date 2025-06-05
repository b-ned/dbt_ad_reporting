{% set include_list = ['amazon_ads', 'apple_search_ads', 'google_ads', 'microsoft_ads'] %}
{% do include_list.append('pinterest_ads') if var('pinterest__using_keywords', true) %}
{% do include_list.append('twitter_ads') if var('twitter_ads__using_keywords', true) %}

{% set enabled_packages = get_enabled_packages(include=include_list)%}
{{ config(enabled=is_enabled(enabled_packages)) }}

with


{% if 'google_ads' in enabled_packages %}
google_ads as (

    {{ get_query(
        platform='google_ads', 
        report_type='keyword', 
        field_mapping={
                'keyword_id': 'criterion_id',
            },
        relation=ref('google_ads__keyword_report')
    ) }}
),
{% endif %}

{% if 'microsoft_ads' in enabled_packages %}
microsoft_ads as (

    {{ get_query(
        platform='microsoft_ads', 
        report_type='keyword', 
        field_mapping={
                'keyword_text': 'keyword_name',
                'keyword_match_type': 'match_type'
            },
        relation=ref('microsoft_ads__keyword_report')
    ) }}
),
{% endif %}


unioned as (

    {{ union_ctes(ctes=enabled_packages)}}
)

select *
from unioned