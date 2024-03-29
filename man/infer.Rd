% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/postestimate_infer.R
\name{infer}
\alias{infer}
\title{Inference}
\usage{
infer(
 .object            = NULL,
 .quantity          = c("all", "mean", "sd", "bias", "CI_standard_z", 
                        "CI_standard_t", "CI_percentile", "CI_basic", 
                        "CI_bc", "CI_bca", "CI_t_interval"),
 .alpha             = 0.05,
 .bias_corrected    = TRUE
)
}
\arguments{
\item{.object}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}

\item{.quantity}{Character string. Which statistic should be returned?
One of "\emph{all}", "\emph{mean}", "\emph{sd}", "\emph{bias}", "\emph{CI_standard_z}", "\emph{CI_standard_t}",
"\emph{CI_percentile}", "\emph{CI_basic}", "\emph{CI_bc}", "\emph{CI_bca}", "\emph{CI_t_interval}"
Defaults to "\emph{all}" in which case all quantities that do not require
additional resampling are returned, i.e., all quantities but "\emph{CI_bca}", "\emph{CI_t_interval}".}

\item{.alpha}{An integer or a numeric vector of significance levels.
Defaults to \code{0.05}.}

\item{.bias_corrected}{Logical. Should the standard and the tStat
confidence interval be bias-corrected using the bootstrapped bias estimate?
If \code{TRUE} the confidence interval for some estimated parameter \code{theta}
is centered at \verb{2*theta - theta*_hat},
where \verb{theta*_hat} is the average over all \code{.R} bootstrap estimates of \code{theta}.
Defaults to \code{TRUE}}
}
\value{
A list of class \code{cSEMInfer}.
}
\description{
\lifecycle{stable}
}
\details{
Calculate common inferential quantities. For users interested in the
estimated standard errors, t-values, p-values and/or confidences
intervals of the path, weight or loading estimates, calling \code{\link[=summarize]{summarize()}}
directly will usually be more convenient as it has a much more
user-friendly print method. \code{\link[=infer]{infer()}} is useful for comparing
different confidence interval estimates.

\code{\link[=infer]{infer()}} is a convenience wrapper around a
number of internal functions that compute a particular inferential
quantity, i.e., a value or set of values to be used in statistical inference.

\pkg{cSEM} relies on resampling (bootstrap and jackknife) as the basis for
the computation of e.g., standard errors or confidence intervals.
Consequently, \code{\link[=infer]{infer()}} requires resamples to work. Technically,
the \link{cSEMResults} object used in the call to \code{\link[=infer]{infer()}} must
therefore also have class attribute \code{cSEMResults_resampled}. If
the object provided by the user does not contain resamples yet,
\code{\link[=infer]{infer()}} will obtain bootstrap resamples first.
Naturally, computation will take longer in this case.

\code{\link[=infer]{infer()}} does as much as possible in the  background. Hence, every time
\code{\link[=infer]{infer()}} is called on a \link{cSEMResults} object the quantities chosen by
the user are automatically computed for every estimated parameter
contained in the object. By default all possible quantities are
computed (\code{.quantity = all}). The following table list the available
inferential quantities alongside a brief description. Implementation and
terminology of the confidence intervals is based on
\insertCite{Hesterberg2015;textual}{cSEM} and
\insertCite{Davison1997;textual}{cSEM}.
\describe{
\item{\code{"mean"}, \code{"sd"}}{The mean or the standard deviation
over all \code{M} resample estimates of a generic statistic or parameter.}
\item{\code{"bias"}}{The difference between the resample mean and the original
estimate of a generic statistic or parameter.}
\item{\code{"CI_standard_z"} and \code{"CI_standard_t"}}{The standard confidence interval
for a generic statistic or parameter with standard errors estimated by
the resample standard deviation. While \code{"CI_standard_z"} assumes a
standard normally distributed statistic,
\code{"CI_standard_t"} assumes a t-statistic with N - 1 degrees of freedom.}
\item{\code{"CI_percentile"}}{The percentile confidence interval. The lower and
upper bounds of the confidence interval are estimated as the alpha and
1-alpha quantiles of the distribution of the resample estimates.}
\item{\code{"CI_basic"}}{The basic confidence interval also called the reverse
bootstrap percentile confidence interval. See \insertCite{Hesterberg2015;textual}{cSEM}
for details.}
\item{\code{"CI_bc"}}{The bias corrected (Bc) confidence interval. See
\insertCite{Davison1997;textual}{cSEM} for details.}
\item{\code{"CI_bca"}}{The bias-corrected and accelerated (Bca) confidence interval.
Requires additional jackknife resampling to compute the influence values.
See \insertCite{Davison1997;textual}{cSEM} for details.}
\item{\code{"CI_t_interval"}}{The "studentized" t-confidence interval. If based on bootstrap
resamples the interval is also called the bootstrap t-interval
confidence interval. See \insertCite{Hesterberg2015;textual}{cSEM} on page 381.
Requires resamples of resamples. See \code{\link[=resamplecSEMResults]{resamplecSEMResults()}}.}
}

By default, all but the studendized t-interval confidence interval and the
bias-corrected and accelerated confidence interval are calculated. The
reason for excluding these quantities by default are that both require
an additional resampling step. The former requires
jackknife estimates to compute influence values and the latter requires
double bootstrap. Both can potentially be time consuming.
Hence, computation is triggered only if explicitly chosen.
}
\examples{
model <- "
# Structural model
QUAL ~ EXPE
EXPE ~ IMAG
SAT  ~ IMAG + EXPE + QUAL + VAL
LOY  ~ IMAG + SAT
VAL  ~ EXPE + QUAL

# Measurement model
EXPE =~ expe1 + expe2 + expe3 + expe4 + expe5
IMAG =~ imag1 + imag2 + imag3 + imag4 + imag5
LOY  =~ loy1  + loy2  + loy3  + loy4
QUAL =~ qual1 + qual2 + qual3 + qual4 + qual5
SAT  =~ sat1  + sat2  + sat3  + sat4
VAL  =~ val1  + val2  + val3  + val4
"
  
## Estimate the model with bootstrap resampling 
a <- csem(satisfaction, model, .resample_method = "bootstrap", .R = 20,
          .handle_inadmissibles = "replace")

## Compute inferential quantities
inf <- infer(a)

inf$Path_estimates$CI_basic
inf$Indirect_effect$sd

### Compute the bias-corrected and accelerated and/or the studentized t-inverval.
## For the studentied t-interval confidence interval a double bootstrap is required.
## This is pretty time consuming.
\dontrun{
  inf <- infer(a, .quantity = c("all", "CI_bca")) # requires jackknife estimates 
  
## Estimate the model with double bootstrap resampling:
# Notes:
#   1. The .resample_method2 arguments triggers a bootstrap of each bootstrap sample
#   2. The double bootstrap is is very time consuming, consider setting 
#      `.eval_plan = "multisession`. 
a1 <- csem(satisfaction, model, .resample_method = "bootstrap", .R = 499,
          .resample_method2 = "bootstrap", .R2 = 199, .handle_inadmissibles = "replace") 
infer(a1, .quantity = "CI_t_interval")}

}
\references{
\insertAllCited{}
}
\seealso{
\code{\link[=csem]{csem()}}, \code{\link[=resamplecSEMResults]{resamplecSEMResults()}}, \code{\link[=summarize]{summarize()}} \link{cSEMResults}
}
