#' Internal: Estimate the structural coefficients
#'
#' Estimates the coefficients of the structural model (nonlinear and linear) using
#' OLS, 2SLS. The latter currently work for linear models only.
#'
#' @usage estimatePath(
#'  .approach_nl      = args_default()$.approach_nl,
#'  .approach_paths   = args_default()$.approach_paths,
#'  .csem_model       = args_default()$.csem_model,
#'  .H                = args_default()$.H,
#'  .normality        = args_default()$.normality,
#'  .P                = args_default()$.P,
#'  .Q                = args_default()$.Q
#'  )
#'   
#' @inheritParams csem_arguments
#'
#' @return A named list containing the estimated structural coefficients, the
#'   R2, the adjusted R2, and the VIFs for each regression.
#'
#' @keywords internal

estimatePath <- function(
  .approach_nl      = args_default()$.approach_nl,
  .approach_paths   = args_default()$.approach_paths,
  .csem_model       = args_default()$.csem_model,
  .H                = args_default()$.H,
  .normality        = args_default()$.normality,
  .P                = args_default()$.P,
  .Q                = args_default()$.Q
  ) {
  
  ## Check approach_path argument:
  if(!any(.approach_paths %in% c("OLS", "2SLS"))) {
    stop2("The following error occured in the `estimatePath()` function:\n",
          paste0("'", .approach_paths, "'"), 
          " is an unknown approach to estimate the path model.")
  }
  
  ## Warning if instruments are given but .approach_paths = "OLS"
  if(!is.null(.csem_model$instruments) & .approach_paths == "OLS") {
    warning2("The following warning occured in the `estimatePath()` function:\n",
      "Instruments supplied but .approach_path = 'OLS'.\n",
      "Instruments are ignored.", 
      " Consider setting `.approach_paths = '2SLS'.")
  }
  
  ## Error if no instruments are given but .approach_paths = "2SLS" or "3SLS"
  if(is.null(.csem_model$instruments) & (.approach_paths %in% c("2SLS", "3SLS"))) {
    stop2("The following error occured in the `estimatePath()` function:\n",
    .approach_paths, " requires instruments.")
  }
  
  m         <- .csem_model$structural
  dep_vars  <- rownames(m)[rowSums(m) != 0] # dependent (LHS variables)
  vars_exo  <- setdiff(colnames(m), dep_vars)
  explained_by_exo_endo <- dep_vars[rowSums(m[dep_vars, dep_vars, drop = FALSE]) != 0]
  vars_ex_by_exo <- setdiff(dep_vars, explained_by_exo_endo)
  vars_explana   <- colnames(m)[colSums(m) != 0]

  # Number of observations (required for the adjusted R^2)
  n <- dim(.H)[1]
  
  if(.csem_model$model_type == "Linear") {

    res <- lapply(dep_vars, function(y) {
      # Which of the variables in dep_vars have instruments specified, i.e.,
      # have endogenous variables on the RHS. By default: FALSE.
      endo_in_RHS <- FALSE
      
      if(!is.null(.csem_model$instruments)) {
        endo_in_RHS <- y %in% names(.csem_model$instruments)
      }
      
      ## Independent variables of the structural equation of construct y
      names_X <-  colnames(m[y, m[y, ] != 0, drop = FALSE])
      
      # Compute "OLS" if endo_in_RHS is FALSE, i.e., no instruments are 
      # given for this particular equation or .approach_paths is "OLS"
      if(!endo_in_RHS | .approach_paths == "OLS") {
        
        # Coef = (X'X)^-1X'y = V(eta_indep)^-1 Cov(eta_indep, eta_dep)
        coef <- solve(.P[names_X, names_X, drop = FALSE]) %*% 
          .P[names_X, y, drop = FALSE]
        
        # Since Var(y) = 1 we have R2 = Var(y_hat) = Var(X*coef) = t(coef) %*% E(X'X) %*% coef
        r2   <- c(t(coef) %*% .P[names_X, names_X, drop = FALSE] %*% coef)
        # names(r2) <- y
        
        # Calculation of the adjusted R^2
        # We calculate it as: R^2_adj = 
        r2adj <- c(1 - (1 - r2)*(n - 1)/(n - length(names_X)-1))
        # names(r2adj) <- y
        
        # Calculation of the VIF values (VIF_k = 1 / (1 - R^2_k)) where R_k is
        # the R^2 from a regression of the k'th explanatory variable on all other
        # explanatory variables of the same structural equation.
        # VIF's require at least two explanatory variables to be meaningful
        vif <- if(length(names_X) > 1) {
          diag(solve(cov2cor(.P[names_X, names_X, drop = FALSE])))
        } else {
          NA
        } 
      } # END OLS
      
      
      # Compute "2SLS" if endo_in_RHS is TRUE, i.e instruments are 
      # given for this particular equation and .approach_paths is "2SLS" or "3SLS".
      
      ## Two stage least squares (2SLS) and three stage least squares (3SLS)
      if(endo_in_RHS & (.approach_paths == "2SLS" | .approach_paths == "3SLS")) {
        
        ## First stage
        # Note: Regress the P endogenous variables (X) on the L instruments 
        #       and the K exogenous independent variables (which must be part of Z).
        #       Therefore: X (N x P) and Z (N x (L + K)) and
        #       beta_1st = (Z'Z)^-1*(Z'X)
        names_endo <- rownames(.csem_model$instruments[[y]])
        names_Z    <- colnames(.csem_model$instruments[[y]])
        
        ## Error if the number of instruments (including the K exogenous variables)
        ## is less than the number of independent variables in the original 
        ## structural equation for construct "y"
        if(length(names_Z) < length(names_X)) {
          stop2("The following error occured in the `estimatePath()` function:\n",
                "The number of instruments for the structural equation of construct ",
                paste0("'", y, "'"), " is less than the number of independent ",
                "variables.\n", "Make sure all exogenous variables correctly ",
                " supplied as instruments to `.instruments`.")
        }
        
        # Assuming that .P (the construct correlation matrix) also contains 
        # the instruments (ensured if only internal instruments are allowed)
        # we can use .P.
        
        # Multivariate regression is conducted, i.e., all independent variables of an equation 
        # including the endogenous variables are regressed on the instruments
        
        beta_1st <- solve(.P[names_Z, names_Z, drop = FALSE], 
                          .P[names_Z, names_X, drop = FALSE])
        
        ## Second stage
        # Note: X_hat = beta_1st*Z --> X_hat'X_hat = beta_1st' (Z'Z) beta_1st
        
        coef <- solve(t(beta_1st) %*% .P[names_Z, names_Z, drop = FALSE] %*% beta_1st, 
                      t(beta_1st) %*% .P[names_Z, y, drop = FALSE])
        
        
        # Although the r^2 can be calculated in case of 2SLS,
        # the r^2 and all corresponding statistics are not correct. 
        # Hence, I suggest to overwrite it with NA. This might help to detect potential problems.
        # 
        r2    = NA
        r2adj = NA
        
        # The VIF should be based on the second-stage equation 
        vif <- if(length(names_Z) > 1) {
          diag(solve(cov2cor(.P[names_Z, names_Z, drop = FALSE])))
        } else {
          NA
        }
      } # END 2SLS
      
      ## Collect results
      list("coef" = coef, "r2" = r2, "r2adj" = r2adj, "vif" = vif)
    }) # END lapply
    
    names(res) <- dep_vars
    res <- purrr::transpose(res)

  } else {
    ## Error if approach_paths is not "OLS"
    # Note (05/2019): Currently, only "OLS" is allowed for nonlinear models
    if(.approach_paths != "OLS") {
      stop2("The following error occured in the `estimatePath()` function:\n",
           "Currently, ", .approach_paths, " is only applicable to linear models.")
    }
    
    ### Preparation ============================================================
    # Implementation and notation is based on:
    # Dijkstra & Schermelleh-Engel (2014) - PLSc for nonlinear structural
    #                                       equation models
    
    ### Calculation ============================================================
    ## Calculate elements of the VCV matrix of the explanatory variables -------
    if(.normality == TRUE) {
      # For the sequential approach normality = TRUE requires all 
      # explanatory variables to be exogenous!
      if(length(setdiff(vars_explana, vars_exo)) != 0 & .approach_nl == "sequential") {
        
        stop("The following error was encountered while calculating the path coefficients:\n",
             "The sequential approach can only be used in conjunction with `normality = TRUE`", 
             " if all explanatory variables are exogenous.", call. = FALSE)
      } else {
        vcv_explana <- outer(vars_explana,
                             vars_explana,
                             FUN = Vectorize(f3, vectorize.args = c(".i", ".j")),
                             .Q  = .Q,
                             .H  = .H)
      }

      # It can happen that this matrix is not symmetric
      vcv_explana[lower.tri(vcv_explana)] = t(vcv_explana)[lower.tri(vcv_explana)]
      
    } else {
      
      # Define the type/class of the moments in the VCV matrix of the explanatory
      # variables 
      class_explana <- outer(vars_explana, vars_explana, FUN = Vectorize(f1))
      rownames(class_explana) <- colnames(class_explana) <- vars_explana
      
      # Calculate
      vcv_explana <- outer(vars_explana,
                           vars_explana,
                           FUN = Vectorize(f2, vectorize.args = c(".i", ".j")),
                           .select_from = class_explana,
                           .Q = .Q,
                           .H = .H)
    
      # It can happen that this matrix is not symmetric
      vcv_explana[lower.tri(vcv_explana)] = t(vcv_explana)[lower.tri(vcv_explana)]
      
      }  #Outcome: The VCV of the explanatory variables
    
    # Set row- and colnames for matrix
    rownames(vcv_explana) <- colnames(vcv_explana) <- vars_explana
    
    # Create list with each list element holding the VCV matrix of the
    # explanatory variables of one endogenous variable
    vcv_explana_ls <- lapply(dep_vars, function(x) {
      res <- colnames(m[x, m[x, , drop = FALSE] == 1, drop = FALSE])
      vcv_explana[res, res, drop = FALSE]
    })
    names(vcv_explana_ls) <- dep_vars
    
    ## Check if all vcv matrices are semi positive-definite and warn if not
    semidef <- lapply(vcv_explana_ls, function(x) {
      matrixcalc::is.positive.semi.definite(x)
    })
    
    if(any(!unlist(semidef))) {
      warning("The following issue was encountered while calculating the path coefficients:\n",
              "The variance-covariance matrix of the explanatory variables for ",
              "at least one of the structural equations is not positive semi-definite.",
              call. = FALSE, immediate. = TRUE)
    }
    ## Calculate covariances between explanatory and endogenous variables ------
    
    # Define the class of the moments in the VCV matrix between explanatory
    # and endogenous variables
    class_endo_explana <- outer(dep_vars, vars_explana, FUN = Vectorize(f1))
    rownames(class_endo_explana) <- dep_vars
    colnames(class_endo_explana) <- vars_explana
    
    # Calculate
    cv_endo_explana <- outer(dep_vars, vars_explana,
                             FUN = Vectorize(f2, vectorize.args = c(".i", ".j")),
                             .select_from = class_endo_explana,
                             .Q = .Q,
                             .H = .H)
    rownames(cv_endo_explana) <- dep_vars
    colnames(cv_endo_explana) <- vars_explana
    
    # Create list with each list element holding the covariances between one
    # endogenous variable and its corresponding explanatory variables
    cv_endo_explana_ls <- lapply(dep_vars, function(x) {
      res <- colnames(m[x, m[x, , drop = FALSE] == 1, drop = FALSE])
      cv_endo_explana[x, res, drop = FALSE]
    })
    names(cv_endo_explana_ls) <- dep_vars
    
    ## Calculate path coef, R2, VIF, and SEs ----------------------------------------------
    # Path coefficients
    coef <- mapply(function(x, y) solve(x) %*% t(y),
                   x = vcv_explana_ls,
                   y = cv_endo_explana_ls,
                   SIMPLIFY = FALSE)
    
    # Coefficient of determinaten (R^2)
    r2 <- mapply(function(x, y) t(y) %*% x %*% y,
                 x = vcv_explana_ls,
                 y = coef,
                 SIMPLIFY = FALSE)
    
    # Adjusted R^2 
    r2adj <- mapply(function(x,y) 1-(1-x)*(n-1)/(n-nrow(y)),
                   x = r2,
                   y = coef)
    
    # Variance inflation factor
    vif <- lapply(vcv_explana_ls, function(x) { 
      tryCatch(
        expr = {diag(solve(cov2cor(x)))},
        error = function(e) {
         NA 
        }
      )
      })
      

    # Calculation of closed-form standard errors
    # by default they are set to NA
      ses = lapply(coef,function(x){
        x[]=NA
        x
      }) 
    ##==========================================================================
    # Replacement approach
    ### ========================================================================
    if(.approach_nl == "replace") {
      # warning("Something is wrong here!")
      ### Preparation ==========================================================
      if(.normality == FALSE) {
        
        stop("The following error was encountered while calculating the path coefficients:\n",
             "The replacement approach is only implemented for `normality = TRUE`.",
             call. = FALSE)
      }
      # Create list with each list element holding one structural equation
      struc_coef_ls <- lapply(coef, function(x) {
        a <- c(x)
        names(a) <- rownames(x)
        a
      })
      
      # Add a "structural equation" for all exogenous constructs
      temp <- intersect(rownames(.csem_model$structural), vars_exo)
      
      if(length(temp) > 0 ) {
        
        struc_coef_ls <- lapply(temp, function(x) {
          struc_coef_ls[[x]] <- 1
          names(struc_coef_ls[[x]]) <- x
          struc_coef_ls
        })[[1]] # there is a problem here 
      }
      
      ### Calculation ==========================================================
      ## Calculate variance of the structural errors
      var_struc_error <- 1 - unlist(r2)
      
      ## Preallocate
      vcv  <- list()

      ## Loop over each endogenous variable
      for(k in dep_vars) {
        
        if(k %in% vars_ex_by_exo) {
          # If the endogenous variable is only explained by exogenous variables:
          # add an error term (zeta)
          
          struc_coef_ls[[k]][paste0("zeta_", k)] <- 1
          
        } else {
          # If the endogenous variable is explained by at least one other
          # endogenous variable the covariances between all explanatory variables
          # needs to be computed in order to compute path coefficients later on
          
          ## Preallocate
          temp <- list()
          explana_k <- names(struc_coef_ls[[k]])
          
          ## Loop over each explanatory variable of structural equation k
          for(m in explana_k) {
            
            # Split term
            a <- strsplit(m, "\\.")[[1]]
            
            # Insert corresponding equation for the first componenent of a
            temp[[m]] <- struc_coef_ls[[a[1]]]
            
            if(length(a) > 1) {
              
              ## Insert the (previously build) corresponding equation for each
              ## component of the splitted term
              for(l in 1:(length(a) - 1)) {
                
                rr             <- temp[[m]] %o% struc_coef_ls[[a[l + 1]]]
                rr_vec         <- c(rr)
                names(rr_vec)  <- c(outer(rownames(rr),
                                          colnames(rr),
                                          FUN = paste, sep = "."))
                
                temp[[m]] <- rr_vec
              } # END for l in 1:(length(a) - 1)
            } # END if
          } # END for m in explana_k
          
          ## Calculate vcv matrix of the explana variables ---------------------
          vcv[[k]] <- outer(explana_k, explana_k,
                            FUN = Vectorize(f4, vectorize.args = c(".i", ".j")),
                            .Q  = .Q,
                            .H  = .H,
                            .var_struc_error = var_struc_error,
                            .temp = temp)
          
          # Set row- and colnames for vcv matrix
          rownames(vcv[[k]]) <- colnames(vcv[[k]]) <- explana_k
          
          ## Calculate path coefs, R^2, adjusted R^2, VIF and update "struc_coef_ls" (= matrix of
          ## structural equations) and "var_struc_error" (= vector of
          ## structural error variances) ---------------------------------------
          
          coef[[k]]  <- solve(vcv[[k]]) %*% t(cv_endo_explana_ls[[k]])
          r2[[k]]    <- t(coef[[k]]) %*% vcv[[k]] %*% coef[[k]]
          r2adj[[k]] <- 1-(1-r2[[k]])*(n-1)/(n-nrow(coef[[k]]))
          vif[[k]]   <-       tryCatch(
            expr  = {diag(solve(cov2cor(vcv[[k]])))},
            error = function(e) {
              NA 
            }
          )
          var_struc_error[k]    <- 1 - r2[[k]]
          # ses[[k]] = NULL
          
          temp <- mapply(function(x, y) x * y,
                         x = temp,
                         y = coef[[k]],
                         SIMPLIFY = FALSE)
          
          struc_coef_ls[[k]]        <- unlist(temp)
          names(struc_coef_ls[[k]]) <- unlist(lapply(temp, names), use.names = FALSE)
          struc_coef_ls[[k]][paste0("zeta_", k)] <- 1
          
        } # END else
      } # END for k in dep_vars
    } # END if(.approach_nl = replace)
    res <- list("coef" = coef, "r2" = r2, "r2adj" = r2adj, "vif" = vif)
  } # END if nonlinear
  ### Structure results --------------------------------------------------------
  tm <- t(.csem_model$structural)
  tm[which(tm == 1)] <- do.call(rbind, res$coef)
  
  ## Delete VIF's that are set to NA
  res$vif <- Filter(Negate(anyNA), res$vif)
  
  ## Return result -------------------------------------------------------------
  list("Path_estimates" = t(tm), "R2" = unlist(res$r2),"R2adj" = unlist(res$r2adj), "VIF" = res$vif)
}