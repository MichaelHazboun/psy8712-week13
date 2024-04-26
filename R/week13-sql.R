# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)

# Data Import and Cleaning
conn <-dbConnect(MariaDB(),  #Connecting to UMN sql
                 user="hazbo002",
                 password=key_get("latis-mysql","hazbo002"),  
                 host="mysql-prod5.oit.umn.edu",
                 port=3306,
                 ssl.ca = '../mysql_hotel_umn_20220728_interm.cer') #was sad, needed to add the ../ after changing the wd to where the r file is located...

dbExecute(conn, "USE cla_tntlab")

# result1 <- dbGetQuery(conn,"SHOW DATABASES;") #( I was too lazy to call IT to download the SQLworkbook thing so I'm doing it this way, the first three results are so I understand the data)
# result2 <- dbExecute(conn, "USE cla_tntlab;")
# result3 <- dbGetQuery(conn, "SHOW TABLES;")
# result4 <- dbGetQuery(conn, 
                      "SELECT *
                      FROM datascience_employees") #Just to see things again
# result5 <- dbGetQuery(conn, 
                      "SELECT *
                      FROM datascience_testscores")
# result6 <- dbGetQuery(conn, 
                      "SELECT *
                      FROM datascience_offices")



#Analysis
##1
#wow_count is 549
result7 <- dbGetQuery(conn, 
                      "SELECT COUNT(*) AS wow_count
                      FROM datascience_employees
                      RIGHT JOIN datascience_testscores
                      ON datascience_employees.employee_id=datascience_testscores.employee_id;")
result7
# did the join (this removes the ones that didn't have a test score), then I counted the number of IDS

##2
#wow_count is 549 (again)
to_see_1 <- dbGetQuery(conn, 
                       "SELECT *
                        FROM datascience_employees e
                        RIGHT JOIN datascience_testscores t
                        ON e.employee_id=t.employee_id;")


result8_for_part_2 <- dbGetQuery(conn,
                                 "SELECT COUNT(DISTINCT datascience_employees.employee_id) AS wow_count
                                 FROM datascience_employees
                                 RIGHT JOIN datascience_testscores
                                 ON datascience_employees.employee_id=datascience_testscores.employee_id;")

result8_for_part_2
# did the join (this removes the ones that didn't have a test score), then I counted the distinct number of IDS

##3
# city wow_count  #I accidentally clicked something when I was copying and reordered them so the output is the same numbers and cities, but different order of the pairs
# Chicago 61
# Houston 20
# New York 183
# Orlando 20
# San Francisco 48
# Toronto 189

result9_for_part_3 <- dbGetQuery(conn, 
                                 "SELECT city, COUNT(datascience_employees.employee_id) AS wow_count
                                 FROM datascience_employees
                                 RIGHT JOIN datascience_testscores
                                 ON datascience_employees.employee_id=datascience_testscores.employee_id
                                 WHERE manager_hire<>'Y'
                                 GROUP BY city;")
result9_for_part_3
#did the join, filtered out the hired as managers, grouped by city, selected city and counted the employee ids (based off of the filtering and grouping)


##4
# performance_group   avg_yrs_employed    SD_yrs_employed
# Bottom              4.74206             0.5348718
# Middle              4.58061             0.5082812
# Top                 4.32581             0.5989064

result10_for_part_4 <- dbGetQuery(conn, 
                                 "SELECT performance_group ,AVG(yrs_employed) AS avg_yrs_employed, STDDEV(yrs_employed) AS SD_yrs_employed
                                 FROM datascience_employees
                                 RIGHT JOIN datascience_testscores
                                 ON datascience_employees.employee_id=datascience_testscores.employee_id
                                 GROUP BY performance_group;")
result10_for_part_4
#did the join, grouped by performance_group, and calculated both the average and sd for years employed and gave those columns names.

##5
to_see_2 <- dbGetQuery(conn, 
                       "SELECT *
                       FROM datascience_employees
                       RIGHT JOIN datascience_testscores
                       ON datascience_employees.employee_id=datascience_testscores.employee_id 
                       LEFT JOIN datascience_offices
                       ON datascience_employees.city=datascience_offices.office;")

result11_for_part_5 <- dbGetQuery(conn, 
                                  "SELECT type, datascience_employees.employee_id,test_score
                                  FROM datascience_employees
                                  RIGHT JOIN datascience_testscores
                                  ON datascience_employees.employee_id=datascience_testscores.employee_id 
                                  LEFT JOIN datascience_offices
                                  ON datascience_employees.city=datascience_offices.office
                                  ORDER BY type, test_score DESC;")
result11_for_part_5
#did both joins, then I ordered by type and descending order of test score.
