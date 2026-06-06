from workflow.lib.utils import get_path

RAW_DIR = get_path(config["data"], 'raw')
FEATURE_DIR = get_path(config["output"], 'features')

HAS_HEADER = {
    'meth_matrix.bed': True,
    'H3K27me_peaks.bed': False,
    'H3K27ac_peaks.bed': False,
    'DEG_All_Genes.csv': True,
    'VST_data.csv': True
}

rule count_features:
    input:
        f"{RAW_DIR}/{{file}}"
    output:
        f"{FEATURE_DIR}/{{file}}.tsv"
    threads: 1
    log:
        f"logs/calculate_desciptive/count_features/{{file}}.log"
    conda:
        f"../envs/calculate_desciptive.yml"
    params:
        skip=lambda wc: 1 if HAS_HEADER[wc.file] else 0,
        name= lambda wc: wc.file
    shell:
        r"""
        {{
            echo -e "{params.name}\t$(( $(wc -l < {input}) - {params.skip} ))"
        }} > {output} 2> {log}
        """

rule merge_features:
    input:
        expand(
            "{out_dir}/{table}.tsv",
            out_dir=FEATURE_DIR,
            table = HAS_HEADER.keys()
        )
    output:
        f"{FEATURE_DIR}/all_features_counts.tsv"
    threads: 1
    log:
        f"logs/calculate_desciptive/merge_features.log"
    conda:
        f"../envs/calculate_desciptive.yml"
    shell:
        r"""
        {{
            echo -e "feature\tcount"
            cat {input}
        }} > {output} 2> {log}
        """