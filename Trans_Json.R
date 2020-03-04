getwd()
setwd("")

library(RCurl)
library(jsonlite)
library(dplyr)
library(sp)
library(curl)

factorconvert <- function(f){as.numeric(levels(f))[f]}
sportvu_convert_json <- function (file.name) {
  # Función que convierte documentos json dataframe
  the.data.file<-fromJSON(file.name)
  ## Se guardan las columnas de eventos y momentos provenientes del dataframe
  moments <- the.data.file$events$moments
  
  ## Función para extraer información del Json
  extractbb <- function (listbb)
  { df <- listbb #Consiste en guardar la información dentro de un dataframe denominado df
  # La función lapply permite aplicar una función en particular a la los valores de la lista. En este caso
  # la función permite extraer la información de las columnas especificas del dataframe original
  quarters <- unlist(lapply(df, function(x) x[[1]]))
  game.clock <- unlist(lapply(df, function(x) x[[3]]))
  shot.clock <- unlist(lapply(df, function(x) ifelse(is.null(x[[4]]), 'NA', x[[4]])))
  moment.details <- (lapply(df, function(x) x[[6]]))
  # Se realiza una cbind con el fin de unir las columnas provenientes de las listas. Similar a lapply, mapply
  # permite aplicar una función especifica a multiple listas. En este caso en particular, se aplica un cbind
  # a las listas obtenidas anteriormente. Adicionalmente todo se guarda en forma de arreglo (matrix)
  x3 <-  mapply(cbind, moment.details, game.clock, shot.clock,quarters, SIMPLIFY=F) 
  # Se hace llamar a la función rbind para guardar la información de las filas dentro del dataframe x4
  x4 <- do.call('rbind', x3)
  return (x4)
  }
  
  # Se adiciona la información del dataframe extractbb al dataframe moments 
  test2 <- lapply(moments, function (x) {extractbb(x)})
  # Se guarda la información del eventId en lengthm 
  lengthmm <- the.data.file$events$eventId
  # Se aplica la función mapply para aplicar la función cbind con el dataframe test2 y el dataframe lengthm
  # en un arreglo en forma de dataframe 
  test2 <- mapply(cbind, test2, "event.id"=lengthmm, SIMPLIFY=F)
  
  # Se eliminan los eventos que son NAs
  final <- (lapply(test2, function(x) {
    if ((length(unlist(x)))<=1) {x <- NA} 
    return(x)
  }))
  
  ## Se unen por filas 
  test2 <- do.call('rbind', final)
  ## Se transforma en dataframe
  test2 <- as.data.frame(test2)
  ## Se prueba la lógica si existen valores de NA dentro de la tabla 
  test2[test2 == "NA" ] = NA
  ## Se guarda la información dentro del dataframe all.movement
  all.movement <- test2
  
  ## Se genera un vector con los strings correspondientes a los nombres de columna 
  headers = c("team_id", "player_id", "x_loc", "y_loc", "radius", "game_clock", "shot_clock", "quarter","event.id")
  ## Se aplican los nombres guardados en el header a las columnas del dataframe all.movement 
  colnames(all.movement) <- headers
  ## Se transforma nuevamente el dataframe all.movement a dataframe 
  all.movement<-data.frame(all.movement)
  ## Se ordenan los valores de la columna game_clock en el dataframe all.movement de manera ascendente para
  ## determinar el tiempo de reloj en el game
  all.movement<-all.movement[order(all.movement$game_clock),]
  
  ## Se genera una lista con los nombres de los jugadores locales provenientes del dataframe original 
  home.players <- the.data.file$events$home$players[[1]]
  ## Se genera una lista con los nombres de los jugadores visitantes provenientes del dataframe original
  away.players <- the.data.file$events$visitor$players[[1]]
  ## Se les categoriza a los dos vectores con el nombre de columna player_id 
  colnames(home.players)[3] <- "player_id"
  colnames(away.players)[3] <- "player_id"
  
  ## Se organiza la información de los movimientos a partir de las coincidencias del dataframe all.movement
  ## con los vectores de home.players, away.players
  home.movements<-merge(home.players, all.movement, by="player_id")
  away.movements<-merge(away.players, all.movement, by="player_id")
  ## Se adiciona la información de los movimientos de la pelota a partir de un filtro en el dataframe 
  ## all.movement. Asimismo, se adicionan valores NA para las columnas jersey, position, team_id, firstname
  ## Se etiqueta la pelota con un lastname <- ball 
  ball.movement<-all.movement %>% filter(player_id == -1)
  ball.movement$jersey <- NA
  ball.movement$position <- NA
  ball.movement$team_id <- NA
  ball.movement$lastname <- "ball"
  ball.movement$firstname <- NA
  ## Se unen en el dataframe la información correspondiente a las filas de home.movements, away.movements y ball.movements
  all.movements <- rbind(home.movements, away.movements,ball.movement)
  ## Con la función factorconvert, todos los valores de los diferentes niveles en el dataframe all.movements
  ## se convierten a valores numericos 
  all.movements[, 6:13] <- lapply(all.movements[, 6:13], factorconvert)
  ## Se declara nuevamente all.movements como un dataframe, utilizando el arreglo dplyr para asegurar que 
  ## todos los valores dentro de las columnas quarter, game_clock, x_loc y y_loc puedan ser utilizados en 
  ## el dataframe 
  all.movements <- as.data.frame(all.movements) %>% dplyr::arrange(quarter,desc(game_clock),x_loc,y_loc)
  return(all.movements)
}
get_pbp <- function(gameid){
  # Recupera la información de jugada a jugada por parte del sitio oficial de la NBA
  URL1 <- paste("http://stats.nba.com/stats/playbyplayv2?EndPeriod=10&EndRange=55800&GameID=",gameid,"&RangeType=2&StartPeriod=1&StartRange=0",sep = "")
  # Se transforma la información del archivo Json a un dataframe denominado the.data.file
  the.data.file<-fromJSON(URL1)
  # Se extrae la información de las columnas resultSets & rowset en un dataframe denominado test 
  test <-the.data.file$resultSets$rowSet
  # Se extrae la  información de la casilla 1 del dataframe test en un vector denominado test2
  test2 <- test[[1]]
  # Se declara un dataframe denominado test3 con la información del vector test2
  test3 <- data.frame(test2)
  # Se declara un vector con la información de la columna resultSets$headers dentro del datafrae the..data.file
  coltest <- the.data.file$resultSets$headers
  # Se declaran los nombres de las columnas en el dataframe test3 a partir de los valores de coltest 
  colnames(test3) <- coltest[[1]]
  return (test3)
}

# Función hecha para la transformación de un archivo json a un dataframe especifico para trabajar en R
all.movements <- sportvu_convert_json("0021500001.json")
# Se guarda y escribe el documento directo en el directorio en formato .csv
write.csv(all.movements, "allmovements.csv")

# Se declara el identificador del juego
gameid = "0021500431"
# Se declara pbp (playbyplay) empleando la función get_pbp con el identificador gameid 
pbp <- get_pbp(gameid)
# Se guarda y escribe el documento directo en el directorio en formato .csv
write.csv(pbp, file = "pbp.csv")
