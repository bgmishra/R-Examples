relationLR = function(ped_numerator, ped_denominator, ids, alleles, afreq=NULL, 
                     known_genotypes=list(), loop_breakers=NULL, Xchrom=FALSE, 
                     plot=TRUE, title1="", title2="") {   
    
    ped_claim = ped_numerator 
    ped_true = ped_denominator
    if (inherits(ped_claim, "linkdat")) 
        ped_claim = list(ped_claim)
    if (inherits(ped_true, "linkdat")) 
        ped_true = list(ped_true)
    ids_claim = lapply(ped_claim, function(x) ids[ids %in% x$orig.ids])
    ids_true = lapply(ped_true, function(x) ids[ids %in% x$orig.ids])
    
    if(!is.null(loop_breakers)) 
        return("Loops not yet implemented")
        #loops_claim = lapply(ped_claim, function(x) {
        #    lb = x$orig.ids[x$orig.ids %in% loop_breakers]
        #    if (length(lb) == 0) 
        #        lb = NULL
        #    lb
        #})
        #loops_true = lapply(ped_true, function(x) {
        #    lb = x$orig.ids[x$orig.ids %in% loop_breakers]
        #    if (length(lb) == 0) 
        #        lb = NULL
        #    lb
        #})
        
    N_claim = length(ped_claim)
    N_true = length(ped_true)
    N = N_claim + N_true
    if (length(alleles) == 1) 
        alleles = seq_len(alleles)
    chrom = if (Xchrom) 23 else NA
    partial_claim = lapply(1:N_claim, function(i) {
        x = ped_claim[[i]]
        m = marker(x, alleles = alleles, afreq = afreq, chrom = chrom)
        for (tup in known_genotypes) if (tup[1] %in% x$orig.ids) 
            m = modifyMarker(x, m, ids = tup[1], genotype = tup[2:3])
        m
    })
    partial_true = lapply(1:N_true, function(i) {
        x = ped_true[[i]]
        m = marker(x, alleles = alleles, afreq = afreq, chrom = chrom)
        for (tup in known_genotypes) if (tup[1] %in% x$orig.ids) 
            m = modifyMarker(x, m, ids = tup[1], genotype = tup[2:3])
        m
    })
    if (isTRUE(plot) || plot == "plot_only") {
        op = par(oma = c(0, 0, 3, 0), xpd = NA)
        widths = ifelse(sapply(c(ped_claim, ped_true), inherits, 
            what = "singleton"), 1, 2)
        claim_ratio = sum(widths[1:N_claim])/sum(widths)
        layout(rbind(1:N), widths = widths)
        has_genotypes = length(known_genotypes) > 0
        for (i in 1:N) {
            if (i <= N_claim) {
                x = ped_claim[[i]]
                avail = ids_claim[[i]]
                mm = if (has_genotypes) partial_claim[[i]] else NULL
            }
            else {
                x = ped_true[[i - N_claim]]
                avail = ids_true[[i - N_claim]]
                mm = if (has_genotypes) partial_true[[i - N_claim]] else NULL
            }
            cols = ifelse(x$orig.ids %in% avail, 2, 1)
            plot(x, marker = mm, col = cols, margin = c(2, 4, 2, 4), title = "")
        }
        mtext(title1, outer = TRUE, at = claim_ratio/2)
        mtext(title2, outer = TRUE, at = 0.5 + claim_ratio/2)
        rect(grconvertX(0.02, from = "ndc"), grconvertY(0.02, 
            from = "ndc"), grconvertX(claim_ratio - 0.02, from = "ndc"), 
            grconvertY(0.98, from = "ndc"))
        rect(grconvertX(claim_ratio + 0.02, from = "ndc"), grconvertY(0.02, 
            from = "ndc"), grconvertX(0.98, from = "ndc"), grconvertY(0.98, 
            from = "ndc"))
        par(op)
        if (plot == "plot_only") 
            return()
    }

    lik.claim = lik.true = 1
    for (i in 1:N_claim) lik.claim = lik.claim * likelihood(ped_claim[[i]], partial_claim[[i]])
    for (i in 1:N_true) lik.true = lik.true * likelihood(ped_true[[i]], partial_true[[i]])
    list(lik.numerator = lik.claim, lik.denominator = lik.true, LR = lik.claim/lik.true)
}
