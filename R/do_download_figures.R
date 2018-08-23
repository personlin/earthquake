
library(rvest)
library(stringr)
library(lubridate)

webpage <- read_html("https://earthquake.usgs.gov/earthquakes/eventpage/us1000gez7#executive")
webpage2 <- read_html("https://earthquake.usgs.gov/earthquakes/eventpage/us1000gez7#shakemap")
# event-datetime
event_datetime_html <- html_nodes(webpage,'.event-datetime')
event_datetime <- str_extract(html_text(event_datetime_html), "\\d{4}.*UTC")

format.Date(ymd_hms(event_datetime), "%Y%m%d")

html_nodes(webpage,'.shakemap-tablist-image')
