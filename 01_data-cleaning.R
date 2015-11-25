
library(readr)
suppressPackageStartupMessages(library(dplyr))
library(tidyr)
library(stringr)
library(magrittr)

## read the raw candy data and fix the Timestamp to m/d/y and H/M/S format
raw <- read_csv("candy_raw.csv")
raw <- read_csv("candy_raw.csv",
                col_types = cols(
                  Timestamp = col_datetime("%m/%d/%Y %H:%M:%S")
))

## adding ID for each response ( for each row), then selecting the variables

raw_id_age <- raw %>%
  mutate(id = sprintf("ID%04d", row_number())) %>% 
  select(id,age = matches("How old are you"), everything())

#A mini `tbl_df` `mini_data` is defined by selecting the `id`, 
#`age = 'How old are you`,`trick_treat = "Are you actually going trick or treating?"` 
# and all the columns with candy values. The later is done by detecting `[]` in the column names.

mini_data <- raw_id_age %>%
  select(id,age , trick_treat = matches("Are you going actually going trick or treating yourself?"),
         one_of(grep("^\\[", colnames(raw_id_age),value = TRUE)))

# Then `mini_data`'s candy names are replaced with the clean candy names.

raw_clean_names <- data_frame(orig_name = names(raw_id_age)) %>% 
  mutate(is_candy = str_detect(orig_name,"^\\["),   #detecting the brackets
         new_name = gsub("\\[|\\]","", orig_name), #removing the brackets
         new_name = gsub('\\W','_', new_name))      #replacing all non alphnum with '_' 

candy_names <- raw_clean_names %>% filter(is_candy) #filtering only the candy values

#replacing the mini data frame (mini_data) with the clean candy names
colnames(mini_data) <- c("id", "age", "trick_treat",candy_names$new_name) 

# filtering the age column in mini_data
candy_clean <- mini_data %>% select(id, age = na.omit(age),everything()) %>%
  mutate(age = as.integer(age))%>% filter(age,(!is.na(age)& age>=10 &age<= 120))

# Turning trick_treat column to a logical variable
candy_clean%<>%mutate(trick_treat = trick_treat == "Yes")

# Data reshaping with gather() which turns the candy variable to a factor with 95 levels
# joy and score are added as two variables , where score is the int value of "Joy/Despair".
candy_tidy <- gather(candy_clean,"candy","joy",4:98) %>%
  mutate(joy = joy == "JOY",score = as.integer(joy))

# Writing candy_tidy to a file

write_csv(candy_tidy,"candy_clean.csv")
