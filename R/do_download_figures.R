
library(rvest)
library(stringr)
library(lubridate)

# reference
# https://medium.com/@kyleake/wikipedia-data-scraping-with-r-rvest-in-action-3c419db9af2d
# http://stanford.edu/~wpmarble/webscraping_tutorial/webscraping_tutorial.pdf
# https://github.com/yusuzech/r-web-scraping-cheat-sheet

# 
# webpage <- read_html("https://earthquake.usgs.gov/earthquakes/eventpage/us1000gez7#executive")
# webpage2 <- read_html("https://earthquake.usgs.gov/earthquakes/eventpage/us1000gez7#shakemap")
# # event-datetime
# event_datetime_html <- html_nodes(webpage,'.event-datetime')
# event_datetime <- str_extract(html_text(event_datetime_html), "\\d{4}.*UTC")
# 
# format.Date(ymd_hms(event_datetime), "%Y%m%d")
# 
# html_nodes(webpage,'.downloads')
# html_attrs(html_nodes(webpage,'.downloads'))
# 
# html_nodes(webpage, xpath = '//*[@id="tablist-panel-8"]')


url <- "https://earthquake.usgs.gov/earthquakes/eventpage/us1000gez7#executive"
id <- url %>% 
  read_html() %>%
  html_node('body .page .page-content .event-content a') %>%
  html_attr("href") %>%
  str_extract("\\d{13}")

# shakemap
# https://earthquake.usgs.gov/realtime/product/dyfi/us1000gez7/us/1535259951585/us1000gez7_ciim_geo.jpg


# pager
# https://earthquake.usgs.gov/realtime/product/losspager/us1000gez7/us/1534956243636/alertfatal_small.png
# https://earthquake.usgs.gov/realtime/product/losspager/us1000gez7/us/1534956243636/alertecon_small.png


url2 <- "http://geofon.gfz-potsdam.de/eqinfo/event.php?id=gfz2018qegj"
url2 %>%
  read_html() %>%
  html_node('body #GEcontent table') %>%
  html_table()

# bb
url2 %>%
  read_html() %>%
  html_node('body #GEcontent img') %>%
  html_attr('src')

# map
url2 %>%
  read_html() %>%
  html_node('body #GEcontent div img') %>%
  html_attr('src')

# moment tensor
url2 %>%
  read_html() %>%
  html_node('body #GEcontent div table .even') %>%
  html_children()
