import pandas as pd

# Load datasets
master = pd.read_csv("processed_data/BREAST_CANCER_MASTER.csv")
oncovar = pd.read_csv("processed_data/OncoVar_MASTER.csv")
bcga = pd.read_csv("processed_data/BCGA_Mutations_Final.csv")
intogen = pd.read_csv("processed_data/IntOGen_Clean.csv")
# Merge in order:
# 1. BREAST_CANCER_MASTER
# 2. OncoVar_ICGC
# 3. BCGA_Mutations_Final

merged = pd.concat(
    [master, oncovar, bcga, intogen],
    ignore_index=True,
    sort=False
)

# Remove exact duplicate rows
merged = merged.drop_duplicates()

# Desired column order
desired_columns = [
    "Database",

    "Gene",

    "Mutation",

    "Mutation_Type",

    "Mutation_Count",

    "No_of_Samples",

    "Mutation_Frequency"
]
# Add missing columns

for col in desired_columns:

    if col not in merged.columns:

        merged[col] = pd.NA
# Keep only columns that exist
existing_columns = [col for col in desired_columns if col in merged.columns]

merged = merged[existing_columns]

# Save output
output_file = "processed_data/BREAST_CANCER_INTEGRATED file.csv"
merged.to_csv(output_file, index=False)

print("=" * 50)
print("Integration completed successfully!")
print("=" * 50)
print(f"MASTER rows : {len(master)}")
print(f"OncoVar rows   : {len(oncovar)}")
print(f"BCGA rows   : {len(bcga)}")
print(f"IntOgen rows : {len(intogen)}")
print(f"FINAL rows  : {len(merged)}")

print(f"Saved file  : {output_file}")
print("=" * 50)

print("\nColumns in final file:")
print(merged.columns.tolist())