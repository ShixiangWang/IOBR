% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_markers_in_bulk.R
\name{find_markers_in_bulk}
\alias{find_markers_in_bulk}
\title{Find markers in bulk}
\usage{
find_markers_in_bulk(
  pdata,
  eset,
  group,
  id_pdata = "ID",
  nfeatures = 2000,
  top_n = 20,
  thresh.use = 0.25,
  only.pos = TRUE,
  min.pct = 0.25,
  npcs = 50
)
}
\arguments{
\item{pdata}{A data frame containing the meta information of the samples.}

\item{eset}{A matrix containing the gene expression data or signature score.}

\item{group}{A string representing the column name for grouping.}

\item{id_pdata}{A string representing the column name for sample IDs, default is "ID".}

\item{nfeatures}{A numeric value indicating the top n features to select from the variable features, default is 2000.}

\item{top_n}{A numeric value representing the top n markers to select in each cluster, default is 20.}

\item{thresh.use}{A numeric value representing the marker selection threshold, default is 0.25.}

\item{only.pos}{A logical value indicating whether to select only positive markers, default is TRUE.}

\item{min.pct}{A numeric value representing the minimum percentage threshold for marker selection, default is 0.25.}

\item{npcs}{Total Number of PCs to compute and store (50 by default)}
}
\description{
The goal of this function is to find relevant results from the given gene expression data and meta information.
}
