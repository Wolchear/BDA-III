from workflow.lib.utils import get_path
import pandas as pd

RAW_DIR = get_path(config["data"], 'raw')

SAMPLES = pd.read_csv("config/samples.tsv", sep="\t").set_index("geo")
SCRIPTS = get_path(config['workflow'], 'scripts')

rule gunzip:
    input:
        f"{RAW_DIR}/{{file}}.gz"
    output:
        f"{RAW_DIR}/{{file}}"
    threads: max(1, config['max_threads'])
    wildcard_constraints:
        file=r".+(?<!\.gz)"
    log:
        "logs/prepare_data/gunzip/{file}.log"
    conda:
        f"../envs/prepare_data.yml"
    shell:
        """
        pigz -dc -p {threads} {input} > {output} 2> {log}
        """


rule get_meth_matix:
    input:
        expand(
            "{input_dir}/{file}",
            input_dir=RAW_DIR,
            file=SAMPLES["file"].tolist()
        )
    output:
        f"{RAW_DIR}/meth_matrix.bed"
    params:
        names=" ".join(SAMPLES["id"].tolist()),
        filler="0" 
    threads: 1
    log:
        "logs/prepare_data/matrix_merge.log"
    conda:
        "../envs/prepare_data.yml"
    shell:
        r"""
        bedtools unionbedg \
            -header \
            -names {params.names} \
            -filler {params.filler} \
            -i {input} \
            > {output} 2> {log}
        """


rule get_deg_bam:
    input:
         f"{RAW_DIR}/DEG_All_Genes.csv"
    output:
        f"{RAW_DIR}/DEG_All_Genes.colored.sorted.bam"
    threads: 1
    log:
        "logs/prepare_data/get_deg_bam.log"
    conda:
        "../envs/convert_deg.yml"
    params:
        script = f"{SCRIPTS}/convert_deg.r"
    shell:
        r"""
        Rscript {params.script} {input} {output}
        """