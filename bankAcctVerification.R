
## UNCOMMENT TO DOWNLOAD THE REQUIRED DATASETS FOR THIS CODE ##

#dropBox_M3 = "https://www.dropbox.com/sh/rlrv8z10ahyhl8l/AADQs5cFZKxKHUVlyNeAkGjua?dl=1"
#destFile_M3 = "downloadM3.zip" 
#curl::curl_download(dropBox_M3,destFile_M3) 
#zip::unzip(destFile_M3, exdir = "Milestone3")

bankAcctVerification = function(output_2){

loginacct = output_2

customer_list = read.csv(file.path("Milestone3","liveCustomerList.csv"))
bankacct_list = read.csv(file.path("Milestone3","liveBankAcct.csv"))

customer_list$fullname <- paste(toupper(customer_list$firstName), toupper(customer_list$lastName), sep = " ")

bankacct_list$fullname <- paste(toupper(bankacct_list$firstName), toupper(bankacct_list$lastName), sep = " ")

cust_bankacct = inner_join(bankacct_list, customer_list, by = "fullname") %>% select(custID,bankAcctID,fullname)
cust_bankacct$bankAcctID = as.character(cust_bankacct$bankAcctID)
cust_bankacct$custID = as.character(cust_bankacct$custID)


acctverify = left_join(loginacct,cust_bankacct, by=c("bankAcctID"="bankAcctID", "loginID"="custID"))

acctverify$rightAcctFlag <- ifelse(!is.na(acctverify$fullname), "1", "0")

results_ms3 = acctverify %>% select("loginID","bankAcctID","rightAcctFlag","not_a_fraudster","verifiedID")

assign("output_df3", results_ms3, envir = globalenv())

return(results_ms3)

}




