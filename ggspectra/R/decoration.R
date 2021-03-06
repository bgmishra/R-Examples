#' Add decorations to spectrum plot (private)
#'
#' Add decorations to plots generated by the plot() methods defined in this
#' package. It collects code that is common to plot methods for different types
#' of spectra but as it may change in the future it is not exported.
#'
#' @param w.band waveband object or list of waveband objects
#' @param ymax,ymin numeric
#' @param annotations character vector
#' @param label.qty character
#' @param summary.label character
#'
#' @keywords internal
#'
#' @return A list of ggplot "components" that can be added to a ggplot object
#'   with operator "+". The length of the list depends on the value of argument
#'   \code{annotations}.
#'
decoration <- function(w.band,
                       y.max,
                       y.min,
                       x.max,
                       x.min,
                       annotations,
                       label.qty,
                       label.mult = 1,
                       summary.label,
                       unit.out = NULL,
                       time.unit = NULL) {
  if (grepl(".pc", label.qty, fixed = TRUE)) {
    label.mult = 100
    label.qty <- sub(".pc", "", label.qty, fixed = TRUE)
  }
  stat_wb_summary <- switch(label.qty,
                            total = stat_wb_total,
                            mean = stat_wb_mean,
                            average = stat_wb_mean,
                            irrad = stat_wb_irrad,
                            sirrad = stat_wb_sirrad,
                            contribution = stat_wb_contribution,
                            relative = stat_wb_relative,
                            function(...) {NULL})
  z <- list()
  if ("peaks" %in% annotations) {
    z <- c(z, stat_peaks(span = 21, label.fmt = "%.4g",
                         ignore_threshold = 0.02, color = "red",
                         geom = "text", vjust = -0.5, size = 2.5))
  }
  if ("valleys" %in% annotations) {
    z <- c(z, stat_valleys(span = 21, label.fmt = "%.4g",
                           ignore_threshold = 0.02, color = "blue",
                           geom = "text", vjust = +1.2, size = 2.5))
  }
  if (!is.null(annotations) &&
      length(intersect(c("labels", "summaries", "colour.guide", "boxes", "segments"),
                       annotations)) > 0L) {
  }
  if ("colour.guide" %in% annotations) {
    z <- c(z, stat_wl_strip(ymax = y.max * 1.26, ymin = y.max * 1.22))
  }
  if ("boxes" %in% annotations) {
    z <- c(z, stat_wl_strip(w.band = w.band,
                            ymax = y.max * 1.20,
                            ymin = y.max * 1.08,
                            color = "white",
                            linetype = "solid"
    ))
    label.color <- "white"
    pos.shift <- 0.00
  }

  if ("segments" %in% annotations) {
    z <- c(z, stat_wl_strip(w.band = w.band,
                            ymax = y.max * 1.10,
                            ymin = y.max * 1.07,
                            color = "white",
                            linetype = "solid"
    ))
    label.color <- "black"
    pos.shift <- 0.01
  }

  if ("labels" %in% annotations || "summaries" %in% annotations) {
    if ("labels" %in% annotations && "summaries" %in% annotations) {
      mapping <- aes_(label = quote(paste(..wb.name.., ..y.label.., sep = "\n")))
    } else if ("labels" %in% annotations) {
      mapping <- aes_(label = ~..wb.name..)
    } else if ("summaries" %in% annotations) {
      mapping <- aes_(label = ~..y.label..)
    }
    if (label.qty %in% c("irrad", "sirrad")) {
      z <- c(z, stat_wb_summary(geom = "text",
                                unit.in = unit.out,
                                time.unit = time.unit,
                                w.band = w.band,
                                label.mult = label.mult,
                                ypos.fixed = y.max * 1.143 + pos.shift,
                                color = label.color,
                                mapping = mapping,
                                size = rel(2)))
    } else {
      z <- c(z, stat_wb_summary(geom = "text",
                                w.band = w.band,
                                label.mult = label.mult,
                                ypos.fixed = y.max * 1.143 + pos.shift,
                                color = label.color,
                                mapping = mapping,
                                size = rel(2)))
    }
  }

  if ("summaries" %in% annotations) {
    z <- c(z,
           annotate("text",
                    x = x.min, y = y.max * 1.09 + 0.5 * y.max * 0.085,
                    size = rel(2), vjust = -0.3, hjust = 0.5, angle = 90,
                    label = summary.label, parse = TRUE))
  }

  z
}