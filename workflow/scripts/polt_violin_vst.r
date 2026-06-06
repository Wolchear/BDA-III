library(data.table)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

input <- args[1]
output <- args[2]
ch <- args[3]
include_columns <- strsplit(args[4], ",")[[1]]

dt <- fread(input)
setnames(dt, 1, "gene")
dt <- dt[, c("gene", include_columns), with = FALSE]


long <- melt(
    dt,
    id.vars = 1,
    variable.name = "sample",
    value.name = "value"
)

long[, group := fifelse(
    sample %in% c("GSM4505877", "GSM4505883"),
    "Normal",
    "Tumor"
)]

p <- ggplot(long, aes(x = sample, y = value, fill=group)) +
    geom_violin(trim = FALSE) +
    geom_boxplot(
        width = 0.12,
        fill = "white",
        outlier.shape = NA
    ) +
    xlab("Sample") +
    ylab("VST-normalized expression") +
    theme_bw()

ggsave(
    output,
    p
)