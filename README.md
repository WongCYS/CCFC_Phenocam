# CCFC_Phenocam

This code is for handling Campbell Scientific CCFC NDVI phenocam.

Currently it will extract NDVI.

Future plans will be to include gcc calculation from the rgb .jpgs.

# Script Description

There are 3 R scripts

# convert_jpg_csv.R 
This script converts the NDVI .jpg images into .csv

This must be run first. It will skip files already converted unless an argument in the script is changed. .csv files will be save in the same folder as the .jpg

This script requires calling a .exe file. Please contact Campbell Scientific for a copy of the .exe file.

It can take ~10-20 seconds per .jpg



# explore_ndvi_csv.R 
This script opens and plots the NDVI .csv files. It will also produce a time series for a region of interest.

# explore_ndvi_jpg.R OPTIONAL (see note)
This opens and plots the NDVI .jpg files. 

**NOTE NDVI is incorrect in this version. Because it is reading from the .jpg rather than the .csv (latter containing correct NDVI values).**
