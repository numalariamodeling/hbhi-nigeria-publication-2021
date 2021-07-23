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
                   tooltip=paste0(LGA, " ",  "is in", " ", State,  " ", "State ", " with ", round(!!column, 1), "%", " ", tooltip_name,
                                  ",", "\n",
                                  "Simday:", " ", simday))) +
    viridis::scale_fill_viridis(direction = -1, na.value = 'grey', limits = c(0, 90)) +
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





theme_georgia <- function(...) {
  theme_gray(base_family = "Georgia", ...) + 
    theme(plot.title = element_text(face = "bold"))
}

draw_label_theme <- function(label, theme = NULL, element = "text", ...) {
  if (is.null(theme)) {
    theme <- ggplot2::theme_get()
  }
  if (!element %in% names(theme)) {
    stop("Element must be a valid ggplot theme element name")
  }
  
  elements <- ggplot2::calc_element(element, theme)
  
  cowplot::draw_label(label, 
                      fontfamily = elements$family,
                      #fontface = elements$face,
                      colour = elements$color,
                      size = elements$size,
                      ...
  )
}

title_function <-function(mainTitle, subTitle, footNote){
  title <- ggdraw() +
    draw_label_theme(mainTitle, 
                     theme = theme_georgia(), element = "plot.title",
                     hjust=0.5,  fontface ="bold")
  subtitle <- ggdraw() +
    draw_label_theme(subTitle,
                     theme = theme_georgia(), element = "plot.subtitle",
                     hjust=0.5, fontface="italic")
  footnote<-ggdraw() +
    draw_label_theme(footNote,
                     theme = theme_georgia(), element = "plot.caption",
                     hjust=0.5,  fontface ="italic")
  
  title_ls<-list(title, subtitle, footnote)
  return(title_ls)
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
# inputs <- file.path(repo, 'simulation_inputs', 'ITN')
# outputs <- file.path('../../data/ITN_coverage')
# 
# val_year = c(2020:2030)
# 
# for (i in 1:length(val_year)){
# ITN <-data.table::fread(file.path(inputs, "itn_scenario3_4_funded_2020_2030.csv")) %>% dplyr::select(-c(six_nine_ITN_use,ten_eighteen_ITN_use, 
#                                                                                                         over_eighteen_ITN_use, 'kill_rate', 'mortality', block_initial, 'LGA_old', mass_llins_fund))
# ITN= ITN[which(ITN$year == val_year[[i]]), ]
# ITN_df = merge(LGAsf, ITN, by ="LGA", all.x =TRUE)
# ITN_df$U5_ITN_use= round(ITN_df$U5_ITN_use* 100, 1)
# ITN_df = rename(ITN_df, ITN_use = U5_ITN_use)
# saveRDS(ITN_df, paste0(outputs, '/', "ITN_coverage", "_> 5 years_Scenario 3 (Budget-prioritized plan)", "_", as.character(val_year[[i]]), ".rds"), compress = FALSE)
#  }

# 
# 
# 
# coverage_map=readRDS(file = paste0(outputs, '/', "ITN_coverage", "Scenario 1 (Business as Usual)", "_", '2021', ".rds"))
# coverage_map = generateMap(coverage_map, quo(U5_ITN_use), "U5 ITN coverage")


# kill_map = kill_map + ggplot2::labs(title = paste0("Simdays:", " ", min(kill_map$data$simday, na.rm = T), "-", max(kill_map$data$simday, na.rm = T),   ", Year:", " ", max(kill_map$data$year, na.rm=T)))
# 
# data <- kill_map$data %>%  sf::st_drop_geometry
# class(data)

