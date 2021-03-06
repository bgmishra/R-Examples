#' Iterate over tape, gathering results.
#' 
#' This function read the tape from the oldest to the newest writes and executes the callback function on each read object. Logically, it is an equivalent to \code{lapply(rtapeAsList(fName),FUN,...)}, but it is optimized to store only the currently processed object in the memory.
#'
#' @param fNames Name of the tape file to read; if this argument is a vector of several names, function behaves as reading a single tape made of all those tapes joined in a given order. 
#' @param FUN Callback function.
#' @param ... Additional parameters to \code{FUN}.
#' @return A list containing results of \code{FUN} calls.
#' @author Miron B. Kursa \email{M.Kursa@@icm.edu.pl}
#' @examples
#' unlink('tmp.tape')
#' #Record something on the tape
#' rtapeAdd('tmp.tape',runif(3))
#' rtapeAdd('tmp.tape',rnorm(3))
#'
#' #Print tape contents
#' rtape_apply('tmp.tape',print)
#' unlink('tmp.tape')

rtapeLapply<-function(fNames,FUN,...){
 match.fun(FUN)->FUN
 ans<-list()
 for(fName in fNames){
  guessFileFormat(fName)(fName,open="rb")->con
  while(!.ckErr(try(unserialize(con),silent=TRUE)->x))
   ans<-c(ans,list(FUN(x,...)))
  close(con)
 }
 ans
}
