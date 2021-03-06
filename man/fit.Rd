% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/csem_fit.R
\name{fit}
\alias{fit}
\title{Model-implied indicator or construct variance-covariance matrix}
\usage{
fit(
  .object    = NULL, 
  .saturated = args_default()$.saturated,
  .type_vcv  = args_default()$.type_vcv
  )
}
\arguments{
\item{.object}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}

\item{.saturated}{Logical. Should a saturated structural model be used?
Defaults to \code{FALSE}.}

\item{.type_vcv}{Character string. Which model-implied correlation
matrix should be calculated?
One of "\emph{indicator}" or "\emph{construct}". Defaults to "\emph{indicator}".}
}
\value{
Either a (K x K) matrix or a (J x J) matrix depending on the \code{type_vcv}.
}
\description{
Calculate the model-implied indicator or construct variance-covariance (VCV)
matrix. Currently only the model-implied VCV for recursive linear models
is implemented (including models containing second order constructs).
}
\details{
Notation is taken from \insertCite{Bollen1989;textual}{cSEM}.
If \code{.saturated = TRUE} the model-implied variance-covariance matrix is calculated
for a saturated structural model (i.e., the VCV of the constructs is replaced
by their correlation matrix). Hence: V(eta) = WSW' (possibly disattenuated).
}
\references{
\insertAllCited{}
}
\seealso{
\code{\link[=csem]{csem()}}, \code{\link[=foreman]{foreman()}}, \link{cSEMResults}
}
