

#' Should be verified
#'
#' Generates prediction of whether Twitter user(s) should be verified. See
#' \strong{details} section below for more information on the prediction model
#'
#' @param user Screen name, user ID, or data frame of user data returned by
#'   \url{https://rtweet.info} function, e.g.,
#'   \code{\link[rtweet]{lookup_users}},
#'   \code{\link[rtweet]{get_timeline}},
#'   \code{\link[rtweet]{search_tweets}}.
#' @param token Token object to be used in any requests sent to Twitter's REST
#'   API (it's passed to internal rtweet function). API requests are only made
#'   if the input object is a screen name or user ID. The default, \code{NULL},
#'   will look for a token saved as an environment token or will leverage the
#'   rtweet app to request a token on behalf of the user–this requires the user
#'   to be in an interactive session and to have a valid user name and password
#'   with which to log into their Twitter account.
#' @return A named (screen name) numeric vector represented the predicted
#'   probability of an account being verified
#' @details Predictions generated from a boosted logistic regression model
#'   trained on 24,000 verified and non-verified Twitter accounts. Performance
#'   on test data was 96% accurate.
#' @export
should_be_verified <- function(user, token = NULL) use_method("should_be_verified")


should_be_verified.default <- function(user, token) {

  ## if screen name or user ID is provided, get twitter data
  if (is.character(user)) {
    user <- rtweet::lookup_users(user, token = token)
  }

  ## if user contains retweet observation, get original tweet via get_timeline
  if (any(user$is_retweet)) {

    ## initialize output vector
    user_new <- vector("list", sum(user$is_retweet))

    ## which ones are retweets
    isrt <- which(user$is_retweet)

    ## run get_timeline for each retweet obs
    for (i in seq_along(isrt)) {
      user_new[[i]] <- rtweet::get_timeline(
        user$screen_name[isrt[i]], n = 100, token = token
      )

      ## if the most recent 100 tweets are SERIOUSLY retweets, then get 3200
      if (all(user_new[[i]]$is_retweet)) {
        user_new[[i]] <- rtweet::get_timeline(
          user$screen_name[isrt[i]], n = 3200, token = token
        )
      }

      ## get/keep only most recent NON-retweet (if all 3200 are retweets,
      ## then just keep most recent one and go with it)
      user_new[[i]] <- most_recent_non_retweet(user_new[[i]])
    }

    ## merge user_new into single data frame
    user_new <- do.call("rbind", user_new)

    ## if any were NOT retweets
    if (any(!user$is_retweet)) {

      ## which ones are NOT retweets
      nort <- which(!user$is_retweet)

      ## merge with non-retweet user data
      user <- rbind(
        user[nort, ],
        user_new
      )

      ## put back in original order
      user <- user[c(nort, isrt), ]

      ## reset row names
      row.names(user) <- NULL
    } else {

      ## if all were retweets, just override user
      user <- user_new
    }

  }

  ## validate data
  stopifnot(
    is.data.frame(user),
    is_twitter_data(user)
  )

  ## make prediction
  should_be_verified_(user)
}


should_be_verified_ <- function(user) {

  ## extract text features
  sh <- capture.output(tf <- suppressWarnings(
    textfeatures::textfeatures(
      should_be_verified_data$word_dim_model,
      normalize = FALSE,
      newdata = user
    )
  ))

  ## numeric twitter variables to keep
  num_vars_to_keep <- c(
    "display_text_width",
    "followers_count",
    "friends_count",
    "listed_count",
    "statuses_count",
    "favourites_count"
  )

  ## if display_text_width is missing, calculate it
  is_na <- is.na(user$display_text_width)
  user$display_text_width[is_na] <- nchar(user$text[is_na])

  ## combine text features with num vars
  tf <- cbind(tf, user[num_vars_to_keep])

  ## get prediction
  p_user <- gbm::predict.gbm(
    should_be_verified_data$gbm_model,
    newdata = tf,
    type = "response",
    n.trees = should_be_verified_data$gbm_model$n.trees
  )

  ## add user name(s)
  names(p_user) <- user$screen_name

  ## return data
  p_user
}


most_recent_non_retweet <- function(x) {
  if (any(!x$is_retweet)) {
    x <- x[!x$is_retweet, ]
  }
  x[1, ]
}
