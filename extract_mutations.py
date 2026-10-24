import pandas as pd
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)
file_path = "raw_data/cBioPortal/brca_tcga_pan_can_atlas_2018 3/data_mutations.txt"

df = pd.read_csv(
    file_path,
    sep="\t",
    comment="#",
    low_memory=False
)

mutation_table = (
    df.groupby(
        ["Hugo_Symbol",
         "HGVSp_Short",
         "Variant_Classification"]
    )["Tumor_Sample_Barcode"]
    .nunique()
    .reset_index()
)

mutation_table.columns = [
    "Gene",
    "Mutation",
    "Mutation_Type",
    "No_of_Samples"
]
mutation_table["Database"] = "TCGA_PanCancer"
mutation_table = mutation_table.sort_values(
    "No_of_Samples",
    ascending=False
)

print(mutation_table.head(20).to_string())

mutation_table.to_csv(
    "TCGA_PanCancer.csv",
    index=False
)

print("\nSaved as TCGA_PanCancer.csv")