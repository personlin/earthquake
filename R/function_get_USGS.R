# function for download USGS event data and figure
library(rvest)
library(stringr)
library(lubridate)

library(geojsonR)
library(RFOC)

get.USGS.event.geojson <- function(eventid){
  # https://earthquake.usgs.gov/fdsnws/event/1/query?eventid=us1000hfxx&format=geojson
  url <- paste0("https://earthquake.usgs.gov/fdsnws/event/1/query?eventid=", eventid, "&format=geojson")
  file_js = FROM_GeoJson(url)
  eq.time <- as.POSIXct((file_js$properties$time)/1000,  origin = "1970-01-01", tz = "GMT")
  eq.lon <- as.numeric(file_js$properties$products$origin[[1]]$properties$longitude)
  eq.lat <- as.numeric(file_js$properties$products$origin[[1]]$properties$latitude)
  eq.depth <- as.numeric(file_js$properties$products$origin[[1]]$properties$depth)
  eq.node1 <- data.frame(strike = as.numeric(file_js$properties$products$`moment-tensor`[[1]]$properti$`nodal-plane-1-strike`),
                         dip = as.numeric(file_js$properties$products$`moment-tensor`[[1]]$properti$`nodal-plane-1-dip`),
                         rake = as.numeric(file_js$properties$products$`moment-tensor`[[1]]$properti$`nodal-plane-1-rake`))
  eq.node2 <- data.frame(strike = as.numeric(file_js$properties$products$`moment-tensor`[[1]]$properti$`nodal-plane-2-strike`),
                         dip = as.numeric(file_js$properties$products$`moment-tensor`[[1]]$properti$`nodal-plane-2-dip`),
                         rake = as.numeric(file_js$properties$products$`moment-tensor`[[1]]$properti$`nodal-plane-2-rake`))
  eq.pager.econ.url <- file_js$properties$products$losspager[[1]]$contents$alertecon.png$url
  eq.pager.fatal.url <- file_js$properties$products$losspager[[1]]$contents$alertfatal.png$url
  eq.shakemap.url <- file_js$properties$products$shakemap[[1]]$contents$`download/intensity.jpg`$url
  eq.finitefault.url <- file_js$properties$products$`finite-fault`[[1]]$contents$basemap.png$url
  # do dir create
  dir.create(here::here("static/images", format(eq.time, "%Y%m%d")))
  dirpath <- here::here("static/images", format(eq.time, "%Y%m%d"))
  # download images
  download.file(eq.pager.econ.url, paste0(dirpath,"/", eventid, "_alertecon_small.png"), mode = "wb")
  download.file(eq.pager.fatal.url, paste0(dirpath,"/", eventid, "_alertfatal_small.png"), mode = "wb")
  download.file(eq.shakemap.url, paste0(dirpath,"/", eventid, "_intensity.jpg"), mode = "wb")
  png(paste0(dirpath,"/", eventid, "_moment-tensor.png"))
  plotMEC(CONVERTSDR(eq.node1$strike, eq.node1$dip, eq.node1$rake), detail = 0)
  dev.off()
  if(!is.null(eq.finitefault.url)){
    download.file(eq.finitefault.url, paste0(dirpath,"/", eventid, "_finite_fault.png"), mode = "wb")
  }
  text1 <- paste(format(eq.time, "%Y-%m-%d %H:%M:%S"), "(UTC)")
  text2 <- paste0(ifelse(eq.lat > 0, paste0(eq.lat,"°N"), paste0(-eq.lat,"°N")), " ", ifelse(eq.lon > 0, paste0(eq.lon,"°E"), paste0(-eq.lon,"°W")))
  text3 <- paste(eq.depth, "km", "depth")
  text4 <- "###ShakeMap"
  text5 <- paste0("[USGS_Shakemap](https://earthquake.usgs.gov/earthquakes/eventpage/",eventid,"/shakemap/intensity)")
  text6 <- paste0("![USGS_Shakemap_img](images/", format(eq.time, "%Y%m%d"), "/",eventid, "_intensity.jpg)")
  text7 <- "###Focal Mechanism"
  text8 <- "Nodal Planes"
  text9 <- "| Plane | Strike | Dip  | Rake |"
  text10 <- "| ----- | ------ | ---- | ---- |"
  text11 <- paste("| NP1   |",  eq.node1$strike, "|", eq.node1$dip, " |", eq.node1$rake, " |")
  text12 <- paste("| NP2   |",  eq.node2$strike, "|", eq.node2$dip, " |", eq.node2$rake, " |")
  text13 <- paste0("![USGS_Focal_Machanism](images/", format(eq.time, "%Y%m%d"), "/",eventid, "_moment-tensor.png)")
  text14 <- "###Finite Fault"
  text15 <- paste0("![USGS_Finite_Fault](images/", format(eq.time, "%Y%m%d"), "/",eventid, "_finite_fault.png)")
  text16 <- "##PAGER"
  text17 <- "Estimated Fatalities"
  text18 <- paste0("![Estimated_Fatalities](images/", format(eq.time, "%Y%m%d"), "/",eventid, "_alertfatal_small.png)")
  text19 <- "Estimated Economic Losses"
  text20 <- paste0("![Estimated_Economic_Losses](images/", format(eq.time, "%Y%m%d"), "/",eventid, "_alertecon_small.png)")
  
  cat(paste0(text1, "\n\n", text2, "\n\n", text3, "\n\n", text4, "\n\n", text5, "\n\n", text6, "\n\n", text7, "\n\n", text8, "\n\n", 
             text9, "\n", text10, "\n", text11, "\n", text12, "\n\n", text13, "\n\n", text14, "\n\n", text15, "\n\n", 
             text16, "\n\n", text17, "\n\n", text18, "\n\n", text19, "\n\n", text20))
}

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

get.USGS.event.geojson("us600042fx")
