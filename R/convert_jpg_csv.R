library(terra)

#get list of all the NDVI images
list_jpg_ndvi <- list.files("./Data/", #set directory of the data location
                         pattern = "NDVI.jpg",
                         full.names = TRUE,
                         recursive = TRUE)


#Convert jpg to csv ------------------- This can take ~10 seconds per image
for (i in 1:length(list_jpg_ndvi)){
  print(paste("In progress:", i, "out of", length(list_jpg_ndvi)))                  #print progress
  system(paste("./Executable/ccfc_ndvi.exe",       #location of executable program
               list_jpg_ndvi[[i]],                                                  #list of ndvi images
               "-c"))                                                               #argument: -c output csv; -o overwrite
}
  
#test a csv file -----------------------------------
library(data.table)
list_csv_ndvi <- list.files(file.path("./Data/"), #set directory of the data location
                   pattern = ".csv",
                   full.names = TRUE,
                   recursive = TRUE)

#load single NDVI image
ndvi_csv <- fread(list_csv_ndvi[[1]], header = F)    #Adjust the index location for specific datetime image

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

