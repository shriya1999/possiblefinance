#### UNCOMMENT TO DOWNLOAD THE REQUIRED DATASETS FROM DROPBOX ####

#dropBoxURL ="https://www.dropbox.com/sh/g4njljbb299t0tp/AAAYIwsvBoYahdiAAuawngpGa?dl=1"
#destFile = "downloadMile2.zip"
#curl::curl_download(dropBoxURL,destFile)
#zip::unzip(destFile, exdir = "Milestone2")


fraudsterIdentification = function(output_1){
customer_list = read.csv(file.path("Milestone2","liveCustomerList.csv"))
customer_list$custID = as.character(customer_list$custID)

joinedlist = left_join(output_df1, customer_list, by = c("loginID" = "custID"))
joinedlist$name = paste(toupper(joinedlist$firstName), toupper(joinedlist$lastName), sep = " ")


fraud_list = read.csv(file.path("Milestone2","liveFraudList.csv"))
fraud_list$name = paste(fraud_list$firstName, fraud_list$lastName, sep = " ")


merged_df = left_join(joinedlist, fraud_list, by="name")

merged_df$not_a_fraudster = ifelse(!is.na(merged_df$firstName.y) & !is.na(merged_df$lastName.y), "0", "1")

results_ms2 = merged_df %>% select(loginID,bankAcctID, not_a_fraudster,verifiedID)

assign("output_df2", results_ms2, envir = globalenv())

return(results_ms2)

}



