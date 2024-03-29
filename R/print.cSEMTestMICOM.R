#' `cSEMTestMICOM` method for `print()`
#'
#' The `cSEMTestMICOM` method for the generic function [print()]. 
#'
#' @inheritParams csem_arguments
#'
#' @seealso [csem()], [cSEMResults], [testMICOM()]
#'
#' @export
#' @keywords internal
print.cSEMTestMICOM <- function(x, ...) {
  
  cat2(
    rule2(type = 2), "\n",
    rule2("Test for measurement invariance based on Henseler et al (2016)"),
    "\n"
  )
  
  x2 <- x$Step2
  x3 <- x$Step3
  
  construct_names <- names(x2$Test_statistic[[1]])
  no_groups       <- length(x2$Test_statistic)
  l_names <- max(nchar(c("Construct", construct_names)))
  
  ### Step 1 ===================================================================
  cat2(
    rule2("Step 1 - Configural invariance", type = 3), "\n\n",
    "\tConfigural invariance is a precondition for step 2 and 3.\n",
    "\tDo not proceed to interpret results unless\n",
    "\tconfigural invariance has been established.\n\n"
  )
  ### Step 2 ===================================================================
  cat2(rule2("Step 2 - Compositional invariance", type = 3))
  
  ## Null hypothesis -----------------------------------------------------------
  cat2(
    "\n\nNull hypothesis:\n\n",
    boxx("H0: Compositional measurement invariance of the constructs.", 
         float = "center",width=80)
  )
  
  ## Test statistic and p-value -----------------------------------------
  cat2("\n\nTest statistic and p-value: \n\n")
  
  for(i in 1:no_groups) {
    
    cat2("  Compared groups: ", names(x2$Test_statistic)[i], "\n\t")
    cat2(
      col_align("", width = l_names),
      "\t",
      col_align("", width = 14), 
      "\t",
      col_align("p-value by adjustment", width = max(sum(nchar(names(x2$P_value))) + 2, 22), 
                align = "center")
    )
    cat2(
      "\n\t",
      col_align("Construct", width = l_names),
      "\t",
      col_align("Test statistic", width = 14), 
      "\t"
    )
    
    for(j in names(x2$P_value)) {
      cat2(col_align(j, width = max(6, nchar(j)) + 2, align = "right"))
    }
    
    cat("\n\t")
    
    for(j in construct_names) {
      cat2(
        col_align(j, width = l_names), 
        "\t",
        col_align(sprintf("%.4f", x2$Test_statistic[[i]][j]), width = 14,
                  align = "center"),
        "\t"
      )
      
      for(k in names(x2$P_value)) {
        cat2(col_align(sprintf("%.4f", x2$P_value[[k]][[i]][j]), 
                       width = max(6, nchar(k)) + 2, align = "right"))
      } # END for j (each construct)
      cat("\n\t")
    } # END for k (each significance level)
    cat("\n\n")
  } # END for i (each group)
  
  ## Decision ------------------------------------------------------------------
  # cat2("Decision: \n\n")
  # 
  # cat2("\tDecision (based on alpha = ", names(x2$P_value[[1]],":\n\n"))
  # 
  # for(i in 1:no_groups) {
  #   # Width of columns
  #   l <- apply(x2$Decision[[[[i]], 2, function(x) {
  #     ifelse(any(x == TRUE), nchar("Do not reject"), nchar("reject"))
  #   })
  #   
  #   l1 <- max(c(sum(l) + 3*(ncol(x2$Decision[[i]]) - 1)), nchar("Significance level"))
  #   cat2("  Compared groups: ", names(x2$Test_statistic)[i], "\n\t")
  #   cat2(
  #     col_align("", width = l_names), 
  #     "\t",
  #     col_align("Significance level", 
  #               width = l1, 
  #               align = "center")
  #   )
  #   cat2(
  #     "\n\t",
  #     col_align("Construct", width = l_names), 
  #     "\t"
  #   )
  #   
  #   for(j in colnames(x2$Critical_value[[i]])) {
  #     cat2(col_align(j, width = l[j], align = "center"), "\t")
  #   }
  #   
  #   cat("\n\t")
  #   
  #   for(j in seq_along(x2$Test_statistic[[i]])) {
  #     
  #     cat2(col_align(names(x2$Test_statistic[[i]])[j], width = l_names), "\t")
  #     
  #     for(k in 1:ncol(x2$Critical_value[[i]])) {
  #       cat2(
  #         col_align(ifelse(x2$Decision[[i]][j, k], 
  #                          green("Do not reject"), red("reject")), 
  #                   width = l[k], align = "center"), 
  #         "\t"
  #       )
  #     }
  #     cat("\n\t")
  #   }  
  #   cat("\n\n")
  # } # END for i (each group )
  # 
  ### Step 3 ===================================================================
  cat2(rule2("Step 3 - Equality of the means and variances", type = 3))
  
  ## Null hypothesis -----------------------------------------------------------
  cat2(
    "\n\nNull hypothesis:\n\n",
    boxx(c("1. H0: Difference between group means is zero",
           "2. H0: Log of the ratio of the group variances is zero"),
         float = "center",width=80)
  )
  
  ## Test statistic and critical value -----------------------------------------
  cat2("\n\nTest statistic and critical values: \n\n")
  
  for(i in 1:no_groups) {
    
    cat2("  Compared groups: ", names(x2$Test_statistic)[i], "\n\n\t")
    for(type in names(x3)) {
      x3_type <- x3[[type]]
      cat2(type, "\n\t")
      cat2(
        col_align("", width = l_names),
        "\t",
        col_align("", width = 14), 
        "\t",
        col_align("p-value by adjustment", width = max(sum(nchar(names(x3_type$P_value))) + 2, 22), 
                  align = "center")
      )
      cat2(
        "\n\t",
        col_align("Construct", width = l_names),
        "\t",
        col_align("Test statistic", width = 14), 
        "\t"
      )

      for(j in names(x3_type$P_value)) {
        cat2(col_align(j, width = max(6, nchar(j)) + 2, align = "right"))
      }
      
      cat("\n\t")
      
      for(j in construct_names) {
        cat2(
          col_align(j, width = l_names), 
          "\t",
          col_align(sprintf("%.4f", x3_type$Test_statistic[[i]][j]), width = 14,
                    align = "center"),
          "\t"
        )
        
        for(k in names(x3_type$P_value)) {
          cat2(col_align(sprintf("%.4f", x3_type$P_value[[k]][[i]][j]), 
                         width = max(6, nchar(k)) + 2, align = "right"))
        } # END for j (each construct)
        cat("\n\t")
      } # END for k (each significance level)
      cat("\n\t")
    } # END for type (one of "Mean" and "Var")
    cat("\n")
  } # END for i (each group)
  
  ## Decision ------------------------------------------------------------------
  # cat("Decision: \n\n", sep = "")
  # 
  # for(i in 1:no_groups) {
  #   
  #   cat("  Compared groups: ", names(x2$Test_statistic)[i], "\n\n\t")
  #   
  #   for(type in names(x3)) {
  #     x3_type <- x3[[type]]
  #     
  #     # Width of columns
  #     l <- apply(x3_type$Decision[[i]], 2, function(x) {
  #       ifelse(any(x == TRUE), nchar("Do not reject"), nchar("reject"))
  #     })
  #     
  #     n1 <- colnames(x3_type$Critical_value[[i]])
  #     n2 <- paste0("[", n1[seq(1, (length(n1) - 1), by = 2)], ";", 
  #                  n1[seq(2, length(n1), by = 2)], "]")
  #     
  #     l1 <- max(c(sum(l) + 3*(ncol(x3_type$Decision[[i]]) - 1)), 
  #               nchar("Significance levels"),
  #               nchar(n2))
  #     
  #     cat(type, "\n\t", sep = "")
  #     cat(
  #       col_align("", width = l_names), 
  #       "\t",
  #       col_align("Significance level", 
  #                 width = l1, 
  #                 align = "center"),
  #       sep = ""
  #     )
  #     cat(
  #       "\n\t",
  #       col_align("Construct", width = l_names), 
  #       "\t",
  #       sep = ""
  #     )
  #     
  #     for(j in seq_along(n2)) {
  #       cat(col_align(n2[j], width = max(l[j], nchar(n2[j])), align = "center"),
  #           "\t", sep = "")
  #     }
  #     
  #     cat("\n\t")
  #     
  #     for(j in seq_along(x3_type$Test_statistic[[i]])) {
  #       
  #       cat(col_align(names(x3_type$Test_statistic[[i]])[j], width = l_names), "\t", sep = "")
  #       
  #       for(k in 1:ncol(x3_type$Decision[[i]])) {
  #         cat(
  #           col_align(ifelse(x3_type$Decision[[i]][j, k], 
  #                            green("Do not reject"), red("reject")),
  #                     width = max(l[k], nchar(n2[k])), align = "center"), 
  #           "\t", 
  #           sep = ""
  #         )
  #       } # END for k (each construct)
  #       cat("\n\t")
  #     } # END for j (each significance level)
  #   } # END for type (one of "Mean" and "Var")
  #   cat("\n")
  # } # END for i (each group)
  # 
  ## Additional information ----------------------------------------------------
  cat("Additional information:")
  cat2(
    "\n\n\tOut of ", x$Information$Total_runs , " permutation runs, ", 
    x$Information$Number_admissibles, " where admissible.\n\t",
    "See ", yellow("?"), magenta("verify"), "()",
    " for what constitutes an inadmissible result.\n\n\t",
    "The seed used was: ", x$Information$Seed, "\n"
  )
  
  cat("\n\tNumber of observations per group:")
  
  l <- max(nchar(c(x$Information$Group_names, "Group")))
  
  cat("\n\n\t",
      col_align("Group", width = l + 6),
      col_align("No. observations", width = 15),
      sep = ""
  )
  for(i in seq_along(x$Information$Group_names)) {
    cat(
      "\n\t",
      col_align(x$Information$Group_names[i], width = l + 6), 
      col_align(x$Information$Number_of_observations[i], width = 15),
      sep = ""
    )
  }
  
  cat2("\n", rule2(type = 2), "\n")
}