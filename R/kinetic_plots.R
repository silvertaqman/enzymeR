#' Get kinetic data to generate usual plots
#'
#' @param df time - substrate - rate (tsr) dataframe
#' @return p plot
#' @importFrom ggplot2 autoplot
#' @examples
#' kinetic_plot(df,mode="tsrplot")
library(patchwork)
library(ggplot2)
kinetic_plot <- function(df) {
  a<-ggplot(df,aes(t,S))+
    geom_point()+
    geom_line()
  b<-ggplot(df,aes(S,v))+
    geom_point()+
    geom_line()
  return(a/b)
}
# Example

