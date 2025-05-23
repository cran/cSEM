#' Internal: Calculate the inner weights for PLS-PM
#'
#' PLS-PM forms "inner" composites as a weighted sum of its *I* related composites.
#' These inner weights are obtained using one of the following schemes \insertCite{Lohmoeller1989}{cSEM}:
#' \describe{
#'   \item{`centroid`}{According to the centroid weighting scheme each inner weight used
#'     to form composite *j* is either 1 if the correlation between composite *j* and 
#'     its via the structural model related composite *i = 1, ..., I* is positive 
#'     and -1 if it is negative.}
#'   \item{`factorial`}{According to the factorial weighting scheme each inner weight used
#'     to form inner composite *j* is equal to the correlation between composite *j* 
#'     and its via the structural model related composite *i = 1, ..., I*.}
#'   \item{`path`}{Lets call all construct that have an arrow pointing to construct *j*
#'     **predecessors of j** and all arrows going from j to other constructs **followers of j**.
#'     According the path weighting scheme, inner weights are computed as follows.
#'     Take construct *j*: 
#'     \itemize{
#'       \item For all predecessors of *j* set the inner weight of predecessor 
#'             *i* to the correlation of *i* with *j*.
#'       \item For all followers of *j* set the inner weight of follower *i* to 
#'             the coefficient of a multiple regression of *j* on all 
#'             followers *i* with *i = 1,...,I*.
#'    }}
#' }
#' Except for the path weighting scheme relatedness can come in two flavors.
#' If `.PLS_ignore_structural_model = TRUE` all constructs are considered related.
#' If `.PLS_ignore_structural_model = FALSE` (the default) only adjacent constructs
#' are considered. If `.PLS_ignore_structural_model = TRUE` and `.PLS_weight_scheme_inner = "path"`
#' a warning is issued and `.PLS_ignore_structural_model` is changed to `FALSE`.
#' 
#' @usage calculateInnerWeightsPLS(
#'   .S                           = args_default()$.S,
#'   .W                           = args_default()$.W,
#'   .csem_model                  = args_default()$.csem_model,
#'   .PLS_ignore_structural_model = args_default()$.PLS_ignore_structrual_model,
#'   .PLS_weight_scheme_inner     = args_default()$.PLS_weight_scheme_inner
#' )
#' @inheritParams csem_arguments
#'
#' @return The (J x J) matrix `E` of inner weights.
#' @keywords internal

calculateInnerWeightsPLS <- function(
  .S                           = args_default()$.S,
  .W                           = args_default()$.W,
  .csem_model                  = args_default()$.csem_model,
  .PLS_ignore_structural_model = args_default()$.PLS_ignore_structrual_model,
  .PLS_weight_scheme_inner     = args_default()$.PLS_weight_scheme_inner
) {
  
  # Composite correlation matrix (C = V(H))
  C <- .W %*% .S %*% t(.W)
  
  # Due to floting point errors may not be symmetric anymore. In order
  # prevent that replace the lower triangular elements by the upper
  # triangular elements
  
  C[lower.tri(C)] <- t(C)[lower.tri(C)]
  
  # Structural model relationship; if only correlations are specified
  # use these
  tmp <- rownames(.csem_model$structural)
  if(sum(rowSums(.csem_model$structural)) == 0) {
    if(.PLS_weight_scheme_inner == "path") {
      stop2("Structural model is required for the PLS path weighting scheme.\n",
            "Please change the inner weighting scheme or supply a path model.")
    }
    D <- .csem_model$cor_specified[tmp, tmp]
  } else {
    E <- .csem_model$structural[tmp, tmp]
    D <- E + t(E)
  }
  
  # Note: June 2019
  if(any(D == 2)) { # non recursive model
    # Set elements back to 1 
    D[D == 2] <- 1 
  }
  
  ## (Inner) weighting scheme:
  if(.PLS_weight_scheme_inner == "path" & .PLS_ignore_structural_model) {
    .PLS_ignore_structural_model <- FALSE
    warning("Structural model is required for the path weighting scheme.\n",
            ".PLS_ignore_structural_model = TRUE was changed to FALSE.", 
            call. = FALSE)
  }
  
  if(.PLS_ignore_structural_model) {
    switch (.PLS_weight_scheme_inner,
            "centroid"  = {E <- sign(C) - diag(1, nrow = nrow(.W))},
            "factorial" = {E <- C - diag(1, nrow = nrow(.W))}
    )
  } else {
    switch (.PLS_weight_scheme_inner,
            "centroid"  = {E <- sign(C) * D},
            "factorial" = {E <- C * D},
            "path"      = {
              ## All construct that have an arrow pointing to construct j
              ## are called predecessors of j; all arrows going from j to other
              ## constructs are called followers of j
              
              ## Path weighting scheme:
              ## Take construct j:
              #  - For all predecessors of j: set the inner weight of
              #    predecessor i to the correlation of i with j.
              #  - For all followers of j: set the inner weight of follower i
              #    to the coefficient of a multiple regression of j on
              #    all followers i with i = 1,...,I.
              
              E_temp <- E
              ## Assign predecessor relation
              E[t(E_temp) == 1] <- C[t(E_temp) == 1]
              
              ## Assign follower relation
              for(j in tmp) {
                
                followers <- E_temp[j, ] == 1
                
                if(sum(followers) > 0) {
                  
                  E[j, followers] <-  solve(C[followers, followers, drop = FALSE]) %*%
                    C[j, followers]
                }
              }
            }
    )
  }
  
  return(E)
} # END calculateInnerWeights

#' Internal: Calculate the outer weights for PLS-PM
#'
#' Calculates outer weights in PLS-PM. Currently, the originally suggested mode A
#' and mode B are suggested. Additionally, non-negative least squares (modeBNNLS) and 
#' weights of principal component analysis (PCA) are implemented.  
#'
#' @usage calculateOuterWeightsPLS(
#'    .data   = args_default()$.data,  
#'    .S      = args_default()$.S,
#'    .W      = args_default()$.W,
#'    .E      = args_default()$.E,
#'    .modes  = args_default()$.modes
#'    )
#'
#' @inheritParams csem_arguments
#'
#' @return A (J x K) matrix of outer weights.
#' @keywords internal

calculateOuterWeightsPLS <- function(
  .data   = args_default()$.data,
  .S      = args_default()$.S,
  .W      = args_default()$.W,
  .E      = args_default()$.E,
  .modes  = args_default()$.modes
) {
  # Covariance/Correlation matrix between each proxy and all indicators (not
  # only the related ones). Note: Cov(H, X) = WS, since H = XW'.
  W <- .W
  proxy_indicator_cor <- .E %*% W %*% .S
  
  # Scale the inner proxy. Inner weights are usually scaled such that the inner
  # proxies are standardized (mean = 0, var = 1)
  inner_proxy <- scale(.data %*% t(W) %*% t(.E))
  colnames(inner_proxy) = rownames(W)
  
  # Compute outer weights by block/ construct
  for(i in 1:nrow(W)) {
    block      <- rownames(W[i, , drop = FALSE])
    indicators <- W[block, ] != 0
    
    if(is.numeric(.modes[[block]]) & length(.modes[[block]]) > 1) {
      if(length(.modes[[block]]) == sum(indicators)) {
        ## Fixed weights - Each weight of "block" is fixed to a user-given value
        W[block, indicators] <- .modes[[block]]
      } else {
        stop2("Construct ", paste0("`", block, "` has ", sum(indicators), 
                                   " indicators but only ",
                                  length(.modes[[block]]), " fixed weights are provided.")) 
      }
    } else if(.modes[block] == "modeA") {
      ## Mode A - Regression of each indicator on its corresponding proxy
      W[block, indicators] <- proxy_indicator_cor[block, indicators]
      
    } else if(.modes[block] == "modeB") {
      ## Mode B - Regression of each proxy on all its indicator
      # W_j = S_jj^{-1} %*% Cov(eta_j, X_j)
      W[block, indicators] <- solve(.S[indicators, indicators]) %*% proxy_indicator_cor[block, indicators]
      
    } else if(.modes[block] == "modeBNNLS"){
      ## Mode BNNLS - Regression of each proxy on its indicators using non-negative LS
      # Note: .data is standardized, i.e., mean 0 and unit variance, inner proxy is also 
      #       standardized (standardization of the inner proxy 
      #       apparently has no effect though.)
      if (!requireNamespace("nnls", quietly = TRUE)) {
        stop2(
          "Package `nnls` needed for \"modeBNNLS\" to work. Use `install.packages(\"nnls\")` and rerun.")
      }
      temp <- nnls::nnls(A = .data[, indicators, drop = FALSE], b = inner_proxy[,block])
      W[block, indicators] <- temp$x
    
    } else if(.modes[block] == "PCA"){
      ## PCA - Weights to create the first principal component are used  (= the first eigenvector of
      ##       of S_jj).
      temp <- psych::principal(r = .S[indicators, indicators], nfactors = 1)
      W[block, indicators] <- c(temp$weights)
      
    } 
    # Set weights of single-indicator constructs to 1 (in order to avoid floating
    # point imprecision)
    if(sum(indicators) == 1){
      W[block, indicators] <- 1 
    } 
    
    # If .modes[block] == "unit" or a single value has been given, nothing needs
    # to happen since W[block, indicators] would be set to 1 (which it already is). 
  }
  return(W)
} # END calculateOuterWeights

#' Internal: Check convergence
#'
#' Check convergence of an algorithm using one of the following criteria:
#' \describe{
#'   \item{`diff_absolute`}{Checks if the largest elementwise absolute difference
#'                          between two matrices `.W_new` and `W.old` is 
#'                          smaller than a given tolerance.}
#'   \item{`diff_squared`}{Checks if the largest elementwise squared difference
#'                         between two matrices `.W_new` and `W.old` is 
#'                         smaller than a given tolerance.}
#'   \item{`diff_relative`}{Checks if the largest elementwise absolute rate of change
#'                          (new - old / new) for two matrices `.W_new` 
#'                          and `W.old` is smaller than a given tolerance.}
#' }
#'
#' @usage checkConvergence(
#'   .W_new          = args_default()$.W_new,
#'   .W_old          = args_default()$.W_old,
#'   .conv_criterion = args_default()$.conv_criterion,
#'   .tolerance      = args_default()$.tolerance
#'   )
#'
#' @inheritParams csem_arguments
#' 
#' @return `TRUE` if converged; `FALSE` otherwise.
#' @keywords internal

checkConvergence <- function(
  .W_new          = args_default()$.W_new,
  .W_old          = args_default()$.W_old,
  .conv_criterion = args_default()$.conv_criterion,
  .tolerance      = args_default()$.tolerance
  ){
  ## Check if correct value is provided:
  match.arg(.conv_criterion, args_default(.choices = TRUE)$.conv_criterion)
  
  switch (.conv_criterion,
    "diff_absolute" = {
      max(abs(.W_old - .W_new)) < .tolerance
    },
    "diff_squared"  = {
      max((.W_old - .W_new)^2) < .tolerance
    },
    "diff_relative" = {
      max(abs((.W_old[.W_new != 0] - .W_new[.W_new != 0]) /
                .W_new[.W_new != 0])) < .tolerance
    }
  )
}

#' Internal: Scale weights
#'
#' Scale weights such that the formed composite has unit variance.
#'
#' @usage scaleWeights(
#'   .S = args_default()$.S, 
#'   .W = args_default()$.W
#'   )
#'
#' @inheritParams csem_arguments
#'
#' @return The (J x K) matrix of scaled weights.
#' @keywords internal

scaleWeights <- function(
  .S = args_default()$.S, 
  .W = args_default()$.W
  ) {
  
  ## Calculate the variance of the proxies:
  var_proxies <- diag(.W %*% .S %*% t(.W))
  
  # Using the solve function is suboptimal as if one of the proxies' variances
  # is closed to 0, matrix inversion might not work. 
  # W_scaled <- solve(diag(sqrt(var_proxies), 
                         # nrow = length(var_proxies),
                         # ncol = length(var_proxies)
                         # )) %*% .W
  
  ## Scale the weights to ensure that the proxies have a variance of one  
  W_scaled <- diag(1/sqrt(var_proxies)) %*%.W
  
  ## Assign rownames and colnames to the scaled weights and return
  rownames(W_scaled) <- rownames(.W)
  colnames(W_scaled) <- colnames(.W)
  
  return(W_scaled)
}

#' Internal: Set starting values
#'
#' Set the starting values.
#'
#' @usage setStartingValues(
#'   .W               = args_default()$.W,
#'   .starting_values = args_default()$.starting_values
#'   )
#'
#' @inheritParams csem_arguments
#'
#' @return The (J x K) matrix of starting values.
#' @keywords internal

setStartingValues = function(.W = args_default()$.W,
                             .starting_values = args_default()$.starting_values){

  if(!is.list(.starting_values)){
    stop2(
      "The following error occured in the `setStartingValues()` function:\n",
      "Starting values must be as a list."
      )
  }
  
  tmp <- setdiff(names(.starting_values), rownames(.W))
  
  if(length(tmp) != 0) {
    stop2(
      "The following error occured in the `setStartingValues()` function:\n",
      "Construct name(s): ", paste0("`", tmp, "`", collapse = ", "), 
      " provided to `.starting_values`", 
      ifelse(length(tmp) == 1, " is", " are"), " unknown.")
  }
  
  # Replace the original ones by the starting value
  for(i in names(.starting_values)) {
    ## Error if starting values for construct i have not been names
    if(is.null(names(.starting_values[[i]]))) {
      stop2(
        "The following error occured in the `setStartingValues()` function:\n",
        "Starting weights must be named."
        )
    }
    # tmp <- setdiff(names(.starting_values[[i]]), colnames(W[i,,drop=FALSE]))
    tmp <- setdiff(names(.starting_values[[i]]), colnames(.W[i,.W[i,]!=0,drop = FALSE]))
    
    
    if(length(tmp) != 0) {
      stop2(
        "The following error occured in the `setStartingValues()` function:\n",
        "Indicator name(s): ", paste0("`", tmp, "`", collapse = ", "), 
        " provided to `.starting_values`", 
        ifelse(length(tmp) == 1, " is", " are"), " unknown.")
    }
    
    .W[i,names(.starting_values[[i]])] = .starting_values[[i]]
    
  }
  
  return(.W)
}

