import pandas as pd


def json_to_excel_convertor(excel_file_path, output_file_path):
    pd.read_json(excel_file_path).to_excel(output_file_path)

