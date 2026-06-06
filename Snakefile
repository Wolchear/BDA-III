from snakemake.utils import min_version
min_version("6.0")
from workflow.lib.utils import get_path

configfile: "config/config.yaml"


DATA = config['data']

rule all:
    input:
       f"{get_path(config["data"], 'raw')}/meth_matrix.bed",
       f"{get_path(config["output"], 'features')}/all_features_counts.tsv"
        

RULES_DIR = get_path(config['workflow'], "rules")

module prepare_data:
    snakefile: f"{RULES_DIR}/prepare_data.smk"
    config: config
use rule * from prepare_data

module calculate_desciptive:
    snakefile: f"{RULES_DIR}/calculate_desciptive.smk"
    config: config
use rule * from calculate_desciptive