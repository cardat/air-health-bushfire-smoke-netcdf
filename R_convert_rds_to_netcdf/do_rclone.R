yy = 2020

for(i in 2:12){
#  i = 1
txt <- sprintf("rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/flagged/flags_pm25_%s%02d_20230329.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/flagged/ \n\n", yy, i)
cat(txt)

}
# actaullay this rclone copy  --progress --transfers 8 Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/flagged cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/flagged


for(i in 1:12){
  #  i = 1
txt2 <- sprintf("rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/pm25_preds/%s/rf_pm25_%s%02d_20230207.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/pm25_preds/%s/ \n\n",yy, yy, i, yy)
cat(txt2)

}
# rclone copy --progress --transfers 8 Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/pm25_preds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/pm25_preds
for(i in 1:12){
  #  i = 1
txt3 <- sprintf("rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_%s%02d_20230316.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ \n\n", yy, i)  
cat(txt3)

}
# rclone copy --progress --transfers 8 Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl
  