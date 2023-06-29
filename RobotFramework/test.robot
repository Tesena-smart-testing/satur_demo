*** Settings ***
Library  RequestsLibrary
Library  JSONLibrary
Library  jsonLibrary.py
Library  excel_to_json_convertor.py
Library  json_to_excel_convertor.py
Library  String
Library  Collections
Library  OperatingSystem
Library  DateTime
Resource  helper.resource
Suite Setup  Create Session  Invia  ${HOST}  disable_warnings=1
Suite Teardown  Delete All Sessions
  

*** Test Cases ***
Get info
    @{output}=  Create List
    ${current_date}=  Get Current Date  result_format=%Y_%m_%d    
    ${excel_json}=  Excel To Json Convertor  input.xls      
    ${excel_string}=  Convert Json To String  ${excel_json}
    Pretty Print Json  ${excel_string}
    FOR  ${item}  IN  @{excel_json}  #go excel by rows
        log  ${item}
        ${hotel_id}  Get Hotel Id   ${item['URL']}
        #prepare and counting some values 
        ${date_from_orig}  Replace String  ${item['termin satur']}  /  .   #change date format
        ${date_from}=  Add Time To Date  ${date_from_orig}  time=${item['terminovy posun']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        ${date_to}=  Add Time To Date  ${date_from_orig}  time=${item['pocet noci']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        ${meal_id}=  Set Variable   ${MEAL['${item['strava']}']}                      
        ${transportation_id}=  Set Variable   ${TRANSPORTATION['${item['odlet']}']}        
        @{occupancies}=  Split String  ${item['PAX']}  +   #get number of adults and children from PAX
        ${adults}=  Set Variable  ${occupancies}[0]
        ${children}=  Set Variable  ${occupancies}[1]
        ${resp_json}=  Call Invia API     #call API with data from current row in excel
        ...                            start_from=${date_from}
        ...                            hotel_id=${hotel_id}  
        ...                            duration_days=${item['pocet noci']}
        ...                            meal=${meal_id}
        ...                            transport=${transportation_id}
        ...                            adults=${adults}   
        ...                            children=${children}
        ...                            end_to=${date_to}        
        ${cnt_data}=  Get Length  ${resp_json['data']}
        log  Pocet zaznamu: ${cnt_data}   #we can parse datas only from non-empty response
        ${current_timestamp}=  Get Current Date        
        IF  ${cnt_data} > 0
            FOR  ${dataItem}  IN  @{resp_json['data']}  #each "dates" field contains one tour
                log  ${dataItem}              
                log  priceGroup ${dataItem['priceGroup']}                
                log  pricePerPerson: ${dataItem['pricePerPerson']}
                log  meal: ${dataItem['meal']}
                log  OfferID: ${dataItem['favouriteData']['offerData']['offerId']}
                @{dateStart}=  Split String   ${dataItem['favouriteData']['offerData']['dateStart']}  T   #format: 2023-09-13T00:00:00+02:00
                @{dateEnd}=  Split String   ${dataItem['favouriteData']['offerData']['dateEnd']}  T
                ${resp_json_availability}=   Call Invia API Availability  #for each tour we should get info about availability
                ...                          type=1  
                ...                          source_id=${dataItem['favouriteData']['offerData']['offerSourceId']}
                ...                          offer_id=${dataItem['favouriteData']['offerData']['offerId']}  
                ...                          hotel_id=${hotel_id}
                ...                          transportation_id=${transportation_id}  
                ...                          total_price=${dataItem['priceGroup']}  
                ...                          tourop_id=${dataItem['favouriteData']['offerData']['tourOperatorId']}  
                ...                          num_passenger=2  
                ...                          departure_date_from=${dateStart}[0]
                ...                          departure_date_to=${dateEnd}[0]
                #TODO: save only available to output.   IF available=true
                #output: izba, CK, termin CK, cena za osobu, cena za zajezd, datum
                Log To Console  ${item['URL']} ; izba=${dataItem['roomType']} ; CK=${dataItem['tourOperatorNameForClient']} ; termin CK=${dataItem['outboundDate']}T${dataItem['outboundTimes']} - ${dataItem['returnDate']}T${dataItem['returnTimes']} ; priceGroup ${dataItem['priceGroup']}
                &{output_excel_row}=  Copy Dictionary  ${item}  #we use origin excel row and we can add values from result (as output)
                Set To Dictionary  ${output_excel_row}  izba=${dataItem['roomType']}  CK=${dataItem['tourOperatorNameForClient']}  termin CK=${dataItem['outboundDate']}T${dataItem['outboundTimes']}  cena za osobu=${dataItem['pricePerPerson']}  cena za zajezd=${dataItem['priceGroup']}  timestamp=${current_timestamp}
                log  ${output_excel_row}
                Append To List  ${output}  ${output_excel_row}   #add output excel row to do final output array
            END
        ELSE  #If we get empty result, to excel we put N/A values
            Log To Console  ${item['URL']} ; N/A , 0 records for date: ${date_from} - ${date_to} 
            &{output_excel_row}=  Copy Dictionary  ${item}
            Set To Dictionary  ${output_excel_row}  izba=N/A  CK=N/A  termin CK=N/A  cena za osobu=N/A  cena za zajezd=N/A  timestamp=${current_timestamp}
            log  ${output_excel_row}
            Append To List  ${output}  ${output_excel_row}    
        
        END
        
        
    END
    Log  ${output}  
    Log List  ${output}
    ${output_string}=  Convert Json To String  ${output}
    Pretty Print Json  ${output_string}
    Create File  data_output.json  ${output_string}
    Json To Excel Convertor  data_output.json  output_${current_date}.xlsx
