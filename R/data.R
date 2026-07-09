# Shipped data ----

#' Kirkland & Coppock (2018) YouGov candidate conjoint
#'
#' The YouGov sample (Study 2) from Kirkland and Coppock's study of candidate
#' choice, in the **profile-long** form this package expects as input: one row
#' per candidate profile per choice task, two profiles per task. Respondents made
#' repeated binary forced choices between pairs of hypothetical candidates
#' described by randomized attributes.
#'
#' This is the shape your own data should be in before calling [as_tasks()]: a
#' set of columns that key the profile (respondent, task, profile index), a
#' binary `chosen` indicator, and one column per randomized attribute. Attribute
#' columns may be `NA` when a feature was not shown in a given condition (here
#' `party` and `occupation` are shown only to some respondents, which is the
#' substantive point of the study).
#'
#' @format A tibble with 11,432 rows (5,716 tasks x 2 profiles) and 11 columns:
#' \describe{
#'   \item{respondent}{Integer respondent id.}
#'   \item{task}{Integer task number within respondent (1-5).}
#'   \item{profile}{Profile index within task, 1 or 2.}
#'   \item{chosen}{1 if this profile was chosen in its task, else 0. Exactly one
#'     profile is chosen per task.}
#'   \item{party}{Candidate party: "Democrat", "Republican", "Independent", or
#'     `NA` in the nonpartisan condition.}
#'   \item{gender}{Candidate gender: "man" or "woman".}
#'   \item{race}{Candidate race: "White", "Black", "Hispanic", or "Asian".}
#'   \item{age}{Candidate age: "younger" or "older".}
#'   \item{occupation}{Candidate occupation: "business", "professional",
#'     "teacher", "working class", or `NA` when not shown.}
#'   \item{experience}{Political experience: "prior experience" or
#'     "no experience".}
#'   \item{resp_party}{Respondent's party identification (a respondent-level
#'     covariate, constant within respondent): "Democrat", "Republican", or
#'     "Independent". Useful for subgroup analyses.}
#' }
#' @source Kirkland, P. A., & Coppock, A. (2018). Candidate Choice without Party
#'   Labels: New Insights from Conjoint Survey Experiments. *Political Behavior*,
#'   40(3), 571-591. \doi{10.1007/s11109-017-9414-8}
#' @examples
#' head(kc_yougov)
#' # reshape to task-wide, then extract a partisan matchup
#' tasks <- as_tasks(kc_yougov,
#'                   task_keys = c("respondent", "task"),
#'                   profile = "profile", outcome = "chosen")
#' get_matchups(tasks, A = list(party = "Democrat"),
#'              B = list(party = "Republican"), outcome = "chosen")
"kc_yougov"
