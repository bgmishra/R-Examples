#Class implementing a Classification Algorithm
  #Implements the Naive Bayes KEEL classification algorithm

NB_C <- function(train, test){
  alg <- RKEEL::R6_NB_C$new()
  alg$setParameters(train, test)
  return (alg)
}

R6_NB_C <- R6::R6Class("R6_NB_C",

  inherit = ClassificationAlgorithm,

  public = list(

    #Public properties


    #Public functions

    #Initialize function
    setParameters = function(train, test){

		  super$setParameters(train, test)

      #Check for constraints
      stopText <- ""

      if((hasContinuousData(train)) || (hasContinuousData(test))){
        stopText <- paste0(stopText, "Dataset has continuous data and the algorithm does not accept it.\n")
      }

      if(stopText != ""){
        stop(stopText)
      }

    }

  ),

  private = list(

    #Private properties

    #jar Filename
    jarName = "Naive_Bayes.jar",

    #algorithm name
    algorithmName = "NB-C",

    #String with algorithm name
    algorithmString = "Naive Bayes Classifier",


    #Private functions

    #Get the text with the parameters for the config file
    getParametersText = function(){

      text <- ""

      return(text)

    }

  )
)
