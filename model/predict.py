# predict.py
import pandas as pd
import joblib
import sys
import ast

# Read command-line arguments
animal_name = sys.argv[1]  # e.g., "dog"
input_symptoms = ast.literal_eval(sys.argv[2])  # e.g., "['fever', 'vomiting']"

# Load model and columns
loaded_model = joblib.load('cat_and_dog_model_new.pkl')
with open("x_columns.txt", "r") as file:
    x_columns_loaded = [line.strip() for line in file.readlines()]

# Prepare input
input_row = pd.DataFrame(columns=x_columns_loaded)
input_row.loc[0] = 0

if animal_name in input_row.columns:
    input_row.at[0, animal_name] = 1

for symptom in input_symptoms:
    if symptom in input_row.columns:
        input_row.at[0, symptom] = 1

prediction = loaded_model.predict(input_row)
result = "Dangerous" if prediction[0] == 1 else "Not Dangerous"
print(result)
