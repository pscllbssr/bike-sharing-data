library(readr)
library(glue)
library(RCurl)

years <- 2018:2022
months <- sprintf("%02d", 01:12)
city_links <- list(Trondheim="https://data.urbansharing.com/trondheimbysykkel.no/trips/v1/{year}/{month}.csv", 
                   Oslo="https://data.urbansharing.com/oslobysykkel.no/trips/v1/{year}/{month}.csv", 
                   Bergen="https://data.urbansharing.com/bergenbysykkel.no/trips/v1/{year}/{month}.csv")

trip_data = data.frame()

for (city in names(city_links)) {
  link <- city_links[[city]]
  for(year in years){
    for(month in months){
      current_link <- glue(link)
      if(url.exists(current_link)) {
        message('downloading: ', current_link)
        data <- read.csv(current_link)
        if(nrow(data) > 0) {
          data$city <- city
        }
        trip_data <- rbind(trip_data, data)
      }
    }
  }
}


# download weather
weather_station_ids <- list(Trondheim="01257", 
                            Oslo="01492", 
                            Bergen="01317")

weather_data = data.frame()

for (city in names(weather_station_ids)) {
  id <- weather_station_ids[[city]]
  link <- glue("https://bulk.meteostat.net/v2/hourly/{id}.csv.gz")
  if(url.exists(link)) {
    message('downloading: ', link)
    data <- read_csv(link, col_names = FALSE)
    data$city <- city
    if(nrow(data) > 0) {
      data$city <- city
    }
    weather_data <- rbind(weather_data, data)
  }
}

colnames(weather_data) <- c("date", "hour", "temp", "dwpt", "rhum", "prcp", "snow", "wdir", "wspd", "wpgt", "pres", "tsun", "coco", "city")

# write to file

write.csv(trip_data, "data/trip_data.csv")
write.csv(weather_data, "data/weather_data.csv")

# TBD: merging the two. Beware: sometimes hourly, sometimes "6-hourly"
