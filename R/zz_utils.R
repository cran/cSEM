#' Internal: Classify structural model terms by type
#'
#' Classify terms of the structural model according to their type.
#'
#' Classification is required to estimate nonlinear structural relationships.
#' Currently the following terms are supported
#' \itemize{
#' \item Single, e.g., `eta1`
#' \item Quadratic, e.g., `eta1.eta1`
#' \item Cubic, e.g., `eta1.eta1.eta1`
#' \item Two-way interaction, e.g., `eta1.eta2`
#' \item Three-way interaction, e.g., `eta1.eta2.eta3`
#' \item Quadratic and two-way interaction, e.g., `eta1.eta1.eta3`
#' }
#' Note that exponential terms are modeled as "interactions with itself"
#' as in i.e., `eta1^3 = eta1.eta1.eta1`.
#'
#' @usage classifyConstructs(.terms = args_default()$.terms)
#'
#' @inheritParams csem_arguments
#'
#' @return A named list of length equal to the number of terms provided containing
#'   a data frame with columns "*Term_class*", "*Component*",
#'   "*Component_type*", and "*Component_freq*".
#' @keywords internal

classifyConstructs <- function(.terms = args_default()$.terms) {
  ## Split term
  terms_split <- strsplit(.terms, "\\.")
  
  ## Count instances of each construct name (used for classifying)
  terms_classified <- lapply(terms_split, function(.x) {
    x <- .x %>%
      table(.) %>%
      as.data.frame(., stringsAsFactors = FALSE)
    
    ## To save typing
    a <- sum(x$Freq)
    b <- length(unique(x$.))
    
    ## Do the actual classification --------------------------------------------
    
    if(a > 3) {
      stop("The nonlinear term(s): ", paste0("`", .terms, "`", collapse = ", "), 
           ifelse(length(.terms == 1), " is", " are"), " currently not supported.\n",
           "Please see ?classifyConstructs for a list of supported terms.",
           call. = FALSE)
    } else {
      switch(a,
             "1" = {
               x <- data.frame("Term_class"     = "Single",
                               "Component"      = x$.,
                               "Component_type" = "Single",
                               "Component_freq" = x$Freq,
                               stringsAsFactors = FALSE)
             },
             "2" = {
               if(b == 1) {
                 x <- data.frame("Term_class"     = "Quadratic",
                                 "Component"      = x$.,
                                 "Component_type" = "Quadratic",
                                 "Component_freq" = x$Freq,
                                 stringsAsFactors = FALSE)
               } else if (b == 2){
                 x <- data.frame("Term_class"     = "TwInter",
                                 "Component"      = x$.,
                                 "Component_type" = c("Single", "Single"),
                                 "Component_freq" = x$Freq,
                                 stringsAsFactors = FALSE)
               }
             },
             "3" = {
               if(b == 1) {
                 x <- data.frame("Term_class"     = "Cubic",
                                 "Component"      = x$.,
                                 "Component_type" = "Cubic",
                                 "Component_freq" = x$Freq,
                                 stringsAsFactors = FALSE)
               } else if (b == 2) {
                 x <- data.frame("Term_class"     = "QuadTwInter",
                                 "Component"      = x$.,
                                 "Component_type" =
                                   ifelse(x$Freq == 1, "Single", "Quadratic"),
                                 "Component_freq" = x$Freq,
                                 stringsAsFactors = FALSE)
               } else if (b == 3) {
                 
                 x <- data.frame("Term_class"     = "ThrwInter",
                                 "Component"      = x$.,
                                 "Component_type" =
                                   c("Single", "Single", "Single"),
                                 "Component_freq" = x$Freq,
                                 stringsAsFactors = FALSE)
               }
             }
      ) # END switch
    } # END else
  }) # END lapply
  
  names(terms_classified) <- unlist(.terms)
  terms_classified
}

#' Wrapper around cat() with sep = ""
#' @noRd
#' 
cat2 <- function(...) {
  cat(..., sep = "")
}

#' Wrapper around stop() with .call = FALSE
#' @noRd
#' 
stop2 <- function(...) {
  stop(..., call. = FALSE)
}

#' Wrapper around warning() with .call = FALSE and .immediate = TRUE
#' @noRd
#' 
warning2 <- function(...) {
  warning(..., call.= FALSE, immediate. = TRUE)
}

#' A rule of with 80 
#' @noRd
#' 
rule2 <- function(x = "", type = 1, align = "center") {
  # type1 : "-"
  # type2 : "_"
  # type3 : "="
  nt <- nchar(x)
  
  if(nt == 0) {
    return(makeLine(type = type, width = 80))
  } else if(nt != 0 & (nt %% 2) == 0) { # number is not zero and even
    width1 <- width2 <- (80 - nt) / 2
  } else { # number is not zero and odd
    width1 <- ceiling((80 - nt) / 2)
    width2 <- width1 - 1
  }
  
  if(align == "center") {
    paste0(
      # The "-1" is for the " " characters
      makeLine(type = type, width = width1 - 1),
      paste0(" ", x, " "),
      makeLine(type = type, width = width2 - 1)
    )
  } else if(align == "right") {
    paste0(makeLine(type = type, width = 2*width1 - 1), " ", x)
  } else if(align == "left") {
    paste0(x, " ", makeLine(type = type, width = 2*width1 - 1))
  } else {
    stop2("`align` must be one of 'center', 'right', or 'left'.")
  } 
}

#' A rule of with 80 
#' @noRd
#' 
makeLine <- function(type = 1, width) {
  x <- switch(type,
              "1" = "-",
              "2" = "_",
              "3" = "=")
  
  paste(rep(x,  width), collapse = "")
}
