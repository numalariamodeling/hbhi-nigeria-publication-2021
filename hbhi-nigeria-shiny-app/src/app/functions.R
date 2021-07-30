import::here('./ui_selection_data.R', admin)
import::from(tidyr, '%>%')
import::from(purrr, map2, map)
import::from(dplyr, left_join)
import::from(grid, textGrob, gpar,grobHeight, unit, unit.c)
import::from(cowplot, ggdraw, plot_grid)
import::from(ggplot2, theme_gray, theme, element_text, margin, guides, guide_legend)
import::from(data.table, fread)
import::from(rlang, quo)

######################################################################################
# Functions 
######################################################################################

#functions 
generateMap <-function(data, column, tooltip_name){
  
  g <- ggplot2::ggplot(data) +
    ggiraph::geom_sf_interactive(
      color='grey', size =0.03, 
      ggplot2::aes(fill=!!column,
                   tooltip=paste0(LGA, " ",  "is in", " ", State,  " ", "State ", " with ", round(!!column, 1), "%", " ", tooltip_name))) +
    viridis::scale_fill_viridis(direction = -1, na.value = 'grey', limits = c(0, 100)) +
    ggplot2::theme(plot.title = ggplot2::element_text(face="italic", hjust = 0.5, size=8),
                   axis.text.x = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(),
                   rect = ggplot2::element_blank(),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                   legend.title = ggplot2::element_blank())+
    ggplot2::theme(plot.margin = ggplot2::margin(6, 0, 6, 0))+
    ggplot2::xlab("")+
    ggplot2::ylab("")
  return(g)
}



######################################################################################
# data 
######################################################################################

#LGA shape file 
LGAsf <- sf::st_read("../../data/LGA_shape/NGA_LGAs.shp") %>%  
  dplyr::mutate(LGA = stringr::str_replace_all(LGA, "/", "-"),
                LGA = dplyr::case_when(LGA == "kiyawa"~ "Kiyawa",
                                LGA == "kaita"~ "Kaita",
                                TRUE ~ as.character(LGA))) 


LGA_list<- list(LGAsf)
######################################################################################
# intervention 
######################################################################################


# repo<- "../../../"
# inputs <- file.path(repo, 'simulation_inputs', 'IPTp')
# outputs <- file.path('../../data/IPTp')
# 
# val_year = c(2020:2030)
# 
# library(dplyr)
# library(tidyr)
# 
# for (i in 1:length(val_year)){
# iptp= data.table::fread(file.path(inputs, "IPTp_coverage_scenario3_4_2020_2030.csv"), header = TRUE) %>% #dplyr::select(-V1) %>%
#   pivot_longer(!DS, names_to = 'year', values_to = 'IPTp')
# iptp = iptp %>%  dplyr::filter(year == val_year[[i]])
# iptp$IPTp= round(iptp$IPTp* 100, 1)
# LGA_shp <- left_join(LGAsf, iptp, by =c("LGA" = "DS"))
# saveRDS(LGA_shp, paste0(outputs, '/', "IPTp_", "Scenario 3 (Budget-prioritized plan)", "_", as.character(val_year[[i]]), ".rds"), compress = FALSE)
# }
#
# 
# map = generateMap(LGA_shp, quo(average_coverage_per_round), "average per cycle coverage")
# map = map + ggplot2::labs(title = paste0("Year:", " ", max(map$data$year, na.rm=T)))
