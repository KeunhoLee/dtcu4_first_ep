library("rtweet")
library("tm")
library("lubridate")
library("stringr")
library("dplyr")
DATA_ROOT <- './data'
SRC_ROOT <- '.'

TOKEN_NAME <- "./token/twitter_token.rds"
LOAD_TOKEN <- TRUE
SOURCE_NAME <- "twitter"
TWEET_N <- 18000
HASHTAG <- "대탈출"


# -------------------------------------------------------------------------
if(LOAD_TOKEN) { twitter_token <- readRDS(TOKEN_NAME) }

if(!dir.exists(DATA_ROOT)){
  dir.create(DATA_ROOT)
}

# -------------------------------------------------------------------------

timestamp <- strftime(now(), format="%Y%m%d%H%M%S")
file_name <- str_interp("${DATA_ROOT}/${SOURCE_NAME}_${timestamp}.rds")

rt <- search_tweets(HASHTAG,
                    n=TWEET_N,
                    include_rts=FALSE,
                    token = twitter_token)

rt %>%
  filter(grepl("^Twitter for", source),
         !grepl("도곡|도구리", text)) %>% # 키워드가 겹치는 의미없는 트윗 삭제  
  select(text, created_at, followers_count) %>%
  saveRDS(file_name)

print(str_interp("Gathered tweets are saved at ${file_name}"))
