library(readr)
library(glue)
library(RCurl)
library(dplyr)

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

# merging the files

## prepare
trip_data$started_at <- as.POSIXct(trip_data$started_at)
trip_data$ended_at <- as.POSIXct(trip_data$ended_at)
trip_data$started_at_date <- as.Date(trip_data$started_at)
trip_data$started_at_hour <- format(trip_data$started_at, "%H")

## test the join
left_join(trip_data[1:100,], weather_data, by = join_by(x$started_at_date == y$date, x$started_at_hour == y$hour, city), keep = TRUE) %>% 
  select(started_at, city.x, city.y, date, hour)

## join!
trips <- left_join(trip_data, weather_data, by = join_by(x$started_at_date == y$date, x$started_at_hour == y$hour, city))

## tidy up
trips <- trips %>% 
  select(
    -started_at_hour,
    -started_at_date
  )

# write to file (complete)
write.csv(trips, "data/trips.csv", row.names = FALSE)


# subset for smaller file size
trips_col_subset <- trips %>% 
  select(
    -start_station_name,
    -start_station_description,
    -end_station_description,
    -end_station_name,
    -rhum,
    -wdir,
    -wspd,
    -pres
  )

write.csv(trips_col_subset, "data/trips_s.csv", row.names = FALSE)
