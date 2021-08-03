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

# library(ggplot2)
# library(ggiraph)
# repo<- "../../../"
# outputs <- file.path('../../data/Prevalence')
# inputs <- file.path(repo, 'simulation_outputs', 'indicators_noGTS_data')
# 
# 
# 
# 
# labels <- c('Modeled historical trend', 'Business as usual (Scenario 1)', 'NMSP, ramping up to 80% coverage (Scenario 2)',
# 'Budget-prioritized plan with coverage increases at \n historical rate and SMC in 235 LGAs (Scenario 3)',
# 'Budget-prioritized plan with coverage increases at \n historical rate and SMC in 310 LGAs (Scenario 4)')
# 
# shapes <- c(NA, NA,NA, NA, NA, 19)
# 
# linetype <- c("solid", "solid","solid", "solid", "solid", 'blank')
# 
# values <- c( "#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3")
# 
# 
# 
# line_plot <- function(y,ylab, ymin, ymax, title, pin, limits) {
#   p<-ggplot(df, aes(x = year, y = y, color =scenario, fill =scenario, tooltip = y)) +
#     geom_ribbon(aes(ymin =ymin, ymax =ymax), alpha = .3, colour = NA)  +
#     geom_line_interactive(size =0.7)+
#     scale_color_manual(labels= labels,
#                        values = values)+
#     scale_fill_manual(values = values, guide = FALSE)+
#     theme_bw()+
#     theme(legend.direction = "vertical",
#           legend.position = c(0.28, 0.25),
#           legend.background = element_rect(fill = "white", colour = 'black'),
#           legend.key = element_rect(size = 3),
#           legend.key.size = unit(0.8, "cm"),
#           legend.text = element_text(size = 9.5),
#           plot.title=element_text(size=, color = "black", face = "bold", hjust=0.5),
#           panel.border = element_blank(),
#           axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "black"),
#           axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "black"),
#           axis.text.x = element_text(size = 12, color = "black"),
#           axis.text.y = element_text(size = 12, color = "black"),
#           #axis.ticks.x = element_blank(),
#           #axis.ticks.y = element_blank(),
#           strip.text.x = element_text(size = 8, colour = "black", face = "bold")) +
#     scale_y_continuous(expand = c(0, 0), breaks = pin, limits = limits) +
#     labs(x = '', y = ylab, col= "INTERVENTION SCENARIOS", title =title)
# }
# 
# all_ages_title <- expression(paste(atop(textstyle(bold("all age PfPR by microscopy, annual average")))))
# 
# u5_title <- expression(paste(atop(textstyle(bold("children under the age of five")),
#                                   atop(textstyle("U5 PfPR by microscopy,"),
#                                        textstyle("annual average")))))
# 
# 
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_data.csv'))
# pfpr <- line_plot(df$PfPR_all_ages, all_ages_title, df$PfPR_all_ages_min, df$PfPR_all_ages_max, 'Projected Trends in Parasite Prevalence', pretty(df$PfPR_all_ages), limits = c(0.00, 0.30))
# 
# 
# saveRDS(pfpr, paste0(outputs, '/', "Prevalence_", "National", ".rds"), compress = FALSE)

# data <- "../../data"
# plot=readRDS(file = paste0(data, "/Prevalence/", 'Prevalence', '_', 'National', ".rds"))
# print(plot)


# labels <-c('Modeled historical trend', 'Business as usual (Scenario 1)', 'NMSP with ramping up to 80% coverage (Scenario 2)',
# 'Budget-prioritized plan with coverage increases at historical rate and SMC in 235 LGAs (Scenario 3)  ',
# 'Budget-prioritized plan with coverage increases at historical rate and SMC in 310 LGAs (Scenario 4)  ', 'GTS targets based on 2015 modeled estimate')
# 
# values <-c("#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3", "#000000") #"", "#D61B5A", "#5393C3", "#98B548"
