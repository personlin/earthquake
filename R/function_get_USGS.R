# function for download USGS event data and figure

get.USGS.event <- function(eventid){
  url <- paste0("https://earthquake.usgs.gov/earthquakes/eventpage/", eventid, "#executive")
  event_datetime_html <- html_nodes(webpage,'.event-datetime')
  event_datetime <- str_extract(html_text(event_datetime_html), "\\d{4}.*UTC")
  img.folder <- paste0("static/images/", format.Date(ymd_hms(event_datetime), "%Y%m%d"), "/")
  # shake map
  
}