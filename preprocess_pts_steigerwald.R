library(dplyr)
library(RStoolbox)
points <- list.files(full.names=T,pattern = "*.csv") %>% 
  lapply(read.csv) %>% 
  bind_rows 


coordinates(points) <- ~GPS.Longitude + GPS.Latitude
points@proj4string <- crs("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
points <- spTransform(points,crs("+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs "))

points$Offset_Angle <- NA
points$Offset_Angle[points$centroid_offset=="east"] <- 0
points$Offset_Angle[points$centroid_offset=="north"] <- 90
points$Offset_Angle[points$centroid_offset=="west"] <- 180
points$Offset_Angle[points$centroid_offset=="south"] <- 270
points$Offset_Angle[points$centroid_offset=="NE"] <- 45
points$Offset_Angle[points$centroid_offset=="NW"] <- 135
points$Offset_Angle[points$centroid_offset=="SW"] <- 225
points$Offset_Angle[points$centroid_offset=="SE"] <- 315

deg2rad <- function(deg) {(deg * pi) / (180)}
y_offset <- function(angle,H){sin(deg2rad(angle))*H}
x_offset <- function(angle,H){cos(deg2rad(angle))*H}

points$Offset_Y <- y_offset(points$Offset_Angle,points$offset_of)
points$Offset_X <- x_offset(points$Offset_Angle,points$offset_of)
points$Offset_Y[is.na(points$Offset_Y)] <- 0
points$Offset_X[is.na(points$Offset_X)] <- 0

points@coords[,1] <- points@coords[,1]+points$Offset_X
points@coords[,2] <- points@coords[,2]+points$Offset_Y



writeOGR(points,dsn = "points_corrected.shp",layer = "pts",driver = "ESRI Shapefile")

