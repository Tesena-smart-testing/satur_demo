import pandas as pd

excel_file = "C:/Users/mulyu/OneDrive/Obrázky/satur_demo/sample.json"
output_file = "output_file.xlsx"

def json_to_excel_convertor(excel_file_path, output_file_path):
    pd.read_json(excel_file_path).to_excel(output_file_path)


json_to_excel_convertor(excel_file,output_file)