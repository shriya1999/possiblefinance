library(dplyr)


identityVerification = function(input_text) {
dropBoxURL_ip = input_text
destFile_ip = "input_m1.zip" 
curl::curl_download(dropBoxURL_ip,destFile_ip) 
zip::unzip(destFile_ip, exdir = "input_m1")

input_path = file.path("input_m1")
input_files = list.files(input_path, full.names = FALSE)
input_files_df = data.frame(picID = input_files)
input_files_df$custID = gsub("\\.jpg", "", input_files_df$picID)
input_files_df$filepath_ip = paste0(input_path,"/",input_files)


library(tidyr)

input_path = "input_m1"
input_files = list.files(input_path, full.names = FALSE)
input_files_df = data.frame(picID = input_files)
input_files_df = separate(input_files_df, picID, into = c("custID", "bankAcctID"), sep = "_", remove = FALSE)
input_files_df$filepath_ip <- file.path(input_path, input_files_df$picID)
input_files_df$picID <- gsub("\\.jpg", "", input_files_df$picID)
input_files_df$bankAcctID <- gsub("\\.jpg", "", input_files_df$bankAcctID)

input_db = input_files_df %>% select(custID,bankAcctID,filepath_ip)


#dropBoxURL_M1 ="https://www.dropbox.com/sh/6a0nlzuzhwl858p/AADSGShTB9oxVq_KauD9ZDLJa?dl=1"
#destFile_M1 = "downloadM5.zip" 
#curl::curl_download(dropBoxURL_M1,destFile_M1,mode="wb") 
#zip::unzip(destFile_M1, exdir = "Milestone1")


known_pics_path = file.path("Milestone1","knownPics-custID_PicID/identityPics-custID_PicID")

file_names = list.files(known_pics_path, full.names = FALSE)
file_names_df = data.frame(picID = file_names)
file_names_df$custID = sub("^(\\w+)_.*", "\\1", file_names_df$picID)
file_names_df$filepath = paste0(known_pics_path,"/",file_names)

picture_db = file_names_df %>% select(custID,filepath)

joined_df = input_db %>% left_join(picture_db, by = "custID")

########################################################################################

library(paws)
library(magick)
library(base64enc)


Sys.setenv(
  AWS_ACCESS_KEY_ID = "your_aws_access_key",
  AWS_SECRECT_ACCESS_KEY = "your_aws_secret_access_key",
  AWS_REGION = "your_aws_region",
  AWS_ENDPOINT_URL = "your_aws_endpoint_url"
)

options("paws.log_level" = 3L)

svc = rekognition()

custID_list = vector("numeric", length = nrow(joined_df))
bankAcctID_list = vector("numeric", length = nrow(joined_df))
confidence_list = vector("numeric", length = nrow(joined_df))


for (i in 1:nrow(joined_df)) {
  source_img = joined_df$filepath_ip[i]
  target_img = joined_df$filepath[i]
  
  
  if (!is.na(target_img)) {
    confidence = 0
    
    compare = svc$compare_faces(
      SourceImage = list(Bytes = source_img),
      TargetImage = list(Bytes = target_img),
      SimilarityThreshold = 0
    )
    
    custID = joined_df$custID[i]
    bankAcctID = joined_df$bankAcctID[i]
    if (length(compare$FaceMatches) > 0) {
      confidence = compare$FaceMatches[[1]]$Similarity
    }
  } else {
    custID = joined_df$custID[i]
    bankAcctID = joined_df$bankAcctID[i]
    confidence = NA
  }
  
  custID_list[i] = custID
  bankAcctID_list[i] = bankAcctID
  confidence_list[i] = confidence
}

result_df = data.frame(loginID = custID_list, bankAcctID = bankAcctID_list, confidence = confidence_list)

result_df$verifiedID = ifelse(!is.na(result_df$confidence) & result_df$confidence > 95, "1", "0")

result_df_unique = result_df %>%
  group_by(loginID) %>%
  filter(confidence == max(confidence)) %>%
  distinct(loginID, .keep_all = TRUE)

result_df_m1 = result_df_unique %>%select(loginID, bankAcctID, verifiedID)

assign("output_df1", result_df_m1, envir = globalenv())

return(result_df_m1)

}
