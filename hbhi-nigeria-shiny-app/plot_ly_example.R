library(tidyverse)
library(sf)
library(plotly)
library(sp)
library(methods)
library(ggplot2)
library(ggiraph)
library(ggthemes)

setwd("C:/Users/ido0493/Documents/covid-GTA-surge-planning-master/src/app")

LGAsf <- st_read("data/LGA_shape/NGA_LGAs.shp") %>%  
  dplyr::mutate(LGA = stringr::str_replace_all(LGA, "/", "-"),
                LGA = case_when(LGA == "kiyawa"~ "Kiyawa",
                                LGA == "kaita"~ "Kaita",
                                TRUE ~ as.character(LGA))) 


case_management <- read.csv("data/case_management.csv") %>% dplyr::filter(year== 2020)


df <- dplyr::left_join(LGAsf, case_management, by=("LGA")) 

fig <- plot_ly(df , split = ~LGA, 
        color = ~U5_coverage, 
        showlegend = FALSE,
        alpha = 1,
        hoverinfo = 'text',
        text = ~paste(LGA, "is in", State.x),
        hoveron= "fill",
        stroke = I("grey"))

fig<- fig %>%  layout(title =unique(cm_scen2_df$scenario))

fig

summary(case_management$U5_coverage)
df$State.x


gg <- ggplot(map_x) +
  geom_sf_interactive(aes(fill = CrudeRate7DayPositive, 
                          tooltip = c(paste0(IntZoneName, "\n",CrudeRate7DayPositive,  " cases per 100,000 \n (7 Day Crude Rate)")),  
                          data_id = IntZoneName)) +
  scale_fill_brewer(palette = "Purples") +
  theme_void()
x <- girafe(ggobj = gg)
x <- girafe_options(x,
                    opts_zoom(min = 0.7, max = 2) )
if( interactive() ) print(x)

#ggplot example

nga.spdf <- as(cm_scen2_df, 'Spatial')
nga.spdf@data$id <- row.names(nga.spdf@data)

nga.tidy <- broom::tidy(nga.spdf)


nga.tidy <- dplyr::left_join(nga.tidy, nga.spdf@data, by='id')

g <- ggplot(nga.tidy) +
  geom_polygon_interactive(
    color='grey',
    aes(long, lat, group=group, fill=U5_coverage,
        tooltip=paste0(LGA, " ",  "is in", " ", State.x,  " ", "State"))) +
  #hrbrthemes::theme_ipsum() +
  colormap::scale_fill_colormap(
    colormap=colormap::colormaps$viridis, reverse = T) +
  labs(title='Case Management in Children (CM) under the age of five', subtitle='Business as Usual Scenario',
       caption='The Demographic and Health surveys was used to parameterize CM coverage', fill = "")+ 
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank(),
        plot.title = element_text(face="bold"),
        plot.subtitle = element_text(face ="italic"),
        plot.caption = element_text(size = 8, face = "italic"))+
  xlab("")+
  ylab("")

widgetframe::frameWidget(ggiraph(code=print(g)))

#######################################################################################

library(ggmap)
library(maps)
library(mapdata)
library(ggiraph)
library(ggpubr)

states <- map_data("state")

y<-runif(15537, min = 0, max = 1)
states$coverage <-y


ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = coverage, group = group), color = "white") + 
  coord_fixed(1.3) +
  guides(fill=FALSE)


g <- ggplot(states) +
  geom_polygon_interactive(
    color='grey',
    aes(long, lat, group=group, fill=coverage,
        tooltip=region)) +
  colormap::scale_fill_colormap(
    colormap=colormap::colormaps$viridis, reverse = T) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank(),
        plot.title = element_text(face="bold"),
        plot.subtitle = element_text(face ="italic"),
        plot.caption = element_text(size = 8, face = "italic"))+
  xlab("")+
  ylab("")


y <-ggarrange(g, g, common.legend = TRUE)

gg<- g + scale_fill_viridis_c_interactive(tooltip = states$region)

widgetframe::frameWidget(ggiraph(code=print(gg)))

ggiraph::ggiraph(code = print(y))









