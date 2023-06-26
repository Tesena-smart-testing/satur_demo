*** Settings ***
Library    OperatingSystem

*** Test Cases ***
Convert String to JSON and Save to File
    ${str}=    Set Variable    {"email": "1234@gmail.com"}
    ${json}=    Evaluate    json.loads($str)
    ${formatted_json}=    Evaluate    json.dumps($json, indent=4)

    # Append the JSON object to a file
    Append To File    json_output.json    ${formatted_json}
