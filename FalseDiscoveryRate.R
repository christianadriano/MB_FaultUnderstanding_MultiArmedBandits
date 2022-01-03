"
Compute the False Discovery Rate of multiple experiments.
"

#----------------------------
"https://strimmerlab.github.io/software/fdrtool/"
install.packages("fdrtool")
library(fdrtool)

#----------------------------
#http://www.bioconductor.org/packages/release/bioc/html/onlineFDR.html
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("onlineFDR")

#browseVignettes("onlineFDR")

