library(jsonlite)
library(udpipe)
udmodel_es <- udpipe_load_model(file='spanish-ancora-ud-2.5-191206.udpipe')
library(stringr)
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
# Procesar JSON de artículos (usar solo 100 aleatorios porque el json es enorme)

