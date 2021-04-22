### ==========================================================================================
### HBHI modelling - Nigeria: Estimating IPTi coverage per LGA
### Dec 2020, MR
###
### input: DS_pen1_pre_18.csv,  DS_pen3_pre_18.csv and IPTI LGA.xlsx
### output: assumedIPTicov.csv (& Rdata) and figures
### ==========================================================================================
# setwd("~hbhi-nigeria/simulation/IPTi_scaling")

### --------------------------------------------------------------------------------------------
#### Settings and custom objects
source("functions/setup.R")
SAVE <- TRUE

pckg <- c("tidyverse", "gsubfn", "readxl", "data.table", "ggthemes", "cowplot", "scales", "raster", "RColorBrewer")
lapply(pckg, require, character.only = TRUE)


### Directories
Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
NUDir <- file.path(Drive, "Box/NU-malaria-team")
ProjectDir <- file.path(NUDir, "projects")
WorkingDir <- file.path(ProjectDir, "IPTi")
simoutDir <- file.path(ProjectDir, "hbhi_nigeria", "simulation_output/2020_to_2025/cache4_Agebins_FineMonthly")
shpDir <- file.path(Drive, "Box/NU-malaria-team/data/nigeria_shapefiles")


### -------------------------------------------------
### Load vaccine coverage data
### -------------------------------------------------
csvDir <- file.path(NUDir, "data/nigeria_dhs/data_analysis/results/vaccine")
list.files(csvDir, pattern = "state_18.csv")
DSpenfiles <- c("DS.pen2_state_18.csv","DS.pen3_state_18.csv","DS.measles_state_18.csv")

dat1 <- fread(file.path(csvDir,DSpenfiles[1])) %>%
  as.data.frame() %>%
  dplyr::select(c("State","LGA","pen2_DS","ci_lDS","ci_uDS")) %>%
  rename(ipti_1_penta2_mean = pen2_DS,
         ipti_1_penta2_cil = ci_lDS,
         ipti_1_penta2_ciu = ci_uDS)

dat2 <- fread(file.path(csvDir,DSpenfiles[2])) %>%
  as.data.frame() %>%
  dplyr::select(c("State","LGA","pen3_DS","ci_lDS","ci_uDS")) %>%
  rename(ipti_2_penta3_mean = pen3_DS,
         ipti_2_penta3_cil = ci_lDS,
         ipti_2_penta3_ciu = ci_uDS)

dat3 <- fread(file.path(csvDir,DSpenfiles[3])) %>%
  as.data.frame() %>%
  dplyr::select(c("State","LGA","measles_DS","ci_lDS","ci_uDS")) %>%
  rename(ipti_3_measles_mean = measles_DS,
         ipti_3_measles_cil = ci_lDS,
         ipti_3_measles_ciu = ci_uDS)

dat <- merge(dat1,dat2, by=c("State","LGA"))
dat <- merge(dat,dat3, by=c("State","LGA"))
str(dat)
rm(dat1, dat2, dat3)

### -------------------------------------------------
### Load IPTi scenarios and combine data
### -------------------------------------------------
IPTiscen.path <- file.path(ProjectDir, "hbhi_nigeria/scenarios/210203_NGA_NSP-GFfr.xlsx")
IPTscen <- read_excel(file.path(IPTiscen.path)) %>%
  dplyr::select(adm2, ipti_nsp) %>%
  dplyr::rename(LGA = adm2, Interventions = ipti_nsp) %>%
  mutate(Scenario = "B") %>%
  mutate(IPTyn = ifelse(Interventions == "Eligible", 1, 0)) %>%
  filter(IPTyn == 1)

length(unique(IPTscen$LGA)[which(unique(IPTscen$LGA) %in% unique(dat$LGA))])
length(unique(IPTscen$LGA)[which(!(unique(IPTscen$LGA) %in% unique(dat$LGA)))])
unique(IPTscen$LGA)[which(!(unique(IPTscen$LGA) %in% unique(dat$LGA)))]
IPTscen$LGA[IPTscen$LGA=='Ijebu Ode'] <- 'Ijebu ode'
IPTscen$LGA[IPTscen$LGA=='Ogun Waterside'] <- 'Ogun waterside'
IPTscen$LGA[IPTscen$LGA=='Ola-Oluwa'] <- 'Ola-oluwa'

### Combine coverage and IPTi scenario dataframes
dat <- merge(dat, IPTscen, by = "LGA", all = TRUE)
dim(dat)
dim(IPTscen)


### -------------------------------------------------
### IPTi coverage adjustments
### -------------------------------------------------
### Assumed coverage for NGA scenarios
dat$IPTyn[is.na(dat$IPTyn)] <- 0
dat$IPTyn <- as.numeric(dat$IPTyn)
table(dat$IPTyn, exclude=NULL)

dat <- dat %>%
  dplyr::mutate(
    ipti_cov_mean = (ipti_1_penta2_mean + ipti_2_penta3_mean + ipti_3_measles_mean) / 3,
    ipti_cov_cil = (ipti_1_penta2_cil + ipti_2_penta3_cil + ipti_3_measles_cil) / 3,
    ipti_cov_ciu =  (ipti_1_penta2_ciu + ipti_2_penta3_ciu + ipti_3_measles_ciu) / 3,
  ) %>%
  dplyr::mutate(
    IPTicov = ifelse(ipti_cov_mean < 0.2 & IPTyn == 1, 0.2, ipti_cov_mean)
  )

tapply(dat$IPTicov, dat$IPTyn, summary)

### Write out file
DSpenIPT <- dat
save(DSpenIPT, file = file.path(ProjectDir, "hbhi_nigeria/IPTi/analysis", "assumedIPTicov.Rdata"))
write.csv(DSpenIPT, file = file.path(ProjectDir, "hbhi_nigeria/IPTi/analysis", "assumedIPTicov.csv"))


### -------------------------------------------------
### Descriptive
### -------------------------------------------------
require(raster)
require(ggthemes)
require(cowplot)
### Map for IPTi areas
LGAshp <- shapefile(file.path(shpDir, "Nigeria LGAs shapefile 191016", "NGA_LGAs.shp"))
admin1shp <- shapefile(file.path(shpDir, "nigeria_polbnda_admin_1_unsalb", "Admin_1", "NGA_cnty_admin1", "nga_polbndl_adm1_1m_salb.shp"))

### Fortify to obtain spatial dataframe
LGAshp.f <- LGAshp %>%
  fortify(region = "LGA") %>%
  mutate(LGA = id) %>%
  dplyr::select(-id)

DSpen.df <- LGAshp.f %>%
  left_join(dat, by = "LGA") %>%
  filter(IPTyn == 1)

summary(DSpen.df$IPTicov)
DSpen.df$IPTicov_fct <- cut(DSpen.df$IPTicov*100,seq(0,100,20))

p1 <- ggplot(data = subset(DSpen.df, IPTyn == 1)) +
  theme_map() +
  geom_polygon(aes(x = long, y = lat, group = group, fill = IPTicov_fct), color = "black", size = 0.35) +
  customTheme +
  scale_fill_brewer(palette = 'RdYlBu') +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    strip.background = element_blank(),
    legend.position = c(0.7, 0.15),
    legend.title = element_text(size = 18, face = "bold"),
    legend.text = element_text(size = 15, face = "bold")
  ) +
  theme(legend.position = "right") +
  labs(title = "", fill = "Mean coverage (%)")

p2 <- dat %>%
  dplyr::select(LGA, ipti_1_penta2_mean, ipti_2_penta3_mean, ipti_3_measles_mean) %>%
  rename(ipti_1_penta2=ipti_1_penta2_mean,
         ipti_2_penta3=ipti_2_penta3_mean,
         ipti_3_measles=ipti_3_measles_mean)%>%
  pivot_longer(values_to = "cov", names_to = "vaccine", cols = -LGA) %>%
  ggplot() +
  theme_cowplot() +
  customTheme +
  geom_hline(yintercept = mean(dat$ipti_cov_mean)*100, linetype="dashed") +
  geom_boxplot(aes(x = vaccine, y = cov * 100, fill = vaccine), show.legend = F, width = 0.5) +
  scale_fill_manual(values = c("gray30", "lightgrey", "lightblue1")) +
  labs(title = "", x = "Penta-valent vaccine dose", y = "Coverage (%)") +
  theme(
    strip.text.x = element_text(size = 22, face = "bold"),
    strip.text.y = element_text(size = 22, face = "bold"),
    strip.background = element_blank(),
    legend.position = c(0.7, 0.15),
    legend.title = element_text(size = 18, face = "bold"),
    legend.text = element_text(size = 15, face = "bold")
  )

title <- ggdraw() + draw_label("Assumed IPTi coverage based on DHS vaccination data for 2018", fontface='bold')
p12 <- plot_grid(p1, p2, rel_widths = c(1, 0.6), rel_heights = c(1, 0.9),labels=c("A","B"))
p12 <- plot_grid(title,p12, ncol=1, rel_heights=c(0.1, 1))
ggsave(file.path(ProjectDir, "hbhi_nigeria/IPTi/analysis","coverage.png"), plot = p12, width = 20, height = 8, device = "png")
ggsave(file.path(ProjectDir, "hbhi_nigeria/IPTi/analysis","coverage.pdf"), plot = p12, width = 20, height = 8, device = "pdf")