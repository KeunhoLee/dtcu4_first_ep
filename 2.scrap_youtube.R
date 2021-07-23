library('rvest')
library('RSelenium')
library('stringr')
library('dplyr')
library('lubridate')

DATA_ROOT <- "./data"
SRC_ROOT <- "."
SOURCE_NAME <- "youtube"

timestamp <- strftime(now(), format="%Y%m%d%H%M%S")
file_name <- str_interp("${DATA_ROOT}/${SOURCE_NAME}_${timestamp}.rds")

# source functions --------------------------------------------------------
source(str_interp('${SRC_ROOT}/youtube_utils.R'), encoding = 'UTF-8')

# code run ----------------------------------------------------------------
#remDr$server$stop()
#remDr$client$open()
# remDr$client$screenshot(display = TRUE)
remDr <- fn_start_driver(4443L)

# URL
MAIN_URL <- "https://www.youtube.com/watch?v=Tnp_2FceTlQ"

init_page_to_crawl(remDr, MAIN_URL)

open_all_details(remDr)

reply_list <- list()

# open_all_details(remDr)

page_src <- remDr$client$getPageSource()

replies <- get_replies(page_src)

remDr$server$stop()
remDr$client$close()
rm(remDr)
gc()

# save result -------------------------------------------------------------

saveRDS(replies, file_name)