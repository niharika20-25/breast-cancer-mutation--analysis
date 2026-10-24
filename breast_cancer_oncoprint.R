# Install packages once
install.packages(c(
  "tidyverse",
  "ComplexHeatmap",
  "circlize",
  "RColorBrewer"
))

library(tidyverse)
library(ComplexHeatmap)
library(circlize)
library(RColorBrewer)

# Load integrated dataset
data <- read.csv(
  "processed_data/BREAST_CANCER_INTEGRATED.csv",
  stringsAsFactors = FALSE
)

###################################################
# 1. Gene x Database Matrix for Oncoprint
###################################################

oncodata <- data %>%
  group_by(Gene, Database) %>%
  summarise(
    Mutation_Type = first(Mutation_Type),
    .groups = "drop"
  )

oncoprint_matrix <- oncodata %>%
  pivot_wider(
    names_from = Database,
    values_from = Mutation_Type,
    values_fill = ""
  )

gene_names <- oncoprint_matrix$Gene

oncoprint_matrix <- as.matrix(
  oncoprint_matrix[, -1]
)

rownames(oncoprint_matrix) <- gene_names

###################################################
# 2. Oncoprint
###################################################

alter_fun = list(
  background = function(x, y, w, h) {
    grid::grid.rect(
      x, y, w, h,
      gp = grid::gpar(fill = "#EEEEEE", col = NA)
    )
  },
  Missense_Mutation = function(x, y, w, h) {
    grid::grid.rect(
      x, y, w*0.9, h*0.9,
      gp = grid::gpar(fill = "red", col = NA)
    )
  }
)

pdf("Unified_Oncoprint.pdf", width=12, height=8)

oncoPrint(
  oncoprint_matrix,
  alter_fun = alter_fun,
  col = c(
    Missense_Mutation = "red"
  ),
  show_column_names = TRUE,
  show_row_names = TRUE
)

dev.off()

###################################################
# 3. Heatmap:
# Gene present in how many databases
###################################################

gene_db <- data %>%
  group_by(Gene) %>%
  summarise(
    Databases = n_distinct(Database)
  ) %>%
  arrange(desc(Databases))

mat <- as.matrix(gene_db$Databases)

rownames(mat) <- gene_db$Gene

pdf("Gene_Database_Heatmap.pdf",
    width=6,
    height=10)

Heatmap(
  mat,
  name = "Databases",
  cluster_rows = TRUE,
  cluster_columns = FALSE
)

dev.off()

###################################################
# 4. Top mutated genes
###################################################

top_genes <- data %>%
  group_by(Gene) %>%
  summarise(
    Total_Samples = sum(No_of_Samples)
  ) %>%
  arrange(desc(Total_Samples)) %>%
  slice(1:20)

ggplot(
  top_genes,
  aes(
    reorder(Gene, Total_Samples),
    Total_Samples
  )
) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_bw() +
  labs(
    title="Top Mutated Genes",
    x="Gene",
    y="Number of Samples"
  )

ggsave(
  "Top_Mutated_Genes.pdf",
  width=8,
  height=6
)

###################################################
# 5. Mutation percentage
###################################################

total_samples <- sum(data$No_of_Samples)

mutation_percent <- data %>%
  group_by(Gene) %>%
  summarise(
    Samples = sum(No_of_Samples)
  ) %>%
  mutate(
    Percentage =
      round((Samples/total_samples)*100,2)
  ) %>%
  arrange(desc(Percentage))

write.csv(
  mutation_percent,
  "Mutation_Percentage_Table.csv",
  row.names = FALSE
)

###################################################
# 6. Mutation Type Distribution
###################################################

ggplot(
  data,
  aes(Mutation_Type)
) +
  geom_bar() +
  theme_bw() +
  coord_flip() +
  labs(
    title="Mutation Type Distribution"
  )

ggsave(
  "Mutation_Type_Distribution.pdf",
  width=8,
  height=6
)

cat("Analysis completed successfully\n")