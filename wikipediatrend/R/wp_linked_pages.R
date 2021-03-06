#' function looking for other languages of a page
#' 
#' @param page title of the wikipedia article to look for links to other
#'   languages
#' @param lang language (shorthand, e.g. "en" for English or "de" for German and
#'   so on) for the afor given title
#' @export


wp_linked_pages <- function(page, lang){
  # input checks
  stopifnot(length(page)==1, length(lang)==1)
  # make first letter of page title always capital
  page <- stringr::str_replace( 
    page, 
    "^.", 
    substring(toupper(page),1,1) 
  )
  # url 
  url <- paste0("https://", lang, ".wikipedia.org/wiki/", page)
  # getting language links
  html_doc   <- html2( url )
  lang_nodes <- rvest::html_nodes( 
    html_doc, 
    xpath="//a[@hreflang and contains(@href, 'wikipedia.org') ]"
  )
  lang_attr  <- rvest::html_attrs( lang_nodes )  
  lang_df    <- 
    data.frame(
      page = sapply(lang_attr, `[`, c("href")) ,
      lang = sapply(lang_attr, `[`, c("hreflang")),
      stringsAsFactors = F
    )
  # data cleansing
  lang_df$page <- stringr::str_replace(
            stringr::str_extract(lang_df$page, "wiki/.+$"), 
          "wiki/", "")
  lang_df[lang_df$lang=="x-default",] <- c(page, lang)
  # add decoded title 
  tmp <- unlist(lapply(lang_df$page, utils::URLdecode))
  Encoding(tmp) <- "UTF-8"
  lang_df$title <- tmp
  # return
  class(lang_df) <- c("wp_df","data.frame")
  return(lang_df)
}



