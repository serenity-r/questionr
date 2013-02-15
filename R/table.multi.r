## Fonction pour le tri à plat "combiné" d'une série de variables binaires
## Arguments :
## - df : data frame
## - varnames : vecteur contenant le nom des variables binaires
## - true.codes : liste contenant des valeurs supplémentaires considérées comme "vraies"
##   (par défaut TRUE et 1 sont considérées comme vraies)
## - weights: nom de la variable de pondération des lignes (facultatif)
 
##' One-way frequency table for multiple choices question
##'
##' This function allows to generate a frequency table from a multiple choices question.
##' The question's answers must be stored in a series of binary variables.
##' 
##' @param df data frame
##' @param vars index vector or character vector of the names of the binary variables
##' @param true.codes optional list of values considered as 'true' for the tabulation
##' @param weights optional weighting variable
##' @details
##' The function is applied to a series of binary variables, each one corresponding to a
##' choice of the question. For example, if the question is about seen movies among a movies
##' list, each binary variable would correspond to a movie of the list and be true or false
##' depending of the choice of the answer.
##'
##' By default, only '1' and 'TRUE' as considered as 'true' values fro the binary variables,
##' and counted in the frequency table. It is possible to specify other values to be counted
##' with the \code{true.codes} argument.
##'
##' @return Object of class table.
##' @seealso \code{\link[questionr]{cross.multi.table}}, \code{\link[questionr]{multi.split}}, \code{\link{table}}
##' @examples
##' ## Sample data frame
##' sex <- sample(c("Man","Woman"),100,replace=TRUE)
##' jazz <- sample(c(0,1),100,replace=TRUE)
##' rock <- sample(c(TRUE, FALSE),100,replace=TRUE)
##' electronic <- sample(c("Y","N"),100,replace=TRUE)
##' weights <- runif(100)*2
##' df <- data.frame(sex,jazz,rock,electronic,weights)
##' ## Frequency table on 'music' variables
##' multi.table(df, c("jazz", "rock","electronic"), true.codes=list("Y"))
##' ## Weighted frequency table on 'music' variables
##' multi.table(df, c("jazz", "rock","electronic"), true.codes=list("Y"), weights="weights")
##' @export
multi.table <- function(df, vars, true.codes=NULL, weights=NULL) {
  true.codes <- c(as.list(true.codes), TRUE, 1)
  as.table(sapply(df[,vars], function(v) {
    sel <- as.numeric(v %in% true.codes)
    if (!is.null(weights)) sel <- sel * df[,weights]
    sum(sel)
  }))
}
 
##' Two-way frequency table between a multiple choices question and a factor
##'
##' This function allows to generate a two-way frequency table from a multiple
##' choices question and a factor. The question's answers must be stored in a
##' series of binary variables.
##' 
##' @param df data frame
##' @param vars index vector or character vector of the names of the binary variables
##' @param crossvar factor to cross the multiple choices question with
##' @param ... arguments passed to \code{multi.table}
##' @details
##' See the \code{multi.table} help page for details on handling of the multiple
##' choices question and corresponding binary variables.
##'
##' @return Object of class table.
##' @seealso \code{\link[questionr]{multi.table}}, \code{\link[questionr]{multi.split}}, \code{\link{table}}
##' @examples
##' ## Sample data frame
##' sex <- sample(c("Man","Woman"),100,replace=TRUE)
##' jazz <- sample(c(0,1),100,replace=TRUE)
##' rock <- sample(c(TRUE, FALSE),100,replace=TRUE)
##' electronic <- sample(c("Y","N"),100,replace=TRUE)
##' weights <- runif(100)*2
##' df <- data.frame(sex,jazz,rock,electronic,weights)
##' ## Two-way frequency table on 'music' variables by sex
##' cross.multi.table(df, c("jazz", "rock","electronic"), df$sex, true.codes=list("Y"))
##' @export
 
cross.multi.table <- function(df, vars, crossvar, ...) {
  tmp <- factor(crossvar)
  simplify2array(by(df, tmp, multi.table, vars, ...))
}


##' Split a multiple choices variable in a series of binary variables
##'
##' 
##' @param var variable to split
##' @param split.char character to split at
##' @param mnames names to give to the produced variabels. If NULL, the name are computed from the original variable name and the answers.
##' @details
##' This function takes as input a multiple choices variable where choices
##' are recorded as a string and separated with a fixed character. For example,
##' if the question is about the favourite colors, answers could be "red/blue",
##' "red/green/yellow", etc. This function splits the variable into as many variables
##' as the number of different choices. Each of these variables as a 1 or 0 value
##' corresponding to the choice of this answer. They are returned as a data frame.
##' ##' @return Returns a data frame.
##' @seealso \code{\link[questionr]{multi.table}}
##' @examples
##' v <- c("red/blue","green","red/green","blue/red")
##' multi.split(v)
##' @export

multi.split <- function (var, split.char="/", mnames = NULL) {
  vname <- deparse(substitute(var))
  lev <- levels(factor(var))
  lev <- unique(unlist(strsplit(lev, split.char)))
  if (is.null(mnames)) 
    mnames <- gsub(" ", "_", paste(vname, lev, sep = "."))
  else mnames <- paste(vname, mnames, sep = ".")
  result <- matrix(data = 0, nrow = length(var), ncol = length(lev))
  char.var <- as.character(var)
  for (i in 1:length(lev)) {
    result[grep(lev[i], char.var, fixed = TRUE), i] <- 1
  }
  result <- data.frame(result)
  colnames(result) <- mnames
  result
}
