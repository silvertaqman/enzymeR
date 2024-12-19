#' Reaction S4 object to manage reactions data
#'
#' @param df Tidy dataframe with at least two columns, one for time and one for substrate (i.e. substrate and rate). This dataframe could also be generalized to have as many substrate and product columns as needed, but then you need to specify its names. It is highly recommended to use subindex in order to correctly classify data input.
#' @param time_type an option marking you passed time-substrate data, so a rate estimations from v=-diff(s)/diff(t) is required for every substrate column [research more about this]. Default is false, you should measure rate. 
#' @param s_names (Optional) vector of substrate names
#' @param p_names (Optional) vector of product names
#' @param e0 enzyme concentration for kcat estimation
#' @return rx an S4 object with substrate and rate data organized, also allows options for products and enzyme data
#' @importFrom 
#' @examples
#' create_rx(df, time_type=TRUE, snames=starts_with("s_"), pnames=starts_with("p_"), e0=17)
setClass("rx_mono",
  representation(
    substrate="double",
    product="double",
    rate="double",
    enzyme="double"
  )
ata2<-new("rx")