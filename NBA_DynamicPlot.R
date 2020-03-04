getwd()
setwd("E:/Día 8/Primera Parte")

library(RCurl)
library(jsonlite)
library(dplyr)
library(sp)
library(curl)
library(ggplot2)
library(data.table)
library(gganimate)
library(gifski)
library(png)
library(grid)

player_position1 <- function(df, eventid,gameclock){
  # Esta función contribuye para recuperar la información proveniente del 'eventid' en un preciso momento del 
  # gameclock
  dfall <- df %>% filter(game_clock == gameclock, event.id==eventid)  %>% 
    filter(lastname!="ball") %>% select (team_id,x_loc,y_loc,jersey)
  # Se declara los nombres de columna en el dataframe dfall
  colnames(dfall) <- c('ID','X','Y','jersey')
  return(dfall)
}
chull_plot <- function(df, eventid, gameclock) {
  # Esta función sirve para generar un dataframe que incluyan las posiciones X en un plano cartesiano 
  # En matematicas euclideanas se conoce como 'Convex hull'
  df2 <- player_position1(df, eventid, gameclock)
  df_hull2 <- df2 %>% filter(ID == min(ID)) %>% select(X,Y)
  df_hull3 <- df2 %>% filter(ID == max(ID)) %>% select(X,Y)
  c.hull2 <- chull(df_hull2)
  c.hull3 <- chull(df_hull3)
  c.hull2 <- c(c.hull2, c.hull2[1])
  c.hull3 <- c(c.hull3, c.hull3[1])
  df2 <- as.data.frame(cbind(1,df_hull2[c.hull2 ,]$X,df_hull2[c.hull2 ,]$Y))
  df3 <- as.data.frame(cbind(2,df_hull3[c.hull3 ,]$X,df_hull3[c.hull3 ,]$Y))
  # Se unen los valoresde filas de los dataframe df2, df3
  dfall <- rbind(df2,df3)
  # Se declara los nombres de columna en el dataframe dfall
  colnames(dfall) <- c('ID','X','Y')
  return(dfall)
}
ball_position1 <- function(df,eventid,gameclock){
  #Genera el dataframe asociado directamente con la posicion del ballon en el plano cartesiano
  dfall <- df %>% filter(game_clock == gameclock, event.id==eventid)  %>% 
    filter(lastname=="ball") %>% select (team_id,x_loc,y_loc,jersey)
  # Se declara los nombres de columna en el dataframe dfall
  colnames(dfall) <- c('ID','X','Y','jersey')
  return(dfall)
}
fullcourt <- function () {
  #Función para generar el ggplot de la cancha, los jugadores y el balÃ³n
  palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
            "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
  
  circleFun()
  #Se incluyen los datos relevantes para generar el centro de la cancha 
  g()
  #Se incluyen los datos relevantes para generar las posiciones geometricas que va tener el ggplot
}

circleFun <- function(center=c(0,5.25), diameter=20.9, npoints=20000, start=0, end=1, filled=TRUE){
  tt <- seq(start*pi, end*pi, length.out=npoints)
  df <- data.frame(
    y = center[1] + diameter / 2 * cos(tt),
    x = center[2] + diameter / 2 * sin(tt)
  )
  return(df) 
  }

g <- function(){
  halfCircle <- circleFun(c(0, 5.25), 20.9*2, start=0, end=1, filled=FALSE) 
  ggplot(data=data.frame(y=1,x=1),aes(x,y))+
    ###linea de medio campo:
    geom_path(data=data.frame(x=c(47,47),y=c(0,50)))+
    ###chico de afuera:
    geom_path(data=data.frame(y=c(0,0,50,50,0),x=c(0,94,94,0,0)))+
    ###semicirculo fuera de cancha:
    geom_path(data=data.frame(y=c((-6000:(-1)/1000)+25,(1:6000/1000)+25),x=c(19+sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(y=y,x=x))+
    geom_path(data=data.frame(y=c((-6000:(-1)/1000)+25,(1:6000/1000)+25),x=c(75+sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(y=y,x=x))+
    ###semicirculo dentro de la linea de tres puntos:
    geom_path(data=data.frame(y=c((-6000:(-1)/1000)+25,(1:6000/1000)+25),x=c(19-sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(y=y,x=x),linetype='dashed')+
    geom_path(data=data.frame(y=c((-6000:(-1)/1000)+25,(1:6000/1000)+25),x=c(75-sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(y=y,x=x),linetype='dashed')+
    ###lÃlinea de tiro libre:
    geom_path(data=data.frame(y=c(17,17,33,33,17),x=c(0,19,19,0,0)))+
    geom_path(data=data.frame(y=c(17,17,33,33,17),x=c(94,75,75,94,94)))+
    ###jugador dentro de la linea de tiro libre:
    geom_path(data=data.frame(y=c(19,19,31,31,19),x=c(0,19,19,0,0)))+
    geom_path(data=data.frame(y=c(19,19,31,31,19),x=c(94,75,75,94,94)))+
    ###area restringida de medio circulo:
    geom_path(data=data.frame(y=c((-4000:(-1)/1000)+25,(1:4000/1000)+25),x=c(5.25+sqrt(4^2-c(-4000:(-1)/1000,1:4000/1000)^2))),aes(y=y,x=x))+
    geom_path(data=data.frame(y=c((-4000:(-1)/1000)+25,(1:4000/1000)+25),x=c(88.75-sqrt(4^2-c(-4000:(-1)/1000,1:4000/1000)^2))),aes(y=y,x=x))+
    ###semicirculo de media cancha:
    geom_path(data=data.frame(y=c((-6000:(-1)/1000)+25,(1:6000/1000)+25),x=c(47-sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(y=y,x=x))+
    geom_path(data=data.frame(y=c((-6000:(-1)/1000)+25,(1:6000/1000)+25),x=c(47+sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(y=y,x=x))+
    ###canasta de tiro:
    geom_path(data=data.frame(y=c((-750:(-1)/1000)+25,(1:750/1000)+25,(750:1/1000)+25,(-1:-750/1000)+25),x=c(c(5.25+sqrt(0.75^2-c(-750:(-1)/1000,1:750/1000)^2)),c(5.25-sqrt(0.75^2-c(750:1/1000,-1:-750/1000)^2)))),aes(y=y,x=x))+
    geom_path(data=data.frame(y=c((-750:(-1)/1000)+25,(1:750/1000)+25,(750:1/1000)+25,(-1:-750/1000)+25),x=c(c(88.75+sqrt(0.75^2-c(-750:(-1)/1000,1:750/1000)^2)),c(88.75-sqrt(0.75^2-c(750:1/1000,-1:-750/1000)^2)))),aes(y=y,x=x))+
    ###pizaron:
    geom_path(data=data.frame(y=c(22,28),x=c(4,4)),lineend='butt')+
    geom_path(data=data.frame(y=c(22,28),x=c(90,90)),lineend='butt')+
    ###linea de tres pntos:
    #geom_path(data=data.frame(y=c(-21,-21,-21000:(-1)/1000,1:21000/1000,21,21),x=c(0,169/12,5.25+sqrt(23.75^2-c(-21000:(-1)/1000,1:21000/1000)^2),169/12,0)),aes(y=y,x=x))+
    ###proporciÃ³n de aspecto 
    geom_path(data=halfCircle,aes(x=x,y=y+25))+
    ###lÃlnea de tres puntos completa:
    geom_path(data=data.frame(y=c(4.1,4.1,45.9,45.9),x=c(5.25,0,0,5.25)))+
    geom_path(data=halfCircle,aes(x=94-x,y=y+25))+
    geom_path(data=data.frame(y=c(4.1,4.1,45.9,45.9),x=c(88.75,94,94,88.75)))+
    coord_fixed()+
    
    ###Limpiar la cancha 
    theme_bw()+theme(panel.grid=element_blank(), legend.title=element_blank(), panel.border=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),axis.title=element_blank(),legend.position="top")}


### Sección 1: Manejo de Datos


# Se guarda la información del json en un dataframe que incluye los movimientos de los jugadores asociados 
# con la información del 'player_id'
all.movements <- read.csv("allmovements.csv") #Se declara un dataframe con la información correspondiente del documento csv 
#str(all.movements)

# La función read.csv se emplea con el fin de guardar en un dataframe los datos del documento pbp, el cual incluye todos los movimientos "play by play"
pbp <- read.csv("pbp.csv") 
#str(pbp)

pbp <- pbp[-1,] #se elimina la primer columna porque son valores NAs
colnames(pbp)[2] <- c('event.id') #se asignan nombres a la columna dos dentro del dataframe pbp
pbp0 <- pbp %>% select (event.id,EVENTMSGTYPE,EVENTMSGACTIONTYPE,SCORE) #se genera un dataframe que consiste particularmente de las columnas seleccionadas 
pbp0$event.id <- as.numeric(levels(pbp0$event.id))[pbp0$event.id]#Se transforman los valores de event.id a numericos

all.movements <- merge(x = all.movements, y = pbp0, by = "event.id", all.x = TRUE) #se une el dataframe pbp0 al 'all.movements'
dim(all.movements) #se muestra las nuevas dimensiones del dataframe 
which(all.movements$event.id == 100) #Se comprueba la existencia del event.id == 100

id100 <- all.movements[which(all.movements$event.id == 58),] #se genera un dataframe que incluya solo los 'event.id' 303
dim(id100) #se muestra las nuevas dimensiones del dataframe 


### Sección 2: Construcción del Plot Estático


# Se genera un dataframe con la información correspondiente para cada uno de los 10 jugadores que se encuentran 
#which(id100$game_clock == 124.61)
playerdf <- player_position1(df=id100, eventid=58,gameclock=365.44) 
playerdf

# Se genera el dataframe que incluye las posiciones de la cancha en la que se ubicaran a los jugadores 
chulldf <- chull_plot(df=id100, eventid=58, gameclock=365.44)
chulldf

# Se genera el dataframe que incluye la posición del ballón dentro de la cancha 
ballposdf <- ball_position1(df=id100, eventid=58, gameclock=365.44)
ballposdf

fullcourt() + 
  geom_point(data=playerdf,aes(x=X,y=Y,group=ID,color=factor(ID)),size=6) +       #lugadores
  geom_text(data=playerdf,aes(x=X,y=Y,group=ID,label=jersey),color='black') +     #numero de jersey
  geom_polygon(data=chulldf,aes(x=X,y=Y,group=ID,fill=factor(ID)),alpha = 0.2) +  #plano cartesiano de cancha
  geom_point(data=ballposdf,aes(x=X,y=Y),color='darkorange',size=3) +             #ball
  scale_color_manual(values=c("lightsteelblue2","orangered2")) +                  #colores de escala
  scale_fill_manual(values=c("lightsteelblue2","orangered2")) +                   #colores de relleno
  theme(legend.position="none")


### Sección 3: Construcción del Plot Dinámico 

#Se declara un vector que incluye el tiempo del reloj en que se marcan las jugadas 
clocktimes <- rev(sort(unique(id100$game_clock)))

#Se habre un vector con una lista 
fulldf <- list()

#Se realiza una loop que introduce cada uno de los movimientos del reloj a los dataframes correspondientes 
for(i in seq_along(clocktimes)){
  dplayer <- player_position1(df=id100, 58,clocktimes[i]) 
  dchull <- chull_plot(df=id100, 58,clocktimes[i])       
  ballpos <- ball_position1(df=id100, 58,clocktimes[i])  
  dchull$jersey = "NA"
  dplayer$valx = 'player'
  dchull$valx = 'hull'
  ballpos$valx  = 'ball'
  fulldf[[i]] = rbind(dplayer,dchull,ballpos) # Se unen todos los valores en el dataframe fulldf
}

length(fulldf)
fulldf = Map(cbind,fulldf,timebin=1:length(fulldf))  # Adición del tiempo
table(lapply(fulldf,nrow) %>% unlist) # Visualización de información de filas en forma de tabla
which(lapply(fulldf,nrow) %>% unlist > 22) # Cuales columnas en el dataframe tienen filas mayores a 23

playdf = data.table::rbindlist(fulldf)
playdf2 = playdf %>% filter(timebin!=1) %>% filter(timebin<845)


makeplot <- function() {  
  p <- fullcourt() + 
    geom_point(data=playdf2 %>% filter(valx=="player"),aes(x=X,y=Y,group=ID,color=factor(ID)),size=6) +
    geom_text(data=playdf2 %>% filter(valx=="player"),aes(x=X,y=Y,group=ID,label=jersey),color='black') +
    geom_polygon(data=playdf2 %>% filter(valx=="hull"),aes(x=X,y=Y,group=ID,fill=factor(ID)),alpha = 0.2) + 
    geom_point(data=playdf2 %>% filter(valx=="ball"),aes(x=X,y=Y),color='darkorange',size=3) +
    scale_color_manual(values=c("lightsteelblue2","orangered2")) +
    scale_fill_manual(values=c("lightsteelblue2","orangered2")) +
    theme(legend.position="none") +
    transition_manual(timebin) # FUNCIÓN ELEMENTAL requerida para realizar el cambio de transiciones para 
  print(p)
}

makeplot()

### Sección 4: Interpolar una imagen PNG en el fondo

# Se produce un vector que contiene la información de la imagen a partir de la función readPNG
img <- readPNG("Bcourt.png")

fullcourt() + 
  annotation_custom(rasterGrob(img)) + #Función annotation_custom permite agregar objetos personalizables mientras que rasterGrob permite rasterizar (convertir vectores en pixeles)
  geom_point(data=playerdf,aes(x=X,y=Y,group=ID,color=factor(ID)),size=6) +       
  geom_text(data=playerdf,aes(x=X,y=Y,group=ID,label=jersey),color='black') +     
  geom_polygon(data=chulldf,aes(x=X,y=Y,group=ID,fill=factor(ID)),alpha = 0.2) +  
  geom_point(data=ballposdf,aes(x=X,y=Y),color='darkorange',size=3) +             
  scale_color_manual(values=c("lightsteelblue2","orangered2")) +                  
  scale_fill_manual(values=c("lightsteelblue2","orangered2")) +                   
  theme(legend.position="none") 
  
### Sección 5: Correr el objeto dinámico con el fondo personalizable 

makeplot <- function() {  
  p <- fullcourt() + 
    annotation_custom(rasterGrob(img)) +
    geom_point(data=playdf2 %>% filter(valx=="player"),aes(x=X,y=Y,group=ID,color=factor(ID)),size=6) +
    geom_text(data=playdf2 %>% filter(valx=="player"),aes(x=X,y=Y,group=ID,label=jersey),color='black') +
    geom_polygon(data=playdf2 %>% filter(valx=="hull"),aes(x=X,y=Y,group=ID,fill=factor(ID)),alpha = 0.2) + 
    geom_point(data=playdf2 %>% filter(valx=="ball"),aes(x=X,y=Y),color='darkorange',size=3) +
    scale_color_manual(values=c("lightsteelblue2","orangered2")) +
    scale_fill_manual(values=c("lightsteelblue2","orangered2")) +
    theme(legend.position="none") +
    transition_manual(timebin) # FUNCIÓN ELEMENTAL requerida para realizar el cambio de transiciones para 
  print(p)
}

makeplot()

# Se genera una función que utilice como argumentos la función de construcción del ggplot(data) y el nombre a asignar (name)
savedynamicplot <- function(data, name){
  gif_file <- file.path(getwd(), name) # Genera una variable que se reduce al nombre completo del archivo
  save_gif(data, gif_file, width = 800, height = 450, res = 92) # Función savegif() que permite guardar el archivo en nuestro ordenador
  utils::browseURL(gif_file) 
}

savedynamicplot(makeplot(), "dynamicplot.gif")