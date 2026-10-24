import pandas as pd
import glob

files = glob.glob("processed_data/*.csv")

dfs = []

for file in files:
    print("Loading:", file)
    dfs.append(pd.read_csv(file))

master_df = pd.concat(dfs, ignore_index=True)


gene_rank = (
    master_df.groupby("Gene")["No_of_Samples"]
    .max()
    .sort_values(ascending=False)
)

master_df["Gene"] = pd.Categorical(
    master_df["Gene"],
    categories=gene_rank.index,
    ordered=True
)

master_df = master_df.sort_values(
    by=["Gene", "No_of_Samples"],
    ascending=[True, False]
)
master_df["Database"] = "cBioPortal"
master_df.to_csv(
    "processed_data/BREAST_CANCER_MASTER.csv",
    index=False
)

print("\nDatasets merged:", len(files))
print("Total rows:", len(master_df))
print("Saved as BREAST_CANCER_MASTER.csv")