{% set enabled_packages = get_enabled_packages() %}
{{ config(enabled=is_enabled(enabled_packages)) }}

with
{% for package in ['google_ads', 'microsoft_ads'] %}
{% if package in enabled_packages %}
{{ package }} as (
    {{ get_query(
        platform=package,
        report_type='ad',
        relation=ref(package ~ '__ad_report')
    ) }}
),
{% endif %}
{% endfor %}


{% if 'facebook_ads' in enabled_packages %}
facebook_ads as (

    {{ get_query(
        platform='facebook_ads', 
        report_type='ad', 
        field_mapping={
                'ad_group_id': 'ad_set_id',
                'ad_group_name': 'ad_set_name'
            },
        relation=ref('facebook_ads__ad_report')
    ) }}
),
{% endif %}

unioned as (

    {{ union_ctes(ctes=enabled_packages)}}
)

select *
from unioned