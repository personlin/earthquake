# do download USGS files

source("R/function_get_USGS.R")

#2019-07-06 美國南加州地震
get.USGS.event.geojson("ci38457511")

#2019-07-04 美國南加州地震
get.USGS.event.geojson("ci38443183")

#2019-06-18 日本山形縣地震
get.USGS.event.geojson("us600042fx")

#2019-06-17 四川長寧地震
get.USGS.event.geojson("us600041ry")
