`tileplot.single` <-
function(genesonchip, array1data, annotationslist, cutoff=-1, cutoff_multiplier=3, outputfile, graphdirectory, outputtable, array1name = "Array 1", smoothing_factor=6)
{
	
#The cluster file is the CD-HIT output piped through a python script to make each line a cluster (a list of identifiers)
#clusters = scan(file=clusterfile, sep="\n", what="raw")

#The genes file should be a simple list of unique gene identifiers without a header. I use IMG identifiers as they are common for both DNA and protein sequences, making life easier.
genes = read.table(file=genesonchip)

#The array data file is a simple, two-column file containing the probe identifiers in the first column and the median hybridization intensities in the second column.  Probe identifiers should take the form "geneidentifier-probenumber", and be sorted according to probe number so that they land in the correct 5' to 3' order.
array1 = read.table(file=array1data)
#array2 = read.table(file=array2data)

if(cutoff==-1)
{
	cutoff=cutoff_multiplier*median(array1[,2])
}
cat("Cutoff calculated as",cutoff,"\n")

#These next lines perform a loess normalization of the loess data (i.e. find the polynomial function that best fits the data, straightens it out to a linear relationship with a slope of 1, then adjusts all data points to that slope)
#array2.loess <- loess(log(y) ~ log(x), span=0.2, degree=2, data.frame(x=array1[,2], y=array2[,2]))
#array2.predict <- predict(array2.loess, data.frame(x=array1[,2]))
#array2.predict.notlog = 2.71828183^array2.predict
#array2adjusted = (array1[,2]/array2.predict.notlog)*array2[,2]

#array2[,2] <- array2adjusted

setwd(graphdirectory)
#write.table(array2, file="normalized_array2")

#The annotations file is a list of annotations containing the gene identifier somewhere in each annotation.
annotations = scan(file=annotationslist, what="list", sep="\n")

#The sequences should each cover a single line and come in the same order as the genes file. 
#sequences = read.table(file=allsequences)

#This is the cutoff hybridization intensity value used for calculating the bright probe fraction.
#cutoff = 150

#The following creates a vector of the number of probes for each gene.
probenums = vector()
for(i in 1:dim(genes)[1])
	{
	probes = grep(as.character(genes[i,]), array1[,1])
	probenums[i] = length(probes)
	}

# In the "probe_matrix" each row is a gene, and each column corresponds to the vertical location of the probes for that gene in the correct order in the array matrix. 
probe_matrix = matrix(nrow=dim(genes)[1],ncol=max(probenums))

for(i in 1:dim(genes)[1])
	{
	probes = grep(as.character(genes[i,]), array1[,1])
	for(j in 1:length(probes))
		{
		probe_matrix[i,j] = probes[j]
		}
	}

#This creates a "chunk matrix" ready to fill with the chunk (bright segment) lengths at each location, but starts out with filling it all with zeros
chunk_matrix1 = matrix(nrow=dim(genes)[1],ncol=max(probenums))

for(i in 1:dim(chunk_matrix1)[1])
	{
	for(j in 1:dim(chunk_matrix1)[2])
		{
		chunk_matrix1[i,j] = 0
		}
	}

#chunk_matrix2 = chunk_matrix1

bright_probe_fraction1 = vector()
#bright_probe_fraction2 = vector()

bright_gene_means1 = vector()
#bright_gene_means2 = vector()

bright_gene_medians1 = vector()
#bright_gene_medians2 = vector()

#For each chunk, the starting and stopping point along the sequence is defined in these two matrices...
start_chunk_blast1 = matrix(nrow=dim(genes)[1],ncol=max(probenums))
#start_chunk_blast2 = matrix(nrow=dim(genes)[1],ncol=max(probenums))
stop_chunk_blast1 = matrix(nrow=dim(genes)[1],ncol=max(probenums))
#stop_chunk_blast2 = matrix(nrow=dim(genes)[1],ncol=max(probenums))

#...so that this sequence_chunks matrix can be filled based on it
#sequence_chunks1 = matrix(nrow=dim(genes)[1],ncol=max(probenums))
#sequence_chunks2 = matrix(nrow=dim(genes)[1],ncol=max(probenums))


#This for loop goes through each gene one by one for array1...
for(i in 1:dim(genes)[1])
	{
	nochunk = 1
	gene = head(array1[probe_matrix[i,],2], n=probenums[i])
	gene_binary =vector(length=length(gene))
#... and then creates a "gene_binary" vector, where each probe is represented by a 1 or a 0 - 1 if it's above the cutoff line, 0 if it's below.
		for(j in 1:length(gene))
			{
				gene_binary[j] = ifelse(gene[j]>cutoff,1,0)
			}
if(sum(gene_binary>0))
{

bright_gene_values = vector(length=sum(gene_binary))
k=1
		for(j in 1:length(gene))
		{
			if(gene[j]>cutoff)
			{
				bright_gene_values[k] = as.numeric(gene[j])
				k=k+1
			}
		}
		bright_gene_means1[i] = mean(bright_gene_values)
		bright_gene_medians1[i] = median(bright_gene_values)
}

else
{
	bright_gene_means1[i] = 0
	bright_gene_medians1[i] = 0	
}
		chunk_coord=1

#Calculating the bright probe fraction is a simple question of summing the gene_binary vector and dividing by the total probe number length of the gene.
		bright_probe_fraction1[i] = sum(gene_binary)/probenums[i]

#This for loop fills out the chunk matrix.  It uses a "chunk_coord" or chunk coordinate to figure out how far along the chunk matrix it is.		
		for(j in 1:length(gene))
			{
#If the probe is bright...
			if(gene_binary[j] == 1)
				{
				chunk_matrix1[i,chunk_coord] = chunk_matrix1[i,chunk_coord] +1
#and a chunk is not currently being recorded, it adds one to the current chunk based on the chunk coordinate.					
					if(nochunk==1)
						{
						start_chunk_blast1[i, chunk_coord] = j*30 - 30
						nochunk = 0
						}
				} else
#If the probe is dark, it moves on in the gene and sets the nochunk variable back to 1 to stop recording a chunk.  In this way every probe below the line is recorded as a 0, but probes above the line are recorded in "chunks" or the length of continuous bright segments.
				{
				chunk_coord = chunk_coord + 1
					if(nochunk==0)
					{
					stop_chunk_blast1[i, chunk_coord-1] = (j-1)*30 + 30
					nochunk = 1
					} 
				}
			}

#If the last probe in the gene is bright, then it wraps up the chunk here for the stop_chunk_blast - otherwise there is not stop value inserted for these cases as the chunk seems to never end.
if(gene_binary[length(gene)] == 1)
{
stop_chunk_blast1[i, chunk_coord] = length(gene)*30
}			

#This fills out the sequence_chunks matrix, a matrix whose first column is gene identifiers, followed by the actual chunks of gene hybridization that have caused brightness.
#sequence_chunks1[i,1] = genes[i,]
#p=2
#for(j in 1:length(gene))
#	{
#	if(is.na(start_chunk_blast1[i,j]))
#	{next} else
#	{
#	sequence_chunks1[i,p] = substr(sequences[grep(genes[i,],sequences[,1]),2],start_chunk_blast1[i,j],stop_chunk_blast1[i,j])
#	p = p+1					
#	}	
#		}			
	}

#This next bit is vital - it takes the length of every chunk, and squares it! This is where the magic happens - chunks that are just one probe long will remain as one, but those that are 2 or greater will incraese in a non-linear fashion.
chunk_matrix_square1 = chunk_matrix1^2

#The squared chunk lengths are then used to make a chunk score
chunk_score1 = vector(length=dim(genes)[1])

for(i in 1:dim(genes)[1])
	{
	chunk_score1[i] <- sum(chunk_matrix_square1[i,])
	}

#The probe matrix is then sorted based on its chunk score - higher chunk scores go up the top.
probe_matrix_chunksort1 = probe_matrix[order(chunk_score1, decreasing=TRUE),]
probenums_chunksort1 = probenums[order(chunk_score1, decreasing=TRUE)]


#The chunk count matrix is used to figure out what number each chunk is, ie so if there are three bright segments in a gene, they can be labeled 1, 2, and 3.
chunk_count_matrix1 = matrix(nrow = dim(chunk_matrix1)[1], ncol = dim(chunk_matrix1)[2])

for(i in 1:dim(chunk_count_matrix1)[1])
	{
		for(j in 1:dim(chunk_count_matrix1)[2])
			{
			if(chunk_matrix1[i,j] == 0)
				{
				chunk_count_matrix1[i,j] = 0
				} else
					{
					chunk_count_matrix1[i,j] = 1
					}
			}
	}

chunk_number1 = sum(chunk_count_matrix1)

mean_probe_intensity1 = vector()

ordered_BPF = bright_probe_fraction1[order(bright_probe_fraction1, decreasing="TRUE")]
BPF_slopes = vector()

BPF_slopes_identifier = vector()

for(i in 1:length(ordered_BPF))
{
	BPF_slopes[i] = ordered_BPF[i] - ordered_BPF[i+smoothing_factor]
	BPF_slopes_identifier[i] = (ordered_BPF[i] + ordered_BPF[i+smoothing_factor])/2
	if(i==length(ordered_BPF)-smoothing_factor)
	{
		break
	}
}

maximum_slope = max(BPF_slopes)

for(i in 1:length(BPF_slopes))
{
	if(BPF_slopes[i]==maximum_slope)
	{
		cat("Recommended BPF threshold is",BPF_slopes_identifier[i],"based on a slope of",BPF_slopes[i]/smoothing_factor)
	}
}

#The rest is just data output, first of all plotting all the hybridization patterns and chunk scores to give an idea of the diversity in the sample.
cat("\\documentclass{article}\n\\usepackage{graphicx}\n\\usepackage{epstopdf}\n\\usepackage{color}\n\\usepackage{fullpage}\n\\begin{document}\n\\ttfamily", file = outputfile)
cat("Gene\tAnnotation\tMean Probe Intensity", array1name, "\tMedian Probe Intensity", array1name, "\tBright Segment Length Dependent Score", array1name, "\tBright Probe Fraction", array1name, "\tMean Bright Probe Intensity", array1name, "\tMedian Bright Probe Intensity", array1name, "\n", file = outputtable)

postscript(file = paste(graphdirectory,"bright_probe_fraction_plot.eps",sep="/"), width=9, height=5)
bpf_matrix = matrix(nrow =length(bright_probe_fraction1), ncol=1)
bpf_matrix[,1] = bright_probe_fraction1[order(bright_probe_fraction1)]
#bpf_matrix[,2] = bright_probe_fraction2[order(bright_probe_fraction2)]
matplot(bpf_matrix, type="l", ylab="Bright probe fraction", xlab="Genes on the chip", main="Bright Probe Fraction Distribution")
dev.off()
cat("\n\\includegraphics[angle=-90,width=15cm]{bright_probe_fraction_plot.eps}\\\\", file = outputfile, append=TRUE)


postscript(file = paste(graphdirectory,"chunk_score_plot.eps",sep="/"), width=9, height=5)
cs_matrix = matrix(nrow =length(chunk_score1), ncol=1)
cs_matrix[,1] = chunk_score1[order(chunk_score1)]
#cs_matrix[,2] = chunk_score2[order(chunk_score2)]
matplot(cs_matrix, type="l", ylab="Bright probe fraction", xlab="Genes on the chip", main="Bright Segment Length Dependent Score Distribution")
dev.off()
cat("\n\n\\includegraphics[angle=-90,width=15cm]{chunk_score_plot.eps}\\\\\n\\clearpage", file = outputfile, append=TRUE)
cat("\\begin{center}\n", file = outputfile, append=TRUE)



#Next up, the hybridization pattern for each gene is plotted individually...
for(i in 1:dim(genes)[1])
	{	
	straightline=vector(length=probenums_chunksort1[i])
	for(j in 1:probenums_chunksort1[i])
		{
			straightline[j]=cutoff
		}

temp_matrix = matrix(nrow =probenums_chunksort1[i], ncol=2)
temp_matrix[,1] = head(array1[probe_matrix_chunksort1[i,],2], n=probenums_chunksort1[i])
temp_matrix[,2] = straightline

postscript(file = paste(graphdirectory,paste(i,".eps",sep=""),sep="/"), width=9, height=5)

par(col="black")
matplot(log(temp_matrix), type="l", lwd="3", ylim = c(2,12),  xlab = "Distance along gene (probes)", ylab = "log hybridization intensity", lty=c(1,1,2), col=c("black","red","green"))
mean_probe_intensity1[i] = mean(temp_matrix[,1])

par(col="black")
par(ps=10)
chunknum = 1
for(j in 1:probenums_chunksort1[i])
	{
	if(is.na(start_chunk_blast1[order(chunk_score1, decreasing=TRUE)[i], j]))
		{next}else
		{
		text((start_chunk_blast1[order(chunk_score1, decreasing=TRUE)[i], j]+30)/30,12, labels=chunknum)
		chunknum = chunknum+1
		}
	}
dev.off()
cat(annotations[grep(genes[order(chunk_score1, decreasing=TRUE)[i],],annotations)], file = outputfile, append=TRUE)
cat("\\\\\n", file = outputfile, append=TRUE)
cat(paste("\n\\includegraphics[angle=-90,width=15cm]{",i,".eps}\\\\",sep=""), file = outputfile, append=TRUE)

cat("\\begin{tabular}{| l | l |}\n", file = outputfile, append=TRUE)
cat("\\hline\n", file = outputfile, append=TRUE)
cat(paste(genes[order(chunk_score1, decreasing=TRUE)[i],]," & ", array1name, " \\\\ \\hline\n"), file = outputfile, append=TRUE)
cat(paste("Mean Probe Intensity: &",round(mean(temp_matrix[,1]), digits=2),"\\\\\n"), file = outputfile, append=TRUE) 
cat(paste("Median Probe Intensity: &",round(median(temp_matrix[,1]), digits=2),"\\\\\n"), file = outputfile, append=TRUE) 
cat(paste("Bright Segment Length Dependent Score: &",chunk_score1[order(chunk_score1, decreasing=TRUE)[i]],"\\\\\n"), file = outputfile, append=TRUE) 
cat(paste("Bright Probe Fraction: &",round(100*bright_probe_fraction1[order(chunk_score1, decreasing=TRUE)[i]],digits=2),"\\%\\\\\n"), file = outputfile, append=TRUE) 
cat(paste("Mean of Bright Probes: &",round(bright_gene_means1[order(chunk_score1, decreasing=TRUE)[i]], digits=2),"\\\\\n"), file = outputfile, append=TRUE)
cat(paste("Median of Bright Probes: &",round(bright_gene_medians1[order(chunk_score1, decreasing=TRUE)[i]], digits=2),"\\\\\n"), file = outputfile, append=TRUE)
cat("\\hline\n\\end{tabular}\n", file = outputfile, append=TRUE)

cat(paste(genes[order(chunk_score1, decreasing=TRUE)[i],], annotations[grep(genes[order(chunk_score1, decreasing=TRUE)[i],],annotations)], mean(temp_matrix[,1]), median(temp_matrix[,1]), chunk_score1[order(chunk_score1, decreasing=TRUE)[i]], bright_probe_fraction1[order(chunk_score1, decreasing=TRUE)[i]], bright_gene_means1[order(chunk_score1, decreasing=TRUE)[i]], bright_gene_medians1[order(chunk_score1, decreasing=TRUE)[i]], sep="\t"), "\n", file = outputtable, append=TRUE)
	
cat("\n\\clearpage\n", file = outputfile, append=TRUE)	
}

cat("\n\\end{center}\n", file = outputfile, append=TRUE)


cat("\n\\end{document}", file = outputfile, append=TRUE)
}

