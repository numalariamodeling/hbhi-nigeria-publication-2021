
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
generateMap <-function(data, column){
  
  g <- ggplot2::ggplot(data) +
    ggiraph::geom_sf_interactive(
      color='grey', size =0.03, 
      ggplot2::aes(fill=!!column,
                   tooltip=paste0(LGA, " ",  "is in", " ", State,  " ", "State ", " with ", round(!!column, 1), "%", " coverage."))) +
    viridis::scale_fill_viridis(direction = -1, na.value = 'grey', limits = c(0, 90)) +
    # colormap::scale_fill_colormap(
    #   colormap=colormap::colormaps$viridis, reverse = T) +
    ggplot2::labs(title = paste0("Simday:", " ", max(data$simday, na.rm = T), ", Year:", " ", max(data$year, na.rm=T)))+
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
Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
data_dir <- file.path(Drive,"Box", "NU-malaria-team", "projects", "hbhi_nigeria_shiny_app_data")

LGAsf <- sf::st_read(file.path(data_dir, "LGA_shape", "NGA_LGAs.shp")) %>%  
  dplyr::mutate(LGA = stringr::str_replace_all(LGA, "/", "-"),
                LGA = dplyr::case_when(LGA == "kiyawa"~ "Kiyawa",
                                LGA == "kaita"~ "Kaita",
                                TRUE ~ as.character(LGA))) 

LGA_list<- list(LGAsf)
######################################################################################
# intervention 
######################################################################################
# 
# year = c(2020:2030)
# 
# ITN <-
# data.table::fread("data/ITN_scenario_df/itn_funded_2020_2030.csv")
# 
# 
# for (i in 1:length(year)){
# ITN = ITN[which(ITN$year == year[[i]]), ]
# ITN$U5_ITN_use = ITN$U5_ITN_use*100
# ITN$simday = sort(ITN$simday)
# ITN_df = split(ITN , by="simday")
# ITN_df = purrr::map2(LGA_list,ITN_df, left_join, by="LGA")
# cols_list = list(quo(U5_ITN_use))
# ITN_map = purrr::map2(ITN_df, cols_list, generateMap)
# #ITN_map[[2]]
# 
# 
# legend <- cowplot::get_legend(
#     # create some space to the left of the legend
#     ITN_map[[4]] + guides(color = guide_legend(nrow = 1)) +
#       theme(legend.position = "bottom")
#   )
# 
#   ITN_grid = plot_grid(ITN_map[[1]] + theme(legend.position="none"),ITN_map[[2]] + theme(legend.position="none"),
#                          ITN_map[[3]] + theme(legend.position="none"), ITN_map[[4]] + theme(legend.position="none"),
#                          ITN_map[[5]] + theme(legend.position="none"), ITN_map[[6]] + theme(legend.position="none"), nrow = 2)
# 
# 
#   ITN_grid= plot_grid(ITN_grid, legend, nrow = 2, rel_heights = c(1, .1))
#   ITN_grid
#   saveRDS(ITN_grid,
#           paste0("data/ITN_map_grid/u5_scenario/", "Scenario 7 (Considered for funding in the NSP)", "_", as.character(year[[i]]),  ".rds"))
# }


# filename = paste0("Scenario 1 (Business as Usual)", "_", "2020")
# #browser()
# kill_grid=readRDS(file = paste0("data/ITN_map_grid/u5_scenario1/", filename, ".rds"))



# case_management <- fread("data/severe_case_management.csv")
# footnote_cm <-'The Demographic and Health surveys were used to parameterize CM coverage. \n
#                   #The same coverage levels were used for both adults and children'
# 
# cm_scen1_df <- case_management[which(case_management$scenario =="Scenario 1(Business as Usual)"), ]
# cm_scen1_df <- merge(LGAsf, y=cm_scen1_df , by="LGA",all.x =TRUE)
# cm_scen1_map<-generateMap(cm_scen1_df, quo(severe_cases))
# cm_scen1_titles <-title_function("Case Management (CM) Coverage", "Scenario 1 (Business as Usual)", footnote_cm)
