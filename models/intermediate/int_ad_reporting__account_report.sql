{% set enabled_packages = get_enabled_packages() %}
{{ config(enabled=is_enabled(enabled_packages)) }}

with
{% for package in ['facebook_ads', 'google_ads', 'microsoft_ads'] %}
{% if package in enabled_packages %}
{{ package }} as (
    {{ get_query(
        platform=package,
        report_type='account',
        relation=ref(package ~ '__account_report')
    ) }}
),
{% endif %}
{% endfor %}

unioned as (

    {{ union_ctes(ctes=enabled_packages)}}
)

select *
from unioned