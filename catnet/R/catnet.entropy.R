#########################################################################
# Categorical Network Class Methods
# entropy

condProbEntropy <- function(idroot, ppars, pcatlist, probs, idx) {
  if(is.null(ppars) || length(idx) < 1) {
    ## if(length(pprobs[[idroot]]) != length(pcatlist[[idroot]]))
    ## stop("length(pprobs[[idroot]]) != length(pcatlist[[idroot]]))")
    nodep <- probs
    ##cat(nodep, "\n")
    nodep <- nodep[nodep!=0]
    return(log(as.numeric(length(pcatlist[[idroot]]))) + sum(nodep*log(nodep)))
  }
  idnode <- ppars[idx[1]]
  return(sum(sapply(seq(1, length(pcatlist[[idnode]])),
         function(cat) condProbEntropy(idroot, ppars, pcatlist, probs[[cat]], idx[-1]))
             ))
}

setMethod("cnKLComplexity", c("catNetwork"), 
          function(object, node=NULL) {
            if(!is(object, "catNetwork"))
              stop("The object should be a catNetwork")
            if(is.null(node))
              node <- 1:object@numnodes
            if(is.character(node))
              node <- which(object@nodes == node)
            if(!is.numeric(node))
              node <- 1:object@numnodes
            nodeEntropy <- sum(sapply(node, function(i) {
              idx <- NULL
              if(length(object@parents[[i]])>0)
                idx <- 1:length(object@parents[[i]])
              return(condProbEntropy(i, object@parents[[i]], object@categories, object@probabilities[[i]], idx))
            }))
            return(nodeEntropy)
          })

cnEntropy <- function(data, perturbations=NULL) {

  if(!is.matrix(data) && !is.data.frame(data))
    stop("'data' should be a matrix or data frame of categories")
  
  if(is.data.frame(data)) {
    data <- as.matrix(t(data))
    if(!is.null(perturbations)) { 
      if(!is.data.frame(perturbations))
        stop("Perturbations should be a data frame")
      perturbations <- as.matrix(t(perturbations))
    }
  }
  
  r <- .categorizeSample(data, perturbations, object=NULL, ask=FALSE)
  data <- r$data
  perturbations <- r$perturbations
  numnodes <- dim(data)[1]
  numsamples <- dim(data)[2]
  nodenames <- rownames(data)
  
  mat <- .Call("ccnEntropyPairwise", 
                  data, perturbations, 
                  PACKAGE="catnet")
  klmat <- matrix(mat, numnodes, numnodes)
  rownames(klmat)<-nodenames
  colnames(klmat)<-nodenames
  return(klmat)
}

cnEdgeDistanceKL <- function(data, perturbations) {

  if(!is.matrix(data) && !is.data.frame(data))
    stop("'data' should be a matrix or data frame of categories")

  if(is.null(perturbations)) {
    warning("Perturbations are essential for estimating the pairwise causality")
  }

  if(is.data.frame(data)) {
    data <- as.matrix(t(data))
    if(!is.null(perturbations)) { 
      if(!is.data.frame(perturbations))
        stop("Perturbations should be a data frame")
      perturbations <- as.matrix(t(perturbations))
    }
  }
  
  r <- .categorizeSample(data, perturbations, object=NULL, ask=FALSE)
  data <- r$data
  perturbations <- r$perturbations
  numnodes <- dim(data)[1]
  numsamples <- dim(data)[2]
  nodenames <- rownames(data)
  
  mat <- .Call("ccnKLPairwise", 
                  data, perturbations, 
                  PACKAGE="catnet")
  klmat <- matrix(mat, numnodes, numnodes)
  rownames(klmat)<-nodenames
  colnames(klmat)<-nodenames
  return(klmat)
}

cnEntropyOrder <- function(data, perturbations=NULL) {

  if(!is.matrix(data) && !is.data.frame(data))
    stop("'data' should be a matrix or data frame of categories")

  ##if(is.null(perturbations))
  ##  warning("Without perturbations the order estimation is poor")

  if(is.data.frame(data)) {
    data <- as.matrix(t(data))
    if(!is.null(perturbations)) { 
      if(!is.data.frame(perturbations))
        stop("Perturbations should be a data frame")
      perturbations <- as.matrix(t(perturbations))
    }
  }
  
  r <- .categorizeSample(data, perturbations, object=NULL, ask=FALSE)
  data <- r$data
  perturbations <- r$perturbations
  numnodes <- dim(data)[1]
  numsamples <- dim(data)[2]
  nodenames <- rownames(data)
  
  norder <- .Call("ccnEntropyOrder", 
                  data, perturbations, 
                  PACKAGE="catnet")
  names(norder) <- nodenames
  return(norder)
}

