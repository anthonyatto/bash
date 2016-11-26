#!/usr/local/bin/Rscript --vanilla
# SHEBANG tells bash what 'program' (or command) to use.

#### OBJECTIVE ####
# practice setting up a cronjob
# practice sending emails via R using gmailr

#### REFERENCES ####
# https://github.com/jennybc/send-email-with-r
# https://help.ubuntu.com/community/CronHowto
# https://github.com/richfitz/remoji
# http://stackoverflow.com/questions/16257175/convert-system-output-into-a-vector
# http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
# http://stackoverflow.com/questions/35351443/rvest-html-nodes-error-cannot-coerce-type-environment-to-vector-of-type-l

#### PACKAGES ####
suppressPackageStartupMessages(require(gmailr))
suppressPackageStartupMessages(require(htmltools))
suppressPackageStartupMessages(require(remoji))
suppressPackageStartupMessages(require(stringr))
suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(httr))
suppressPackageStartupMessages(require(rvest))
suppressPackageStartupMessages(require(methods))

#### KEY VARIABLES ###
# get directory and name of this script
initial.options <- commandArgs(trailingOnly = FALSE)
script_directory <- str_subset(initial.options, "--file=") %>% str_replace("--file=","")
script_name <- script_directory %>% str_split("/") %>% unlist() %>% last()

# get matching cronjob and crontime
cron <- system("crontab -l", intern=TRUE) %>% str_subset(script_name)
cron_time <- str_sub(cron, start=1, end = cron %>% str_locate_all(" ") %>% unlist() %>% max() - 1) %>% str_replace_all(" ", "+")
  
# create link to convert cron time to human readable
hr_time <- GET(paste0("http://cronexpressiondescriptor.azurewebsites.net/?Language=en-US&DayOfWeekStartIndexOne=false&Use24HourFormat=false&VerboseDescription=false&Expression=", cron_time)) %>% content("parsed") %>% html_node("#description") %>% html_text() %>% trimws()

#### EMAIL ####
# authenticate gmail account using gmailid stored in .ssh folder
use_secret_file("~/.ssh/gmailR_id.json")

# draft email
email <- mime() %>%
  to("anthony.richard.atto@gmail.com") %>%
  from("anthony.richard.atto@gmail.com") %>%
  subject("nerding out") %>% 
  html_body(HTML(paste0(
    "hey anthony, <br><br>
    this is a note from yourself reminding you that you are awesome.  <br><br>
    in case you were wondering, this email was sent at ", tolower(date()), ".  further, gmailr is a very handy package.  lastly, the script that generated this email can be found at <code>", script_directory, "</code> and will be sent via a cronjob ", tolower(hr_time), ".  <br><br>
    MAJOR ", emoji("key"))))

# send email
send_message(email)

