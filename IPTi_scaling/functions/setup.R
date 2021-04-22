## ========================================
###  Collection of custom themes and objects
## ========================================


## Packages
pckg <- c("tidyverse",  "gsubfn",  "readxl", "data.table")
lapply(pckg, require, character.only = TRUE)


pos <- position_dodge(width = 0.9)
### For plotting
customTheme <- theme(
  strip.text.x = element_text(size = 16, face = "bold"),
  strip.text.y = element_text(size = 16, face = "bold"),
  strip.background = element_blank(),
  plot.title = element_text(size = 20, vjust = -1, hjust = 0),
  plot.subtitle = element_text(size = 16),
  plot.caption = element_text(size = 16),
  legend.title = element_text(size = 20),
  legend.text = element_text(size = 16),
  axis.title.x = element_text(size = 16),
  axis.title.y = element_text(size = 16),
  axis.text.x = element_text(size = 16),
  axis.text.y = element_text(size = 16)
)
##### Custom functions
## Extended and edited from:
# https://stackoverflow.com/questions/35953394/calculating-length-of-95-ci-using-dplyr
f_weighted.aggrDat <- function(dataframe, groupVars, valueVar, weightVar, WideToLong = FALSE) {
  # dataframe = dataframe to aggregate (new datafram will be created)
  # groupVars = variables to aggregate at
  # valueVar = variable to aggregate
  # WideToLong = transfrom data to long format,
  #              so that statistics are in one column instead of spread over rows
  
  dataframe <- as.data.frame(dataframe)
  dataframe$tempvar <- dataframe[, colnames(dataframe) == valueVar]
  dataframe$w <- dataframe[, colnames(dataframe) == weightVar]
  
  datAggr <- dataframe %>%
    dplyr::group_by_(.dots = groupVars) %>%
    dplyr::summarise(
      min.val = min(tempvar, na.rm = TRUE),
      max.val = max(tempvar, na.rm = TRUE),
      mean.val = wt.mean(tempvar, w),
      median.val = weighted.median(tempvar, w),
      sd.val = wt.sd(tempvar, w),
      n.val = n(),
      q25 = weighted.quantile(tempvar, w, probs = 0.25),
      q75 = weighted.quantile(tempvar, w, probs = 0.75),
      q2.5 = weighted.quantile(tempvar, w, probs = 0.025),
      q97.5 = weighted.quantile(tempvar, w, probs = 0.975)
    ) %>%
    dplyr::mutate(
      se.val = sd.val / sqrt(n.val),
      lower.ci.val = mean.val - qt(1 - (0.05 / 2), n.val - 1) * se.val,
      upper.ci.val = mean.val + qt(1 - (0.05 / 2), n.val - 1) * se.val,
      weighted = 1
    ) %>%
    # dplyr::select(-sd.val, -n.val,-se.val) %>%
    as.data.frame()
  
  if (WideToLong) {
    datAggr <- gather(datAggr, -groupVars)
    colnames(datAggr)[colnames(datAggr) == "variable"] <- "statistic"
    colnames(datAggr)[colnames(datAggr) == "value"] <- valueVar
    datAggr$statistic <- gsub(".val", "", datAggr$statistic)
  }
  
  return(datAggr)
}

f_mergevars <- function(datX, datY) {
  mergevars <- colnames(datX)[colnames(datX) %in% colnames(datY)]
  return(mergevars)
}


f_addVar <- function(datX, datY, allX = TRUE) {
  nrowB <- dim(datX)[1]
  mergevars <- f_mergevars(datX, datY)
  
  out <- dplyr::left_join(datX, datY, by = mergevars, all.x = TRUE)
  
  if (dim(out)[1] != nrowB) warning("Number of rows do not match")
  message(paste0("Message: x nrow= ", dim(out)[1], " and y nrow=", dim(datX)[1], "\n Number of variables added: ", dim(out)[2] - dim(datX)[2]))
  
  
  return(out)
}


f_cleanColnames <- function(x) {
  unwanted_array <- list(
    "Š" = "S", "š" = "s", "Ž" = "Z", "ž" = "z", "À" = "A", "Á" = "A", "Â" = "A", "Ã" = "A", "Ä" = "A", "Å" = "A", "Æ" = "A", "Ç" = "C", "È" = "E", "É" = "E",
    "Ê" = "E", "Ë" = "E", "Ì" = "I", "Í" = "I", "Î" = "I", "Ï" = "I", "Ñ" = "N", "Ò" = "O", "Ó" = "O", "Ô" = "O", "Õ" = "O", "Ö" = "O", "Ø" = "O", "Ù" = "U",
    "Ú" = "U", "Û" = "U", "Ü" = "U", "Ý" = "Y", "Þ" = "B", "ß" = "Ss", "à" = "a", "á" = "a", "â" = "a", "ã" = "a", "ä" = "a", "å" = "a", "æ" = "a", "ç" = "c",
    "e" = "e", "e" = "e", "ê" = "e", "ë" = "e", "ì" = "i", "í" = "i", "î" = "i", "ï" = "i", "ð" = "o", "ñ" = "n", "ò" = "o", "ó" = "o", "ô" = "o", "õ" = "o",
    "ö" = "o", "ø" = "o", "ù" = "u", "ú" = "u", "û" = "u", "ý" = "y", "ý" = "y", "þ" = "b", "ÿ" = "y"
  )

  x <- gsubfn(paste(names(unwanted_array), collapse = "|"), unwanted_array, x)
  # x <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", x)
  x <- gsub(")", "", x)
  x <- gsub("[(]", "__", x)
  x <- gsub(" ", "_", x)
  x <- gsub(" ", "", x)
  x <- gsub("^\\_", "", x)
  return(x)
}


f_LGAnames <- function(x) {

  ### Correct the names  (code can be improved)
  x[x == "Ado Odo/Ota"           ] <- "Ado-Odo/Ota"
  x[x == "Ado-Ekiti"             ] <- "Ado Ekiti"
  x[x == "Ajeromi/Ifelodun"      ] <- "Ajeromi-Ifelodun"
  x[x == "Amuwo Odofin"          ] <- "Amuwo-Odofin"
  x[x == "Arewa Dandi"           ] <- "Arewa-Dandi"
  x[x == "Atakunmosa East"       ] <- "Atakumosa East"
  x[x == "Atakunmosa West"       ] <- "Atakumosa West"
  x[x == "Atisbo"                ] <- "Atigbo"
  x[x == "Ayedade"               ] <- "Aiyedade"
  x[x == "Ayedire"               ] <- "Aiyedire"
  x[x == "Barkin Ladi"           ] <- "Barikin Ladi"
  x[x == "Bassa"                 ] <- "Bassa1"
  x[x == "Bekwarra"              ] <- "Bekwara"
  x[x == "Birnin Gwari"          ] <- "Birnin-Gwari"
  x[x == "Birnin Kudu"           ] <- "Birni Kudu"
  x[x == "Birnin Magaji/Kiyaw"   ] <- "Birnin Magaji"
  x[x == "Birniwa"               ] <- "Biriniwa"
  x[x == "Calabar Municipal"     ] <- "Calabar-Municipal"
  x[x == "Dange-Shuni"           ] <- "Dange-Shnsi"
  x[x == "Dutsin Ma"             ] <- "Dutsin-Ma"
  x[x == "Efon"                  ] <- "Efon-Alayee"
  x[x == "Ehime -Mbano"          ] <- "Ehime-Mbano"
  x[x == "Ekiti South-West"      ] <- "Ekiti South West"
  x[x == "Emuoha"                ] <- "Emohua"
  x[x == "Esan North-East"       ] <- "Esan North East"
  x[x == "Esan South-East"       ] <- "Esan South East"
  x[x == "Ese Odo"               ] <- "Ese-Odo"
  x[x == "Eti Osa"               ] <- "Eti-Osa"
  x[x == "Ganye"                 ] <- "Ganaye"
  x[x == "Gbonyin"               ] <- "Gboyin"
  x[x == "Girei"                 ] <- "Gireri"
  x[x == "Gwadabawa"             ] <- "Gawabawa"
  x[x == "Ibeju Lekki"           ] <- "Ibeju/Lekki"
  x[x == "Ido-Osi"               ] <- "Idosi-Osi"
  x[x == "Ifako/Ijaye"           ] <- "Ifako-Ijaye"
  x[x == "Ifelodun"              ] <- "Ifelodun1"
  x[x == "Igbo-Eze-North"        ] <- "Igbo-Eze North"
  x[x == "Igbo-Eze-South"        ] <- "Igbo-Eze South"
  x[x == "Iguegben"              ] <- "Igueben"
  x[x == "Ijebu Ode"             ] <- "Ijebu ode"
  x[x == "Ile Oluji/Okeigbo"     ] <- "Ile-Oluji-Okeigbo"
  x[x == "Ilejemeje"             ] <- "Ilemeji"
  x[x == "Imeko Afon"            ] <- "Imeko-Afon"
  x[x == "Irepodun"              ] <- "Irepodun1"
  x[x == "Isuikwuato"] <- "Isuikwato"
  x[x == "Jema'A"                ] <- "Jema'a"
  x[x == "Kaita"                 ] <- "kaita"
  x[x == "Karim Lamido"          ] <- "Karin-Lamido"
  x[x == "Kaura Namoda"] <- "Kaura-Namoda"
  x[x == "Kiyawa"                ] <- "kiyawa"
  x[x == "Makarfi"               ] <- "Markafi"
  x[x == "Matazu"                ] <- "Matazuu"
  x[x == "Mbatoli"               ] <- "Mbaitoli"
  x[x == "Municipal Area Council"] <- "Abuja Municipal"
  x[x == "Munya"                 ] <- "Muya"
  x[x == "Nasarawa Egon"         ] <- "Nasarawa-Eggon"
  x[x == "Nasarawa"              ] <- "Nasarawa1" ####  check
  x[x == "Nassarawa"             ] <- "Nasarawa2" ####  check
  x[x == "Obafemi Owode"         ] <- "Obafemi-Owode"
  x[x == "Obi Nwga"] <- "Obi Nwa"
  x[x == "Obi"                   ] <- "Obi1"
  x[x == "Obio/Akpor"            ] <- "Obia/Akpor"
  x[x == "Odo Otin"              ] <- "Odo-Otin"
  x[x == "Ogori/Magongo"         ] <- "Ogori/Mangongo"
  x[x == "Ogu Bolo"              ] <- "Ogu/Bolo"
  x[x == "Ogun Waterside"        ] <- "Ogun waterside"
  x[x == "Oke Ero"               ] <- "Oke-Ero"
  x[x == "Ola Oluwa"             ] <- "Ola-oluwa"
  x[x == "Olamaboro"             ] <- "Olamabolo"
  x[x == "Ona ara"               ] <- "Ona-Ara"
  x[x == "Onuimo"                ] <- "Unuimo"
  x[x == "Oshodi/Isolo"          ] <- "Oshodi-Isolo"
  x[x == "Ovia North-East"       ] <- "Ovia North East"
  x[x == "Ovia South-West"       ] <- "Ovia South West"
  x[x == "Owerri Municipal"      ] <- "Owerri-Municipal"
  x[x == "Paikoro"               ] <- "Pailoro"
  x[x == "Sabon Gari"            ] <- "Sabon-Gari"
  x[x == "Sule Tankarkar"        ] <- "Sule-Tankarkar"
  x[x == "Surulere"              ] <- "Surulere1"
  x[x == "Takai"                 ] <- "Takali"
  x[x == "Tarmuwa"               ] <- "Tarmua"
  x[x == "Umu-Nneochi"           ] <- "Umu-Neochi"
  x[x == "Urue Offong/Oruko"     ] <- "Urue-Offong/Oruko"
  x[x == "Wamakko"               ] <- "Wamako"
  x[x == "Warri South-West"      ] <- "Warri South West"
  # x[x== "Yewa North"            ] <-
  # x[x== "Yewa South"            ] <-
  x[x == "Zangon Kataf"          ] <- "Zango-Kataf"

  return(x)
}
