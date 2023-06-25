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
        ${date_from_orig}  Replace String  ${item['termin satur']}  /  .   #change date format
        ${date_from}=  Add Time To Date  ${date_from_orig}  time=${item['terminovy posun']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        ${date_to}=  Add Time To Date  ${date_from_orig}  time=${item['pocet noci']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        ${meal_id}=  Set Variable   ${MEAL['${item['strava']}']}                      
        ${transportation_id}=  Set Variable   ${TRANSPORTATION['${item['odlet']}']}
        @{occupancies}=  Split String  ${item['PAX']}  +   #get number of adults and children from PAX
        ${adults}=  Set Variable  ${occupancies}[0]
        ${children}=  Set Variable  ${occupancies}[1]
        ${resp_json}=  Call Invia API  
        ...                            start_from=${date_from}
        ...                            hotel_id=${hotel_id}  
        ...                            duration_days=${item['pocet noci']}
        ...                            meal=${meal_id}
        ...                            transport=${transportation_id}
        ...                            adults=${adults}   
        ...                            children=${children}
        ...                            end_to=${date_to}        
        ${cnt_data}=  Get Length  ${resp_json['data']}
        log  Pocet zaznamu: ${cnt_data}
        IF  ${cnt_data} > 0
            FOR  ${dataItem}  IN  @{resp_json['data']}
                log  ${dataItem}              
                log  priceGroup ${dataItem['priceGroup']}                
                log  pricePerPerson: ${dataItem['pricePerPerson']}
                log  meal: ${dataItem['meal']}
                log  OfferID: ${dataItem['favouriteData']['offerData']['offerId']}
                ${resp_json_availability}=   Call Invia API Availability  
                ...                          type=1  
                ...                          source_id=${dataItem['favouriteData']['offerData']['offerSourceId']}
                ...                          offer_id=${dataItem['favouriteData']['offerData']['offerId']}  
                ...                          hotel_id=${hotel_id}
                ...                          transportation_id=${transportation_id}  
                ...                          total_price=${dataItem['priceGroup']}  
                ...                          tourop_id=${dataItem['favouriteData']['offerData']['tourOperatorId']}  
                ...                          num_passenger=2  
                ...                          departure_date_from=
                
                #output: izba, CK, termin CK, cena za osobu, cena za zajezd, datum
            END
                
        
        END
        
        
    END    
    