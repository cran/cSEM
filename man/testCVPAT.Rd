% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/postestimate_test_CVPAT.R
\name{testCVPAT}
\alias{testCVPAT}
\title{Perform a Cross-Validated Predictive Ability Test (CVPAT)}
\usage{
testCVPAT(
.object1              = NULL,
.object2              = NULL,
.approach_predict     = c("earliest", "direct"),
.seed                 = NULL,
.cv_folds             = 10,
.handle_inadmissibles = c("stop", "ignore"),
.testtype             = c("twosided", "onesided"))
}
\arguments{
\item{.object1}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}

\item{.object2}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}

\item{.approach_predict}{Character string. Which approach should be used to
predictions? One of "\emph{earliest}" and "\emph{direct}". If "\emph{earliest}" predictions
for indicators associated to endogenous constructs are performed using only
indicators associated to exogenous constructs. If "\emph{direct}", predictions for
indicators associated to endogenous constructs are based on indicators associated
to their direct antecedents. Defaults to "\emph{earliest}".}

\item{.seed}{Integer or \code{NULL}. The random seed to use. Defaults to \code{NULL} in which
case an arbitrary seed is chosen. Note that the scope of the seed is limited
to the body of the function it is used in. Hence, the global seed will
not be altered!}

\item{.cv_folds}{Integer. The number of cross-validation folds to use. Setting
\code{.cv_folds} to \code{N} (the number of observations) produces
leave-one-out cross-validation samples. Defaults to \code{10}.}

\item{.handle_inadmissibles}{Character string. How should inadmissible results
be treated? One of "\emph{drop}", "\emph{ignore}", or "\emph{replace}". If "\emph{drop}", all
replications/resamples yielding an inadmissible result will be dropped
(i.e. the number of results returned will potentially be less than \code{.R}).
For "\emph{ignore}" all results are returned even if all or some of the replications
yielded inadmissible results (i.e. number of results returned is equal to \code{.R}).
For "\emph{replace}" resampling continues until there are exactly \code{.R} admissible solutions.
Depending on the frequency of inadmissible solutions this may significantly increase
computing time. Defaults to "\emph{drop}".}

\item{.testtype}{Character string. One of "\emph{twosided}" (H1: The models do not
perform equally in predicting indicators belonging to endogenous constructs)"
and \emph{onesided}" (H1: Model 1 performs better in predicting indicators belonging
to endogenous constructs than model2). Defaults to "\emph{twosided}".}
}
\value{
An object of class \code{cSEMCVPAT} with print and plot methods.
Technically, \code{cSEMCVPAT} is a
named list containing the following list elements:

\describe{
\item{'$Information'}{Additional information.}
}
}
\description{
\lifecycle{maturing}
}
\details{
Perform a Cross-Validated Predictive Ability Test (CVPAT) as described in
\insertCite{Liengaard2020}{cSEM}. The predictive performance of two models
based on the same dataset is compared. In doing so, the average difference in
losses in predictions is compared for both models.
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
