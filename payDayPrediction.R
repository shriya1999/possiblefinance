library(dplyr)
library(lubridate)

## UNCOMMENT TO DOWNLOAD DATASETS ##

#dropBoxURL_M5 ="https://www.dropbox.com/sh/moduebxwqz4qfmd/AABeqzUBJbFUTqNfA286s7Eqa?dl=1"
#destFile_M5 = "downloadM5.zip" 
#curl::curl_download(dropBoxURL_M5,destFile_M5,mode="wb") 
#zip::unzip(destFile_M5, exdir = "Milestone5")

payDayPrediction = function(output_3){

bank_accounts = output_3
start_balance = read.csv(file.path("Milestone5","startBalance.csv"))
bank_transaction = read.csv(file.path("Milestone5","bankTransactions.csv"))

start_balance$bankAcctID = as.character(start_balance$bankAcctID)
bank_transaction$bankAcctID = as.character(bank_transaction$bankAcctID)

startbal_acct = left_join(bank_accounts,start_balance,by=c("bankAcctID"="bankAcctID"))
transactions_acct = left_join(bank_accounts,bank_transaction,by=c("bankAcctID"="bankAcctID"))

colnames(transactions_acct)[colnames(transactions_acct) == "transAmount"] = "amt"

bal_transactions = rbind(startbal_acct,transactions_acct)


salary_data = bal_transactions %>% filter(amt>200) %>% arrange(by=bankAcctID)
salary_filterdata = salary_data %>% filter(date >= as.Date("2020-01-01") & date <= as.Date("2020-04-30"))
salary_filterdata$date = as.Date(salary_filterdata$date)
salary_filterdata = salary_filterdata %>% mutate(day_of_week = format(date, "%a"))


salary_filterdata$date = as.Date(salary_filterdata$date)
salary_groupeddata = salary_filterdata %>% group_by(bankAcctID) %>% arrange(bankAcctID, date)
lastTwoTransactions = salary_groupeddata %>% group_by(bankAcctID) %>% slice_tail(n = 2)
paydate_diff = lastTwoTransactions %>% group_by(bankAcctID) %>% summarise(predicted = as.numeric(diff(date)))

salary_filterdata$date = as.Date(salary_filterdata$date)
grouped_data <- salary_filterdata %>% group_by(bankAcctID) %>% arrange(bankAcctID, desc(date))
latest_dates <- grouped_data %>% group_by(bankAcctID) %>% slice_head(n = 1)

merged_data <- latest_dates %>% left_join(paydate_diff, by = "bankAcctID") %>% 
  mutate(predicted_date = date + predicted, predicted_day_of_week = format(predicted_date, "%a")) %>% ungroup()
merged_data$predicted_date = as.Date(merged_data$predicted_date)



merged_data <- merged_data %>% mutate(predicted_date = ifelse(weekdays(predicted_date) %in% c("Saturday", "Sunday"), 
                                                              ifelse(weekdays(predicted_date) == "Saturday", 
                                                                     predicted_date - 1, 
                                                                     predicted_date - 2), 
                                                              predicted_date))

merged_data$predicted_date = as.Date(merged_data$predicted_date,origin = "1970-01-01")
merged_data$predicted_day_of_week = format(merged_data$predicted_date, "%a")

results_ms5 = merged_data %>% select("bankAcctID","predicted_date","loginID","rightAcctFlag","not_a_fraudster","verifiedID")

assign("output_df5", results_ms5, envir = globalenv())

return(results_ms5)

}


