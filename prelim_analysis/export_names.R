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
info_table <- info_table[, c("Species", "common_names", "Paper", "Region",
                             "N")]
info_table <- info_table[order(info_table$Region), ]
write.table(info_table, file = "~/Documents/amphibian_meta_project/
            Data_Info.txt",
          row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE) # }}}
