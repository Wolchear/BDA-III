library(data.table)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

input <- args[1]
output <- args[2]
ch <- args[3]
include_columns <- strsplit(args[4], ",")[[1]]

dt <- fread(input)
dt <- dt[get("chrom") == ch]

long <- melt(
    dt,
    id.vars = c("chrom", "start", "end"),
    variable.name = "sample",
    value.name = "value"
)

long[, group := fifelse(
    sample %in% c("N2", "N12"),
    "Normal",
    "Tumor"
)]

p <- ggplot(long, aes(x = sample, y = value, fill=group)) +
    geom_boxplot(outlier.size = 0.2) +
    xlab("Sample") +
    ylab("Beta-value") +
    theme_bw()

ggsave(
    output,
    p
)