for(i in 1:10){
#txt <- sprintf("rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/flagged/flags_pm25_2019%02d_20230329.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/flagged/ \n",  i)
#txt <- sprintf("rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/pm25_preds/2019/rf_pm25_2019%02d_20230207.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/pm25_preds/2019/ \n",  i)
txt <- sprintf("rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_2019%02d_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ \n",  i)  
cat(txt)
}
# 
rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201901_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201902_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201903_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201904_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201905_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201906_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201907_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201908_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201909_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  rclone copy Cloudstor:Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/stl_pm25_201910_20230306.rds cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_provided/stl/ 
  