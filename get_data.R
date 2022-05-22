# The code chunk which gets download/play counts from Internet Archive.

# Loading the libraries.
library(internetarchive)
library(tidyverse)
library(jsonlite)

# Getting the Treetrunk data from IA.
s_query <- c("collection" = "treetrunk")
treetrunk_names <- ia_search(s_query, num_results = 751)
treetrunk_list <- treetrunk_names %>% ia_get_items()

# Creating an empty data.frame for Treetrunk.
treetrunk_df <- data.frame(matrix(ncol = 5, nrow = length(treetrunk_names)))
colnames(treetrunk_df) <- c("Identifier", "Creator", "Title", "Downloads", "Date")

# Filling the data.frame with data. The metadata format changed a couple of times on IA
# between 2006 and 2013, or probably wasn't enforced strictly, producing
# 4 missing values for Creator. Imputing with the help of Title.
for (i in seq_along(treetrunk_names)) {
  treetrunk_df$Identifier[i] <- treetrunk_list[[treetrunk_names[i]]][["metadata"]][["identifier"]][[1]]
  treetrunk_df$Downloads[i] <- treetrunk_list[[treetrunk_names[i]]][["item"]][["downloads"]]
  treetrunk_df$Title[i] <- treetrunk_list[[treetrunk_names[i]]][["metadata"]][["title"]][[1]]
  treetrunk_df$Date[i] <- treetrunk_list[[treetrunk_names[i]]][["metadata"]][["publicdate"]][[1]]
  if (!is.null(treetrunk_list[[treetrunk_names[i]]][["metadata"]][["creator"]][[1]])) {
    treetrunk_df$Creator[i] <- treetrunk_list[[treetrunk_names[i]]][["metadata"]][["creator"]][[1]]
  } else {
    treetrunk_str <- treetrunk_list[[treetrunk_names[i]]][["metadata"]][["title"]][[1]] %>%
      str_split("-")
    treetrunk_df$Creator[i] <- treetrunk_str[[1]][[1]]
  }
}

# Saving the Treetrunk data.
write.csv(treetrunk_df, file = "treetrunk_data.csv")

# Getting the Midnight Radio data from IA.
s_query <- c("creator" = "midnightradio compilation")
midnight_names <- ia_search(s_query, num_results = 94)
midnight_list <- midnight_names %>% ia_get_items()

# Creating an empty data.frame for the Midnight Radio data.
midnight_df <- data.frame(matrix(ncol = 5, nrow = length(midnight_names)))
colnames(midnight_df) <- c("Identifier", "Creator", "Title", "Downloads", "Date")

# Filling this data.frame with data.
for (i in seq_along(midnight_names)) {
  midnight_df$Identifier[i] <- midnight_list[[midnight_names[i]]][["metadata"]][["identifier"]][[1]]
  midnight_df$Downloads[i] <- midnight_list[[midnight_names[i]]][["item"]][["downloads"]]
  midnight_df$Title[i] <- midnight_list[[midnight_names[i]]][["metadata"]][["title"]][[1]]
  midnight_df$Date[i] <- midnight_list[[midnight_names[i]]][["metadata"]][["publicdate"]][[1]]
  midnight_df$Creator[i] <- midnight_list[[midnight_names[i]]][["metadata"]][["creator"]][[1]]
}

# Saving the Midnight Radio data.
write.csv(midnight_df, file = "midnight_data.csv")

# Getting the MedMera data from Audius.
auJSON <- fromJSON("https://discoveryprovider.audius.co/v1/full/users/handle/medmera/tracks")

# Creating and filling the data.frame with data.
mm_df <- as.data.frame(cbind(
  auJSON[["data"]][["play_count"]],
  auJSON[["data"]][["title"]],
  auJSON[["data"]][["created_at"]]
))
colnames(mm_df) <- c("Plays", "Title", "Date")

# Saving the MedMera data.
write.csv(mm_df, file = "medmera_data.csv")
