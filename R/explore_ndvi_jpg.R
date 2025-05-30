#This script is OPTIONAL
#It reads in the .jpg files. 
#You can set an extent to crop images for calculating mean NDVI for that region of interest
#Also includes a time series of the region of interest when multiple .jpg files
#NOTE that NDVI from this script is not correct. Please use the explore_ndvi_csv.R file for correct NDVI values

library('terra')
library('ggplot2')

#get list of all the NDVI images
list_jpg_ndvi <- list.files(file.path("/Data/"), #set directory of the data location
                            pattern = "NDVI.jpg",
                            full.names = TRUE,
                            recursive = TRUE)

#Image and extend exploration ---------------------
#load single NDVI image
ndvi_jpg <- rast(list_jpg_ndvi[[1]])   #Adjust the index location for specific datetime image

#Set image extent for cropping
e <- ext(1000, 1200, 500, 700)

#plot image and extent
plot(ndvi_jpg)    #plot image
lines(e)          #plot extent area

#Read in all data -----------------------
df_ndvi <- data.frame()     #make empty dataframe where the data will be stored

for (i in 1:length(list_jpg_ndvi)){
  print(paste("In progress:", i, "out of", length(list_jpg_ndvi)))                #print progress
  temp_ndvi <- rast(list_jpg_ndvi[[i]])                                           #load NDVI image
  temp_name <- names(temp_ndvi)[[1]]                                              #extract name of image
  temp_date <- as.Date(paste(read.table(text = temp_name, sep = "_")$V2,          #extract date of image from image name
                             read.table(text = temp_name, sep = "_")$V3, 
                             read.table(text = temp_name, sep = "_")$V4,
                             sep = "-"))
  temp_time <- paste(read.table(text = temp_name, sep = "_")$V5,                  #extract time of image from image name
                     read.table(text = temp_name, sep = "_")$V6, 
                     read.table(text = temp_name, sep = "_")$V7,
                     sep = ":")
  datetime <- as.POSIXct(paste(temp_date, temp_time), format="%Y-%m-%d %H:%M:%S") #create datetime
  temp_ndvi <- crop(temp_ndvi, e)                                                 #crop image to set extent
  temp_ndvi <- colorize(temp_ndvi, to='col')                                      #convert r g b into single color value
  temp_ndvi <- as.data.frame(temp_ndvi,xy=TRUE)                                   #convert to dataframe
  
  ndvi <- mean(temp_ndvi[[3]], na.rm=TRUE)                                        #get mean NDVI of the cropped image
  temp_df <- data.frame(datetime, ndvi)                                           #create temp dataframe with datetime and mean NDVI
  df_ndvi <- rbind(df_ndvi, temp_df)                                              #append temp dataframe to the main dataframe
}


#data analysis and visualization ------------------
#convert to uncorrected NDVI values
df_ndvi$false_ndvi <- (df_ndvi$ndvi - 127.5) / 127.5                #convert from 0-255 to -1 to 1

#plot data
ggplot(df_ndvi, aes(x = datetime, y = false_ndvi))+
  geom_line()+
  geom_point()+
  scale_x_datetime(date_labels = "%m-%d %H:%M")+
  theme_bw()



