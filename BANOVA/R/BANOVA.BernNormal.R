BANOVA.BernNormal <-
function(l1_formula = 'NA', l2_formula = 'NA', data, id, l2_hyper, burnin, sample, thin, adapt, conv_speedup, jags){
  cat('Model initializing...\n')
  # check y, if it is integers
  mf1 <- model.frame(formula = l1_formula, data = data)
  y <- model.response(mf1)
  mf2 <- model.frame(formula = l2_formula, data = data)
  if (class(y) != 'integer'){
    warning("The response variable must be integers (data class also must be 'integer')..")
    y <- as.integer(y)
    warning("The response variable has been converted to integers..")
  }
  # check each column in the dataframe should have the class 'factor' or 'numeric', no other classes such as 'matrix'...
  for (i in 1:ncol(data)){
    if(class(data[,i]) != 'factor' && class(data[,i]) != 'numeric' && class(data[,i]) != 'integer') stop("data class must be 'factor', 'numeric' or 'integer'")
    response_name <- attr(mf1,"names")[attr(attr(mf1, "terms"),"response")]
    # checking missing predictors
    if(i != which(colnames(data) == response_name) & sum(is.na(data[,i])) > 0) stop("Data type error, NAs/missing values included in independent variables") 
    if(i != which(colnames(data) == response_name) & class(data[,i]) == 'numeric')
      data[,i] = data[,i] - mean(data[,i])
  }
  n <- nrow(data)
  uni_id <- unique(id)
  num_id <- length(uni_id)
  new_id <- rep(0, length(id)) # store the new id from 1,2,3,...
  for (i in 1:length(id))
    new_id[i] <- which(uni_id == id[i])
  id <- new_id
  dMatrice <- design.matrix(l1_formula, l2_formula, data = data, id = id)
  JAGS.model <- JAGSgen.bernNormal(dMatrice$X, dMatrice$Z, l2_hyper, conv_speedup)
  JAGS.data <- dump.format(list(n = n, id = id, M = num_id, y = y, X = dMatrice$X, Z = dMatrice$Z))
  result <- run.jags (model = JAGS.model$sModel, data = JAGS.data, inits = JAGS.model$inits, n.chains = 1,
                      monitor = c(JAGS.model$monitorl1.parameters, JAGS.model$monitorl2.parameters), 
                      burnin = burnin, sample = sample, thin = thin, adapt = adapt, jags = jags, summarise = FALSE, 
                      method="rjags")
  samples <- result$mcmc[[1]]
  # find the correct samples, in case the order of monitors is shuffled by JAGS
  n_p_l2 <- length(JAGS.model$monitorl2.parameters)
  index_l2_param<- array(0,dim = c(n_p_l2,1))
  for (i in 1:n_p_l2)
    index_l2_param[i] <- which(colnames(result$mcmc[[1]]) == JAGS.model$monitorl2.parameters[i])
  if (length(index_l2_param) > 1)
    samples_l2_param <- result$mcmc[[1]][,index_l2_param]
  else
    samples_l2_param <- matrix(result$mcmc[[1]][,index_l2_param], ncol = 1)
  n_p_l1 <- length(JAGS.model$monitorl1.parameters)
  index_l1_param<- array(0,dim = c(n_p_l1,1))
  for (i in 1:n_p_l1)
    index_l1_param[i] <- which(colnames(result$mcmc[[1]]) == JAGS.model$monitorl1.parameters[i])
  if (length(index_l1_param) > 1)
    samples_l1_param <- result$mcmc[[1]][,index_l1_param]
  else
    samples_l1_param <- matrix(result$mcmc[[1]][,index_l1_param], ncol = 1)
  
  #anova.table <- table.ANOVA(samples_l1_param, dMatrice$X, dMatrice$Z)
  cat('Constructing ANOVA/ANCOVA tables...\n')
  anova.table <- table.ANCOVA(samples_l1_param, dMatrice$X, dMatrice$Z) # for ancova models
  coef.tables <- table.coefficients(samples_l2_param, JAGS.model$monitorl2.parameters, colnames(dMatrice$X), colnames(dMatrice$Z), 
                                    attr(dMatrice$X, 'assign') + 1, attr(dMatrice$Z, 'assign') + 1)
  pvalue.table <- table.pvalue(coef.tables$coeff_table, coef.tables$row_indices, l1_names = attr(dMatrice$X, 'varNames'), 
                               l2_names = attr(dMatrice$Z, 'varNames'))
  conv <- conv.geweke.heidel(samples_l2_param, colnames(dMatrice$X), colnames(dMatrice$Z))
  class(conv) <- 'conv.diag'
  cat('Done...\n')
  return(list(anova.table = anova.table,
              coef.tables = coef.tables,
              pvalue.table = pvalue.table,
              conv = conv,
              dMatrice = dMatrice, samples_l2_param = samples_l2_param, data = data, mf1 = mf1, mf2 = mf2, JAGSmodel = JAGS.model$sModel))
}
