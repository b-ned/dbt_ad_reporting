{% set enabled_packages = get_enabled_packages(exclude=['amazon_ads', 'apple_search_ads']) %}
{{ config(enabled=is_enabled(enabled_packages)) }}

with
{% for package in ['google_ads', 'microsoft_ads'] %}
{% if package in enabled_packages %}
{{ package }} as (
    {{ get_query(
        platform=package,
        report_type='url',
        relation=ref(package ~ '__url_report')
    ) }}
),
{% endif %}
{% endfor %}

{% if 'facebook_ads' in enabled_packages %}
facebook_ads as (

    {{ get_query(
        platform='facebook_ads', 
        report_type='url', 
        field_mapping={
                'ad_group_id': 'ad_set_id',
                'ad_group_name': 'ad_set_name'
            },
        relation=ref('facebook_ads__url_report')
    ) }}
),
{% endif %}

unioned as (

    {{ union_ctes(ctes=enabled_packages)}}
)

select *
from unioned