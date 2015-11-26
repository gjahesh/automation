
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(RColorBrewer)
library(gplots)

#Exploring the clean candy data with some plots

candy_tidy <- read_csv("candy_clean.csv")

candy_count<- candy_tidy %>% group_by(candy, age)%>% tally()

# plotting the reordered number of responses for each age.

ggplot(candy_count, aes(x = reorder(age,candy), y = age, fill = n))+
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust =1 ,size = 6))+
  geom_tile(stat = "identity")+ggtitle("Number of responses vs age-reordered")+
  scale_size_area()+ggsave("resp_reorder_age.png")

#Function`candy_score` is defined for calculating the score of candy likability responses

candy_score <-  function(dat, na.rm = TRUE){
  total_score = dat$score %>% sum
  score_ratio = total_score/nrow(dat)
  data.frame(score_ratio)
}

# function `age_grouper` is grouping the age range of respondents.

age_grouper <-  function(x, na.rm = TRUE){
  
  c <- quantile(x ,probs = seq(0,1,0.25), na.rm = TRUE)
  #  0%  25%  50%  75% 100% 
  # 10   29   35   44  120 
  l <- sapply(x, function(n){
    
    if(n <= c[1] ){
      1
    } else if (n<=c[2]){
      2
    } else if (n<=c[3]){
      3
    } else if (n<=c[4]){
      4
    } else if (n<=c[5]){
      5
    }
  })
  unlist(l)
}

# Applying the defined functions to candy_clean

candy_grouped_scores <- candy_tidy %>% mutate(ageGroups = age_grouper(age))%>%
  group_by(ageGroups, candy) %>% filter(score %>% is.na %>% !.) %>%
  do(candy_score(.)) %>% spread(candy,score_ratio) %>%select(-1) 

# CLustering the candy_grouped_scores and plotting it.

candy_grouped_scores %>% t %>% dist  %>% hclust %>% .$labels

png("heatmap_candy_age_group.png")
pal <- colorRampPalette(brewer.pal(n = 9,"RdBu"))
candy_grouped_scores %>% as.matrix %>% heatmap.2(col = pal,scale = "none", trace = "none")
dev.off()

# Trick or treat ?

candy_grouped_trick <- candy_tidy %>%
  mutate(ageGroups = age_grouper(age))%>%
  group_by(ageGroups,trick_treat) %>% tally() %>% 
  mutate(trick_ratio = n/sum(n)) 

ggplot(candy_grouped_trick, aes(x = ageGroups, y= trick_ratio,
                                fill = trick_treat))+
  geom_bar(stat = "identity",position = "dodge")+
  ggtitle("Trick or treat ratio for age groups")+ggsave("trick_treat_age_group.png")


# Writing candy_grouped_scores to a file
write_csv(candy_grouped_scores,"candy_grouped_scores.csv")

