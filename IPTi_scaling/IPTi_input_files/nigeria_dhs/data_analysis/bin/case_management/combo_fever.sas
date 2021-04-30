* Written by R;
*  write.foreign(comboACT.list[[2]], "bin/myACTdata.txt", "bin/combo_fever.sas",  ;

libname ACT "C:\Users\ido0493\Box\NU-malaria-team\data\nigeria_dhs\data_analysis\bin";

PROC FORMAT;
value CNTRY_CO 
     1 = "NGA" 
;

value Country 
     1 = "Nigeria" 
;

value State 
     1 = "Abia" 
     2 = "Adamawa" 
     3 = "Akwa lbom" 
     4 = "Anambra" 
     5 = "Bauchi" 
     6 = "Bayelsa" 
     7 = "Benue" 
     8 = "Borno" 
     9 = "Cross River" 
     10 = "Delta" 
     11 = "Ebonyi" 
     12 = "Edo" 
     13 = "Ekiti" 
     14 = "Enugu" 
     15 = "Federal Capital Territory" 
     16 = "Gombe" 
     17 = "Imo" 
     18 = "Jigawa" 
     19 = "Kaduna" 
     20 = "Kano" 
     21 = "Katsina" 
     22 = "Kebbi" 
     23 = "Kogi" 
     24 = "Kwara" 
     25 = "Lagos" 
     26 = "Nasarawa" 
     27 = "Niger" 
     28 = "Ogun" 
     29 = "Ondo" 
     30 = "Osun" 
     31 = "Oyo" 
     32 = "Plateau" 
     33 = "Rivers" 
     34 = "Sokoto" 
     35 = "Taraba" 
     36 = "Yobe" 
     37 = "Zamfara" 
;

value LGA 
     1 = "Aba North" 
     2 = "Aba South" 
     3 = "Abadam" 
     4 = "Abaji" 
     5 = "Abak" 
     6 = "Abakaliki" 
     7 = "Abeokuta North" 
     8 = "Abeokuta South" 
     9 = "Abi" 
     10 = "Aboh-Mbaise" 
     11 = "Abua/Odual" 
     12 = "Abuja Municipal" 
     13 = "Adavi" 
     14 = "Ado" 
     15 = "Ado-Odo/Ota" 
     16 = "Ado Ekiti" 
     17 = "Afijio" 
     18 = "Afikpo North" 
     19 = "Afikpo South" 
     20 = "Agaie" 
     21 = "Agatu" 
     22 = "Agege" 
     23 = "Aguata" 
     24 = "Agwara" 
     25 = "Ahiazu-Mbaise" 
     26 = "Ahoada East" 
     27 = "Ahoada West" 
     28 = "Aiyedade" 
     29 = "Aiyedire" 
     30 = "Ajaokuta" 
     31 = "Ajeromi-Ifelodun" 
     32 = "Ajingi" 
     33 = "Akamkpa" 
     34 = "Akinyele" 
     35 = "Akko" 
     36 = "Akoko-Edo" 
     37 = "Akoko North East" 
     38 = "Akoko North West" 
     39 = "Akoko South East" 
     40 = "Akoko South West" 
     41 = "Akpabuyo" 
     42 = "Akuku Toru" 
     43 = "Akure North" 
     44 = "Akure South" 
     45 = "Akwanga" 
     46 = "Albasu" 
     47 = "Aleiro" 
     48 = "Alimosho" 
     49 = "Alkaleri" 
     50 = "Amuwo-Odofin" 
     51 = "Anambra East" 
     52 = "Anambra West" 
     53 = "Anaocha" 
     54 = "Andoni" 
     55 = "Aninri" 
     56 = "Aniocha North" 
     57 = "Aniocha South" 
     58 = "Anka" 
     59 = "Ankpa" 
     60 = "Apa" 
     61 = "Apapa" 
     62 = "Ardo-Kola" 
     63 = "Arewa-Dandi" 
     64 = "Argungu" 
     65 = "Arochukwu" 
     66 = "Asa" 
     67 = "Asari-Toru" 
     68 = "Askira/Uba" 
     69 = "Atakumosa East" 
     70 = "Atakumosa West" 
     71 = "Atiba" 
     72 = "Atigbo" 
     73 = "Augie" 
     74 = "Auyo" 
     75 = "Awe" 
     76 = "Awgu" 
     77 = "Awka North" 
     78 = "Awka South" 
     79 = "Ayamelum" 
     80 = "Babura" 
     81 = "Badagry" 
     82 = "Bade" 
     83 = "Bagudo" 
     84 = "Bagwai" 
     85 = "Bakassi" 
     86 = "Bakori" 
     87 = "Bakura" 
     88 = "Balanga" 
     89 = "Bali" 
     90 = "Bama" 
     91 = "Barikin Ladi" 
     92 = "Baruten" 
     93 = "Bassa1" 
     94 = "Bassa2" 
     95 = "Batagarawa" 
     96 = "Batsari" 
     97 = "Bauchi" 
     98 = "Baure" 
     99 = "Bayo" 
     100 = "Bebeji" 
     101 = "Bekwara" 
     102 = "Bende" 
     103 = "Biase" 
     104 = "Bichi" 
     105 = "Bida" 
     106 = "Billiri" 
     107 = "Bindawa" 
     108 = "Binji" 
     109 = "Biriniwa" 
     110 = "Birni Kudu" 
     111 = "Birnin-Gwari" 
     112 = "Birnin Kebbi" 
     113 = "Birnin Magaji" 
     114 = "Biu" 
     115 = "Bodinga" 
     116 = "Bogoro" 
     117 = "Boki" 
     118 = "Bokkos" 
     119 = "Boluwaduro" 
     120 = "Bomadi" 
     121 = "Bonny" 
     122 = "Borgu" 
     123 = "Boripe" 
     124 = "Bosso" 
     125 = "Brass" 
     126 = "Buji" 
     127 = "Bukkuyum" 
     128 = "Bungudu" 
     129 = "Bunkure" 
     130 = "Bunza" 
     131 = "Bursari" 
     132 = "Buruku" 
     133 = "Burutu" 
     134 = "Bwari" 
     135 = "Calabar-Municipal" 
     136 = "Calabar South" 
     137 = "Chanchaga" 
     138 = "Charanchi" 
     139 = "Chibok" 
     140 = "Chikun" 
     141 = "Dala" 
     142 = "Damaturu" 
     143 = "Damban" 
     144 = "Dambatta" 
     145 = "Damboa" 
     146 = "Dan Musa" 
     147 = "Dandi" 
     148 = "Dandume" 
     149 = "Dange-Shnsi" 
     150 = "Danja" 
     151 = "Darazo" 
     152 = "Dass" 
     153 = "Daura" 
     154 = "Dawakin Kudu" 
     155 = "Dawakin Tofa" 
     156 = "Degema" 
     157 = "Dekina" 
     158 = "Demsa" 
     159 = "Dikwa" 
     160 = "Doguwa" 
     161 = "Doma" 
     162 = "Donga" 
     163 = "Dukku" 
     164 = "Dunukofia" 
     165 = "Dutse" 
     166 = "Dutsi" 
     167 = "Dutsin-Ma" 
     168 = "Eastern Obolo" 
     169 = "Ebonyi" 
     170 = "Edati" 
     171 = "Ede North" 
     172 = "Ede South" 
     173 = "Edu" 
     174 = "Efon-Alayee" 
     175 = "Egbado North" 
     176 = "Egbado South" 
     177 = "Egbeda" 
     178 = "Egbedore" 
     179 = "Egor" 
     180 = "Ehime-Mbano" 
     181 = "Ejigbo" 
     182 = "Ekeremor" 
     183 = "Eket" 
     184 = "Ekiti" 
     185 = "Ekiti East" 
     186 = "Ekiti South West" 
     187 = "Ekiti West" 
     188 = "Ekwusigo" 
     189 = "Eleme" 
     190 = "Emohua" 
     191 = "Emure" 
     192 = "Enugu East" 
     193 = "Enugu North" 
     194 = "Enugu South" 
     195 = "Epe" 
     196 = "Esan Central" 
     197 = "Esan North East" 
     198 = "Esan South East" 
     199 = "Esan West" 
     200 = "Ese-Odo" 
     201 = "Esit Eket" 
     202 = "Essien Udim" 
     203 = "Etche" 
     204 = "Ethiope East" 
     205 = "Ethiope West" 
     206 = "Eti-Osa" 
     207 = "Etim Ekpo" 
     208 = "Etinan" 
     209 = "Etsako Central" 
     210 = "Etsako East" 
     211 = "Etsako West" 
     212 = "Etung" 
     213 = "Ewekoro" 
     214 = "Ezeagu" 
     215 = "Ezinihitte" 
     216 = "Ezza North" 
     217 = "Ezza South" 
     218 = "Fagge" 
     219 = "Fakai" 
     220 = "Faskari" 
     221 = "Fika" 
     222 = "Fufore" 
     223 = "Funakaye" 
     224 = "Fune" 
     225 = "Funtua" 
     226 = "Gabasawa" 
     227 = "Gada" 
     228 = "Gagarawa" 
     229 = "Gamawa" 
     230 = "Ganaye" 
     231 = "Ganjuwa" 
     232 = "Garki" 
     233 = "Garko" 
     234 = "Garum Mallam" 
     235 = "Gashaka" 
     236 = "Gassol" 
     237 = "Gawabawa" 
     238 = "Gaya" 
     239 = "Gbako" 
     240 = "Gboko" 
     241 = "Gboyin" 
     242 = "Geidam" 
     243 = "Gezawa" 
     244 = "Giade" 
     245 = "Gireri" 
     246 = "Giwa" 
     247 = "Gokana" 
     248 = "Gombe" 
     249 = "Gombi" 
     250 = "Goronyo" 
     251 = "Gubio" 
     252 = "Gudu" 
     253 = "Gujba" 
     254 = "Gulani" 
     255 = "Guma" 
     256 = "Gumel" 
     257 = "Gummi" 
     258 = "Gurara" 
     259 = "Guri" 
     260 = "Gusau" 
     261 = "Guyuk" 
     262 = "Guzamala" 
     263 = "Gwagwalada" 
     264 = "Gwale" 
     265 = "Gwandu" 
     266 = "Gwaram" 
     267 = "Gwarzo" 
     268 = "Gwer East" 
     269 = "Gwer West" 
     270 = "Gwiwa" 
     271 = "Gwoza" 
     272 = "Hadejia" 
     273 = "Hawul" 
     274 = "Hong" 
     275 = "Ibadan North" 
     276 = "Ibadan North East" 
     277 = "Ibadan North West" 
     278 = "Ibadan South East" 
     279 = "Ibadan South West" 
     280 = "Ibaji" 
     281 = "Ibarapa Central" 
     282 = "Ibarapa East" 
     283 = "Ibarapa North" 
     284 = "Ibeju/Lekki" 
     285 = "Ibeno" 
     286 = "Ibesikpo Asutan" 
     287 = "Ibi" 
     288 = "Ibiono Ibom" 
     289 = "Idah" 
     290 = "Idanre" 
     291 = "Ideato North" 
     292 = "Ideato South" 
     293 = "Idemili North" 
     294 = "Idemili South" 
     295 = "Ido" 
     296 = "Idosi-Osi" 
     297 = "Ifako-Ijaye" 
     298 = "Ife Central" 
     299 = "Ife East" 
     300 = "Ife North" 
     301 = "Ife South" 
     302 = "Ifedayo" 
     303 = "Ifedore" 
     304 = "Ifelodun1" 
     305 = "Ifelodun2" 
     306 = "Ifo" 
     307 = "Igabi" 
     308 = "Igalamela-Odolu" 
     309 = "Igbo-Etiti" 
     310 = "Igbo-Eze North" 
     311 = "Igbo-Eze South" 
     312 = "Igueben" 
     313 = "Ihiala" 
     314 = "Ihitte/Uboma" 
     315 = "Ijebu East" 
     316 = "Ijebu North" 
     317 = "Ijebu North East" 
     318 = "Ijebu ode" 
     319 = "Ijero" 
     320 = "Ijumu" 
     321 = "Ika" 
     322 = "Ika North East" 
     323 = "Ika South" 
     324 = "Ikara" 
     325 = "Ikeduru" 
     326 = "Ikeja" 
     327 = "Ikenne" 
     328 = "Ikere" 
     329 = "Ikole" 
     330 = "Ikom" 
     331 = "Ikono" 
     332 = "Ikorodu" 
     333 = "Ikot Abasi" 
     334 = "Ikot Ekpene" 
     335 = "Ikpoba-Okha" 
     336 = "Ikwerre" 
     337 = "Ikwo" 
     338 = "Ikwuano" 
     339 = "Ila" 
     340 = "Ilaje" 
     341 = "Ile-Oluji-Okeigbo" 
     342 = "Ilemeji" 
     343 = "Ilesha East" 
     344 = "Ilesha West" 
     345 = "Illela" 
     346 = "Ilorin East" 
     347 = "Ilorin South" 
     348 = "Ilorin West" 
     349 = "Imeko-Afon" 
     350 = "Ingawa" 
     351 = "Ini" 
     352 = "Ipokia" 
     353 = "Irele" 
     354 = "Irepo" 
     355 = "Irepodun/Ifelodun" 
     356 = "Irepodun1" 
     357 = "Irepodun2" 
     358 = "Irewole" 
     359 = "Isa" 
     360 = "Ise/Orun" 
     361 = "Iseyin" 
     362 = "Ishielu" 
     363 = "Isi-Uzo" 
     364 = "Isiala-Ngwa North" 
     365 = "Isiala-Ngwa South" 
     366 = "Isiala Mbano" 
     367 = "Isin" 
     368 = "Isokan" 
     369 = "Isoko North" 
     370 = "Isoko South" 
     371 = "Isu" 
     372 = "Isuikwato" 
     373 = "Itas/Gadau" 
     374 = "Itesiwaju" 
     375 = "Itu" 
     376 = "Ivo" 
     377 = "Iwajowa" 
     378 = "Iwo" 
     379 = "Izzi" 
     380 = "Jaba" 
     381 = "Jada" 
     382 = "Jahun" 
     383 = "Jakusko" 
     384 = "Jalingo" 
     385 = "Jama'are" 
     386 = "Jega" 
     387 = "Jema'a" 
     388 = "Jere" 
     389 = "Jibia" 
     390 = "Jos East" 
     391 = "Jos North" 
     392 = "Jos South" 
     393 = "Kabba/Bunu" 
     394 = "Kabo" 
     395 = "Kachia" 
     396 = "Kaduna North" 
     397 = "Kaduna South" 
     398 = "Kafin Hausa" 
     399 = "Kafur" 
     400 = "Kaga" 
     401 = "Kagarko" 
     402 = "Kaiama" 
     403 = "kaita" 
     404 = "Kajola" 
     405 = "Kajuru" 
     406 = "Kala/Balge" 
     407 = "Kalgo" 
     408 = "Kaltungo" 
     409 = "Kanam" 
     410 = "Kankara" 
     411 = "Kanke" 
     412 = "Kankia" 
     413 = "Kano Municipal" 
     414 = "Karasuwa" 
     415 = "Karaye" 
     416 = "Karin-Lamido" 
     417 = "Karu" 
     418 = "Katagum" 
     419 = "Katcha" 
     420 = "Katsina" 
     421 = "Katsina-Ala" 
     422 = "Kaugama" 
     423 = "Kaura" 
     424 = "Kaura-Namoda" 
     425 = "Kauru" 
     426 = "Kazaure" 
     427 = "Keana" 
     428 = "Kebbe" 
     429 = "Keffi" 
     430 = "Khana" 
     431 = "Kibiya" 
     432 = "Kirfi" 
     433 = "Kiri Kasamma" 
     434 = "Kiru" 
     435 = "kiyawa" 
     436 = "Kogi" 
     437 = "Koko/Besse" 
     438 = "Kokona" 
     439 = "Kolokuma/Opokuma" 
     440 = "Konduga" 
     441 = "Konshisha" 
     442 = "Kontagora" 
     443 = "Kosofe" 
     444 = "Kubau" 
     445 = "Kudan" 
     446 = "Kuje" 
     447 = "Kukawa" 
     448 = "Kumbotso" 
     449 = "Kunchi" 
     450 = "Kura" 
     451 = "Kurfi" 
     452 = "Kurmi" 
     453 = "Kusada" 
     454 = "Kwali" 
     455 = "Kwami" 
     456 = "Kwande" 
     457 = "Kware" 
     458 = "Kwaya Kusar" 
     459 = "Lafia" 
     460 = "Lagelu" 
     461 = "Lagos Island" 
     462 = "Lagos Mainland" 
     463 = "Lamurde" 
     464 = "Langtang North" 
     465 = "Langtang South" 
     466 = "Lapai" 
     467 = "Lau" 
     468 = "Lavun" 
     469 = "Lere" 
     470 = "Logo" 
     471 = "Lokoja" 
     472 = "Machina" 
     473 = "Madagali" 
     474 = "Madobi" 
     475 = "Mafa" 
     476 = "Magama" 
     477 = "Magumeri" 
     478 = "Mai'Adua" 
     479 = "Maiduguri" 
     480 = "Maigatari" 
     481 = "Maiha" 
     482 = "Maiyama" 
     483 = "Makoda" 
     484 = "Makurdi" 
     485 = "Malam Madori" 
     486 = "Malumfashi" 
     487 = "Mangu" 
     488 = "Mani" 
     489 = "Maradun" 
     490 = "Mariga" 
     491 = "Markafi" 
     492 = "Marte" 
     493 = "Maru" 
     494 = "Mashegu" 
     495 = "Mashi" 
     496 = "Matazuu" 
     497 = "Mayo-Belwa" 
     498 = "Mbaitoli" 
     499 = "Mbo" 
     500 = "Michika" 
     501 = "Miga" 
     502 = "Mikang" 
     503 = "Minjibir" 
     504 = "Misau" 
     505 = "Mkpat Enin" 
     506 = "Moba" 
     507 = "Mobbar" 
     508 = "Mokwa" 
     509 = "Monguno" 
     510 = "Mopa-Muro" 
     511 = "Moro" 
     512 = "Mubi North" 
     513 = "Mubi South" 
     514 = "Musawa" 
     515 = "Mushin" 
     516 = "Muya" 
     517 = "Nafada" 
     518 = "Nangere" 
     519 = "Nasarawa-Eggon" 
     520 = "Nasarawa1" 
     521 = "Nasarawa2" 
     522 = "Ndokwa East" 
     523 = "Ndokwa West" 
     524 = "Nembe" 
     525 = "Ngala" 
     526 = "Nganzai" 
     527 = "Ngaski" 
     528 = "Ngor-Okpala" 
     529 = "Nguru" 
     530 = "Ningi" 
     531 = "Njaba" 
     532 = "Njikoka" 
     533 = "Nkanu East" 
     534 = "Nkanu West" 
     535 = "Nkwerre" 
     536 = "Nnewi North" 
     537 = "Nnewi South" 
     538 = "Nsit Atai" 
     539 = "Nsit Ibom" 
     540 = "Nsit Ubium" 
     541 = "Nsukka" 
     542 = "Numan" 
     543 = "Nwangele" 
     544 = "Obafemi-Owode" 
     545 = "Obanliku" 
     546 = "Obi Nwa" 
     547 = "Obi1" 
     548 = "Obi2" 
     549 = "Obia/Akpor" 
     550 = "Obokun" 
     551 = "Obot Akara" 
     552 = "Obowo" 
     553 = "Obubra" 
     554 = "Obudu" 
     555 = "Odeda" 
     556 = "Odigbo" 
     557 = "Odo-Otin" 
     558 = "Odogbolu" 
     559 = "Odukpani" 
     560 = "Offa" 
     561 = "Ofu" 
     562 = "Ogba/Egbema/Ndoni" 
     563 = "Ogbadibo" 
     564 = "Ogbaru" 
     565 = "Ogbia" 
     566 = "Ogbomosho North" 
     567 = "Ogbomosho South" 
     568 = "Ogo Oluwa" 
     569 = "Ogoja" 
     570 = "Ogori/Mangongo" 
     571 = "Ogu/Bolo" 
     572 = "Ogun waterside" 
     573 = "Oguta" 
     574 = "Ohafia" 
     575 = "Ohaji/Egbema" 
     576 = "Ohaozara" 
     577 = "Ohaukwu" 
     578 = "Ohimini" 
     579 = "Oji-River" 
     580 = "Ojo" 
     581 = "Oju" 
     582 = "Oke-Ero" 
     583 = "Okehi" 
     584 = "Okene" 
     585 = "Okigwe" 
     586 = "Okitipupa" 
     587 = "Okobo" 
     588 = "Okpe" 
     589 = "Okpokwu" 
     590 = "Okrika" 
     591 = "Ola-oluwa" 
     592 = "Olamabolo" 
     593 = "Olorunda" 
     594 = "Olorunsogo" 
     595 = "Oluyole" 
     596 = "Omala" 
     597 = "Omumma" 
     598 = "Ona-Ara" 
     599 = "Ondo East" 
     600 = "Ondo West" 
     601 = "Onicha" 
     602 = "Onitsha North" 
     603 = "Onitsha South" 
     604 = "Onna" 
     605 = "Opobo/Nkoro" 
     606 = "Oredo" 
     607 = "Orelope" 
     608 = "Orhionmwon" 
     609 = "Ori Ire" 
     610 = "Oriade" 
     611 = "Orlu" 
     612 = "Orolu" 
     613 = "Oron" 
     614 = "Orsu" 
     615 = "Oru East" 
     616 = "Oru West" 
     617 = "Oruk Anam" 
     618 = "Orumba North" 
     619 = "Orumba South" 
     620 = "Ose" 
     621 = "Oshimili North" 
     622 = "Oshimili South" 
     623 = "Oshodi-Isolo" 
     624 = "Osisioma Ngwa" 
     625 = "Osogbo" 
     626 = "Oturkpo" 
     627 = "Ovia North East" 
     628 = "Ovia South West" 
     629 = "Owan East" 
     630 = "Owan West" 
     631 = "Owerri-Municipal" 
     632 = "Owerri North" 
     633 = "Owerri West" 
     634 = "Owo" 
     635 = "Oye" 
     636 = "Oyi" 
     637 = "Oyigbo" 
     638 = "Oyo East" 
     639 = "Oyo West" 
     640 = "Oyun" 
     641 = "Pailoro" 
     642 = "Pankshin" 
     643 = "Patani" 
     644 = "Pategi" 
     645 = "Port-Harcourt" 
     646 = "Potiskum" 
     647 = "Qua'an Pan" 
     648 = "Rabah" 
     649 = "Rafi" 
     650 = "Rano" 
     651 = "Remo North" 
     652 = "Rijau" 
     653 = "Rimi" 
     654 = "Rimin Gado" 
     655 = "Ringim" 
     656 = "Riyom" 
     657 = "Rogo" 
     658 = "Roni" 
     659 = "Sabon-Gari" 
     660 = "Sabon Birni" 
     661 = "Sabuwa" 
     662 = "Safana" 
     663 = "Sagbama" 
     664 = "Sakaba" 
     665 = "Saki East" 
     666 = "Saki West" 
     667 = "Sandamu" 
     668 = "Sanga" 
     669 = "Sapele" 
     670 = "Sardauna" 
     671 = "Shagamu" 
     672 = "Shagari" 
     673 = "Shanga" 
     674 = "Shani" 
     675 = "Shanono" 
     676 = "Shelleng" 
     677 = "Shendam" 
     678 = "Shinkafi" 
     679 = "Shira" 
     680 = "Shiroro" 
     681 = "Shomgom" 
     682 = "Shomolu" 
     683 = "Silame" 
     684 = "Soba" 
     685 = "Sokoto North" 
     686 = "Sokoto South" 
     687 = "Song" 
     688 = "Southern Ijaw" 
     689 = "Sule-Tankarkar" 
     690 = "Suleja" 
     691 = "Sumaila" 
     692 = "Suru" 
     693 = "Surulere1" 
     694 = "Surulere2" 
     695 = "Tafa" 
     696 = "Tafawa-Balewa" 
     697 = "Tai" 
     698 = "Takali" 
     699 = "Takum" 
     700 = "Talata Mafara" 
     701 = "Tambuwal" 
     702 = "Tangaza" 
     703 = "Tarauni" 
     704 = "Tarka" 
     705 = "Tarmua" 
     706 = "Taura" 
     707 = "Tofa" 
     708 = "Toro" 
     709 = "Toto" 
     710 = "Toungo" 
     711 = "Tsafe" 
     712 = "Tsanyawa" 
     713 = "Tudun Wada" 
     714 = "Tureta" 
     715 = "Udenu" 
     716 = "Udi" 
     717 = "Udu" 
     718 = "Udung Uko" 
     719 = "Ughelli North" 
     720 = "Ughelli South" 
     721 = "Ugwunagbo" 
     722 = "Uhunmwonde" 
     723 = "Ukanafun" 
     724 = "Ukum" 
     725 = "Ukwa East" 
     726 = "Ukwa West" 
     727 = "Ukwuani" 
     728 = "Umu-Neochi" 
     729 = "Umuahia North" 
     730 = "Umuahia South" 
     731 = "Ungogo" 
     732 = "Unuimo" 
     733 = "Uruan" 
     734 = "Urue-Offong/Oruko" 
     735 = "Ushongo" 
     736 = "Ussa" 
     737 = "Uvwie" 
     738 = "Uyo" 
     739 = "Uzo-Uwani" 
     740 = "Vandeikya" 
     741 = "Wamako" 
     742 = "Wamba" 
     743 = "Warawa" 
     744 = "Warji" 
     745 = "Warri North" 
     746 = "Warri South" 
     747 = "Warri South West" 
     748 = "Wasagu/Danko" 
     749 = "Wase" 
     750 = "Wudil" 
     751 = "Wukari" 
     752 = "Wurno" 
     753 = "Wushishi" 
     754 = "Yabo" 
     755 = "Yagba East" 
     756 = "Yagba West" 
     757 = "Yakurr" 
     758 = "Yala" 
     759 = "Yamaltu/Deba" 
     760 = "Yankwashi" 
     761 = "Yauri" 
     762 = "Yenegoa" 
     763 = "Yola North" 
     764 = "Yola South" 
     765 = "Yorro" 
     766 = "Yunusari" 
     767 = "Yusufari" 
     768 = "Zaki" 
     769 = "Zango" 
     770 = "Zango-Kataf" 
     771 = "Zaria" 
     772 = "Zing" 
     773 = "Zurmi" 
     774 = "Zuru" 
;

value Dstrct_C 
     1 = "NGA001" 
     2 = "NGA002" 
     3 = "NGA003" 
     4 = "NGA004" 
     5 = "NGA005" 
     6 = "NGA006" 
     7 = "NGA007" 
     8 = "NGA008" 
     9 = "NGA009" 
     10 = "NGA010" 
     11 = "NGA011" 
     12 = "NGA012" 
     13 = "NGA013" 
     14 = "NGA014" 
     15 = "NGA015" 
     16 = "NGA016" 
     17 = "NGA017" 
     18 = "NGA018" 
     19 = "NGA019" 
     20 = "NGA020" 
     21 = "NGA021" 
     22 = "NGA022" 
     23 = "NGA023" 
     24 = "NGA024" 
     25 = "NGA025" 
     26 = "NGA026" 
     27 = "NGA027" 
     28 = "NGA028" 
     29 = "NGA029" 
     30 = "NGA030" 
     31 = "NGA031" 
     32 = "NGA032" 
     33 = "NGA033" 
     34 = "NGA034" 
     35 = "NGA035" 
     36 = "NGA036" 
     37 = "NGA037" 
     38 = "NGA038" 
     39 = "NGA039" 
     40 = "NGA040" 
     41 = "NGA041" 
     42 = "NGA042" 
     43 = "NGA043" 
     44 = "NGA044" 
     45 = "NGA045" 
     46 = "NGA046" 
     47 = "NGA047" 
     48 = "NGA048" 
     49 = "NGA049" 
     50 = "NGA050" 
     51 = "NGA051" 
     52 = "NGA052" 
     53 = "NGA053" 
     54 = "NGA054" 
     55 = "NGA055" 
     56 = "NGA056" 
     57 = "NGA057" 
     58 = "NGA058" 
     59 = "NGA059" 
     60 = "NGA060" 
     61 = "NGA061" 
     62 = "NGA062" 
     63 = "NGA063" 
     64 = "NGA064" 
     65 = "NGA065" 
     66 = "NGA066" 
     67 = "NGA067" 
     68 = "NGA068" 
     69 = "NGA069" 
     70 = "NGA070" 
     71 = "NGA071" 
     72 = "NGA072" 
     73 = "NGA073" 
     74 = "NGA074" 
     75 = "NGA075" 
     76 = "NGA076" 
     77 = "NGA077" 
     78 = "NGA078" 
     79 = "NGA079" 
     80 = "NGA080" 
     81 = "NGA081" 
     82 = "NGA082" 
     83 = "NGA083" 
     84 = "NGA084" 
     85 = "NGA085" 
     86 = "NGA086" 
     87 = "NGA087" 
     88 = "NGA088" 
     89 = "NGA089" 
     90 = "NGA090" 
     91 = "NGA091" 
     92 = "NGA092" 
     93 = "NGA093" 
     94 = "NGA094" 
     95 = "NGA095" 
     96 = "NGA096" 
     97 = "NGA097" 
     98 = "NGA098" 
     99 = "NGA099" 
     100 = "NGA100" 
     101 = "NGA101" 
     102 = "NGA102" 
     103 = "NGA103" 
     104 = "NGA104" 
     105 = "NGA105" 
     106 = "NGA106" 
     107 = "NGA107" 
     108 = "NGA108" 
     109 = "NGA109" 
     110 = "NGA110" 
     111 = "NGA111" 
     112 = "NGA112" 
     113 = "NGA113" 
     114 = "NGA114" 
     115 = "NGA115" 
     116 = "NGA116" 
     117 = "NGA117" 
     118 = "NGA118" 
     119 = "NGA119" 
     120 = "NGA120" 
     121 = "NGA121" 
     122 = "NGA122" 
     123 = "NGA123" 
     124 = "NGA124" 
     125 = "NGA125" 
     126 = "NGA126" 
     127 = "NGA127" 
     128 = "NGA128" 
     129 = "NGA129" 
     130 = "NGA130" 
     131 = "NGA131" 
     132 = "NGA132" 
     133 = "NGA133" 
     134 = "NGA134" 
     135 = "NGA135" 
     136 = "NGA136" 
     137 = "NGA137" 
     138 = "NGA138" 
     139 = "NGA139" 
     140 = "NGA140" 
     141 = "NGA141" 
     142 = "NGA142" 
     143 = "NGA143" 
     144 = "NGA144" 
     145 = "NGA145" 
     146 = "NGA146" 
     147 = "NGA147" 
     148 = "NGA148" 
     149 = "NGA149" 
     150 = "NGA150" 
     151 = "NGA151" 
     152 = "NGA152" 
     153 = "NGA153" 
     154 = "NGA154" 
     155 = "NGA155" 
     156 = "NGA156" 
     157 = "NGA157" 
     158 = "NGA158" 
     159 = "NGA159" 
     160 = "NGA160" 
     161 = "NGA161" 
     162 = "NGA162" 
     163 = "NGA163" 
     164 = "NGA164" 
     165 = "NGA165" 
     166 = "NGA166" 
     167 = "NGA167" 
     168 = "NGA168" 
     169 = "NGA169" 
     170 = "NGA170" 
     171 = "NGA171" 
     172 = "NGA172" 
     173 = "NGA173" 
     174 = "NGA174" 
     175 = "NGA175" 
     176 = "NGA176" 
     177 = "NGA177" 
     178 = "NGA178" 
     179 = "NGA179" 
     180 = "NGA180" 
     181 = "NGA181" 
     182 = "NGA182" 
     183 = "NGA183" 
     184 = "NGA184" 
     185 = "NGA185" 
     186 = "NGA186" 
     187 = "NGA187" 
     188 = "NGA188" 
     189 = "NGA189" 
     190 = "NGA190" 
     191 = "NGA191" 
     192 = "NGA192" 
     193 = "NGA193" 
     194 = "NGA194" 
     195 = "NGA195" 
     196 = "NGA196" 
     197 = "NGA197" 
     198 = "NGA198" 
     199 = "NGA199" 
     200 = "NGA200" 
     201 = "NGA201" 
     202 = "NGA202" 
     203 = "NGA203" 
     204 = "NGA204" 
     205 = "NGA205" 
     206 = "NGA206" 
     207 = "NGA207" 
     208 = "NGA208" 
     209 = "NGA209" 
     210 = "NGA210" 
     211 = "NGA211" 
     212 = "NGA212" 
     213 = "NGA213" 
     214 = "NGA214" 
     215 = "NGA215" 
     216 = "NGA216" 
     217 = "NGA217" 
     218 = "NGA218" 
     219 = "NGA219" 
     220 = "NGA220" 
     221 = "NGA221" 
     222 = "NGA222" 
     223 = "NGA223" 
     224 = "NGA224" 
     225 = "NGA225" 
     226 = "NGA226" 
     227 = "NGA227" 
     228 = "NGA228" 
     229 = "NGA229" 
     230 = "NGA230" 
     231 = "NGA231" 
     232 = "NGA232" 
     233 = "NGA233" 
     234 = "NGA234" 
     235 = "NGA235" 
     236 = "NGA236" 
     237 = "NGA237" 
     238 = "NGA238" 
     239 = "NGA239" 
     240 = "NGA240" 
     241 = "NGA241" 
     242 = "NGA242" 
     243 = "NGA243" 
     244 = "NGA244" 
     245 = "NGA245" 
     246 = "NGA246" 
     247 = "NGA247" 
     248 = "NGA248" 
     249 = "NGA249" 
     250 = "NGA250" 
     251 = "NGA251" 
     252 = "NGA252" 
     253 = "NGA253" 
     254 = "NGA254" 
     255 = "NGA255" 
     256 = "NGA256" 
     257 = "NGA257" 
     258 = "NGA258" 
     259 = "NGA259" 
     260 = "NGA260" 
     261 = "NGA261" 
     262 = "NGA262" 
     263 = "NGA263" 
     264 = "NGA264" 
     265 = "NGA265" 
     266 = "NGA266" 
     267 = "NGA267" 
     268 = "NGA268" 
     269 = "NGA269" 
     270 = "NGA270" 
     271 = "NGA271" 
     272 = "NGA272" 
     273 = "NGA273" 
     274 = "NGA274" 
     275 = "NGA275" 
     276 = "NGA276" 
     277 = "NGA277" 
     278 = "NGA278" 
     279 = "NGA279" 
     280 = "NGA280" 
     281 = "NGA281" 
     282 = "NGA282" 
     283 = "NGA283" 
     284 = "NGA284" 
     285 = "NGA285" 
     286 = "NGA286" 
     287 = "NGA287" 
     288 = "NGA288" 
     289 = "NGA289" 
     290 = "NGA290" 
     291 = "NGA291" 
     292 = "NGA292" 
     293 = "NGA293" 
     294 = "NGA294" 
     295 = "NGA295" 
     296 = "NGA296" 
     297 = "NGA297" 
     298 = "NGA298" 
     299 = "NGA299" 
     300 = "NGA300" 
     301 = "NGA301" 
     302 = "NGA302" 
     303 = "NGA303" 
     304 = "NGA304" 
     305 = "NGA305" 
     306 = "NGA306" 
     307 = "NGA307" 
     308 = "NGA308" 
     309 = "NGA309" 
     310 = "NGA310" 
     311 = "NGA311" 
     312 = "NGA312" 
     313 = "NGA313" 
     314 = "NGA314" 
     315 = "NGA315" 
     316 = "NGA316" 
     317 = "NGA317" 
     318 = "NGA318" 
     319 = "NGA319" 
     320 = "NGA320" 
     321 = "NGA321" 
     322 = "NGA322" 
     323 = "NGA323" 
     324 = "NGA324" 
     325 = "NGA325" 
     326 = "NGA326" 
     327 = "NGA327" 
     328 = "NGA328" 
     329 = "NGA329" 
     330 = "NGA330" 
     331 = "NGA331" 
     332 = "NGA332" 
     333 = "NGA333" 
     334 = "NGA334" 
     335 = "NGA335" 
     336 = "NGA336" 
     337 = "NGA337" 
     338 = "NGA338" 
     339 = "NGA339" 
     340 = "NGA340" 
     341 = "NGA341" 
     342 = "NGA342" 
     343 = "NGA343" 
     344 = "NGA344" 
     345 = "NGA345" 
     346 = "NGA346" 
     347 = "NGA347" 
     348 = "NGA348" 
     349 = "NGA349" 
     350 = "NGA350" 
     351 = "NGA351" 
     352 = "NGA352" 
     353 = "NGA353" 
     354 = "NGA354" 
     355 = "NGA355" 
     356 = "NGA356" 
     357 = "NGA357" 
     358 = "NGA358" 
     359 = "NGA359" 
     360 = "NGA360" 
     361 = "NGA361" 
     362 = "NGA362" 
     363 = "NGA363" 
     364 = "NGA364" 
     365 = "NGA365" 
     366 = "NGA366" 
     367 = "NGA367" 
     368 = "NGA368" 
     369 = "NGA369" 
     370 = "NGA370" 
     371 = "NGA371" 
     372 = "NGA372" 
     373 = "NGA373" 
     374 = "NGA374" 
     375 = "NGA375" 
     376 = "NGA376" 
     377 = "NGA377" 
     378 = "NGA378" 
     379 = "NGA379" 
     380 = "NGA380" 
     381 = "NGA381" 
     382 = "NGA382" 
     383 = "NGA383" 
     384 = "NGA384" 
     385 = "NGA385" 
     386 = "NGA386" 
     387 = "NGA387" 
     388 = "NGA388" 
     389 = "NGA389" 
     390 = "NGA390" 
     391 = "NGA391" 
     392 = "NGA392" 
     393 = "NGA393" 
     394 = "NGA394" 
     395 = "NGA395" 
     396 = "NGA396" 
     397 = "NGA397" 
     398 = "NGA398" 
     399 = "NGA399" 
     400 = "NGA400" 
     401 = "NGA401" 
     402 = "NGA402" 
     403 = "NGA403" 
     404 = "NGA404" 
     405 = "NGA405" 
     406 = "NGA406" 
     407 = "NGA407" 
     408 = "NGA408" 
     409 = "NGA409" 
     410 = "NGA410" 
     411 = "NGA411" 
     412 = "NGA412" 
     413 = "NGA413" 
     414 = "NGA414" 
     415 = "NGA415" 
     416 = "NGA416" 
     417 = "NGA417" 
     418 = "NGA418" 
     419 = "NGA419" 
     420 = "NGA420" 
     421 = "NGA421" 
     422 = "NGA422" 
     423 = "NGA423" 
     424 = "NGA424" 
     425 = "NGA425" 
     426 = "NGA426" 
     427 = "NGA427" 
     428 = "NGA428" 
     429 = "NGA429" 
     430 = "NGA430" 
     431 = "NGA431" 
     432 = "NGA432" 
     433 = "NGA433" 
     434 = "NGA434" 
     435 = "NGA435" 
     436 = "NGA436" 
     437 = "NGA437" 
     438 = "NGA438" 
     439 = "NGA439" 
     440 = "NGA440" 
     441 = "NGA441" 
     442 = "NGA442" 
     443 = "NGA443" 
     444 = "NGA444" 
     445 = "NGA445" 
     446 = "NGA446" 
     447 = "NGA447" 
     448 = "NGA448" 
     449 = "NGA449" 
     450 = "NGA450" 
     451 = "NGA451" 
     452 = "NGA452" 
     453 = "NGA453" 
     454 = "NGA454" 
     455 = "NGA455" 
     456 = "NGA456" 
     457 = "NGA457" 
     458 = "NGA458" 
     459 = "NGA459" 
     460 = "NGA460" 
     461 = "NGA461" 
     462 = "NGA462" 
     463 = "NGA463" 
     464 = "NGA464" 
     465 = "NGA465" 
     466 = "NGA466" 
     467 = "NGA467" 
     468 = "NGA468" 
     469 = "NGA469" 
     470 = "NGA470" 
     471 = "NGA471" 
     472 = "NGA472" 
     473 = "NGA473" 
     474 = "NGA474" 
     475 = "NGA475" 
     476 = "NGA476" 
     477 = "NGA477" 
     478 = "NGA478" 
     479 = "NGA479" 
     480 = "NGA480" 
     481 = "NGA481" 
     482 = "NGA482" 
     483 = "NGA483" 
     484 = "NGA484" 
     485 = "NGA485" 
     486 = "NGA486" 
     487 = "NGA487" 
     488 = "NGA488" 
     489 = "NGA489" 
     490 = "NGA490" 
     491 = "NGA491" 
     492 = "NGA492" 
     493 = "NGA493" 
     494 = "NGA494" 
     495 = "NGA495" 
     496 = "NGA496" 
     497 = "NGA497" 
     498 = "NGA498" 
     499 = "NGA499" 
     500 = "NGA500" 
     501 = "NGA501" 
     502 = "NGA502" 
     503 = "NGA503" 
     504 = "NGA504" 
     505 = "NGA505" 
     506 = "NGA506" 
     507 = "NGA507" 
     508 = "NGA508" 
     509 = "NGA509" 
     510 = "NGA510" 
     511 = "NGA511" 
     512 = "NGA512" 
     513 = "NGA513" 
     514 = "NGA514" 
     515 = "NGA515" 
     516 = "NGA516" 
     517 = "NGA517" 
     518 = "NGA518" 
     519 = "NGA519" 
     520 = "NGA520" 
     521 = "NGA521" 
     522 = "NGA522" 
     523 = "NGA523" 
     524 = "NGA524" 
     525 = "NGA525" 
     526 = "NGA526" 
     527 = "NGA527" 
     528 = "NGA528" 
     529 = "NGA529" 
     530 = "NGA530" 
     531 = "NGA531" 
     532 = "NGA532" 
     533 = "NGA533" 
     534 = "NGA535" 
     535 = "NGA537" 
     536 = "NGA538" 
     537 = "NGA539" 
     538 = "NGA540" 
     539 = "NGA541" 
     540 = "NGA542" 
     541 = "NGA543" 
     542 = "NGA544" 
     543 = "NGA545" 
     544 = "NGA546" 
     545 = "NGA547" 
     546 = "NGA548" 
     547 = "NGA549" 
     548 = "NGA550" 
     549 = "NGA551" 
     550 = "NGA552" 
     551 = "NGA553" 
     552 = "NGA554" 
     553 = "NGA555" 
     554 = "NGA556" 
     555 = "NGA557" 
     556 = "NGA558" 
     557 = "NGA559" 
     558 = "NGA560" 
     559 = "NGA561" 
     560 = "NGA562" 
     561 = "NGA563" 
     562 = "NGA564" 
     563 = "NGA565" 
     564 = "NGA566" 
     565 = "NGA567" 
     566 = "NGA568" 
     567 = "NGA569" 
     568 = "NGA570" 
     569 = "NGA571" 
     570 = "NGA572" 
     571 = "NGA573" 
     572 = "NGA574" 
     573 = "NGA575" 
     574 = "NGA576" 
     575 = "NGA577" 
     576 = "NGA578" 
     577 = "NGA579" 
     578 = "NGA580" 
     579 = "NGA581" 
     580 = "NGA582" 
     581 = "NGA583" 
     582 = "NGA584" 
     583 = "NGA585" 
     584 = "NGA586" 
     585 = "NGA587" 
     586 = "NGA588" 
     587 = "NGA589" 
     588 = "NGA590" 
     589 = "NGA591" 
     590 = "NGA592" 
     591 = "NGA593" 
     592 = "NGA594" 
     593 = "NGA595" 
     594 = "NGA596" 
     595 = "NGA597" 
     596 = "NGA598" 
     597 = "NGA599" 
     598 = "NGA600" 
     599 = "NGA601" 
     600 = "NGA602" 
     601 = "NGA603" 
     602 = "NGA604" 
     603 = "NGA605" 
     604 = "NGA606" 
     605 = "NGA607" 
     606 = "NGA608" 
     607 = "NGA609" 
     608 = "NGA610" 
     609 = "NGA611" 
     610 = "NGA612" 
     611 = "NGA613" 
     612 = "NGA614" 
     613 = "NGA615" 
     614 = "NGA616" 
     615 = "NGA618" 
     616 = "NGA619" 
     617 = "NGA620" 
     618 = "NGA622" 
     619 = "NGA623" 
     620 = "NGA624" 
     621 = "NGA625" 
     622 = "NGA626" 
     623 = "NGA627" 
     624 = "NGA628" 
     625 = "NGA629" 
     626 = "NGA630" 
     627 = "NGA631" 
     628 = "NGA632" 
     629 = "NGA633" 
     630 = "NGA634" 
     631 = "NGA635" 
     632 = "NGA636" 
     633 = "NGA637" 
     634 = "NGA638" 
     635 = "NGA639" 
     636 = "NGA640" 
     637 = "NGA641" 
     638 = "NGA642" 
     639 = "NGA643" 
     640 = "NGA644" 
     641 = "NGA645" 
     642 = "NGA646" 
     643 = "NGA647" 
     644 = "NGA648" 
     645 = "NGA649" 
     646 = "NGA650" 
     647 = "NGA651" 
     648 = "NGA652" 
     649 = "NGA653" 
     650 = "NGA654" 
     651 = "NGA655" 
     652 = "NGA656" 
     653 = "NGA657" 
     654 = "NGA658" 
     655 = "NGA659" 
     656 = "NGA660" 
     657 = "NGA661" 
     658 = "NGA662" 
     659 = "NGA663" 
     660 = "NGA665" 
     661 = "NGA667" 
     662 = "NGA668" 
     663 = "NGA669" 
     664 = "NGA670" 
     665 = "NGA671" 
     666 = "NGA672" 
     667 = "NGA673" 
     668 = "NGA674" 
     669 = "NGA675" 
     670 = "NGA676" 
     671 = "NGA677" 
     672 = "NGA678" 
     673 = "NGA679" 
     674 = "NGA680" 
     675 = "NGA681" 
     676 = "NGA682" 
     677 = "NGA683" 
     678 = "NGA684" 
     679 = "NGA685" 
     680 = "NGA686" 
     681 = "NGA687" 
     682 = "NGA688" 
     683 = "NGA689" 
     684 = "NGA690" 
     685 = "NGA691" 
     686 = "NGA692" 
     687 = "NGA693" 
     688 = "NGA694" 
     689 = "NGA695" 
     690 = "NGA696" 
     691 = "NGA697" 
     692 = "NGA698" 
     693 = "NGA699" 
     694 = "NGA700" 
     695 = "NGA701" 
     696 = "NGA702" 
     697 = "NGA703" 
     698 = "NGA704" 
     699 = "NGA705" 
     700 = "NGA706" 
     701 = "NGA707" 
     702 = "NGA708" 
     703 = "NGA709" 
     704 = "NGA710" 
     705 = "NGA711" 
     706 = "NGA712" 
     707 = "NGA713" 
     708 = "NGA714" 
     709 = "NGA715" 
     710 = "NGA716" 
     711 = "NGA717" 
     712 = "NGA718" 
     713 = "NGA719" 
     714 = "NGA720" 
     715 = "NGA721" 
     716 = "NGA722" 
     717 = "NGA723" 
     718 = "NGA724" 
     719 = "NGA725" 
     720 = "NGA726" 
     721 = "NGA727" 
     722 = "NGA728" 
     723 = "NGA729" 
     724 = "NGA730" 
     725 = "NGA731" 
     726 = "NGA732" 
     727 = "NGA733" 
     728 = "NGA734" 
     729 = "NGA735" 
     730 = "NGA736" 
     731 = "NGA737" 
     732 = "NGA738" 
     733 = "NGA739" 
     734 = "NGA740" 
     735 = "NGA741" 
     736 = "NGA742" 
     737 = "NGA743" 
     738 = "NGA744" 
     739 = "NGA745" 
     740 = "NGA746" 
     741 = "NGA747" 
     742 = "NGA748" 
     743 = "NGA749" 
     744 = "NGA750" 
     745 = "NGA751" 
     746 = "NGA752" 
     747 = "NGA753" 
     748 = "NGA754" 
     749 = "NGA755" 
     750 = "NGA756" 
     751 = "NGA757" 
     752 = "NGA758" 
     753 = "NGA759" 
     754 = "NGA760" 
     755 = "NGA761" 
     756 = "NGA762" 
     757 = "NGA763" 
     758 = "NGA764" 
     759 = "NGA765" 
     760 = "NGA766" 
     761 = "NGA767" 
     762 = "NGA768" 
     763 = "NGA769" 
     764 = "NGA770" 
     765 = "NGA771" 
     766 = "NGA772" 
     767 = "NGA773" 
     768 = "NGA774" 
;

value repDS 
     1 = "Ahoada West" 
     2 = "Akinyele" 
     3 = "Alkaleri" 
     4 = "Babura" 
     5 = "Birnin Kebbi" 
     6 = "Darazo" 
     7 = "Gawabawa" 
     8 = "Giwa" 
     9 = "Gwarzo" 
     10 = "Isoko South" 
     11 = "Keana" 
     12 = "Ngor-Okpala" 
     13 = "Nsit Ubium" 
     14 = "Obubra" 
     15 = "Oke-Ero" 
     16 = "Oru West" 
     17 = "Owan East" 
     18 = "Rimi" 
     19 = "Soba" 
     20 = "Takali" 
     21 = "Taura" 
     22 = "Uzo-Uwani" 
;

DATA  rdata ;
LENGTH
 caseid $ 15
 v000 $ 3
;

INFILE  "myACTdata.txt" 
     DSD 
     LRECL= 763 ;
INPUT
 caseid
 hidx
 v000
 v001
 v002
 v003
 v004
 v005
 v006
 v007
 v008
 v009
 v010
 v011
 v012
 v013
 v014
 v015
 v016
 v017
 v018
 v019
 v019a
 v020
 v021
 v022
 v023
 v024
 v025
 v026
 v027
 v028
 v029
 v030
 v031
 v032
 v034
 v040
 v042
 v101
 v102
 v103
 v104
 v105
 v106
 v107
 v113
 v116
 v119
 v120
 v121
 v122
 v123
 v124
 v125
 v127
 v128
 v129
 v130
 v131
 v133
 v134
 v135
 v136
 v137
 v138
 v139
 v140
 v141
 v149
 v150
 v151
 v152
 v153
 v155
 v161
 v190
 v191
 ml101
 v201
 v202
 v203
 v204
 v205
 v206
 v207
 v208
 v209
 v210
 v211
 v212
 v213
 v214
 v218
 v219
 v220
 v222
 v223
 v224
 v235
 v237
 v238
 v417
 v418
 v461
 bidx
 bord
 b0
 b1
 b2
 b3
 b4
 b5
 b6
 b7
 b8
 b9
 b10
 b11
 b12
 b13
 b15
 b16
 midx
 m2a
 m2b
 m2c
 m2d
 m2e
 m2f
 m2g
 m2h
 m2i
 m2j
 m2k
 m2l
 m2m
 m2n
 m49a
 m49b
 m49c
 m49d
 m49e
 m49f
 m49g
 m49x
 m49z
 m49y
 s311
 h22
 h32a
 h32b
 h32c
 h32d
 h32e
 h32f
 h32g
 h32h
 h32i
 h32j
 h32k
 h32l
 h32m
 h32n
 h32o
 h32p
 h32q
 h32r
 h32s
 h32t
 h32u
 h32v
 h32w
 h32x
 h32y
 h32z
 h46b
 h47
 idxml
 ml0
 ml1
 ml2
 ml11
 ml12
 ml13a
 ml13b
 ml13c
 ml13d
 comboACT
 ml13f
 ml13g
 ml13h
 ml13i
 ml13j
 ml13k
 ml13l
 ml13m
 ml13n
 ml13o
 ml13p
 ml13x
 ml13y
 ml13z
 ml14a
 ml14b
 ml14y
 ml14z
 ml15a
 ml15b
 ml15c
 ml16a
 ml16b
 ml16c
 ml17a
 ml17b
 ml17c
 ml18a
 ml18b
 ml18c
 ml19a
 ml19b
 ml19c
 ml19d
 ml19e
 ml19f
 ml19x
 ml19y
 ml19z
 ml20a
 ml20b
 ml20c
 ml21a
 ml21b
 ml21c
 ml22a
 ml22b
 ml22c
 ml23a
 ml23b
 ml23c
 ml24c
 s316
 sbuild
 snumber
 sstate
 slarea
 slocal
 senumer
 smalar
 slang1
 slang2
 slang3
 stransl
 s226a
 s226ba
 s226bb
 s226bc
 s226bd
 s226be
 s226bf
 s226bx
 s226c
 s226da
 s226db
 s226dx
 s226dz
 s226f
 s226g
 s401
 s402a
 s402b
 s402c
 s402d
 s402e
 s402f
 s402g
 s402x
 s402z
 s403a
 s403b
 s403c
 s403d
 s403e
 s403z
 s404a
 s404b
 s404c
 s404d
 s404e
 s404x
 s404z
 s405
 s406a
 s406b
 s406c
 s406d
 s406e
 s406f
 s406g
 s406h
 s406i
 s406x
 s406z
 s407a
 s407b
 s407c
 s407d
 s407e
 s407x
 s407z
 s408
 s409a
 s409b
 s409c
 s409d
 s409e
 s409x
 s409z
 s410a
 s410b
 s410c
 s410d
 s410e
 s410x
 s410z
 s411
 s412a
 s412b
 s412c
 s412d
 s412e
 s412f
 s412g
 s412h
 s412i
 s412j
 s412k
 s412x
 s412z
 s413a
 s413b
 s413c
 s413d
 s413e
 s413f
 s413g
 s413h
 s413i
 s413j
 s413k
 s413l
 s413m
 s413x
 CNTRY_CODE
 Country
 State
 LGA
 District_C
 Map_Code
 wt
 strat
 id
 num_p
 X
 repDS
;
FORMAT CNTRY_CODE CNTRY_CO. ;
FORMAT Country Country. ;
FORMAT State State. ;
FORMAT LGA LGA. ;
FORMAT District_C Dstrct_C. ;
FORMAT repDS repDS. ;
RUN;



ODS TAGSETS.EXCELXP
file='C:\Users\ido0493\Box\NU-malaria-team\data\nigeria_dhs\data_analysis\bin\ACT_fever_U5.xls'
STYLE=minimal
OPTIONS ( Orientation = 'landscape'
FitToPage = 'yes'
Pages_FitWidth = '1'
Pages_FitHeight = '100' );


proc surveyfreq data = rdata;
tables repDS*comboACT/row cl (type= CLOPPERPEARSON psmall=0.28)alpha=0.20;
stratum v022;
Cluster v021;
weight wt;
run;


ods tagsets.excelxp close;
