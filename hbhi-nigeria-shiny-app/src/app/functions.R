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

# 
# repo<- "../../../"
# inputs <- file.path(repo, 'simulation_inputs', 'SMC')
# outputs <- file.path('../../data/SMC')
# 
# val_year = c(2020:2030)

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
# coverage_map=readRDS(file = paste0(outputs, '/', "ITN_coverage_> 5 years_", "Scenario 1 (Business as Usual)", "_", '2021', ".rds"))
# coverage_map = generateMap(coverage_map, quo(ITN_use), "U5 ITN coverage")


# kill_map = kill_map + ggplot2::labs(title = paste0("Simdays:", " ", min(kill_map$data$simday, na.rm = T), "-", max(kill_map$data$simday, na.rm = T),   ", Year:", " ", max(kill_map$data$year, na.rm=T)))
# 
# data <- kill_map$data %>%  sf::st_drop_geometry
# class(data)

# library(patchwork)
# SMC = data.table::fread(file.path(inputs, "smc_scenario1_BAU_2020_2030.csv")) %>%  dplyr::select(-c(State))
# SMC = SMC %>%  dplyr::filter(year == 2020)
# SMC$coverage_high_access= round(SMC$coverage_high_access* 100, 1)
# SMC = split(SMC, SMC$round)
# LGA_shp <-map2(LGA_list, SMC, left_join, by ="LGA")
# val = list(quo(coverage_high_access))
# tooltip = list("SMC coverage high access group")
# maps <- pmap(list(LGA_shp, val,tooltip), generateMap)
# 
# legend <- cowplot::get_legend(
#     # create some space to the left of the legend
#     maps[[4]] + guides(color = guide_legend(nrow = 1)) +
#       theme(legend.position = "right")
#   )
# 
# all_maps =maps[[1]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[1]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[1]]$data$simday, na.rm = T), "-", max(maps[[1]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[1]]$data$year, na.rm=T))) +
#   theme(legend.position="none", plot.margin = unit(c(0, 0, 0, 0), "cm")) +
#   
#   
#   maps[[2]] +
#   ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[2]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[2]]$data$simday, na.rm = T), "-", max(maps[[2]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[2]]$data$year, na.rm=T))) +
#   theme(legend.position="none", plot.margin = unit(c(0, 0, 0, 0), "cm")) +
#   
#   maps[[3]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[3]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[3]]$data$simday, na.rm = T), "-", max(maps[[3]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[3]]$data$year, na.rm=T))) +
# theme(legend.position="none", plot.margin = unit(c(0, 0, 0, 0), "cm")) +
#   
#   maps[[4]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[4]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[4]]$data$simday, na.rm = T), "-", max(maps[[4]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[4]]$data$year, na.rm=T)))+
# theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) 
# 
# all_map = plot_grid(
#   maps[[1]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[1]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[1]]$data$simday, na.rm = T), "-", max(maps[[1]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[1]]$data$year, na.rm=T))) +
#     theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")),
# 
#   maps[[2]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[2]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[2]]$data$simday, na.rm = T), "-", max(maps[[2]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[2]]$data$year, na.rm=T))) +
#     theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")),
# 
#   maps[[3]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[3]]$data$round))))+
#     ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[3]]$data$simday, na.rm = T), "-", max(maps[[3]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[3]]$data$year, na.rm=T)))
#   + theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")),
# 
#   maps[[4]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[4]]$data$round))))+
#     ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[4]]$data$simday, na.rm = T), "-", max(maps[[4]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[4]]$data$year, na.rm=T)))
#   + theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")))
# 
# # 
# map_leg = plot_grid(all_map, legend, nrow = 2, rel_heights = c(1, .2))
# # 
# saveRDS(all_maps, paste0(outputs, '/', "SMC", "_high access children_Scenario 1 (Business as Usual)", "_", as.character(2020), ".rds"), compress = FALSE)
# 
# # 
# 
