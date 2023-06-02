# Generalised Additive Model (Emilia)

Another approach to predict the duration of the trips was to use a Generalise Additive Model (GAM), to study weather the  weather conditions affect the duration of trips.

```{r gam_dataset, message=FALSE}

#retrieve only data about the duration and weather parameters 
weather <- data %>% select(c(city, duration, temp, dwpt, prcp, snow, wpgt))
colnames(weather) <- c("city","Duration", "Temperature","Dew_Point", "Precipitation", "Snow_Depth", "Wind_Peak_Gust")

#remove NA values and chose relevant weather parameters
weather<- na.omit(weather[, c("city","Duration","Temperature", "Dew_Point", "Precipitation")])

head(weather)

#display relationship of duration with the weather variables
template.graph.weather <- ggplot(data = weather,
                                 mapping = aes(y = log(Duration))) +
  geom_point() +
  geom_smooth()

template.graph.weather + aes(x = Temperature)
template.graph.weather + aes(x = Dew_Point)
template.graph.weather + aes(x = Precipitation)
```
The distribution of temperature and dew point is evenly scattered through the graph. Whereas, the precipitation values are mainly available on the left side of the graph area. 
The graph of each variable seem to have a linear relationship that remains flat throughout the graph, therefore, an effect is difficult to spot here. 

```{r gam}
gam <- gam(log(Duration) ~ s(Temperature) + s(Dew_Point) + s(Precipitation), data = weather)

summary(gam)

plot(gam, residuals = TRUE, pages = 1, shade = TRUE)
```

The GAM model states that temperature, dew_point and precipitation have a significant effect on the duration of a bike trip. The smooth term temperature has the largest edf value `r round(summary(gam)$s.table["s(Temperature)", "edf"], 3)` and precipitation the lowest with a value of `r round(summary(gam)$s.table["s(Precipitation)", "edf"], 3)`. The intercept is existing. 


_INTERPRETATION__
<<<<<<< HEAD

```{r}
#extraction of the coefficient "weekend" for interpretation of the model

coef(glm_binomial)[c("weekendWeekend", "temp")]

exp(coef(glm_binomial)["weekendWeekend"])
```
All variables present to have significant coefficients, consequently, they all  highly impact the probability of a trip being a round trip. However, if we interpret individual coefficients such as the weekend/weekday, we can determine that the odds of a round trip on a weekend is 1.94 higher than on weekday.  

```{r}
#extraction of the coefficient temperature

exp.coef.temp <- exp(coef(glm_binomial)["temp"])
print(exp.coef.temp, digits = 3)


exp.coef.temp.10 <- exp(coef(glm_binomial)["temp"] * 10)
print(exp.coef.temp.10, digits = 3)
```
When increasing the temperature by 1°C, the odds of a round trip increase by 4%. 
To check the effect of the change of temperature, we wanted to test what would happen if we increase the temperature by 10°C. As we can see, the odds of a round trip increase to 55%.