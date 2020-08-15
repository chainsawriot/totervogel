
.get_frds_info <- function(user) {
    frds <- rtweet::get_friends(user)
    info <- rtweet::lookup_users(frds$user_id)
    return(info)
}


.extract_fsd <- function(x, exclude_zero = TRUE) {
    res <- substr(as.character(x), 1, 1)
    if (exclude_zero) {
        res <- res[res != 0]
    }
    return(as.numeric(res))
}

.gen_expected_distribution <- function(x) {
    expected_dist <- log10(1 + (1/1:9)) * length(x)
    observed_dist <- as.numeric(table(factor(x, levels = 1:9)))
    return(data.frame(fsd = 1:9, expected_dist, observed_dist))
}

.gen_scores <- function(info) {
    friends_dist <- .gen_expected_distribution(.extract_fsd(info$friends_count))
    statuses_dist <- .gen_expected_distribution(.extract_fsd(info$statuses_count))
    followers_dist <- .gen_expected_distribution(.extract_fsd(info$followers_count))
    res <- list(friends = friends_dist, statuses = statuses_dist, followers = followers_dist, info = info, friends_benford = benford.analysis::benford(info$friends_count, number.of.digits = 1), statuses_benford = benford.analysis::benford(info$statuses_count, number.of.digits = 1), followers_benford = benford.analysis::benford(info$followers_count, number.of.digits = 1))
    return(res)
}

#' @export
create_totervogel <- function(user_id) {
    info <- .get_frds_info(user_id)
    if (nrow(info) == 0) {
        stop("No friend.")
    }
    res <- .gen_scores(info)
    res$user_id <- user_id
    class(res) <- append("totervogel", class(res))
    return(res)
}

#' @export
print.totervogel <- function(totervogel, ...) {
    cat("User ID:", totervogel$user_id, "\n")
    cat("Friends Correlation: ", cor(totervogel[[1]]$expected_dist, totervogel[[1]]$observed_dist), "\n")
    cat("Friends MAD: ", totervogel$friends_benford$MAD, "(",totervogel$friends_benford$MAD.conformity, ")\n")
    cat("Statuses Correlation:", cor(totervogel[[2]]$expected_dist, totervogel[[2]]$observed_dist), "\n")
    cat("Statuses MAD: ", totervogel$statuses_benford$MAD, "(",totervogel$statuses_benford$MAD.conformity, ")\n")
    cat("Followers Correlation: ", cor(totervogel[[3]]$expected_dist, totervogel[[3]]$observed_dist), "\n")
    cat("Followers MAD: ", totervogel$followers_benford$MAD, "(",totervogel$followers_benford$MAD.conformity, ")\n")
}

#' @export
plot.totervogel <- function(totervogel, ...) {
    friends_df <- totervogel$friends
    friends_df$type <- "friends"
    followers_df <- totervogel$followers
    followers_df$type <- "followers"
    statuses_df <- totervogel$statuses
    statuses_df$type <- "statuses"
    rbind(friends_df, followers_df, statuses_df) %>% tidyr::pivot_longer(tidyr::ends_with("dist"), names_to = "dist_type", values_to = "value") %>% ggplot2::ggplot(ggplot2::aes(x = fsd, y = value, color = dist_type)) + ggplot2::geom_line() + ggplot2::facet_grid(cols = ggplot2::vars(type)) + ggplot2::ggtitle(totervogel$user_id)
}
