twitter_text <- readRDS(get_latest_data("twitter_")) %>%
  get_text_twitter()

twitter_text <- preprocess_text(twitter_text)

twitter_text %>%
  unlist() %>%
  write.table("twitter_text.txt", row.names = FALSE)
