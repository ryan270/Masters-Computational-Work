#!/usr/bin/env Rscript

#then write to new fasta

#random number generator write to txt
write.table(sample(796338:815484, 470), file = 'new_samples.txt', sep = "",
            col.names = 'samples',row.names = FALSE, quote = FALSE)

#upload txt file
sample_list <- read.delim('new_samples.txt')
#paste ID name to sample number
for (x in 1:length(sample_list$samples)){
  sample_list[x,] <- paste0("SPI150_", sample_list$samples[x])
}
#export data
write.table(sample_list, file = '/Users/ade/Desktop/sample_list.txt', sep = "", quote = FALSE, row.names = FALSE)

#delete old file
file.remove('new_samples.txt')
