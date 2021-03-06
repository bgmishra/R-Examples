# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

extract_GT_to_CM <- function(x, element = "DP") {
    .Call('vcfR_extract_GT_to_CM', PACKAGE = 'vcfR', x, element)
}

extract_GT_to_CM2 <- function(fix, gt, element = "DP", allele_sep = '/', alleles = 0L, extract = 1L) {
    .Call('vcfR_extract_GT_to_CM2', PACKAGE = 'vcfR', fix, gt, element, allele_sep, alleles, extract)
}

CM_to_NM <- function(x) {
    .Call('vcfR_CM_to_NM', PACKAGE = 'vcfR', x)
}

extract_haps <- function(ref, alt, gt, gt_split, verbose) {
    .Call('vcfR_extract_haps', PACKAGE = 'vcfR', ref, alt, gt, gt_split, verbose)
}

gt_to_popsum <- function(var_info, gt) {
    .Call('vcfR_gt_to_popsum', PACKAGE = 'vcfR', var_info, gt)
}

NM2winNM <- function(x, pos, maxbp, winsize = 100L) {
    .Call('vcfR_NM2winNM', PACKAGE = 'vcfR', x, pos, maxbp, winsize)
}

windowize_NM <- function(x, pos, starts, ends, summary = "mean") {
    .Call('vcfR_windowize_NM', PACKAGE = 'vcfR', x, pos, starts, ends, summary)
}

pair_sort <- function() {
    .Call('vcfR_pair_sort', PACKAGE = 'vcfR')
}

rank_variants <- function(variants, ends, score) {
    .Call('vcfR_rank_variants', PACKAGE = 'vcfR', variants, ends, score)
}

seq_to_rects <- function(seq, targets) {
    .Call('vcfR_seq_to_rects', PACKAGE = 'vcfR', seq, targets)
}

window_init <- function(window_size, max_bp) {
    .Call('vcfR_window_init', PACKAGE = 'vcfR', window_size, max_bp)
}

windowize_fasta <- function(wins, seq) {
    .Call('vcfR_windowize_fasta', PACKAGE = 'vcfR', wins, seq)
}

windowize_variants <- function(windows, variants) {
    .Call('vcfR_windowize_variants', PACKAGE = 'vcfR', windows, variants)
}

windowize_annotations <- function(wins, ann_starts, ann_ends, chrom_length) {
    .Call('vcfR_windowize_annotations', PACKAGE = 'vcfR', wins, ann_starts, ann_ends, chrom_length)
}

vcf_stats_gz <- function(x) {
    .Call('vcfR_vcf_stats_gz', PACKAGE = 'vcfR', x)
}

read_meta_gz <- function(x, stats, verbose) {
    .Call('vcfR_read_meta_gz', PACKAGE = 'vcfR', x, stats, verbose)
}

read_body_gz <- function(x, stats, nrows = -1L, skip = 0L, cols = 0L, verbose = 1L) {
    .Call('vcfR_read_body_gz', PACKAGE = 'vcfR', x, stats, nrows, skip, cols, verbose)
}

write_vcf_body <- function(fix, gt, filename, mask = 0L) {
    invisible(.Call('vcfR_write_vcf_body', PACKAGE = 'vcfR', fix, gt, filename, mask))
}

write_fasta <- function(seq, seqname, filename, rowlength = 80L, verbose = 1L) {
    invisible(.Call('vcfR_write_fasta', PACKAGE = 'vcfR', seq, seqname, filename, rowlength, verbose))
}

