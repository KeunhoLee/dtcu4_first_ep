# install.packages("widyr")
# install.packages("tidygraph")
# install.packages("ggraph")
# install.packages("showtext")

library("widyr")
library("tidygraph")
library("ggraph")
library("showtext")

SOURCE_NAME <- "youtube"

texts <- readRDS(get_latest_data(SOURCE_NAME)) %>%
  get_text(SOURCE_NAME)

texts <- preprocess_text(texts)

words <- tokenize_text(texts)
# -------------------------------------------------------------------------

target_morph <- c("nng", "nnp", "va", "xr", "sl", "@")

pair <- words %>%
  mutate(word=ifelse(morph=="va", paste0(word,"다"), word),
                       word=ifelse(word %in% names(synonym_dict),
                                   synonym_dict[word],
                                   word),
                       word=toupper(word)) %>%
  filter(word!="대탈출",
         word!="같다",
         nchar(word)>1,
         morph %in% target_morph) %>%
  pairwise_count(item=word,
                 feature=id,
                 sort=T)


# 관련없는 키워드 삭제
trash <- c("LT", "GT",
           "결제", "티빙",
           "유니", "버스",
           "피오", "블락비", "BLOCKB",
           "같다",
           "인성", "최고", "신사", "축하", "생일", "HAPPYINSEONGDAY")

set.seed(1)
graph_component <- pair %>%
  filter(n>7,
         !((item1 %in% trash) & (item1 %in% trash))) %>%
  as_tbl_graph(directed=FALSE) %>%
  mutate(centrality=centrality_degree(),
         group=as.factor(group_infomap()))

ggraph(graph_component,
      layout="nicely") +
  geom_edge_link(color="gray50",
                 alpha=.5) + 
  geom_node_point(aes(color=group,
                  size=centrality),
                  show.legend = FALSE) +
  scale_size(range=c(5, 15)) +
  geom_node_text(aes(label=name),
                 repel=TRUE,
                 size=5,
                 family="naumgothic") +
  theme_graph()


# twitter_word %>%
#    left_join(twitter_text, by="id") %>%
#   filter(word=="시즌") %>% View
