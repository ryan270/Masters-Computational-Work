## EXPORT NAMES: Create a summarized table of the metadata
setwd("~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/")
ampm <- read.table(file = "merged_metadata.txt", sep = "\t", header = TRUE)

## STANDARDIZE DATA FOR EACH REGION
# Create vectors for Sample sizes & Species
se_d <- data.frame(Paper = "Ellison et al., 2018", # SE Dataset
                   Species = "Rana Sierrae",
                   Region = "Sierra Nevada",
                   N = 130)

# MG Dataset
mg_spp <- unique(ampm$Species[which(ampm$Dataset == "Ellison et al., 2017")])
mg_sam <- NULL
for (i in mg_spp) {
    ph <- length(which(ampm$Species == i))
    mg_sam <- c(mg_sam, ph)
}
mg_d <- data.frame(Paper = "Ellison et al., 2017",
                   Species = mg_spp,
                   Region = "Central America",
                   N = mg_sam)

# SPI Dataset
spi_reg <- unique(ampm$State_Region[which(ampm$Dataset ==
                                          "Prado-Irwin et al., 2017")])
spi_sam <- numeric()
for (i in 1:4) {
    ph <- length(which(ampm$Species == "Ensatina_eschscholtzii" &
                       ampm$State_Region == spi_reg[i] &
                       ampm$Dataset == "Prado-Irwin et al., 2017"))
    spi_sam <- c(spi_sam, ph)
}
spi_d <- data.frame(Paper = "Prado-Irwin et al., 2017",
                    Species = "Ensatina eschscholtzii",
                    Region = spi_reg,
                    N = spi_sam)

# AB dataset
ab_spp <- unique(ampm$Species[which(ampm$Dataset ==
                                    "Bird et al., 2018")])
ab_reg <- unique(ampm$State_Region[which(ampm$Dataset == "Bird et al., 2018")])
ab_d <- data.frame(Species = c(ab_spp[1], ab_spp[1], ab_spp[2], ab_spp[3],
                                ab_spp[4], ab_spp[4], ab_spp[4], ab_spp[4]),
                    Region = c(ab_reg[1], ab_reg[2], ab_reg[3], ab_reg[1],
                               ab_reg[1], ab_reg[2], ab_reg[3], ab_reg[4]),
                    N = c(5, 15, 4, 8, 10, 39, 2, 13),
                    Paper = "Bird et al., 2018")

# Cleanup
rm(ab_spp, ab_reg, spi_sam, spi_reg, mg_sam, mg_spp, ph, se_reg) 

## {{{ MERGE, FORMAT, WRITE TABLE
info_table <- rbind(ab_d, mg_d, se_d, spi_d)
for (i in seq_len(info_table)) {
    info_table$Species[i] <- gsub("_", " ", info_table$Species[i])
}
info_table <- info_table[order(info_table$Paper), ]
info_table$common_names <-
    c("California Slender Salamander",
      "California Slender Salamander",
      "Gregarious Slender Salamander",
      "Santa Lucia Mountains Slender Salamander",
      "Ensatina Salamanders", "Ensatina Salamanders",
      "Ensatina Salamanders", "Ensatina Salamanders",
      "Tropical Lungless Salamanders",
      "Royal False Brook Salamander", "Neotropical Salamanders",
      "Spikethumb Frogs", "Spikethumb Frogs",
      "Guatemalan Bromeliad Salamander",
      "Climbing Salamander Hybrid", "Volcan Tacana Toad",
      "Sierra Nevada Yellow-Legged Frog",
      "Tropical Lungless Salamanders",
      "Franklin's Climbing Salamander", "Spikethumb Frogs",
      "Brittle-belly Frogs",  "Spikethumb Frogs",
      "Neotropical Salamander", "Brittle-belly Frogs",
      "Ensatina Salamanders", "Ensatina Salamanders",
      "Ensatina Salamanders", "Ensatina Salamanders")
info_table <- info_table[, c("Species", "common_names", "Paper", "Region", "N")]
info_table <- info_table[order(info_table$Region), ]
write.table(info_table, file = "~/Documents/amphibian_meta_project/
            Data_Info.txt",
          row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE) # }}}
