# Description of script execution:

1. Open Excel file and read one defined row => Set variables for data in 'key:value' format
2. Parse data into JSON format 
3. For one Excel item, create a new endpoint with a body that includes props from `json.object[0]`
4. Call the endpoint => Save response to an intermediate result
5. Call the endpoint for checking availability => Save intermediate result of the available item into an Array of JSON
6. Repeat from step 1 for each Excel row
7. Parse JSON to output Excel file
