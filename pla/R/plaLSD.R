plaLSD <- function(data,
                   alpha         = 0.05,
                   imputeMissing = FALSE,
                   dfAdjustment  = NA,
                   dilutionRatio = NA,
                   factor        = NA,
                   echoData      = TRUE,
                   colors        = "default",
                   projectTitle  = "",
                   assayTitle    = "")
    pla(data          = data,
        alpha         = alpha,
        imputeMissing = imputeMissing,
        dfAdjustment  = dfAdjustment,
        dilutionRatio = dilutionRatio,
        factor        = factor,
        echoData      = echoData,
        colors        = colors,
        projectTitle  = projectTitle,
        assayTitle    = assayTitle,
        design        = "lsd")
