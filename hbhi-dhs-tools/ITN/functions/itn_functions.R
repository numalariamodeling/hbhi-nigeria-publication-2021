#recoder itn
recode_itn <- function(data) {
  data %>% mutate(hh_itn = ifelse(hml12 >=8, NA,ifelse(hml12 ==1 | hml12 ==2, 1, 0)))
}

survey.month.fun <- function(data) {
  data%>% mutate(MM = (hv008 - ((hv007 - 1900) * 12))) %>% #dhs pr 2010
    dplyr::rename(v001 = hv001) %>%
    mutate(YYYY = (floor((hv008 - 1)/12)+1900))%>%
    mutate (timepoint = str_c(MM, hv016, YYYY, sep = '-'))%>%
    mutate(time2 = str_c(MM, YYYY, sep = '-'))
}


generate.ITN.state_LGA_repDS <- function(df, var){
  df1<-dataclean2(df, hh_itn, hv005, 'hh_itn', 'ITN')  
  svyd <- svydesign.fun(df1)
  #generate LGA estimates 
  df2 <- result.fun2('ITN', var,design=svyd, data =df1) 
  # df1$comboACT <- as.factor(df1$comboACT)
  # df2 <- result.fun('comboACT', "State",design=svyd, data =df1) 
  if(var == "LGA"){
    df2 <- df2 %>% mutate(LGA = case_when(LGA == "kiyawa"~ "Kiyawa", LGA == "kaita" ~"Kaita", TRUE ~ LGA)) 
  }else{
    print("no name corrections for state, repDS or regional estimates")
  }
  repDS_LGA %>% left_join(df2)%>% tidyr::fill(year, .direction = "updown")
}

ITN.fun_region <- function(df){
  df1<-dataclean2(df, hml12, hv005, 'hml12', 'ITN')  
  svyd <- svydesign.fun(df1)
  #generate LGA estimates 
  df2 <- result.fun2('ITN', 'hv024',design=svyd, data =df1)
  repDS_region %>%  left_join(df2)
}