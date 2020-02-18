library(shiny)
library(shinydashboard)
library(leaflet)


# setwd('/nfs/see-fs-02_users/eebjs/OneDrive/AIA_project/scripts/interactive_map/china_aqtrends')

# load in trends dataset
trends <- read.csv("./datafiles/theilsen_trends.csv", header=TRUE, stringsAsFactors=FALSE)
colnames(trends)[1] <- "station"
colnames(trends)[2] <- "pol"
# combine with lookup data
lookup <- read.csv("./datafiles/station_lookup.csv", header=TRUE, stringsAsFactors=FALSE)
trends <- merge(trends, lookup, by = 'station')
# remove rows with missing lat/lon data
trends <- trends[!is.na(trends$lat),]
trends <- trends[!is.na(trends$lon),]
# exclude large trends
trends <- trends[trends$slope>-10 & trends$slope<10, ] # replace later with excluding short trends

# load in means dataset
means <- read.csv("./datafiles/decomposed_means.csv", header=TRUE, stringsAsFactors=FALSE, check.names = FALSE)
# remove rows with missing lat/lon data
trends <- trends[!is.na(trends$lat),]
trends <- trends[!is.na(trends$lon),]
# # create copy of table with just numeric columns
# nummeans <- means[, unlist(lapply(means, is.numeric))]


# # Load in WHO AQGs data
# aqgs <- read.csv("./datafiles/who_aqgs.csv", header=TRUE, stringsAsFactors=FALSE)
# # Create a categorical palette function for WHO AQGs
# who_pal <- function(pol) {
#   # extract pollutant
#   polaqg <- aqgs[aqgs$pol == pol & aqgs$avtime == 'year',]
#   polaqg <- polaqg[, unlist(lapply(polaqg, is.numeric))]
#   polaqg <- polaqg[,colSums(is.na(polaqg))<nrow(polaqg)]
#   
# }

# a function used in the month slider
monthStart <- function(x) {
  x <- as.POSIXlt(x)
  x$mday <- 1
  as.Date(x)
}