## Simple plot
library(ggplot2)

x$map_date <- as.Date(x$map_date, format="%d-%b-%Y")

ggplot(x) + theme_bw() +
  geom_bar(aes(map_date, fill = country_name), stat = "bin")
