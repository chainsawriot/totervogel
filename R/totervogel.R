
.get_friends_info <- function(user) {
    frds <- rtweet::get_friends(user)
    info <- rtweet::lookup_users(frds$user_id)
    return(info)
}

.get_followers_info <- function(user) {
    fols <- rtweet::get_followers(user)
    info <- rtweet::lookup_users(fols$user_id)
    return(info)
}

.extract_fsd <- function(x, exclude_zero = TRUE) {
    res <- substr(as.character(x), 1, 1)
    if (exclude_zero) {
        res <- res[res != 0]
    }
    return(as.numeric(res))
}

.extract_lsd <- function(x, exclude_zero = FALSE) {
    x <- as.character(x)
    res <- substr(x, nchar(x) - 1 + 1, nchar(x))
    if (exclude_zero) {
        res <- res[res != 0]
    }
    return(as.numeric(res))
}

.gen_fsd_expected_distribution <- function(x) {
    expected_dist <- log10(1 + (1/1:9)) * length(x)
    observed_dist <- as.numeric(table(factor(x, levels = 1:9)))
    return(data.frame(digit = 1:9, expected_dist, observed_dist))
}

.gen_lsd_expected_distribution <- function(x) {
    expected_dist <- 1/10 * length(x)
    observed_dist <- as.numeric(table(factor(x, levels = 0:9)))
    return(data.frame(digit = 0:9, expected_dist, observed_dist))
}

.gen_scores <- function(info) {
    friends_fsd_dist <- .gen_fsd_expected_distribution(.extract_fsd(info$friends_count))
    friends_lsd_dist <- .gen_lsd_expected_distribution(.extract_lsd(info$friends_count))
    statuses_fsd_dist <- .gen_fsd_expected_distribution(.extract_fsd(info$statuses_count))
    statuses_lsd_dist <- .gen_lsd_expected_distribution(.extract_lsd(info$statuses_count))
    followers_fsd_dist <- .gen_fsd_expected_distribution(.extract_fsd(info$followers_count))
    followers_lsd_dist <- .gen_lsd_expected_distribution(.extract_lsd(info$followers_count))
    res <- list(friends_fsd = friends_fsd_dist, statuses_fsd = statuses_fsd_dist, followers_fsd = followers_fsd_dist, friends_lsd = friends_lsd_dist, statuses_lsd = statuses_lsd_dist, followers_lsd = followers_lsd_dist, info = info, friends_benford = benford.analysis::benford(info$friends_count, number.of.digits = 1), statuses_benford = benford.analysis::benford(info$statuses_count, number.of.digits = 1), followers_benford = benford.analysis::benford(info$followers_count, number.of.digits = 1))
    return(res)
}

#' @export
create_totervogel <- function(user_id, followers = FALSE) {
    if (followers) {
        info <- .get_followers_info(user_id)
    } else {
        info <- .get_friends_info(user_id)
    }
    if (nrow(info) == 0) {
        stop("No data.")
    }
    res <- .gen_scores(info)
    res$user_id <- user_id
    res$followers <- followers
    class(res) <- append("totervogel", class(res))
    return(res)
}

.emit_correlation <- function(x, digits = 3) {
    cat(cli::style_bold("Correlation: "), cli::cli_format(cor(x$expected_dist, x$observed_dist), style = list(digits = digits)), "/ ")
}

.emit_chi <- function(x, digits = 3) {
    cat(cli::style_bold("Chi-sq: "), cli::cli_format(x, style = list(digits = digits)), "\n")
}

#' @export
print.totervogel <- function(totervogel, ...) {
    cli::cli_h2(paste0(totervogel$user_id))
    cli::cat_bullet(c(paste0("Type:", ifelse(totervogel$followers, "Followers", "Friends")), paste0("Total: ", nrow(totervogel$info))))
    cli::cli_h2("First significant digit")
    cli::cli_h3("Friends")
    .emit_correlation(totervogel$friends_fsd)
    .emit_chi(totervogel$friends_benford$stats$chisq$statistic)
    cli::cli_h3("Statuses")
    .emit_correlation(totervogel$statuses_fsd)
    .emit_chi(totervogel$statuses_benford$stats$chisq$statistic)
    cli::cli_h3("Followers")
    .emit_correlation(totervogel$followers_fsd)
    .emit_chi(totervogel$followers_benford$stats$chisq$statistic)
    cli::cli_h2("Last significant digit")
    cli::cli_h3("Friends")
    .emit_chi(chisq.test(totervogel$friends_lsd$observed_dist, p = rep(0.1, 10))$statistic)
    cli::cli_h3("Statuses")
    .emit_chi(chisq.test(totervogel$statuses_lsd$observed_dist, p = rep(0.1, 10))$statistic)
    cli::cli_h3("Followers")
    .emit_chi(chisq.test(totervogel$followers_lsd$observed_dist, p = rep(0.1, 10))$statistic)
}

#' @export
plot.totervogel <- function(totervogel, ...) {
    friends_df <- totervogel$friends_fsd
    friends_df$type <- "friends"
    followers_df <- totervogel$followers_fsd
    followers_df$type <- "followers"
    statuses_df <- totervogel$statuses_fsd
    statuses_df$type <- "statuses"
    res <- rbind(friends_df, followers_df, statuses_df)
    res$digittype <- "First significant digit"
    friends_df <- totervogel$friends_lsd
    friends_df$type <- "friends"
    followers_df <- totervogel$followers_lsd
    followers_df$type <- "followers"
    statuses_df <- totervogel$statuses_lsd
    statuses_df$type <- "statuses"
    res2 <- rbind(friends_df, followers_df, statuses_df)
    res2$digittype <- "Last significant digit"
    rbind(res, res2) %>% tidyr::pivot_longer(tidyr::ends_with("dist"), names_to = "Distribution", values_to = "value") %>% ggplot2::ggplot(ggplot2::aes(x = digit, y = value, color = Distribution)) + ggplot2::geom_line() + ggplot2::geom_point() + ggplot2::facet_grid(rows = ggplot2::vars(digittype), cols = ggplot2::vars(type), scales = "free_y") + ggplot2::ggtitle(totervogel$user_id, subtitle = paste0("Type:", ifelse(totervogel$followers, "Followers", "Friends"))) + ggplot2::ylab("Frequency") + ggplot2::scale_x_continuous(breaks = seq(0, 9)) + ggplot2::scale_color_brewer(palette = "Dark2")
}
