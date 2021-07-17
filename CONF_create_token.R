library("rtweet")

app_name <- "GreatEscapeAnalysis"
consumer_key <- "TqGEL0FKVoN295NnnIffxTVMV"
consumer_secret <- "6Tml9uwxHFGtbftcATS8AHzkTC4EyRCNrr5pLGcDok8MfbnALJ"
access_token <- "1414419484610232324-qwsRHZL2TWwXwE9PFagmIr3aBtKsQf"
access_secret <- "w6Tahcg4gls2Cd0w2wJPOvtUinCqE3BNXPSEipqiDQfUx"

twitter_token <- create_token(
  app = app_name,
  consumer_key = consumer_key,
  consumer_secret = consumer_secret,
  access_token = access_token,
  access_secret = access_secret
)

saveRDS(twitter_token, "twitter_token.rds")
