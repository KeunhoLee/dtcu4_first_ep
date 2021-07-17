library("rtweet")

app_name <- "insert yours"
consumer_key <- "insert yours"
consumer_secret <- "insert yours"
access_token <- "insert yours"
access_secret <- "insert yours"

twitter_token <- create_token(
  app = app_name,
  consumer_key = consumer_key,
  consumer_secret = consumer_secret,
  access_token = access_token,
  access_secret = access_secret
)

if(!dir.exists("./token")){
  dir.create("./token")
}

saveRDS(twitter_token, "./token/twitter_token.rds")
