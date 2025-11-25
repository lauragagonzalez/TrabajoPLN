install.packages("jsonlite")

library(jsonlite)
library(jsonlite)

json_file <- "MESINESP_ORIGINAL_TRAINING.json"

# Leer cada línea como JSON
lines <- readLines(json_file)

# Convertir cada línea a lista
data_list <- lapply(lines, fromJSON)

# Si quieres un data.frame
data_df <- do.call(rbind, lapply(data_list, as.data.frame))


json_file <- "MESINESP_ORIGINAL_TRAINING.json"
data_list <- fromJSON(txt = json_file)
str(data_list)

# Seleccionar aleatoriamente 20 registros
set.seed(123) # Para reproducibilidad
if (nrow(data_list) >= 20) {
  seleccionados <- data_list[sample(nrow(data_list), 20), ]
} else {
  seleccionados <- data_list
  cat("El archivo tiene menos de 20 registros, se seleccionarán todos.\n")
}

# Crear un directorio para los archivos de salida
output_dir <- "abstracts_txt"
if (!dir.exists(output_dir)) dir.create(output_dir)


# Guardar cada abstract en un archivo .txt separado
for (i in 1:nrow(seleccionados)) {
  file_name <- paste0(output_dir, "/", seleccionados$id[i], ".txt")
  writeLines(seleccionados$abstractText[i], con = file_name)
  cat("Archivo creado:", file_name, "\n")
}
