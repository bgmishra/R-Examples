CalculateAFROCPoints <- function(NL, LL, modalityID, readerID, maxNL, lesionNum, plottingModalities, plottingReaders) {
  UNINITIALIZED <- RJafrocEnv$UNINITIALIZED
  I <- length(plottingModalities)
  J <- dim(NL)[2]
  K <- dim(NL)[3]
  K2 <- dim(LL)[3]
  K1 <- K - K2
  
  if (all(is.character(plottingModalities))) 
    plottingModalities <- which(modalityID %in% plottingModalities)
  NL <- NL[plottingModalities, , , ]
  LL <- LL[plottingModalities, , , ]
  dim(NL) <- c(I, J, K, maxNL)
  dim(LL) <- c(I, J, K2, max(lesionNum))
  modalityID <- modalityID[plottingModalities]
  
  
  J <- length(plottingReaders)
  
  if (all(is.character(plottingReaders))) 
    plottingReaders <- which(readerID %in% plottingReaders)
  NL <- NL[, plottingReaders, , ]
  LL <- LL[, plottingReaders, , ]
  dim(NL) <- c(I, J, K, maxNL)
  dim(LL) <- c(I, J, K2, max(lesionNum))
  readerID <- readerID[plottingReaders]
  
  sumLL <- sum(lesionNum)
  NL <- apply(NL, c(1, 2, 3), max)
  AFROCPoints <- data.frame(FPF = NULL, LLF = NULL)
  for (i in 1:I) {
    for (j in 1:J) {
      nl <- NL[i, j, 1:K1]
      ll <- LL[i, j, , ][LL[i, j, , ] != UNINITIALIZED]
      nlTable <- rev(table(nl))
      llTable <- rev(table(ll))
      
      if (length(nlTable) == 1) {
        nlScores <- as.numeric(attr(nlTable, "names"))
      } else {
        nlScores <- as.numeric(unlist(attr(nlTable, "dimnames")))
      }
      
      if (length(llTable) == 1) {
        llScores <- as.numeric(attr(llTable, "names"))
      } else {
        llScores <- as.numeric(unlist(attr(llTable, "dimnames")))
      }
      scores <- sort(unique(c(nlScores, llScores)), decreasing = TRUE)
      
      fpf <- cumsum(as.vector(nlTable))/K1
      llf <- cumsum(as.vector(llTable))/sumLL
      
      if (length(llf) == 0){
        llScores <- -Inf
        llf <- 0
      }else if (llf[length(llf)] != 1) {
        llScores <- c(llScores, -Inf)
        llf <- c(llf, 1)  #dummy ll score and llf
      }
      
      FPF <- 0:length(scores)
      LLF <- FPF
      
      numNL <- 1
      numLL <- 1
      for (k in 1:length(scores)) {
        if (!is.na(nlScores[numNL]) && nlScores[numNL] >= scores[k]) {
          FPF[k + 1] <- fpf[numNL]
          numNL <- numNL + 1
        } else {
          FPF[k + 1] <- FPF[k]
        }
        
        if (!is.na(llScores[numLL]) && llScores[numLL] >= scores[k]) {
          LLF[k + 1] <- llf[numLL]
          numLL <- numLL + 1
        } else {
          LLF[k + 1] <- LLF[k]
        }
      }
      AFROCPoints <- rbind(AFROCPoints, data.frame(FPF = FPF, LLF = LLF, Modality = i, Reader = j))
    }
  }
  class <- paste("M-", modalityID[AFROCPoints$Modality], "\n", "R-", readerID[AFROCPoints$Reader], sep = "")
  AFROCPoints <- data.frame(FPF = AFROCPoints$FPF, LLF = AFROCPoints$LLF, class = class, type = "individual")
  return(AFROCPoints)
} 
