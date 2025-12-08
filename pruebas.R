library(jsonlite)
library(udpipe)
udmodel_es <- udpipe_load_model(file='spanish-ancora-ud-2.5-191206.udpipe')
library(stringr)
library(stringi)
library(rvest)


# Función que clasifica por afijos
afijos <- function(palabra) {
  palabra <- tolower(palabra)
  if(grepl("algia$", palabra)) return("dolor")
  if(grepl("^hipo|^hiper", palabra)) return("alteración")
  if(grepl("itis$", palabra)) return("infección")
  if(grepl("oma$", palabra)) return("cáncer")
  return(NA) # si la palabra no coincide con ningún afijo
}

# Función para construir los sintagmas nominales
sintagmas_nominales <- function(anotacion) {
  n <- nrow(anotacion)
  results <- data.frame()
  for(i in 1:n) {
    upos_i <- anotacion$upos[i]
    # Solo procesamos si es NOUN o PROPN
    if(!is.na(upos_i) && (upos_i == "NOUN" || upos_i == "PROPN")) {
      izquierda <- i
      while(izquierda > 1 &&
            !is.na(anotacion$upos[izquierda-1]) &&
            (anotacion$upos[izquierda-1] == "ADJ" ||
             anotacion$upos[izquierda-1] == "NOUN" ||
             anotacion$upos[izquierda-1] == "PROPN")) {
        izquierda <- izquierda - 1
      }
      derecha <- i
      while(derecha < n &&
            !is.na(anotacion$upos[derecha+1]) &&
            (anotacion$upos[derecha+1] == "ADJ" ||
             anotacion$upos[derecha+1] == "NOUN" ||
             anotacion$upos[derecha+1] == "PROPN")) {
        derecha <- derecha + 1
      }
      
      phrase_tokens <- anotacion$token[izquierda:derecha]
      phrase_text <- paste(phrase_tokens, collapse = " ")
      
      results <- rbind(
        results,
        data.frame(
          text = phrase_text,
          head_id = i,
          start = izquierda,
          end = derecha,
          stringsAsFactors = FALSE
        )
      )
    }
  }
  rownames(results) <- NULL
  return(results)
}


# Función que busca enfermedades




# Opcional: Buscar definición en CUN
buscar_enfermedad <- function(palabra) {
  url <- paste0("https://www.cun.es/diccionario-medico/terminos/", palabra)
  lines <- readLines(url)
  
  # Obtiene la definición
  comienzo_inf <- grep("<section class=\"textImageComponent textImageComponent\">", lines)[1]+1
  length_inf <- grep("^<h2>", lines[comienzo_inf+1:length(lines)])[1]-1
  text <- lines[comienzo_inf:(comienzo_inf+length_inf)]
  
  # Elimina las líneas con cabeceras si tiene
  cabeceras <- grep("<h2>", text)
  if (length(cabeceras) != 0){
    text <- text[-cabeceras]
  }
  
  info <- paste(unlist(lapply(text, limpiarTexto)), collapse="\n")
  traducirTexto(info)
}

# Función auxiliar que elimina las etiquetas de HTML
limpiarTexto<-function(cadena){
  res<-gsub("<[^<>]*>", "", cadena)
  trimws(res)
}

# Función auxiliar que traduce las letras con tilde y la eñe
traducirTexto <- function(cadena){
  trad <- list(c("&aacute;", "á"),
               c("&Aacute;", "Á"),
               c("&eacute;", "e"),
               c("&Eacute;", "É"),
               c("&iacute;", "í"),
               c("&Iacute;", "Í"),
               c("&oacute;", "ó"),
               c("&Oacute;", "Ó"),
               c("&uacute;", "ú"),
               c("&Uacute;", "Ú"),
               c("&ntilde;", "ñ"),
               c("&Ntilde;", "Ñ"),
               c("&iquest;", "¿"),
               c("&iexcl;", "¡"),
               c("&laquo;", "«"),
               c("&raquo;", "»"),
               c("&ndash;", "-")
  )
  stri_replace_all_regex(cadena,
                         pattern=unlist(lapply(trad, function(x){x[1]})),
                         replacement=unlist(lapply(trad, function(x){x[2]})),
                         vectorize=FALSE)
}


# Procesar JSON de artículos (usar solo 100 aleatorios porque el json es enorme)

