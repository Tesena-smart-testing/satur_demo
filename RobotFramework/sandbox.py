import os
import pandas as pd
from datetime import datetime
import json_to_excel_convertor
import excel_to_json_convertor

# Determine the current directory
current_directory = os.path.dirname(os.path.abspath(__file__))

# Specify the relative paths to the files
excel_file_path1 = 'RobotFramework/input.xls'
sheet_name1 = 'Sheet1'
output_file_path1 = os.path.join(current_directory, 'sample.json')
output_file = os.path.join(current_directory, 'output_file.xlsx')


def automate():
    try:
        excel_to_json_convertor.excel_to_json_convertor(excel_file_path1, sheet_name1, output_file_path1)
        json_to_excel_convertor.json_to_excel_convertor(output_file_path1, output_file)
        print("Automation completed successfully!")
    except Exception as e:
        print(f"An error occurred during automation: {str(e)}")

automate()
