from workflow.lib.utils import get_path
import pandas as pd

RAW_DIR = get_path(config["data"], 'raw')

SAMPLES = pd.read_csv("config/samples.tsv", sep="\t").set_index("geo")


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
        pigz -dc -p {threads} {input} > {output}
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
        names=" ".join(SAMPLES["file"].tolist()),
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