#!/bin/bash
echo "🔄 Generating .strings files from Excel..."

cd "$(dirname "$0")"

# ✅ 필요한 패키지 설치
echo "📦 Installing required Python packages..."
pip3 install --quiet --upgrade pip
pip3 install --quiet -r requirements.txt

python3 - <<EOF
import pandas as pd
import os

input_excel = "localization_20_languages.xlsx"
output_root = "strings_output"

os.makedirs(output_root, exist_ok=True)
df = pd.read_excel(input_excel)

for lang in df.columns[1:]:
    lang_dir = os.path.join(output_root, f"{lang}.lproj")
    os.makedirs(lang_dir, exist_ok=True)
    strings = []
    for _, row in df.iterrows():
        key = row["key"]
        value = row[lang]
        if pd.notna(value):
            strings.append(f'\\"{key}\\" = \\"{value}\\";')
    with open(os.path.join(lang_dir, "Localizable.strings"), "w", encoding="utf-8") as f:
        f.write("\\n".join(strings))

print("✅ Done! Output is in ./strings_output/")
EOF
