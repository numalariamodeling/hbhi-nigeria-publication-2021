
recoder <- function(x){
  ifelse(x > 6, NA,ifelse(x == 0, 0, 1))
}

ACT.fun_region <- function(df){
  df1<-dataclean(df, ml13e, v005, 'ml13e', 'comboACT')  
  svyd <- svydesign.fun(df1)
  #generate LGA estimates 
  df2 <- result.fun('comboACT', 'v024',design=svyd, data =df1)
  repDS_region %>%  left_join(df2)
}


generate.ACT.state_LGA_repDS <- function(df, var){
  df1<-dataclean(df, ml13e, v005, 'ml13e', 'comboACT')  
  svyd <- svydesign.fun(df1)
  #generate LGA estimates 
  df2 <- result.fun('comboACT', var,design=svyd, data =df1) 
  if(var == "LGA"){
    df2 <- df2 %>% mutate(LGA = case_when(LGA == "kiyawa"~ "Kiyawa", LGA == "kaita" ~"Kaita", TRUE ~ LGA)) 
  }else{
    print("no name corrections for state, repDs or regional estimates")
  }
  repDS_LGA %>% left_join(df2)%>% tidyr::fill(year, .direction = "updown")
}




generate_logit  <- function(data) {
  data%>%mutate(logit_ACT=ifelse(!is.na(comboACT),logit(comboACT),NA),
                var_logit_ACT=(se^2)/(comboACT^2*(1-comboACT)^2),
                # var_logit_obese=ifelse(se==0,NA,var_logit_obese),
                var_logit_ACT=ifelse(se<0.00001,NA,var_logit_ACT),
                logit_ACT=ifelse(is.na(var_logit_ACT),NA,logit_ACT))%>% fill(year, .direction = "updown")
}

generate_smooth_values <- function(dat){
  year <- unique(dat$year)
  mod2 <- inla(smoothing.model.2,
               family = "gaussian",
               data =dat,
               control.predictor=list(compute=TRUE),
               control.compute=list(cpo=TRUE,dic=TRUE,waic=T,config=T),
               control.family=list(hyper=list(prec=list(initial=log(1),fixed=TRUE))),
               scale=prec)
  cbind(mod2, year)
}




