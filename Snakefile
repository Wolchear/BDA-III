from snakemake.utils import min_version
min_version("6.0")
from workflow.lib.utils import get_path

configfile: "config/config.yaml"


DATA = config['data']

PLOTS = expand(
    "{plots_dir}/{file}.png",
    plots_dir = get_path(config["output"], 'plots'),
    file = ['meth_matrix.bed', 'VST_data.csv']
)

rule all:
    input:
       f"{get_path(config["output"], 'features')}/all_features_counts.tsv",
       PLOTS,
       f"{get_path(config["data"], 'raw')}/DEG_All_Genes.colored.sorted.bam"
        

RULES_DIR = get_path(config['workflow'], "rules")

module prepare_data:
    snakefile: f"{RULES_DIR}/prepare_data.smk"
    config: config
use rule * from prepare_data

module calculate_desciptive:
    snakefile: f"{RULES_DIR}/calculate_desciptive.smk"
    config: config
use rule * from calculate_desciptive