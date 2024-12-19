#' Reaction S4 object to manage reactions data for Simple Michaelis-Menten Kinetics
#'
#' @param df Tidy dataframe with at least two columns, one for time and one for substrate (i.e. substrate and rate). This dataframe could also be generalized to have as many substrate and product columns as needed, but then you need to specify its names. It is highly recommended to use subindex in order to correctly classify data input.
#' @param istime an option marking you passed time-substrate data, so a rate estimations from v=-diff(s)/diff(t) is required for every substrate column [research more about this]. Default is false, you should measure rate. 
#' @param snames substrate names (e.g. s_Glucose) for Glucose -> Fructose reaction
#' @param pnames product names (e.g. p_Fructose) for Glucose -> Fructose reaction
#' @param e0 enzyme concentration for kcat estimation
#' @return rx an S4 object with substrate and rate data organized, also allows options for products and enzyme data
#' @examples
#' create_rx(df, istime=FALSE, reversible = TRUE, snames=starts_with("s_"), pnames=starts_with("p_"), e0=17)
# Define la clase S4 para manejar datos de reacciones cinéticas.
setClass(
  "rx_mono",
  slots = list(
    df = "data.frame",        # Dataframe con las columnas necesarias.
    istime = "logical",       # Indica si los datos incluyen tiempo y sustrato.
    snames = "character",     # Nombres de los sustratos.
    pnames = "character",     # Nombres de los productos.
    e0 = "numeric"            # Concentración de enzima.
  ),
  prototype = list(
    df = tibble(),
    istime = FALSE,
    snames = character(),
    pnames = character(),
    e0 = 0
  )
)

# Define una función para crear objetos de la clase "rx_mono" y realizar cálculos si es necesario.
create_rx <- function(df, istime = FALSE, snames = NULL, pnames = NULL, e0 = 0) {
  # Validación de entradas.
  if (!is.data.frame(df)) stop("'df' debe ser un dataframe.")
  if (!is.logical(istime)) stop("'istime' debe ser un valor lógico.")
  if (!is.numeric(e0) || e0 < 0) stop("'e0' debe ser un número no negativo.")

  # Calcula las tasas de reacción si istime es TRUE.
  if (istime) {
    time_col <- grep("time", names(df), value = TRUE)
    substrate_cols <- grep("^s_", names(df), value = TRUE)

    if (length(time_col) == 0 || length(substrate_cols) == 0) {
      stop("El dataframe debe contener columnas de tiempo y sustrato con nombres adecuados.")
    }

    time <- df[[time_col]]
    for (substrate in substrate_cols) {
      df[[paste0(substrate, "_rate")]] <- c(NA, -diff(df[[substrate]]) / diff(time))
    }
  }

  # Crea y retorna el objeto S4.
  new("rx_mono", df = df, istime = istime, snames = snames, pnames = pnames, e0 = e0)
}

# Ejemplo de uso:
df_example <- data.frame(
  time = c(0, 1, 2, 3, 4),
  s_Glucose = c(100, 80, 60, 40, 20),
  s_Fructose = c(0, 20, 40, 60, 80)
)

rx_object <- create_rx(df = df_example, istime = TRUE, snames = c("s_Glucose"), pnames = c("s_Fructose"), e0 = 17)

# Verifica el objeto creado.
rx_object