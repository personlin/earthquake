# function for download GFZ event data and figure
library(rvest)
library(lubridate)

get.GFZ <- function(eventid){
  # "http://geofon.gfz-potsdam.de/eqinfo/event.php?id=gfz2019pjye"
  url <- paste0("http://geofon.gfz-potsdam.de/eqinfo/event.php?id=", eventid)
  text.all <- url %>% 
    read_html() %>% 
    html_nodes(xpath = "//table") %>%
    html_nodes("td") %>%
    html_text()
  eq.time <- as.POSIXct(text.all[5], tz = "UTC")
  # http://geofon.gfz-potsdam.de/data/alerts/2019/gfz2019pjye/gfz2019pjye.jpg
  # http://geofon.gfz-potsdam.de/data/alerts/2019/gfz2019pjye/mt.txt
  # http://geofon.gfz-potsdam.de/data/alerts/2019/gfz2019pjye/bb.png
  eq.map.url <- paste0("http://geofon.gfz-potsdam.de/data/alerts/", year(eq.time), "/", eventid, "/", eventid, ".jpg")
  eq.bb.url <- paste0("http://geofon.gfz-potsdam.de/data/alerts/", year(eq.time), "/", eventid, "/bb.png")
  eq.mt.url <- paste0("http://geofon.gfz-potsdam.de/data/alerts/", year(eq.time), "/", eventid, "/mt.txt")
  mt <- readLines("http://geofon.gfz-potsdam.de/data/alerts/2019/gfz2019pjye/mt.txt", n=20)
  eq.node1 <- readr::parse_number(str_split(mt[19], "=")[[1]])[2:4]
  eq.node2 <- readr::parse_number(strsplit(mt[20], "\\s+")[[1]])[3:5]
  # do dir create
  dir.create(here::here("static/images", format(eq.time, "%Y%m%d")))
  dirpath <- here::here("static/images", format(eq.time, "%Y%m%d"))
  # download images
  download.file(eq.map.url, paste0(dirpath,"/", eventid, ".jpg"), mode = "wb")
  download.file(eq.bb.url, paste0(dirpath,"/", eventid, "_bb.png"), mode = "wb")
  download.file(eq.mt.url, paste0(dirpath,"/", eventid, "_mt.txt"), mode = "wb")
  # generate text
  text1 <- paste(text.all[1], text.all[2])
  text2 <- paste(text.all[4], text.all[5])
  text3 <- paste(text.all[6], text.all[7])
  text4 <- paste(text.all[8], paste(str_extract_all(text.all[9], "[0-9]{1,3}\\.[0-9]{1,2}.[A-Z]")[[1]], collapse = ", "))
  text5 <- paste(text.all[10], text.all[11])
  text6 <- paste(text.all[12], text.all[13])
  text7 <- "###Map"
  text8 <- paste0("![GFZ_Map](images/", format(eq.time, "%Y%m%d"), "/",eventid, ".jpg)")
  text9 <- "###Focal Mechanism"
  text10 <- "| Plane | Strike | Dip  | Rake |"
  text11 <- "| ----- | ------ | ---- | ---- |"
  text12 <- paste("| NP1   |",   paste(eq.node1, collapse = "   |   "), "|")
  text13 <- paste("| NP2   |",   paste(eq.node2, collapse = "   |   "), "|")
  text14 <- paste0("![GFZ_Focal_Machanism](images/", format(eq.time, "%Y%m%d"), "/",eventid, "_bb.png)")
  cat(paste0(text1, "\n\n", text2, "\n\n", text3, "\n\n", text4, "\n\n", text5, "\n\n", text6, "\n\n", text7, "\n\n", text8, "\n\n", 
             text9, "\n\n", text10, "\n", text11, "\n", text12, "\n", text13, "\n\n", text14, "\n\n"))
}


# 2019-08-08 宜蘭地震
get.GFZ("gfz2019pjye")
