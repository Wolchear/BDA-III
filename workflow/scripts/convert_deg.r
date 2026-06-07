library(GenomicRanges)
library(AnnotationDbi)
library(org.Hs.eg.db)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)

args <- commandArgs(trailingOnly = TRUE)

deg <- read.csv(args[1])
output <-args[2]

txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
genes_gr <- genes(txdb)

genes_gr <- genes_gr[names(genes_gr) %in% as.character(deg$ENTREZID)]
deg_matched <- deg[match(names(genes_gr), deg$ENTREZID), ]

gene_symbols <- mapIds(
  org.Hs.eg.db,
  keys = names(genes_gr),
  column = "SYMBOL",
  keytype = "ENTREZID",
  multiVals = "first"
)

itemRgb <- ifelse(
  deg_matched$log2FoldChange > 0,
  "255,0,0",
  ifelse(
    deg_matched$log2FoldChange < 0,
    "0,0,255",
    "160,160,160"
  )
)

deg_bed <- data.frame(
  chr = as.character(seqnames(genes_gr)),
  start = start(genes_gr) - 1,
  end = end(genes_gr),
  name = paste0(
    gene_symbols,
    "|ENTREZID=", names(genes_gr),
    "|log2FC=", round(deg_matched$log2FoldChange, 2)
  ),
  score = 0,
  strand = as.character(strand(genes_gr)),
  thickStart = start(genes_gr) - 1,
  thickEnd = end(genes_gr),
  itemRgb = itemRgb
)

deg_bed <- deg_bed[order(deg_bed$chr, deg_bed$start), ]

writeLines('track name="DEG_genes" itemRgb="On"', output)

write.table(
  deg_bed,
  output,
  sep = "\t",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  append = TRUE
)