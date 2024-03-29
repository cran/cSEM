% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zz_templates.R
\name{csem_model}
\alias{csem_model}
\alias{cSEMModel}
\title{cSEMModel}
\value{
An object of class \link{cSEMModel} is a standardized list containing the
following components. J stands for the number of constructs and K for the number
of indicators.
\describe{
\item{\verb{$structural}}{A matrix mimicking the structural relationship between
constructs. If constructs are only linearly related, \code{structural} is
of dimension (J x J) with row- and column names equal to the construct
names. If the structural model contains nonlinear relationships
\code{structural} is (J x (J + J*)) where J* is the number of
nonlinear terms. Rows are ordered such that exogenous constructs are always
first, followed by constructs that only depend on exogenous constructs and/or
previously ordered constructs.}
\item{\verb{$measurement}}{A (J x K) matrix mimicking the measurement/composite
relationship between constructs and their related indicators. Rows are in the same
order as the matrix \verb{$structural} with row names equal to
the construct names. The order of the columns is such that \verb{$measurement}
forms a block diagonal matrix.}
\item{\verb{$error_cor}}{A (K x K) matrix mimicking the measurement error
correlation relationship. The row and column order is identical to
the column order of \verb{$measurement}.}
\item{\verb{$cor_specified}}{A matrix indicating the correlation relationships
between any variables of the model as specified by the user. Mainly for internal purposes.
Note that \verb{$cor_specified} may also contain inadmissible correlations
such as a correlation between measurement errors indicators and constructs.}
\item{\verb{$construct_type}}{A named vector containing the names of each construct
and their respective type ("Common factor" or "Composite").}
\item{\verb{$construct_order}}{A named vector containing the names of each construct
and their respective order ("First order" or "Second order").}
\item{\verb{$model_type}}{The type of model ("Linear" or "Nonlinear").}
\item{\verb{$instruments}}{Only if instruments are supplied: a list of structural
equations relating endogenous RHS variables to instruments.}
\item{\verb{$indicators}}{The names of the indicators
(i.e., observed variables and/or first-order constructs)}
\item{\verb{$cons_exo}}{The names of the exogenous constructs of the structural model
(i.e., variables that do not appear on the LHS of any structural equation)}
\item{\verb{$cons_endo}}{The names of the endogenous constructs of the structural model
(i.e., variables that appear on the LHS of at least one structural equation)}
\item{\verb{$vars_2nd}}{The names of the constructs modeled as second orders.}
\item{\verb{$vars_attached_to_2nd}}{The names of the constructs forming or building
a second order construct.}
\item{\verb{$vars_not_attached_to_2nd}}{The names of the constructs not forming or building
a second order construct.}
}
It is possible to supply an incomplete list to \code{\link[=parseModel]{parseModel()}}, resulting
in an incomplete \link{cSEMModel} list which can be passed
to all functions that require \code{.csem_model} as a mandatory argument. Currently,
only the structural and the measurement matrix are required.
However, specifying an incomplete \link{cSEMModel} list may lead to unexpected behavior
and errors. Use with care.
}
\description{
cSEMModel
}
\details{
A standardized list containing model-related information. To convert a
a model written in \link[lavaan:model.syntax]{lavaan model syntax}
to a \link{cSEMModel} list use \code{\link[=parseModel]{parseModel()}}.
}
\seealso{
\link{parseModel}
}
\keyword{internal}
