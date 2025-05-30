#This script reads in the .csv files. 
#You can set an extent to crop images for calculating mean NDVI for that region of interest
#Also includes a time series of the region of interest when multiple .csv files

library(terra)
library(data.table)
library(ggplot2)

#get list of all the NDVI csv images
list_csv_ndvi <- list.files(file.path("./Data/"), #set directory of the data location
                            pattern = ".csv",
                            full.names = TRUE,
                            recursive = TRUE)

list_csv_ndvi_name <- list.files(file.path("./Data/"), #set directory of the data location
                            pattern = ".csv",
                            full.names = FALSE,
                            recursive = TRUE)

#Image and extent exploration ---------------------
#load single NDVI image
ndvi_csv <- read.csv(list_csv_ndvi[[1]], header = F)    #Adjust the index location for specific datetime image

#convert csv to matrix
ndvi_matrix <- as.matrix(ndvi_csv)
#convert matrix to raster
ndvi_rast <- rast(ndvi_matrix)

#plot image
plot(ndvi_rast)

#Set image extent for cropping
e <- ext(200, 400, 200, 400)

#add extent to image
lines(e)          #plot extent area

#Read in all data -----------------------
df_ndvi <- data.frame()     #make empty dataframe where the data will be stored

for (i in 1:length(list_csv_ndvi)){
  print(paste("In progress:", i, "out of", length(list_csv_ndvi)))                      #print progress
  ndvi_csv <- fread(list_csv_ndvi[[i]], header = F)                                     #load NDVI csv
  ndvi_matrix <- as.matrix(ndvi_csv)                                                    #convert csv to matrix
  ndvi_rast <- rast(ndvi_matrix)                                                        #convert matrix to raster
  temp_date <- as.Date(paste(read.table(text = list_csv_ndvi_name[[i]], sep = "_")$V2,  #extract date of image from image name
                             read.table(text = list_csv_ndvi_name[[i]], sep = "_")$V3, 
                             read.table(text = list_csv_ndvi_name[[i]], sep = "_")$V4,
                             sep = "-"))
  temp_time <- paste(read.table(text = list_csv_ndvi_name[[i]], sep = "_")$V5,         #extract time of image from image name
                     read.table(text = list_csv_ndvi_name[[i]], sep = "_")$V6, 
                     read.table(text = list_csv_ndvi_name[[i]], sep = "_")$V7,
                     sep = ":")
  datetime <- as.POSIXct(paste(temp_date, temp_time), format="%Y-%m-%d %H:%M:%S")       #create datetime
  ndvi_rast <- crop(ndvi_rast, e)                                                       #crop image to set extent
  ndvi_mean <- global(ndvi_rast, "mean", na.rm=T)                                       #get mean NDVI of the cropped image
  
  temp_df <- data.frame(datetime, ndvi_mean)                                            #create temp dataframe with datetime and mean NDVI
  df_ndvi <- rbind(df_ndvi, temp_df)                                                    #append temp dataframe to the main dataframe
}


#data analysis and visualization ------------------
#plot data
ggplot(df_ndvi, aes(x = datetime, y = mean))+
  geom_line()+
  geom_point()+
  scale_x_datetime(date_labels = "%m-%d %H:%M")+
  theme_bw()



