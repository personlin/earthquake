# function for download USGS event data and figure
library(rvest)
library(stringr)
library(lubridate)

get.USGS.event <- function(eventid){
  url <- paste0("https://earthquake.usgs.gov/earthquakes/eventpage/", eventid, "#executive")
  webpage <- read_html(url)
  event_datetime_html <- html_nodes(webpage,'.event-datetime')
  event_datetime <- str_extract(html_text(event_datetime_html), "\\d{4}.*UTC")
  img.folder <- paste0("static/images/", format.Date(as_date(ymd_hms(event_datetime), tz="Asia/Taipei"), "%Y%m%d"), "/")
  # create folder for images
  dir.create(img.folder)
  # get USGS id
  id.shakemap <- webpage %>%
    html_nodes('body .page .page-content .event-content a') %>%
    html_attr("href") %>%
    grep("shakemap", ., value = TRUE) %>%
    str_extract("\\d{13}") %>%
    unique(.)
  # get shake map
  # https://earthquake.usgs.gov/realtime/product/shakemap/us2000h8ty/us/1536257681703/download/intensity.jpg
  url.shakemap <- paste0("https://earthquake.usgs.gov/realtime/product/shakemap/", eventid, "/us/",
                         id.shakemap, "/download/intensity.jpg")
  download.file(url.shakemap, paste0(img.folder,"/",eventid,"_intensity.jpg"), mode = "wb")
  # get pager id
  id.pager <- webpage %>%
    html_nodes('body .page .page-content .event-content a') %>%
    html_attr("href") %>%
    grep("losspager", ., value = TRUE) %>%
    str_extract("\\d{13}") %>%
    unique(.)
  # get pager alert
  # https://earthquake.usgs.gov/realtime/product/losspager/us2000h8ty/us/1536257826032/alertfatal_small.png
  url.pager1 <- paste0("https://earthquake.usgs.gov/realtime/product/losspager/", eventid, "/us/",
                      id.pager, "/alertfatal_small.png")
  url.pager2 <- paste0("https://earthquake.usgs.gov/realtime/product/losspager/", eventid, "/us/",
                       id.pager, "/alertecon_small.png")
  download.file(url.pager1, paste0(img.folder,"/",eventid,"_alertfatal_small.png"), mode = "wb")
  download.file(url.pager2, paste0(img.folder,"/",eventid,"_alertecon_small.png"), mode = "wb")
  
}
