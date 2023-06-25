import pandas as pd


def json_to_excel_convertor(json_file_path, output_file_path):
    pd.read_json(json_file_path).to_excel(output_file_path)

