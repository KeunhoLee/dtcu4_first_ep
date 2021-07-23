
# base --------------------------------------------------------------------
rand_delay <- function(mean_delay=0.5){
  
  Sys.sleep(rexp(1,1/mean_delay))
  
}

fn_start_driver <- function(port = 4445L, browser = "chrome", chromever = "91.0.4472.101"){
  
  eCaps <- list(chromeOptions = list(
    args = c('--window-size=1280,800', '--headless','--disable-gpu') # '--window-size=1280,800'
  ))
  
  remDr <- rsDriver(port = port, browser = browser, chromever = chromever)#, extraCapabilities = eCaps)
  
  return(remDr)
}

init_page_to_crawl <- function(remDr, url, sleep_time = 3){
  
  remDr$client$navigate(url)
  Sys.sleep(1) # wait 1 sec to load page
  last_scroll_height <- remDr$client$executeScript('return document.documentElement.scrollHeight')[[1]]
  
  if(sleep_time > 0) {
    
    while(TRUE){
      
      remDr$client$executeScript('window.scrollTo(0, document.documentElement.scrollHeight);')
      Sys.sleep(sleep_time)
      new_scroll_height <- remDr$client$executeScript('return document.documentElement.scrollHeight')[[1]]
      
      if(new_scroll_height == last_scroll_height){
        break
      } else {
        last_scroll_height <- new_scroll_height
      }
      
    }
  }
  
}

open_all_details <- function(remDr){
  
  # 자세히 보기를 누르지 않아도 내용을 가져 올 수 있다.
  # more_detail_buttons <- remDr$client$findElements(using = 'xpath', '//paper-button[@id="more"]')
  # for(i in 1:length(more_detail_buttons)){
  #   
  #   print(paste('More detail :', length(more_detail_buttons)))
  #   more_detail_buttons[[i]]$clickElement()
  #   print(paste('detail', i))
  #   rand_delay(1)
  # }
  
  more_reply_buttons <- remDr$client$findElements(using = 'xpath', '//ytd-button-renderer[@id="more-replies"]')
  
  print(paste('More reply :', length(more_reply_buttons)))
  
  for(i in 1:length(more_reply_buttons)){
    
    more_reply_buttons[[i]]$clickElement()
    print(paste('reply', i))
    rand_delay(0.5)
  }
}

get_replies <- function(page_src){
  
  reply_html <- read_html(page_src[[1]]) 
  
  if(is_stop_reply(reply_html)){
    return(NULL)
  }
  
  reply_html <- reply_html %>%
    html_nodes(xpath = '//ytd-item-section-renderer/div[@id="contents"]') %>%
    html_nodes(xpath = 'ytd-comment-thread-renderer') #%>% length
  
  result <- data.frame()
  
  for( i in 1:length(reply_html)){
    
    # 댓글쓴이  
    reply_author <- reply_html[i] %>% 
      html_nodes(css="#author-text") %>%
      html_text %>%
      gsub('\n', '', .) %>%
      gsub(' ', '', .)
    
    # 댓글
    reply_comment <- reply_html[i] %>%
      html_nodes(css="#content") %>% 
      html_text %>%
      gsub('\n', ' ', .) %>%
      gsub(' +', ' ', .) %>%
      trimws
    
    
    # 댓글
    reply_like <- reply_html[i] %>%
      html_nodes(css="#vote-count-middle") %>% 
      html_text %>%
      gsub('[^0-9]', '', .) %>%
      as.numeric
    
    # 댓글 좋아요/ 나빠요
    
    result <- rbind(result, data.frame(reply_author = reply_author,
                                       reply_comment = reply_comment,
                                       reply_like = reply_like,
                                       reply_id = i,
                                       reply_sub_id = 1:length(reply_comment)))
    
  }
  
  result$timestamp <- now() 
  
  return(result)
}
