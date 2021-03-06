% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper_assess.R
\name{calculateGoF}
\alias{calculateGoF}
\title{Goodness of Fit (GoF)}
\usage{
calculateGoF(
 .object              = NULL
)
}
\arguments{
\item{.object}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}
}
\value{
A single numeric value.
}
\description{
Calculate the Goodness of Fit (GoF) proposed by \insertCite{Tenenhaus2004;textual}{cSEM}.
Note that, contrary to what the name suggests, the GoF is \strong{not} a
measure of model fit in the sense of SEM. See e.g. \insertCite{Henseler2012a;textual}{cSEM}
for a discussion.
}
\details{
The GoF is inherently tied to the common factor model. It is therefore
unclear how to meaningfully interpret the GoF in the context of a
model that contains constructs modeled as composites.
}
\references{
\insertAllCited{}
}
\seealso{
\code{\link[=assess]{assess()}}, \link{cSEMResults}
}
