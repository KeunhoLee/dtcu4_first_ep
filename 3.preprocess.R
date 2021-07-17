library("tidytext")
library("tidyr")
library("dplyr")
library("stringr")
library("Elbird")

DATA_ROOT <- './data'

# useful ------------------------------------------------------------------
get_latest_data <- function(source, data_root=DATA_ROOT){
  
  data_list <- list.files(data_root, full.names = TRUE) %>%
    grep(source, ., value=TRUE) %>%
    sort(decreasing = TRUE)
  
  return(data_list[1])
  
}

# Twitter -----------------------------------------------------------------
get_text_twitter <- function(twitter_df){

  twitter_df %>%
    filter( created_at > as_datetime("2021-07-11 13:40:00") ) %>%
    mutate(id=row_number()) %>%
    select( id, text )
}

rmURLs <- function(x) { gsub("(f|ht)tp(s?)://\\S+", "", x, perl=T) }
rmTag <- function(x) { gsub("(@[A-Za-z가-힣0-9_]+)", "", x, perl=T) }
rmEmoji <- function(x) { gsub("[\U00010000-\U0010FFFF]+", "", x, perl=T) }
toSpace <- function(x, pattern) { gsub(pattern, " ", x) }

preprocess_text <- function(text_df) {
  
  text_df %>%
    mutate(text=rmURLs(text),
              text=rmTag(text),
              text=rmEmoji(text),
              text=toSpace(text, "\n"),
              text=toSpace(text, "[^가-힣A-Za-z]"),
              text=gsub(" +", " ", text),
              text=trimws(text),
              text=toupper(text))
  
}

tokenize_text <- function(text_df) {
  
  text_df %>% 
    unnest_tokens(
      input = text,
      output = word,
      token = analyze_tidy
    ) %>%
    separate(word, sep="/", into=c("word", "morph"))
  
}

# -------------------------------------------------------------------------
twitter_text <- readRDS(get_latest_data("twitter_")) %>%
  get_text_twitter()

twitter_text <- preprocess_text(twitter_text)

read_user_dict("./user_dict.txt")

twitter_word <- tokenize_text(twitter_text)

target_morph <- c("nng", "nnp", "va", "xr", "sl", "@")

synonym <- data.table::fread("synonym.csv", encoding = "UTF-8")
synonym_dict <- NULL

for (i in 1:dim(synonym)[1]){
  # print(i)
  synonym_dict[synonym$og[i]] <- synonym$synonym[i]
  
}

processed_word <- twitter_word %>%
  filter(morph %in% target_morph,
         word!="같") %>%
  mutate(word=ifelse(morph=="va", paste0(word,"다"), word),
         word=ifelse(word %in% names(synonym_dict),
                     synonym_dict[word],
                     word),
         word=toupper(word)) %>%
  count(word) %>%
  filter(nchar(word)>1,
         n>10) %>%
  rename(freq=n) %>%
  arrange(desc(freq))




