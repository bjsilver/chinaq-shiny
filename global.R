library(shiny)
library(shinydashboard)
library(leaflet)


#setwd('/nfs/see-fs-02_users/eebjs/OneDrive/AIA_project/scripts/interactive_map/shiny_map/china_aqtrends')

# load in trends dataset
trends <- read.csv("./datafiles/theilsen_trends.csv", header=TRUE, stringsAsFactors=FALSE)
colnames(trends)[1] <- "station"
colnames(trends)[2] <- "pol"
# combine with lookup data
lookup <- read.csv("./datafiles/station_lookup.csv", header=TRUE, stringsAsFactors=FALSE)
trends <- merge(trends, lookup, by = 'station')
# exclude large trends
trends <- trends[trends$slope>-10 & trends$slope<10, ]

# load in means dataset
means <- read.csv("./datafiles/decomposed_means.csv", header=TRUE, stringsAsFactors=FALSE, check.names = FALSE)
# # create copy of table with just numeric columns
# nummeans <- means[, unlist(lapply(means, is.numeric))]

# Create a continuous palette function
pal <- colorNumeric(
  palette = "RdBu",
  domain = NULL, reverse=TRUE)

# Create a continuous palette function for means
palmean <- colorNumeric(
  palette = "YlOrRd",
  domain = NULL, reverse=F,
  na.color = "transparent")

# Create a categorical palette function for Chinese Air Quality Guidelines



# a function used in the month slider
monthStart <- function(x) {
  x <- as.POSIXlt(x)
  x$mday <- 1
  as.Date(x)
}