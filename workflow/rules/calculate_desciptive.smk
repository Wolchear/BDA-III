from workflow.lib.utils import get_path

RAW_DIR = get_path(config["data"], 'raw')
FEATURE_DIR = get_path(config["output"], 'features')
PLOTS_DIR = get_path(config["output"], 'plots')

SCRIPTS = get_path(config['workflow'], 'scripts')

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

SCRIPT_TO_PLOT = {
    'meth_matrix.bed': "plot_violin_meth.r",
    'VST_data.csv': "polt_violin_vst.r"
}

INCLUDE_COLUMNS = {
    'meth_matrix.bed': "N1, N12, T1, T2",
    'VST_data.csv': "GSM4505877,GSM4505883,GSM4505887,GSM4505893"
}
rule plot_violin:
    input:
        f"{RAW_DIR}/{{file}}"
    output:
        f"{PLOTS_DIR}/{{file}}.png"
    log:
        f"logs/calculate_desciptive/plot_violin/{{file}}.log"
    threads: 1
    wildcard_constraints:
        file="meth_matrix.bed|VST_data.csv"
    conda:
        f"../envs/calculate_desciptive.yml"
    params:
        script = lambda wc: f"{SCRIPTS}/{SCRIPT_TO_PLOT[wc.file]}",
        chromosome = 'chr10',
        inclde_columns = lambda wc: INCLUDE_COLUMNS[wc.file]
    shell:
        """
        Rscript {params.script} {input} {output} {params.chromosome} {params.inclde_columns} > {log} 2>&1
        """
    

