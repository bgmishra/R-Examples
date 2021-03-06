# The NanoStringNorm package is copyright (c) 2012 Ontario Institute for Cancer Research (OICR)
# This package and its accompanying libraries is free software; you can redistribute it and/or modify it under the terms of the GPL
# (either version 1, or at your option, any later version) or the Artistic License 2.0.  Refer to LICENSE for the full license text.
# OICR makes no representations whatsoever as to the SOFTWARE contained herein.  It is experimental in nature and is provided WITHOUT
# WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE OR ANY OTHER WARRANTY, EXPRESS OR IMPLIED. OICR MAKES NO REPRESENTATION
# OR WARRANTY THAT THE USE OF THIS SOFTWARE WILL NOT INFRINGE ANY PATENT OR OTHER PROPRIETARY RIGHT.
# By downloading this SOFTWARE, your Institution hereby indemnifies OICR against any loss, claim, damage or liability, of whatsoever kind or
# nature, which may arise from your Institution's respective use, handling or storage of the SOFTWARE.
# If publications result from research using this SOFTWARE, we ask that the Ontario Institute for Cancer Research be acknowledged and/or
# credit be given to OICR scientists, as scientifically appropriate.

test.code.count.normalization <- function(date.input = '2011-11-04', date.checked.output = '2011-11-04'){
	
	# go to test data directory
	path.to.input.files <- '../NanoStringNorm/extdata/input/';
	path.to.output.files <- '../NanoStringNorm/extdata/output/';

	# read input files
	x             <- read.table(paste(path.to.input.files, 'mRNA_TCDD_matrix.txt', sep = ''), sep = '\t', header = TRUE, as.is = TRUE);
	anno          <- read.table(paste(path.to.input.files, 'mRNA_TCDD_anno.txt', sep = ''), sep = '\t', header = TRUE, as.is = TRUE);
	trait         <- read.table(paste(path.to.input.files, 'mRNA_TCDD_strain_info.txt', sep = ''), sep = '\t', header = TRUE, as.is = TRUE);

	# read *checked output*
	checked.output.sum <- dget(file = paste(path.to.output.files, 'mRNA_TCDD_sum_Code_Count_Normalization.txt', sep = ''));
	checked.output.geo.mean <- dget(file = paste(path.to.output.files, 'mRNA_TCDD_geo.mean_Code_Count_Normalization.txt', sep = ''));

	# run function to get *test output* 
	test.output.sum      <- NanoStringNorm:::code.count.normalization(x, anno, 'sum', verbose = FALSE);
	test.output.geo.mean <- NanoStringNorm:::code.count.normalization(x, anno, 'geo.mean', verbose = FALSE);

	### check1 - compare checked output == test output
	check1.1 <- checkEquals(checked.output.sum, test.output.sum);
	check1.2 <- checkEquals(checked.output.geo.mean, test.output.geo.mean);

	### check2 - check garbage input
	check2.1 <- checkException(NanoStringNorm:::code.count.normalization(x, anno, 'mean', verbose = FALSE));
	check2.2 <- checkException(NanoStringNorm:::code.count.normalization(x, anno, NA, verbose = FALSE));

	checks <- c(check1.1 = check1.1, check1.2 = check1.2, check2.1 = check2.1, check2.2 = check2.2);
	if (!all(checks)) print(checks[checks == FALSE]);

	return(all(checks))

	}
