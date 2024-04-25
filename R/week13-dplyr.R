# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)
library(tidyverse)

# Data Import and Cleaning
conn <-dbConnect(MariaDB(),  
                 user="hazbo002",
                 password=key_get("latis-mysql","hazbo002"),  
                 host="mysql-prod5.oit.umn.edu",
                 port=3306,
                 ssl.ca = 'mysql_hotel_umn_20220728_interm.cer')

result1 <- dbGetQuery(conn,"SHOW DATABASES;")
result2 <- dbExecute(conn, "USE cla_tntlab;")
result3 <- dbGetQuery(conn, "SHOW TABLES;")
result4 <- dbGetQuery(conn, "SELECT * FROM datascience_employees")
result5 <- dbGetQuery(conn, "SELECT * FROM datascience_offices")
result6 <- dbGetQuery(conn, "SELECT * FROM datascience_testscores")

employees_tbl <- as_tibble(result4) 
offices_tbl <- as_tibble(result5)
testscores_tbl <- as_tibble(result6)


# write_csv(employees_tbl,  "../data/employees.csv")
# write_csv(offices_tbl,  "../data/offices.csv")
# write_csv(testscores_tbl,  "../data/testscores.csv")

week13_tbl_part1<- right_join(employees_tbl,testscores_tbl, by=join_by(employee_id)) 
week13_tbl <- left_join(week13_tbl_part1,offices_tbl, by=join_by(city==office))

# write_csv(week13_tbl, "../out/week13.csv")
