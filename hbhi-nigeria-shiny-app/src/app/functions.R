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


generateLine <- function(df, y,ylab, title, pin, limits) {
  p<-ggplot2::ggplot(df, ggplot2::aes(x = year, y = y, color =scenario, group =scenario)) +
    ggiraph::geom_line_interactive(size =0.7)+
    ggiraph::geom_point_interactive(size=0.1, ggplot2::aes(tooltip =y))+
    ggplot2::scale_color_manual(labels= c('Modeled historical trend', 'Business as usual (Scenario 1)', 'NMSP, ramping up to 80% coverage (Scenario 2)',
                                          'BPP, coverage increases at historical rate \n (Scenario 3)',
                                          'BPP, coverage increases at historical rate \n and expanded SMC (Scenario 4)'),
                                values = c( "#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3"))+
    ggplot2::theme_bw()+
    ggplot2::theme(legend.direction = "vertical", 
                   legend.background = element_rect(fill = "white", colour = 'black'),
                   legend.key = element_rect(size = 3),
                   legend.key.size = unit(0.65, "cm"),
                   legend.text = ggplot2::element_text(size = 8),
                   plot.title=ggplot2::element_text(size=, color = "black", face = "bold", hjust=0.5),
                   panel.border = element_blank(),
                   axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "black"),
                   axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "black"),
                   axis.text.x = element_text(size = 12, color = "black"),
                   axis.text.y = element_text(size = 12, color = "black"),
                   strip.text.x = ggplot2::element_text(size = 8, colour = "black", face = "bold")) +
    scale_y_continuous(breaks = pin, limits = limits) +
    theme(axis.title.y.left = ggplot2::element_text(margin = margin(r = 0.1, unit ='in')),
          axis.title.y = ggplot2::element_text(face ='bold'))+
    labs(x = '', y = ylab,  title =title) + #col= "INTERVENTION SCENARIOS",
    theme(axis.title.x=element_blank(), legend.title = element_blank())
}


generateLinePT <- function(df_gts, data_1, data_2, breaks, limits) {
  p<-ggplot(df_gts, aes(x = year,  y = count, color =scenario, fill =scenario)) +
    geom_line_interactive(data = data_1,  
                          size =0.7)+
    geom_point_interactive(data = data_1, 
                           size =0.1, aes(tooltip = round(count, 3)))+
    geom_point_interactive(data = data_2 , size = 3, tooltip =round(data_2$count, 3))+
    scale_color_manual(labels=c('Modeled historical trend', 'Business as usual (Scenario 1)', 'NMSP with ramping up to 80% coverage (Scenario 2)',
                                'BPP, coverage increases at \n historical rate (Scenario 3)  ',
                                'BPP with coverage increases at \n historical rate (Scenario 4)  ', 'GTS targets based on 2015 modeled estimate'),
                       values = c("#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3", "#000000"),
                       breaks = c("NGA projection scenario 0", "NGA projection scenario 1", "NGA projection scenario 2", "NGA projection scenario 3", "NGA projection scenario 4", "GTS targets based on 2015 modeled estimate"),
                       guide = guide_legend(override.aes = list(
                         linetype = c("solid", "solid","solid", "solid", "solid", 'blank'),
                         shape = c(NA, NA,NA, NA, NA, 19))))+
    scale_fill_manual(values = c("#5a5757", '#913058', "#F6851F", "#00A08A", "#8971B3", "#000000"),  breaks =
                        c("NGA projection scenario 0", "NGA projection scenario 1", "NGA projection scenario 2", "NGA projection scenario 3", "NGA projection scenario 4", "GTS targets based on 2015 modeled estimate"), guide = FALSE)+
    scale_shape_manual(values = c(NA, NA,NA, NA, NA, 19))+
    theme_bw()+
    theme(legend.direction = "vertical",
          legend.title =element_blank(),
          legend.background = element_rect(fill = "white", colour = 'black'),
          legend.key = element_rect(size = 3),
          legend.key.size = unit(0.65, "cm"),
          legend.text = element_text(size = 8),
          plot.title=element_text(color = "black", face = "bold", hjust=0.5),
          panel.border = element_blank(),
          axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "black"),
          axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "black"),
          axis.text.x = element_text(size = 12, color = "black"),
          axis.text.y = element_text(size = 12, color = "black"),
          strip.text.x = element_text(size = 8, colour = "black", face = "bold"))+
    theme(axis.title.y.left = element_text(margin = margin(r = 0.1, unit ='in')),
          axis.title.y = element_text(face ='bold'))+
    scale_y_continuous(expand = c(0, 0), breaks = breaks, limits=limits) +
    theme(axis.title.x=element_blank())
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

statesf <- sf::st_read("../../data/shapefiles/gadm36_NGA_shp/gadm36_NGA_1.shp") %>% 
  dplyr::mutate(NAME_1 = dplyr::case_when(NAME_1 == 'Nassarawa' ~ 'Nasarawa',
                                     TRUE ~ as.character(NAME_1)))


######################################################################################
# intervention 
######################################################################################

# library(ggplot2)
# library(ggiraph)
# library(dplyr)
# library(tidyr)
# repo<- "../../../"
# outputs <- file.path('../../data/Trends')
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


#creating State data 

# library(dplyr)
# library(tidyr)
# library(stringr)
# library(patchwork)
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_state.csv')) %>% dplyr::select(-c(death_rate_1_all_ages,death_rate_2_all_ages, death_rate_1_U5, death_rate_2_U5, V1, .id)) %>%
#  filter(year !=2010) %>%  pivot_longer(cols=-c('State', 'scenario', 'year'), names_to = 'indicator', values_to='count') %>%
#   mutate(trend = ifelse(grepl('^PfPR', indicator),'Prevalence',
#                                             ifelse(grepl('^incidence', indicator),'Incidence per 1000',
#                                                              ifelse(grepl('^death', indicator), 'Deaths per 1000', NA)))) %>%
#   mutate(age =  ifelse(grepl('ages', indicator), 'all_ages',
#                        ifelse(grepl('U5', indicator), 'U5', NA))) %>%
#   mutate(State = stringr::str_replace_all(State, '\\_', ' ')) %>%  mutate(count = round(count, 2))
# write.csv(df, file.path(inputs, 'indicators_noGTS_state_new.csv'), row.names = FALSE)

# line<- data.table::fread(file.path(inputs, 'indicators_noGTS_state_new.csv')) %>%  dplyr::filter(trend == 'Prevalence' & age =='U5', State == 'Abia')
# U5pfpr <- generateLine(line, line$count, "U5 PfPR by microscopy, annual average", title='Projected trends in parasite prevalence', pin = c(0.00, 0.10, 0.20, 0.30), limits = c(range(pretty(line$count))))
# map <- statesf %>%  filter(NAME_1 == 'Abia')
# plot = statesf%>% mutate(interest = ifelse(NAME_1 == 'Abia', 'Abia', NA)) 
# map = ggplot2::ggplot(plot)+
#   ggiraph::geom_sf_interactive(ggplot2::aes(fill = interest))+
#   ggplot2::theme(axis.text.x = ggplot2::element_blank(),
#                  axis.text.y = ggplot2::element_blank(),
#                  axis.ticks = ggplot2::element_blank(),
#                  rect = ggplot2::element_blank(),
#                  plot.background = ggplot2::element_rect(fill = "white", colour = NA),
#                  legend.position = 'none')
# patchwork::map + U5pfpr +  plot_layout(widths = c(0.5, 2))


# #PfPR all ages
# 
# df<- data.table::fread(file.path(inputs, 'indicators_noGTS_data.csv'))
# df$PfPR_all_ages <- round(df$PfPR_all_ages, 3)
# df$PfPR_all_ages_max <- round(df$PfPR_all_ages_max, 3)
# df$PfPR_all_ages_min <- round(df$PfPR_all_ages_min, 3)
# #
# df <- tibble::tibble(PfPR_all_ages=df$PfPR_all_ages, PfPR_all_ages_min=df$PfPR_all_ages_min,
#                      PfPR_all_ages_max=df$PfPR_all_ages_max, year = df$year, scenario=df$scenario)
# #
# pfpr <- generateLine(df$all_ages_PfPR, "all age PfPR by microscopy, annual average", 'Projected national yearly trends in parasite prevalence (2020 - 2030)', pin = c(0, 0.10, 0.20, 0.30), limits = c(0.00, 0.30))
# # 
# x = girafe(ggobj = pfpr, options = list(opts_tooltip(
#     opacity = .8,
#     css = "background-color:gray;color:white;padding:2px;border-radius:2px;"
#   ),
#   opts_hover(css = "fill:#1279BF;stroke:#1279BF;cursor:pointer;")
# )
# )
# 
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
# U5pfpr <- line_plot(df$PfPR_U5, "U5 PfPR by microscopy, annual average", title='Projected trends in parasite prevalence', pin = c(0.00, 0.10, 0.20, 0.30), limits = c(range(pretty(df$PfPR_U5))))
# 
# U5pfpr=U5pfpr + theme(plot.title = element_blank())
# 
# x = girafe(ggobj = U5pfpr, options = list(opts_tooltip(
#   opacity = .8,
#   css = "background-color:gray;color:white;padding:2px;border-radius:2px;"
# ),
# opts_hover(css = "fill:#1279BF;stroke:#1279BF;cursor:pointer;")
# )
# )
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
# u5_incidence <- line_plot(df$incidence_U5, "U5 annual incidence per 1000", '', pin = c(0, 1000, 2000), limits = c(0, 2500))
# 
# u5_incidence=u5_incidence + theme(plot.title = element_blank())
# 
# x = girafe(ggobj = u5_incidence, options = list(opts_tooltip(
#   opacity = .8,
#   css = "background-color:gray;color:white;padding:2px;border-radius:2px;"
# ),
# opts_hover(css = "fill:#1279BF;stroke:#1279BF;cursor:pointer;")
# )
# )
# outputs <- file.path('../../data/Trends')
# saveRDS(u5_incidence, paste0(outputs, '/', "Incidence_", "National", '_U5', ".rds"), compress = FALSE)
# 
# 
# #U5 deaths
# line_plot_int <- function(y,ylab, ymin, ymax, title, pin, limits) {
#   p<-ggplot(df, aes(x = year, y = y, color =scenario, fill =scenario)) +
#     geom_ribbon_interactive(aes(ymin =ymin, ymax =ymax), alpha = .3, color = NA)  +
#     geom_line_interactive(size =0.7)+
#     geom_point_interactive(size=0.1, aes(tooltip =y))+
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
# x = girafe(ggobj = u5_deaths, options = list(opts_tooltip(
#   opacity = .8,
#   css = "background-color:gray;color:white;padding:2px;border-radius:2px;"
# ),
# opts_hover(css = "fill:#1279BF;stroke:#1279BF;cursor:pointer;")
# )
# )
# 
# outputs <- file.path('../../data/Trends')
# 
# saveRDS(u5_deaths, paste0(outputs, '/', "Mortality_", "National", "_U5", ".rds"), compress = FALSE)
# 
# # #################################################
# # #GTS
# # ################################################
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
# 


# repo<- "../../../"
# inputs <- file.path(repo, 'simulation_outputs', 'indicators_withGTS_data')
# 





# df<- data.table::fread(file.path(inputs, 'indicators_withGTS_state.csv')) %>% dplyr::select(-c(death_rate_1_all_ages,death_rate_2_all_ages, death_rate_1_U5, death_rate_2_U5, V1, .id)) %>%
#  dplyr::filter(year !=2010) %>%  tidyr::pivot_longer(cols=-c('State', 'scenario', 'year'), names_to = 'indicator', values_to='count') %>%
#   mutate(trend = ifelse(grepl('^PfPR', indicator),'Prevalence',
#                                             ifelse(grepl('^incidence', indicator),'Incidence per 1000',
#                                                              ifelse(grepl('^death', indicator), 'Deaths per 1000', NA)))) %>%
#   mutate(age =  ifelse(grepl('ages', indicator), 'all_ages',
#                        ifelse(grepl('U5', indicator), 'U5', NA))) %>%
#   mutate(State = stringr::str_replace_all(State, '\\_', ' ')) %>%  mutate(count = round(count, 2))
# write.csv(df, file.path(inputs, 'indicators_withGTS_state_new.csv'), row.names = FALSE)
# 
# plot_df = df %>%  dplyr::filter(trend == 'Incidence per 1000' & State == 'Adamawa' & age == 'all_ages')
# df_gts = plot_df
# 
# data_1 = dplyr::filter(plot_df, !(scenario %in% c('GTS targets based on 2015 modeled estimate')))
# data_2 = dplyr::filter(plot_df, scenario %in% c('GTS targets based on 2015 modeled estimate'))
# breaks = pretty(df_gts$count)
# limits = range(pretty(df_gts$count))
# plot = generateLinePT(data_1, data_2, breaks)



# 
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
# 
# data = dplyr::filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate')))
# data2 = dplyr::filter(df_gts, scenario %in% c('GTS targets based on 2015 modeled estimate'))
# incidence_all_ages =data$incidence_all_ages
# 
# #pin<- pretty(df_gts$incidence_all_ages)
# incidence<-ggplot(df_gts, aes(x = year,  y = incidence_all_ages, color =scenario, fill =scenario)) +
#   geom_ribbon_interactive(data = data,
#               aes(ymin =incidence_all_ages_min, ymax =incidence_all_ages_max), alpha = .3, color = NA)+
#   geom_line_interactive(data = data,  size =0.7)+
#   geom_point_interactive(data =data, size =0.1, aes(tooltip = round(incidence_all_ages, 3)))+
#   geom_point_interactive(data = data2, size = 3, tooltip =round(data2$incidence_all_ages, 3))+
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
# x = girafe(ggobj = incidence, options = list(opts_tooltip(
#     opacity = .8,
#     css = "background-color:gray;color:white;padding:2px;border-radius:2px;"
#   ),
#   opts_hover(css = "fill:#1279BF;stroke:#1279BF;cursor:pointer;")
#   )
#   )
# 
# 
# outputs <- file.path('../../data/Trends')
# 
# saveRDS(incidence, paste0(outputs, '/', "Incidence_", "National", ".rds"), compress = FALSE)
# 
# incidence<-readRDS(paste0(outputs, '/','Incidence_',  "National", "_U5", ".rds"))
# incidence
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
# data = filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate')))
# data2 = filter(df_gts, scenario %in% c('GTS targets based on 2015 modeled estimate'))
# 
# pin<- pretty(df_gts$death_rate_mean_all_ages)
# death<-ggplot(df_gts, aes(x = year,  y = death_rate_mean_all_ages, color =scenario, fill =scenario)) +
#   geom_ribbon_interactive(data = data,
#               aes(ymin =death_rate_mean_all_ages_min, ymax =death_rate_mean_all_ages_max), alpha = .3, color = NA)+
#   geom_line_interactive(data = data, size =0.7)+
#   geom_point_interactive(data =data, size =0.1, aes(tooltip = round(death_rate_mean_all_ages, 3)))+
#   geom_point_interactive(data = data2, size = 3, tooltip =round(data2$death_rate_mean_all_ages, 3))+
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
# 
# 
# # data <- "../../data"
# # plot=readRDS(file = paste0(data, "/Prevalence/", 'Prevalence', '_', 'National', ".rds"))
# # print(plot)
# 
# #--------------------------------------------
# 
# # relative change in 2030 compared to 2020
# 
# #---------------------------------------------
# 
# 
# library(ggplot2)
# library(ggiraph)
# library(dplyr)
# library(tidyr)
# library(stringr)
# library(rlang)
# 
# 
# #params
# projection_year = 2030
# comparison_year = 2015
# repo<- "../../../"
# input_csv='relative_change_2015_base.csv'
# inputs <- file.path(repo, 'simulation_outputs', 'relative_change_2015_base')
# outputs <- file.path('../../data/Relative_change_2025_2015_base')
# 
# values <-c('#913058', "#F6851F", "#00A08A", "#8971B3")
# 
# generateBar<- function(column1, column2, ylab, title){
# plot =ggplot(df, aes(x = {{column1}}, y = column2, fill ={{column1}}))+
#   ggiraph::geom_bar_interactive(data=df, stat="identity", tooltip = round(column2, 1))+
#   labs(x = '', y = ylab,  title =title) +
#   theme_classic()+
#   scale_fill_manual(values = values)+
#   theme(legend.position = 'none',
#         axis.text.x = element_text(size = 12, color = "black"),
#         axis.text.y = element_text(size = 12, color = "black"),
#         axis.title.y = element_text(face ='bold'),
#         plot.title=element_text(color = "black", face = "bold", hjust=0.5))
# 
# }
# 
# str_wrap_factor <- function(x, ...) {
#   levels(x) <- str_wrap(levels(x), ...)
#   x
# }
# 
# #pfpr
# df<- data.table::fread(file.path(inputs, input_csv)) %>%  filter(year == projection_year)
# 
# df <- tibble::tibble(scenario=df$scenario, PfPR_percent_change=df$PfPR_percent_change, projection_year = projection_year,
#                      comparison_year = comparison_year)
# df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
# df$scenario = str_wrap_factor(df$scenario, width=20)
# 
# 
# pfpr <- generateBar(scenario,df$PfPR_percent_change,
#                    paste0('Percent change in all age PfPR in ', projection_year, '\n compared to ', comparison_year),
#                     paste0("Projected change in ", projection_year, ' prevalence relative to ', comparison_year))
# pfpr
# x <- girafe(ggobj = pfpr)
# if( interactive() ) print(x)
# 
# saveRDS(pfpr, paste0(outputs, '/','Prevalence_',  "National", ".rds"), compress = FALSE)
# 
# pfpr<-readRDS(paste0(outputs, '/','Prevalence_',  "National", ".rds"))
# pfpr
# 
# 
# #u5 pfpr
# df<- data.table::fread(file.path(inputs, input_csv)) %>%  filter(year ==projection_year)
# df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
# 
# df <- tibble::tibble(scenario=df$scenario, U5_PfPR_percent_change=df$U5_PfPR_percent_change, projection_year = projection_year,
#                      comparison_year = comparison_year)
# 
# df$scenario = str_wrap_factor(df$scenario, width=20)
# u5pfpr <-generateBar(scenario, df$U5_PfPR_percent_change,
#                      paste0('Percent change in U5 PfPR in ', projection_year,  '\n compared to ', comparison_year), "")
# ufpfpr = u5pfpr + theme(plot.title = element_blank())
# 
# x <- girafe(ggobj = u5pfpr)
# if( interactive() ) print(x)
# 
# 
# saveRDS(u5pfpr, paste0(outputs, '/','Prevalence_',  "National", "_U5",  ".rds"), compress = FALSE)
# 
# u5pfpr<-readRDS(paste0(outputs, '/','Prevalence_',  "National", "_U5", ".rds"))
# u5pfpr
# 
# 
# # incidence
# df<- data.table::fread(file.path(inputs, input_csv)) %>%  filter(year ==projection_year)
# df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
# 
# df <- tibble::tibble(scenario=df$scenario, incidence_percent_change=df$incidence_percent_change,
#                      projection_year = projection_year,
#                      comparison_year = comparison_year)
# df$scenario = str_wrap_factor(df$scenario, width=20)
# incidence <-generateBar(scenario, df$incidence_percent_change,
#                         paste0('Percent change in incidence in ', projection_year, '\n compared to ', comparison_year),
#                         paste0("Projected change in ", projection_year, ' incidence relative to ', comparison_year))
# 
# 
# 
# x <- girafe(ggobj = incidence)
# if( interactive() ) print(x)
# 
# saveRDS(incidence, paste0(outputs, '/','Incidence_',  "National", ".rds"), compress = FALSE)
# 
# 
# #u5 incidence
# df<- data.table::fread(file.path(inputs, input_csv)) %>%  filter(year ==projection_year)
# df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
# 
# df <- tibble::tibble(scenario=df$scenario, U5_incidence_percent_change=df$U5_incidence_percent_change, projection_year = projection_year,
#                      comparison_year = comparison_year)
# 
# df$scenario = str_wrap_factor(df$scenario, width=20)
# u5_incidence <-generateBar(scenario, df$U5_incidence_percent_change,
#                            paste0('Percent change in U5 incidence in ','\n', projection_year, ' compared to ', comparison_year),
#                        "")
# u5_incidence = u5_incidence + theme(plot.title = element_blank())
# 
# x <- girafe(ggobj = u5_incidence)
# if( interactive() ) print(x)
# 
# saveRDS(u5_incidence, paste0(outputs, '/','Incidence_',  "National", "_U5", ".rds"), compress = FALSE)
# 
# 
# 
# #mortality
# df<- data.table::fread(file.path(inputs, input_csv)) %>%  filter(year ==projection_year)
# df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
# 
# df <- tibble::tibble(scenario=df$scenario, death_percent_change=df$death_percent_change,
#                      projection_year = projection_year, comparison_year = comparison_year)
# df$scenario = str_wrap_factor(df$scenario, width=20)
# mortality <-generateBar(scenario, df$death_percent_change,
#                         paste0('Percent change in mortality in ', projection_year, '\n compared to ', comparison_year),
#                         paste0("Projected change in ", projection_year, ' mortality relative to ', comparison_year))
# 
# 
# x <- girafe(ggobj = mortality)
# if( interactive() ) print(x)
# 
# saveRDS(mortality, paste0(outputs, '/','Mortality_',  "National", ".rds"), compress = FALSE)
# 
# 
# 
# #u5 mortality
# df<- data.table::fread(file.path(inputs, input_csv)) %>%  filter(year ==projection_year)
# df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
#                                               "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
# 
# df <- tibble::tibble(scenario=df$scenario, U5_death_percent_change=df$U5_death_percent_change,
#                      projection_year = projection_year, comparison_year = comparison_year)
# df$scenario = str_wrap_factor(df$scenario, width=20)
# u5_mortality <-generateBar(scenario, df$U5_death_percent_change,
#                            paste0('Percent change in U5 mortality in ', projection_year, '\n compared to ', comparison_year),
#                         "")
# u5_mortality = u5_mortality + theme(plot.title = element_blank())
# 
# x <- girafe(ggobj = u5_mortality)
# if( interactive() ) print(x)
# 
# saveRDS(u5_mortality, paste0(outputs, '/','Mortality_',  "National", "_U5", ".rds"), compress = FALSE)
# 
