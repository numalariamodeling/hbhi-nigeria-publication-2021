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
                   legend.title = element_blank(),
                   legend.background = element_rect(fill = "white", colour = 'black'),
                   legend.key = element_rect(size = 3),
                   legend.key.height = unit(0.65, "cm"),
                   legend.key.width = unit(0.60, "cm"),
                   legend.margin=margin(t=-0.25,l=0.05,b=0.0,r=0.05, unit='cm'),
                   legend.text = ggplot2::element_text(size = 8),
                   legend.text.align = 0, 
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
    theme(axis.title.x=element_blank())
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
          legend.key.height = unit(0.65, "cm"),
          legend.key.width = unit(0.60, "cm"),
          legend.text = element_text(size = 8),
          legend.text.align = 0,
          legend.margin=margin(t=-0.25,l=0.05,b=0.0,r=0.05, unit='cm'),
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


generateBar<- function(df, column1, column2, ylab, title){
  plot =ggplot2::ggplot(df, aes(x = {{column1}}, y = column2, fill ={{column1}}))+
    ggiraph::geom_bar_interactive(data=df, stat="identity", tooltip = round(column2, 1))+
    labs(x = '', y = ylab,  title =title) +
    theme_classic()+
    scale_fill_manual(values = c('#913058', "#F6851F", "#00A08A", "#8971B3"))+
    theme(legend.position = 'none',
          axis.text.x = element_text(size = 12, color = "black"),
          axis.text.y = element_text(size = 12, color = "black"),
          axis.title.y = element_text(face ='bold'),
          plot.title=element_text(color = "black", face = "bold", hjust=0.5))
  
}

str_wrap_factor <- function(x, ...) {
  levels(x) <- str_wrap(levels(x), ...)
  x
}

######################################################################################
# data 
######################################################################################

statesf <- sf::st_read("data/shapefiles/gadm36_NGA_shp/gadm36_NGA_1.shp") %>% 
  dplyr::mutate(NAME_1 = dplyr::case_when(NAME_1 == 'Nassarawa' ~ 'Nasarawa',
                                     TRUE ~ as.character(NAME_1)))



