
process_text <- function(input_text) {
  cat("Processing text:", input_text, "\n")
}

input_text <- "default_value" 
if (!is.null(storedText())) {
  input_text <- storedText()
}

process_text(input_text)
print(input_text)

#assign("input_data", input_url, envir = globalenv())

source("identityVerification.R")
source("fraudsterIdentification.R")
source("bankAcctVerification.R")
source("payDayPrediction.R")

output_1 = identityVerification(input_text)

output_2 = fraudsterIdentification(output_1)

output_3 = bankAcctVerification(output_2)

output_5 = payDayPrediction(output_3)

output_5$date = NA


for (i in 1:nrow(output_5)) {
  if (any(output_5[i, c("verifiedID", "not_a_fraudster", "rightAcctFlag")] == 0)) {
    output_5[i, "date"] <- NA
  } else {
    output_5[i, "date"] <- output_5[i, "predicted_date"]
  }
}

FINAL = output_5 %>% select("loginID","date")

op_filename = basename(input_text)
op_filename = sub("\\?.*", "", op_filename)
op_filename = sub(".zip", "", op_filename)
op_filename = paste0(op_filename[[1]][1],".csv")

write.csv(FINAL, op_filename, row.names = FALSE)






