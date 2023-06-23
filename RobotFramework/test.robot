*** Settings ***
Library  RequestsLibrary
Library  ExcelRobot
Library  JSONLibrary
Library  jsonLibrary.py
Library  excel_to_json_convertor.py
Library  String
Library  DateTime
Resource  helper.resource
Suite Setup  Create Session  Invia  ${HOST}  disable_warnings=1
Suite Teardown  Delete All Sessions
  

*** Test Cases ***
Get info    
    ${excel_json}=  Excel To Json Convertor  input.xls    
    FOR  ${item}  IN  @{excel_json}
        log  ${item}
        ${hotel_id}  Get Hotel Id   ${item['URL']}
        ${date_from}  Replace String  ${item['termin satur']}  /  .   #change date format
        ${date_to}=  Add Time To Date  ${date_from}  time=${item['pocet noci']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y            
        ${resp_json}=  Call Invia API  start_from=${date_from}  duration_days=${item['pocet noci']}  end_to=${EMPTY}  hotel_id=${hotel_id}        
        ${cnt_data}=  Get Length  ${resp_json['data']}
        log  Pocet zaznamu: ${cnt_data}
        IF  ${cnt_data} > 0
            FOR  ${dataItem}  IN  @{resp_json['data']}                
                log  priceGroup ${dataItem['priceGroup']}
                Log To Console  priceGroup ${dataItem['priceGroup']}
                log  pricePerPerson: ${dataItem['pricePerPerson']}
                log  meal: ${dataItem['meal']}
            END
                
        
        END
        
        
    END    
    