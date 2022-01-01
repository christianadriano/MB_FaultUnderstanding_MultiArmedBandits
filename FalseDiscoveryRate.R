"
Compute the False Discovery Rate of multiple experiments
"

"https://strimmerlab.github.io/software/fdrtool/"
install.packages("fdrtool")
library(fdrtool)


if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("onlineFDR")

