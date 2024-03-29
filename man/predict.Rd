% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/postestimate_predict.R
\name{predict}
\alias{predict}
\title{Predict indicator scores}
\usage{
predict(
 .object                   = NULL,
 .benchmark                = c("lm", "unit", "PLS-PM", "GSCA", "PCA", "MAXVAR", "NA"),
 .approach_predict         = c("earliest", "direct"),
 .cv_folds                 = 10,
 .handle_inadmissibles     = c("stop", "ignore", "set_NA"),
 .r                        = 1,
 .test_data                = NULL,
 .approach_score_target    = c("mean", "median", "mode"),
 .sim_points               = 100,
 .disattenuate             = TRUE,
 .treat_as_continuous      = TRUE,
 .approach_score_benchmark = c("mean", "median", "mode", "round"),
 .seed                     = NULL
 )
}
\arguments{
\item{.object}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}

\item{.benchmark}{Character string. The procedure to obtain benchmark predictions.
One of "\emph{lm}", "\emph{unit}", "\emph{PLS-PM}", "\emph{GSCA}", "\emph{PCA}", "\emph{MAXVAR}", or "\emph{NA}".
Default to "\emph{lm}".}

\item{.approach_predict}{Character string. Which approach should be used to perform
predictions? One of "\emph{earliest}" and "\emph{direct}". If "\emph{earliest}" predictions
for indicators associated to endogenous constructs are performed using only
indicators associated to exogenous constructs. If "\emph{direct}", predictions for
indicators associated to endogenous constructs are based on indicators associated
to their direct antecedents. Defaults to "\emph{earliest}".}

\item{.cv_folds}{Integer. The number of cross-validation folds to use. Setting
\code{.cv_folds} to \code{N} (the number of observations) produces
leave-one-out cross-validation samples. Defaults to \code{10}.}

\item{.handle_inadmissibles}{Character string. How should inadmissible results
be treated? One of "\emph{stop}", "\emph{ignore}", or "\emph{set_NA}". If "\emph{stop}", \code{\link[=predict]{predict()}}
will stop immediately if estimation yields an inadmissible result.
For "\emph{ignore}" all results are returned even if all or some of the estimates
yielded inadmissible results.
For "\emph{set_NA}" predictions based on inadmissible parameter estimates are
set to \code{NA}. Defaults to "\emph{stop}"}

\item{.r}{Integer. The number of repetitions to use. Defaults to \code{1}.}

\item{.test_data}{A matrix of test data with the same column names as the
training data.}

\item{.approach_score_target}{Character string. How should the aggregation of the estimates of
the truncated normal distribution for the predictions using OrdPLS/OrdPLSc be done?
One of "\emph{mean}", "\emph{median}" or "\emph{mode}".
If "\emph{mean}", the mean of the estimated endogenous indicators is calculated.
If "\emph{median}", the mean of the estimated endogenous indicators is calculated.
If "\emph{mode}", the maximum empirical density on the intervals defined by the thresholds
is used. Defaults to "\emph{mean}".}

\item{.sim_points}{Integer. How many samples from the truncated normal distribution should
be simulated to estimate the exogenous construct scores? Defaults to "\emph{100}".}

\item{.disattenuate}{Logical. Should the benchmark predictions be based on
disattenuated parameter estimates? Defaults to \code{TRUE}.}

\item{.treat_as_continuous}{Logical. Should the indicators for the benchmark predictions
be treated as continuous? If \code{TRUE} all indicators are treated as continuous and PLS-PM/PLSc is applied.
If \code{FALSE} OrdPLS/OrdPLSc is applied. Defaults to \code{TRUE}.}

\item{.approach_score_benchmark}{Character string. How should the aggregation
of the estimates of the truncated normal distribution be done for the
benchmark predictions? Ignored if not OrdPLS or OrdPLSc is used to obtain benchmark predictions.
One of "\emph{mean}", "\emph{median}", "\emph{mode}" or "\emph{round}".
If "\emph{round}", the benchmark predictions are obtained using the traditional prediction
algorithm for PLS-PM which are rounded for categorical indicators.
If "\emph{mean}", the mean of the estimated endogenous indicators is calculated.
If "\emph{median}", the mean of the estimated endogenous indicators is calculated.
If "\emph{mode}", the maximum empirical density on the intervals defined by the thresholds
is used.
If \code{.treat_as_continuous = TRUE} or if all indicators are on a continuous scale,
\code{.approach_score_benchmark} is ignored. Defaults to "\emph{round}".}

\item{.seed}{Integer or \code{NULL}. The random seed to use. Defaults to \code{NULL} in which
case an arbitrary seed is chosen. Note that the scope of the seed is limited
to the body of the function it is used in. Hence, the global seed will
not be altered!}
}
\value{
An object of class \code{cSEMPredict} with print and plot methods.
Technically, \code{cSEMPredict} is a
named list containing the following list elements:

\describe{
\item{\verb{$Actual}}{A matrix of the actual values/indicator scores of the endogenous constructs.}
\item{\verb{$Prediction_target}}{A list containing matrices of the predicted indicator
scores of the endogenous constructs based on the target model for each repetition
.r. Target refers to procedure used to estimate the parameters in \code{.object}.}
\item{\verb{$Residuals_target}}{A list of matrices of the residual indicator scores
of the endogenous constructs based on the target model in each repetition .r.}
\item{\verb{$Residuals_benchmark}}{A list of matrices of the residual indicator scores
of the endogenous constructs based on a model estimated by the procedure
given to \code{.benchmark} for each repetition .r.}
\item{\verb{$Prediction_metrics}}{A data frame containing the predictions metrics
MAE, RMSE, Q2_predict, the misclassification error rate (MER), the MAPE, the MSE2,
Theil's forecast accuracy (U1), Theil's forecast quality (U2), Bias proportion
of MSE (UM), Regression proportion of MSE (UR), and disturbance proportion
of MSE (UD) \insertCite{Hora2015,Watson2002}{cSEM}.}
\item{\verb{$Information}}{A list with elements
\code{Target}, \code{Benchmark},
\code{Number_of_observations_training}, \code{Number_of_observations_test}, \code{Number_of_folds},
\code{Number_of_repetitions}, and \code{Handle_inadmissibles}.}
}
}
\description{
\lifecycle{maturing}
}
\details{
The predict function implements the procedure introduced by \insertCite{Shmueli2016;textual}{cSEM} in the PLS context
known as "PLSPredict" \insertCite{Shmueli2019}{cSEM} including its variants PLScPredcit, OrdPLSpredict and OrdPLScpredict.
It is used to predict the indicator scores of endogenous constructs and to evaluate the out-of-sample predictive power
of a model.
For that purpose, the predict function uses k-fold cross-validation to randomly
split the data into training and test datasets, and subsequently predicts the
values of the test data based on the model parameter estimates obtained
from the training data. The number of cross-validation folds is 10 by default but
may be changed using the \code{.cv_folds} argument.
By default, the procedure is not repeated (\code{.r = 1}). You may choose to repeat
cross-validation by setting a higher \code{.r} to be sure not to have a particular
(unfortunate) split. See \insertCite{Shmueli2019;textual}{cSEM} for
details. Typically \code{.r = 1} should be sufficient though.

Alternatively, users may supply a test dataset as matrix or a data frame of \code{.test_data} with
the same column names as those in the data used to obtain \code{.object} (the training data).
In this case, arguments \code{.cv_folds} and \code{.r} are
ignored and predict uses the estimated coefficients from \code{.object} to
predict the values in the columns of \code{.test_data}.

In \insertCite{Shmueli2016;textual}{cSEM} PLS-based predictions for indicator \code{i}
are compared to the predictions based on a multiple regression of indicator \code{i}
on all available exogenous indicators (\code{.benchmark = "lm"}) and
a simple mean-based prediction summarized in the Q2_predict metric.
\code{predict()} is more general in that is allows users to compare the predictions
based on a so-called target model/specification to predictions based on an
alternative benchmark. Available benchmarks include predictions
based on a linear model, PLS-PM weights, unit weights (i.e. sum scores),
GSCA weights, PCA weights, and MAXVAR weights.

Each estimation run is checked for admissibility using \code{\link[=verify]{verify()}}. If the
estimation yields inadmissible results, \code{predict()} stops with an error (\code{"stop"}).
Users may choose to \code{"ignore"} inadmissible results or to simply set predictions
to \code{NA} (\code{"set_NA"}) for the particular run that failed.
}
\examples{
### Anime example taken from https://github.com/ISS-Analytics/pls-predict/

# Load data
data(Anime) # data is similar to the Anime.csv found on 
            # https://github.com/ISS-Analytics/pls-predict/ but with irrelevant
            # columns removed

# Split into training and data the same way as it is done on 
# https://github.com/ISS-Analytics/pls-predict/
set.seed(123)

index     <- sample.int(dim(Anime)[1], 83, replace = FALSE)
dat_train <- Anime[-index, ]
dat_test  <- Anime[index, ]

# Specify model
model <- "
# Structural model

ApproachAvoidance ~ PerceivedVisualComplexity + Arousal

# Measurement/composite model

ApproachAvoidance         =~ AA0 + AA1 + AA2 + AA3
PerceivedVisualComplexity <~ VX0 + VX1 + VX2 + VX3 + VX4
Arousal                   <~ Aro1 + Aro2 + Aro3 + Aro4
"

# Estimate (replicating the results of the `simplePLS()` function)
res <- csem(dat_train, 
            model, 
            .disattenuate = FALSE, # original PLS
            .iter_max = 300, 
            .tolerance = 1e-07, 
            .PLS_weight_scheme_inner = "factorial"
)

# Predict using a user-supplied training data set
pp <- predict(res, .test_data = dat_test)
pp

### Compute prediction metrics  ------------------------------------------------
res2 <- csem(Anime, # whole data set
            model, 
            .disattenuate = FALSE, # original PLS
            .iter_max = 300, 
            .tolerance = 1e-07, 
            .PLS_weight_scheme_inner = "factorial"
)

# Predict using 10-fold cross-validation
\dontrun{
pp2 <- predict(res, .benchmark = "lm")
pp2
## There is a plot method available
plot(pp2)}

### Example using OrdPLScPredict -----------------------------------------------
# Transform the numerical indicators into factors
\dontrun{
data("BergamiBagozzi2000")
data_new <- data.frame(cei1    = as.ordered(BergamiBagozzi2000$cei1),
                       cei2    = as.ordered(BergamiBagozzi2000$cei2),
                       cei3    = as.ordered(BergamiBagozzi2000$cei3),
                       cei4    = as.ordered(BergamiBagozzi2000$cei4),
                       cei5    = as.ordered(BergamiBagozzi2000$cei5),
                       cei6    = as.ordered(BergamiBagozzi2000$cei6),
                       cei7    = as.ordered(BergamiBagozzi2000$cei7),
                       cei8    = as.ordered(BergamiBagozzi2000$cei8),
                       ma1     = as.ordered(BergamiBagozzi2000$ma1),
                       ma2     = as.ordered(BergamiBagozzi2000$ma2),
                       ma3     = as.ordered(BergamiBagozzi2000$ma3),
                       ma4     = as.ordered(BergamiBagozzi2000$ma4),
                       ma5     = as.ordered(BergamiBagozzi2000$ma5),
                       ma6     = as.ordered(BergamiBagozzi2000$ma6),
                       orgcmt1 = as.ordered(BergamiBagozzi2000$orgcmt1),
                       orgcmt2 = as.ordered(BergamiBagozzi2000$orgcmt2),
                       orgcmt3 = as.ordered(BergamiBagozzi2000$orgcmt3),
                       orgcmt5 = as.ordered(BergamiBagozzi2000$orgcmt5),
                       orgcmt6 = as.ordered(BergamiBagozzi2000$orgcmt6),
                       orgcmt7 = as.ordered(BergamiBagozzi2000$orgcmt7),
                       orgcmt8 = as.ordered(BergamiBagozzi2000$orgcmt8))

model <- "
# Measurement models
OrgPres =~ cei1 + cei2 + cei3 + cei4 + cei5 + cei6 + cei7 + cei8
OrgIden =~ ma1 + ma2 + ma3 + ma4 + ma5 + ma6
AffJoy  =~ orgcmt1 + orgcmt2 + orgcmt3 + orgcmt7
AffLove =~ orgcmt5 + orgcmt 6 + orgcmt8

# Structural model
OrgIden ~ OrgPres
AffLove ~ OrgIden
AffJoy  ~ OrgIden 
"
# Estimate using cSEM; note: the fact that indicators are factors triggers OrdPLSc
res <- csem(.model = model, .data = data_new[1:250,])
summarize(res)

# Predict using OrdPLSPredict
set.seed(123)
pred <- predict(
  .object = res, 
  .benchmark = "PLS-PM",
  .test_data = data_new[(251):305,],
   .treat_as_continuous = TRUE, .approach_score_target = "median"
  )

pred 
round(pred$Prediction_metrics[, -1], 4)}
}
\references{
\insertAllCited{}
}
\seealso{
\link{csem}, \link{cSEMResults}, \code{\link[=exportToExcel]{exportToExcel()}}
}
