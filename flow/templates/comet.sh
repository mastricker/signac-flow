{% extends "slurm.sh" %}
{# Must override this block before header block is created #}
{% block tasks %}
{% if 'shared' in partition %}
{% if num_tasks > 24 %}
{% raise "You cannot use more than 24 cores on the 'shared' partitions." %}
{% else %}
#SBATCH --nodes={{ 1 }}
#SBATCH --ntasks-per-node={{ num_tasks }}
{% endif %}
{% else %}
{% set nn = (num_tasks/24)|round(method='ceil')|int %}
{% set ntasks = 24 if num_tasks > 24 else num_tasks %}
{% set node_util = num_tasks / (24 * nn) %}
{% if not force and node_util < 0.9 %}
{% raise "Bad node utilization!!" %}
{% endif %}
#SBATCH --nodes={{ nn }}
#SBATCH --ntasks-per-node={{ ntasks }}
{% endif %}
{% if partition == 'gpu-shared' %}
#SBATCH --gres=gpu:p100:{{ num_tasks }}
{% endif %}
{% endblock %}
{% block header %}
{{ super () -}}
{% set account = 'account'|get_config_value(ns=environment) %}
{% if account %}
#SBATCH -A {{ account }}
{% endif %}
{% if memory %}
#SBATCH --mem={{ memory }}G
{% endif %}
{% endblock %}
