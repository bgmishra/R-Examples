## summarizeRobMahalanobis <- function(x, probs = c(0.9,0.99,0.999,0.9999), prop=0.5, ...) {
##     ## Purpose: nicely summarize cell or row outliers

##   cells <- function(x, probs, prop) {
##     df <- 2
##     RSR <- rsr(resid=x$resid, Sigma=x$Sigma)
##     JL <- nrow(RSR)
##     p <- nrow(x$resid)
##     n <- ncol(x$resid)
##     jlmat <- matrix(0, nrow=JL, ncol=2)
##     jl <- 0
##     for (j in 1:(p-1)) {
##       for (l in (j+1):p) {
##         jl <- jl + 1
##         jlmat[jl,] <- c(j,l)
##       }
##     }
##     qc <- qchisq(probs, df=df)
##     pos <- array(FALSE, dim=c(p,n,length(qc)))    
##     for (k in 1:length(qc)) {
##       temp <- which(RSR > qc[k], arr.ind=TRUE)
##       if (NROW(temp)) {
##         nn <- unique(temp[,2])
##         for (i in nn) {
##           temp1 <- temp[which(temp[,2]==i),1]
##           temp1 <- table(factor(jlmat[temp1,], levels=1:p))
##           pos[which(temp1>=JL*prop),i,k] <- TRUE
##         }
##       }
##     }
##     ans <- list()
##     ans$pos.cells <- pos
##     ans$cells <- apply(pos, 3, function(x) which(x, arr.ind=TRUE))
##     if (any(pos)) {
##       cellstable <- cbind(probs, sapply(ans$cells, NROW))
##       cellstable <- cbind(cellstable, cellstable[,2]/(p*n))
##     } else {
##       cellstable <- matrix(NA, nrow=0, ncol=3)
##     }
##     dimnames(cellstable) <- list(NULL, c("Level", "Number of cells", "Fraction of cells"))
##     ans$table.cells <- cellstable
##     ans$num.cells <- p*n
##     return(ans)
##   }

##   rows <- function(x, probs) {
##     df <- nrow(x$Sigma)
##     Sigmainv <- solve(x$Sigma)
##     RSR <- rep(0, ncol(x$resid))  
##     for (i in 1:ncol(x$resid))
##       RSR[i] <- drop(x$resid[,i]%*%Sigmainv%*%x$resid[,i])
##     qc <- qchisq(probs, df=df)
##     pos <- matrix(FALSE,nrow=ncol(x$resid), ncol=length(qc))
##     for (j in 1:length(qc))
##       pos[,j] <- RSR > qc[j]
##     ans <- list()
##     ans$pos.rows <- pos
##     ans$rows <- apply(pos, 2, which)
##     if (any(pos)) {
##       rowstable <- cbind(probs, sapply(ans$rows, length))
##       rowstable <- cbind(rowstable, rowstable[,2]/n)
##     } else {
##       rowstable <- matrix(NA, nrow=0, ncol=3)
##     }  
##     dimnames(rowstable) <- list(NULL, c("Level", "Number of rows", "Fraction of rows"))
##     ans$table.rows <- rowstable
##     ans$num.rows <- n
##     return(ans)
##   }

##   cells2 <- function(x, probs) {
##     df <- 1
##     Sigmainv <- 1/diag(x$Sigma)
##     p <- nrow(x$resid)
##     n <- ncol(x$resid)
##     RSR <- matrix(NA, p, n)  
##     for (i in 1:n) {
##       for (j in 1:p) {
##         RSR[j,i] <- drop(x$resid[j,i]^2*Sigmainv[j])
##       }
##     }
##     qc <- qchisq(probs, df=df)
##     pos <- array(FALSE, dim=c(p,n,length(qc)))    
##     for (k in 1:length(qc))
##       pos[,,k] <- RSR > qc[k]
##     ans <- list()
##     ans$pos.cells <- pos
##     ans$cells <- apply(pos, 3, function(x) which(x, arr.ind=TRUE))
##     if (any(pos)) {
##       cellstable <- cbind(probs, sapply(ans$cells, NROW))
##       cellstable <- cbind(cellstable, cellstable[,2]/(p*n))
##     } else {
##       cellstable <- matrix(NA, nrow=0, ncol=3)
##     }
##     dimnames(cellstable) <- list(NULL, c("Level", "Number of cells", "Fraction of cells"))
##     ans$table.cells <- cellstable
##     ans$num.cells <- p*n
##     return(ans)        
##   }
  
##   cellsoutliers <- cells(x=x, probs=probs, prop=prop)
##   cells2outliers <- cells2(x=x, probs=probs)      
##   rowsoutliers <- rows(x=x, probs=probs)  
##   ans <- list()
##   ans$cellsoutliers <- cellsoutliers
##   ans$cells2outliers <- cells2outliers      
##   ans$rowsoutliers <- rowsoutliers  
##   return(ans)
## }
