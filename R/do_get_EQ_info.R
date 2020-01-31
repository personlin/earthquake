
source("R/function_get_USGS.R")
source("R/function_get_GFZ.R")


# Get EQ info from USGS ----

#2019-06-18 日本山形縣地震
get.USGS.event.geojson("us600042fx")

#2019-06-17 四川長寧地震
get.USGS.event.geojson("us600041ry")

#2019-07-06 南加州地震
get.USGS.event.geojson2("ci38457511")

#2019-08-08 宜蘭地震
get.USGS.event.geojson("us6000522g")

#2020-01-07 波多黎各地震
get.USGS.event.geojson("us70006vll")

#2020-01-28 牙買加地震
get.USGS.event.geojson("us60007idc")

# Get EQ info from GFZ ----

# 2019-08-08 宜蘭地震
get.GFZ("gfz2019pjye")

# 2020-01-07 波多黎各地震
get.GFZ("gfz2020alpr")

# 2020-01-28 牙買加地震
get.GFZ("gfz2020byun")
