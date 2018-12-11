is_lang <- function(x) identical(typeof(x), "language")

use_method <- function(method) {
  args <- as.list(parent.frame(), all.names = TRUE)
  do_call(method, args)
}

do_call <- function(method, args) {
  do.call(default_method(method), args, quote = TRUE)
}

default_method <- function(x) paste0(x, ".default")

is_twitter_data <- function(x) {
  key_vars <- c(
    "screen_name",
    "text",
    "display_text_width",
    "followers_count",
    "friends_count",
    "listed_count",
    "statuses_count",
    "favourites_count"
  )
  all(key_vars %in% names(x))
}
