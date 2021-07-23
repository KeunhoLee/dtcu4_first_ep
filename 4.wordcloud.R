library(wordcloud2)
library(webshot)
library(htmlwidgets)

SOURCE_NAME <- "twitter"

# preprocess.R 먼저 실행
processed_word$freq[1] <- min(processed_word$freq[1],
                              processed_word$freq[2]*2)

wc <- wordcloud2(
  processed_word,
  size=1.5,
  color = c("black",
            sample(
              rep_len(gray.colors(20, start = 0, end = .4),
                      nrow(processed_word) - 1),
              nrow(processed_word) - 1
            )),
  backgroundColor = "#FFE400",
  rotateRatio = .4,
  shape = "diamond",
  gridSize = 7,
  ellipticity = .6,
  shuffle=FALSE
)

saveWidget(wc, str_interp("${SOURCE_NAME}_wordcloud.html"), selfcontained = F)
