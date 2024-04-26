# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)
library(tidyverse)

# Data Import and Cleaning
conn <-dbConnect(MariaDB(),  #Connecting to UMN sql
                 user="hazbo002",
                 password=key_get("latis-mysql","hazbo002"),  
                 host="mysql-prod5.oit.umn.edu",
                 port=3306,
                 ssl.ca = 'mysql_hotel_umn_20220728_interm.cer')

result1 <- dbGetQuery(conn,"SHOW DATABASES;") #( I was too lazy to call IT to download the SQLworkbook thing so I'm doing it this way, the first three results are so I understand the data)
result2 <- dbExecute(conn, "USE cla_tntlab;")
result3 <- dbGetQuery(conn, "SHOW TABLES;")
result4 <- dbGetQuery(conn, "SELECT * FROM datascience_employees") #Pulled the employees table
result5 <- dbGetQuery(conn, "SELECT * FROM datascience_offices") #Pulled the offices table
result6 <- dbGetQuery(conn, "SELECT * FROM datascience_testscores") #Pulled the test-scores table

employees_tbl <- as_tibble(result4)  #made them into tibbles
offices_tbl <- as_tibble(result5)
testscores_tbl <- as_tibble(result6)


# write_csv(employees_tbl,  "../data/employees.csv") #made them into CSV files
# write_csv(offices_tbl,  "../data/offices.csv")
# write_csv(testscores_tbl,  "../data/testscores.csv")

week13_tbl<- right_join(employees_tbl,testscores_tbl, by=join_by(employee_id)) %>% #made the first part of week13_tbl by joining the employees and testscores tibbles, this was a right join so we only get the employees that have test scores
  left_join(offices_tbl, by=join_by(city==office)) # Added offices because one of the questions needed it

# write_csv(week13_tbl, "../out/week13.csv") #made it into a csv



# Analysis

##1 total number of managers (549)
week13_tbl %>% 
  summarize(n()) #then counted (using count() also worked but according to the help file that gives the unique values so we don't)

##2 total number of unique managers (also 549...)
week13_tbl %>%
  distinct(employee_id)%>% #pulled the distinct employee_ids
  count() #counted *wow*

##3 Display a summary of the number of managers split by location, but only include those who were not originally hired as managers.
# city              n
# Chicago          61
# Houston          20
# New York        183
# Orlando          20
# San Francisco    48
# Toronto         189
week13_tbl %>%
  filter(manager_hire != "Y") %>% #got rid of hired as managers, then grouped by city and counted
  group_by(city) %>%
  count()

##4 Display the mean and standard deviation of number of years of employment split by performance level (bottom, middle, and top)

# performance_group  mean   sd
# Bottom             4.74   0.537
# Middle             4.58   0.509
# Top                4.33   0.604

week13_tbl %>%
  group_by(performance_group) %>% #grouped by performance group then calculated mean and sd
  summarise(mean=mean(yrs_employed), 
            sd=sd(yrs_employed))

##5 Display each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score.
#not going to paste the output here because it's too big
week13_tbl %>%
  select(type,employee_id,test_score) %>% #selected desired columns, then arranged them in desired order
  arrange(type,desc(test_score))
