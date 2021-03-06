#' Internal: Helper for doNonlinearEffectsAnalysis()
#'
#' Function that calculates the values required for the floodlight analysis, 
#' namely 1) partial effect of the independent variable on the dependent variable 
#' for each bootstrap run and for the original estimation for each step of the moderator
#' 2) alpha/2 and 1-alpha/2 quantile of the bootstrap estimates.
#'
#' Only variables that comprise the independent variable are taken into account.
#' If it contains a variable other than the independent variable and the moderator
#' the effect is set to zero as the other variables are evaluated at their means (=0),
#' hence the effect is zero. 
#' 
#' @inheritParams csem_arguments
#'   
#' @keywords internal

getValuesFloodlight <- function(
  .model             = NULL,
  .path_coefficients = args_default()$.path_coefficients,
  .dependent         = args_default()$.dependent,
  .independent       = args_default()$.independent,
  .moderator         = args_default()$.moderator,
  .steps_mod         = args_default()$.steps_mod,
  .value_independent = args_default()$.value_independent,
  .alpha             = args_default()$.alpha
  ){
  
  # Find variables that include the independent variable (IV)
  all_IV_names <- names(.model$structural[.dependent, .model$structural[.dependent, ] != 0])
  
  # Split IVs at the dot
  splitIV <- strsplit(x = all_IV_names, split = '\\.')
  
  # Check which contain the independent variable
  IVselect<-sapply(splitIV,function(x){
    .independent %in% x
  })
  
  splitIVrel <- splitIV[IVselect]  
  
  # check whether it contains a variable different than 
  # the independent and the moderator
  IVselect1 <- sapply(splitIVrel, function(x) {
    all(x %in% c(.independent, .moderator))
  })
  
  # terms that contain only the independent and the moderator variable
  relevant_terms <- splitIVrel[IVselect1]

  # lapply over the steps of the moderator
  out <- lapply(.steps_mod, function(step){
   # lapply over the various terms of the equation of the dependent variable
    effect_per_term <- lapply(relevant_terms,function(x){
      
      # count the number of independent variables contained by the term
      countIV = matrixStats::count(x = x, value = .independent)
      countMed = matrixStats::count(x = x, value = .moderator)
      
      # build terms
      term <- paste0(.dependent, ' ~ ', paste0(x, collapse = '.'))
      
      # calculate the effects for the resampled effects and the original effect
      effect_resampled <- .path_coefficients$Resampled[, term] *
        countIV * .value_independent ^ (countIV - 1) *
        step ^ countMed
      
      # calculate the original effect
      effect_original <- .path_coefficients$Original[term] *
        countIV * .value_independent ^ (countIV - 1) *
        step ^ countMed
      
      list(effect_resampled = effect_resampled,
           effect_original = effect_original)
    })
    temp <- purrr::transpose(effect_per_term)
    bootstrapEffects <- Reduce('+', temp$effect_resampled)
    # calculate the upper and lower bound of the bootstrap runs per step
    bounds <- quantile(bootstrapEffects , c(.alpha / 2, 1 - .alpha / 2))
    # calculate the original effect per step
    original_effect <- Reduce('+', temp$effect_original)
    c(original_effect, step, bounds[1], bounds[2])
  })
  
  floodout <- do.call(rbind,out)
  colnames(floodout) <- c('direct_effect', 'value_z', 'lb', 'ub')
  return(floodout)
}
