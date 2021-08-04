import::from(tidyr, '%>%')
import::from(purrr, map2, map)
import::from(dplyr, left_join, mutate)
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
# library(dplyr)
# library(tidyr)
# repo<- "../../../"
# # outputs <- file.path('../../data/Prevalence')
# inputs <- file.path(repo, 'simulation_outputs', 'indicators_noGTS_data')

#################################################
#no GTS
################################################


# labels <- c('Modeled historical trend', 'Business as usual (Scenario 1)', 'NMSP, ramping up to 80% coverage (Scenario 2)',
# 'Budget-prioritized plan with coverage increases at \n historical rate and SMC in 235 LGAs (Scenario 3)',
# 'Budget-prioritized plan with coverage increases at \n historical rate and SMC in 310 LGAs (Scenario 4)')
# 
# shapes <- c(NA, NA,NA, NA, NA, 19)
# 
# linetype <- c("solid", "solid","solid", "solid", "solid", 'blank')
# 
# values <- c( "#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3")



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
#           strip.text.x = element_text(size = 8, colour = "black", face = "bold")) +
#     scale_y_continuous(breaks = pin, limits = limits) +
#     theme(axis.title.y.left = element_text(margin = margin(r = 0.1, unit ='in')),
#           axis.title.y = element_text(face ='bold'))+
#     labs(x = '', y = ylab, col= "INTERVENTION SCENARIOS", title =title) +
#     theme(axis.title.x=element_blank())
# }

# #PfPR all ages
# 
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_data.csv'))
# df$PfPR_all_ages <- round(df$PfPR_all_ages, 3)
# df$PfPR_all_ages_max <- round(df$PfPR_all_ages_max, 3)
# df$PfPR_all_ages_min <- round(df$PfPR_all_ages_min, 3)
# 
# df <- tibble::tibble(PfPR_all_ages=df$PfPR_all_ages, PfPR_all_ages_min=df$PfPR_all_ages_min,
#                      PfPR_all_ages_max=df$PfPR_all_ages_max, year = df$year, scenario=df$scenario)
# 
# pfpr <- line_plot(df$PfPR_all_ages, "all age PfPR by microscopy, annual average", df$PfPR_all_ages_min, df$PfPR_all_ages_max, 'Projected national yearly trends in parasite prevalence (2020 - 2030)', pin = c(0, 0.10, 0.20, 0.30), limits = c(0.00, 0.30))
# saveRDS(pfpr, paste0(outputs, '/', "Prevalence_", "National", ".rds"), compress = FALSE)
# 
# 
# 
# # U5 PfPR
# 
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_data.csv'))
# df$PfPR_U5 <- round(df$PfPR_U5, 3)
# df$PfPR_U5_max <- round(df$PfPR_U5_max, 3)
# df$PfPR_U5_min <- round(df$PfPR_U5_min, 3)
# 
# df <- tibble::tibble(PfPR_U5=df$PfPR_U5, PfPR_U5_min=df$PfPR_U5_min,
#                      PfPR_U5_max=df$PfPR_U5_max, year = df$year, scenario=df$scenario)
# 
# U5pfpr <- line_plot(df$PfPR_U5, "U5 PfPR by microscopy, annual average", df$PfPR_U5_min, df$PfPR_U5_max,
#                     'Projected trends in parasite prevalence', pin = c(0.00, 0.10, 0.20, 0.30), limits = c(range(pretty(df$PfPR_U5))))
# 
# U5pfpr=U5pfpr + theme(plot.title = element_blank())
# 
# saveRDS(U5pfpr, paste0(outputs, '/', "Prevalence_", "National", '_U5',  ".rds"), compress = FALSE)
# 
# 
# # U5 incidence
# 
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_data.csv'))
# df$incidence_U5 <- round(df$incidence_U5, 3)
# df$incidence_U5_max <- round(df$incidence_U5_max, 3)
# df$incidence_U5_min <- round(df$incidence_U5_min, 3)
# 
# df <- tibble::tibble(incidence_U5=df$incidence_U5, incidence_U5_min=df$incidence_U5_min,
#                      incidence_U5_max=df$incidence_U5_max, year = df$year, scenario=df$scenario)
# 
# u5_incidence <- line_plot(df$incidence_U5, "U5 annual incidence per 1000", df$incidence_U5_min, df$incidence_U5_max,
#                           '', pin = c(0, 1000, 2000), limits = c(0, 2500))
# 
# u5_incidence=u5_incidence + theme(plot.title = element_blank())
# 
# outputs <- file.path('../../data/Incidence')
# saveRDS(u5_incidence, paste0(outputs, '/', "Incidence_", "National", '_U5', ".rds"), compress = FALSE)
# 
# 
#U5 deaths
# line_plot_int <- function(y,ylab, ymin, ymax, title, pin, limits) {
#   p<-ggplot(df, aes(x = year, y = y, color =scenario, fill =scenario, tooltip = y)) +
#     geom_ribbon(aes(ymin =ymin, ymax =ymax), alpha = .3, color = NA)  +
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
#           strip.text.x = element_text(size = 8, colour = "black", face = "bold")) +
#     scale_y_continuous(breaks = pin, limits = limits) +
#     theme(axis.title.y.left = element_text(margin = margin(r = 0.1, unit ='in')),
#           axis.title.y = element_text(face ='bold'))+
#     labs(x = '', y = ylab, col= "INTERVENTION SCENARIOS", title =title) +
#     theme(axis.title.x=element_blank())
# }
# 
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_data.csv'))
# df$death_rate_mean_U5 <- round(df$death_rate_mean_U5, 3)
# df$death_rate_mean_U5_max <- round(df$death_rate_mean_U5_max, 3)
# df$death_rate_mean_U5_min <- round(df$death_rate_mean_U5_min, 3)
# 
# df <- tibble::tibble(death_rate_mean_U5=df$death_rate_mean_U5, death_rate_mean_U5_min=df$death_rate_mean_U5_min,
#                      death_rate_mean_U5_max=df$death_rate_mean_U5_max, year = df$year, scenario=df$scenario)
# 
# u5_deaths <- line_plot_int(df$death_rate_mean_U5, "U5 annual death per 1000", df$death_rate_mean_U5_min, df$death_rate_mean_U5_max,
#                           '', c(0, 2, 4), limits = c(0, 5))
# 
# u5_deaths=u5_deaths + theme(plot.title = element_blank())
# 
# outputs <- file.path('../../data/Trends')
# 
# saveRDS(u5_deaths, paste0(outputs, '/', "Mortality_", "National", "_U5", ".rds"), compress = FALSE)

# #################################################
# #GTS
# ################################################
# 
# labels <-c('Modeled historical trend', 'Business as usual (Scenario 1)', 'NMSP with ramping up to 80% coverage (Scenario 2)',
# 'Budget-prioritized plan with coverage increases at \n historical rate and SMC in 235 LGAs (Scenario 3)  ',
# 'Budget-prioritized plan with coverage increases at \n historical rate and SMC in 310 LGAs (Scenario 4)  ', 'GTS targets based on 2015 modeled estimate')
# 
# values <-c("#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3", "#000000")
# 
# shapes <- c(NA, NA,NA, NA, NA, 19)
# 
# linetype <- c("solid", "solid","solid", "solid", "solid", 'blank')


# #incidence
# inputs <- file.path(repo, 'simulation_outputs', 'indicators_withGTS_data')
# df_gts<- data.table::fread(file.path(inputs, 'indicators_withGTS_data.csv'))
# df_gts$incidence_all_ages <- round(df_gts$incidence_all_ages, 3)
# df_gts$incidence_all_ages_max <- round(df_gts$incidence_all_ages_max, 3)
# df_gts$incidence_all_ages_min <- round(df_gts$incidence_all_ages_min, 3)
# 
# df_gts<- tibble::tibble(incidence_all_ages=df_gts$incidence_all_ages, incidence_all_ages_max=df_gts$incidence_all_ages_max,
#                         incidence_all_ages_min=df_gts$incidence_all_ages_min,
#                         year = df_gts$year, scenario=df_gts$scenario)
# 
# #pin<- pretty(df_gts$incidence_all_ages)
# incidence<-ggplot(df_gts, aes(x = year,  y = incidence_all_ages, color =scenario, fill =scenario)) +
#   geom_ribbon(data = filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate'))),
#               aes(ymin =incidence_all_ages_min, ymax =incidence_all_ages_max), alpha = .3, color = NA)+
#   geom_line_interactive(data = filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate'))),  size =0.5)+
#   geom_point(data = filter(df_gts, scenario %in% c('GTS targets based on 2015 modeled estimate')), size = 3)+
#   labs(y = "all age annual incidence per 1000", color= "INTERVENTION SCENARIOS", title ='Projected trends in national uncomplicated malaria incidence (2020 - 2030)')+
#   scale_color_manual(labels=labels,
#                      values = values,
#                      breaks = unique(df_gts$scenario),
#                      guide = guide_legend(override.aes = list(
#                        linetype = linetype,
#                        shape = shapes)))+
#   scale_fill_manual(values = values,  breaks = unique(df_gts$scenario), guide = FALSE)+
#   scale_shape_manual(values = shapes)+
#   theme_bw()+
#   theme(legend.direction = "vertical",
#         legend.position = c(0.28, 0.25),
#         legend.background = element_rect(fill = "white", colour = 'black'),
#         legend.key = element_rect(size = 3),
#         legend.key.size = unit(0.8, "cm"),
#         legend.text = element_text(size = 9.5),
#         plot.title=element_text(color = "black", face = "bold", hjust=0.5),
#         panel.border = element_blank(),
#         axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "black"),
#         axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "black"),
#         axis.text.x = element_text(size = 12, color = "black"),
#         axis.text.y = element_text(size = 12, color = "black"),
#         strip.text.x = element_text(size = 8, colour = "black", face = "bold"))+
#       theme(axis.title.y.left = element_text(margin = margin(r = 0.1, unit ='in')),
#       axis.title.y = element_text(face ='bold'))+
#   scale_y_continuous(expand = c(0, 0), breaks =c(0, 400, 800, 1200),  limits = c(0, 1400)) +
#   theme(axis.title.x=element_blank())
# 
# outputs <- file.path('../../data/Trends')
# 
# saveRDS(incidence, paste0(outputs, '/', "Incidence_", "National", ".rds"), compress = FALSE)
# 
# 
# 
# #deaths
# inputs <- file.path(repo, 'simulation_outputs', 'indicators_withGTS_data')
# df_gts<- data.table::fread(file.path(inputs, 'indicators_withGTS_data.csv'))
# 
# #data cleaning
# 
# df_gts$death_rate_mean_all_ages <- round(df_gts$death_rate_mean_all_ages, 3)
# df_gts$death_rate_mean_all_ages_max <- round(df_gts$death_rate_mean_all_ages_max, 3)
# df_gts$death_rate_mean_all_ages_min <- round(df_gts$death_rate_mean_all_ages_min, 3)
# 
# df_gts<- tibble::tibble(death_rate_mean_all_ages=df_gts$death_rate_mean_all_ages,
#                         death_rate_mean_all_ages_max=df_gts$death_rate_mean_all_ages_max,
#                         death_rate_mean_all_ages_min=df_gts$death_rate_mean_all_ages_min,
#                         year = df_gts$year, scenario=df_gts$scenario)
# 
# 
# 
#pin<- pretty(df_gts$death_rate_mean_all_ages)
# death<-ggplot(df_gts, aes(x = year,  y = death_rate_mean_all_ages, color =scenario, fill =scenario)) +
#   geom_ribbon(data = filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate'))),
#               aes(ymin =death_rate_mean_all_ages_min, ymax =death_rate_mean_all_ages_max), alpha = .3, color = NA)+
#   geom_line_interactive(data = filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate'))),  size =0.5)+
#   geom_point(data = filter(df_gts, scenario %in% c('GTS targets based on 2015 modeled estimate')), size = 3)+
#   labs(x = '', y = 'all age annual death per 1000', color= "INTERVENTION SCENARIOS", title ="Projected trends in malaria mortality (2020 - 2030)")+
#   scale_color_manual(labels=labels,
#                      values = values,
#                      breaks = unique(df_gts$scenario),
#                      guide = guide_legend(override.aes = list(
#                        linetype = linetype,
#                        shape = shapes)))+
#   scale_fill_manual(values = values,  breaks = unique(df_gts$scenario), guide = FALSE)+
#   scale_shape_manual(values = shapes)+
#   theme_bw()+
#   theme(legend.direction = "vertical",
#         legend.position = c(0.28, 0.25),
#         legend.background = element_rect(fill = "white", colour = 'black'),
#         legend.key = element_rect(size = 3),
#         legend.key.size = unit(0.8, "cm"),
#         legend.text = element_text(size = 9.5),
#         plot.title=element_text(color = "black", face = "bold", hjust=0.5),
#         panel.border = element_blank(),
#         axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "black"),
#         axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "black"),
#         axis.text.x = element_text(size = 12, color = "black"),
#         axis.text.y = element_text(size = 12, color = "black"),
#         strip.text.x = element_text(size = 8, colour = "black", face = "bold"))+
#   theme(axis.title.y.left = element_text(margin = margin(r = 0.1, unit ='in')),
#         axis.title.y = element_text(face ='bold'))+
#   scale_y_continuous(expand = c(0, 0), breaks=c(0.0, 0.4, 0.8, 1.2), limits = c(0, 1.2))+
#   theme(axis.title.x=element_blank())
# 
# outputs <- file.path('../../data/Trends')
# 
# saveRDS(death, paste0(outputs, '/', "Mortality_", "National", ".rds"), compress = FALSE)
# data <- "../../data"
# plot=readRDS(file = paste0(data, "/Prevalence/", 'Prevalence', '_', 'National', ".rds"))
# print(plot)

#--------------------------------------------

# relative change in 2030 compared to 2020

#---------------------------------------------


# library(ggplot2)
# library(ggiraph)
# library(dplyr)
# library(tidyr)
# repo<- "../../../"
# outputs <- file.path('../../data/Relative_change_2030')
inputs <- file.path(repo, 'simulation_outputs', 'indicators_noGTS_data')
