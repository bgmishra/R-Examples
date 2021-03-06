# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' @rdname metaphone
#' @name metaphone
#' @title Metaphone
#'
#' @description
#' The Metaphone phonentic algorithm
#'
#' @param word string or vector of strings to encode
#' @param maxCodeLen  maximum length of the resulting encodings, in characters
#'
#' @details The function \code{metaphone} phonentically encodes the
#' given string using the metaphone algorithm.  There is some discrepency
#' with respect to how the metaphone algorithm actually works.  For
#' instance, there is a version in the Java Apache Commons library.
#' There is a version provided within PHP.  These do not provide the same
#' results.  On the questionable theory that the implementation in PHP
#' is probably more well known, this code should match it in output.
#'
#' This implementation is based on a Javascript implementation which is
#' itself based on the PHP internal implementation.
#'
#' The variable \code{maxCodeLen} is the limit on how long the returned
#' metaphone should be.
#'
#' @return metaphone encoded character vector
#'
#' @family phonics
#'
#' @examples
#' metaphone("wheel")
#' metaphone(c("school", "benji"))
#'
#' @useDynLib phonics
#' @importFrom Rcpp evalCpp
#' @export
metaphone <- function(word, maxCodeLen = 10L) {
    .Call('phonics_metaphone', PACKAGE = 'phonics', word, maxCodeLen)
}

#' @rdname soundex
#' @name soundex
#' @title Soundex
#'
#' @description
#' The Soundex phonetic algorithms
#'
#' @param word string or vector of strings to encode
#' @param maxCodeLen  maximum length of the resulting encodings, in characters
#'
#' @details The function \code{soundex} phonentically encodes the given
#' string using the soundex algorithm.  The function \code{refinedSoundex}
#' uses Apache's refined soundex algorithm.  Both implementations are loosely
#' based on the Apache Commons Java editons.
#'
#' The variable \code{maxCodeLen} is the limit on how long the returned
#' soundex should be.
#'
#' @return soundex encoded character vector
#'
#' @references
#' Charles P. Bourne and Donald F. Ford, "A study of methods for
#' systematically abbreviating English words and names," \emph{Journal
#' of the ACM}, vol. 8, no. 4 (1961), p. 538-552.
#'
#' Howard B. Newcombe, James M. Kennedy, "Record linkage: making
#' maximum use of the discriminating power of identifying information,"
#' \emph{Communications of the ACM}, vol. 5, no. 11 (1962), p. 563-566.
#'
#' @family phonics
#'
#' @examples
#' soundex("wheel")
#' soundex(c("school", "benji"))
#'
#' @useDynLib phonics
#' @importFrom Rcpp evalCpp
#' @export
soundex <- function(word, maxCodeLen = 4L) {
    .Call('phonics_soundex', PACKAGE = 'phonics', word, maxCodeLen)
}

#' @rdname soundex
#' @useDynLib phonics
#' @importFrom Rcpp evalCpp
#' @export
refinedSoundex <- function(word, maxCodeLen = 10L) {
    .Call('phonics_refinedSoundex', PACKAGE = 'phonics', word, maxCodeLen)
}

