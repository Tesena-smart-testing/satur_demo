# import pandas as pd
# import json
# from datetime import datetime

# # Read the Excel file
# excel_data_df = pd.read_excel('C:/Users/mulyu/OneDrive/Obrázky/satur_demo/RobotFramework/input.xls', sheet_name='Sheet1')

# # Convert the Excel data to a list of dictionaries
# data = excel_data_df.to_dict(orient='records')

# # Convert datetime objects to strings
# for item in data:
#     for key, value in item.items():
#         if isinstance(value, datetime):
#             item[key] = value.strftime('%d/%m/%Y')

# # Write the JSON to a file
# with open("sample.json", "w") as outfile:
#     json.dump(data, outfile)

# print('Excel data converted to JSON and saved to sample.json')



import pandas as pd
import json
from datetime import datetime

excel_file_path1 = 'C:/Users/mulyu/OneDrive/Obrázky/satur_demo/RobotFramework/input.xls'
sheet_name1 = 'Sheet1'
output_file_path1 = 'sample.json'

def excel_to_json_convertor(excel_file_path, sheet_name, output_file_path):
    # Read the Excel file
    excel_data_df = pd.read_excel(excel_file_path, sheet_name=sheet_name)

    # Convert the Excel data to a list of dictionaries
    data = excel_data_df.to_dict(orient='records')

    # Convert datetime objects to strings
    for item in data:
        for key, value in item.items():
            if isinstance(value, datetime):
                item[key] = value.strftime('%d/%m/%Y')

    # Write the JSON to a file
    with open(output_file_path, "w") as outfile:
        json.dump(data, outfile)

print('Excel data converted to JSON and saved to', output_file_path1)





excel_to_json_convertor(excel_file_path1, sheet_name1, output_file_path1)



