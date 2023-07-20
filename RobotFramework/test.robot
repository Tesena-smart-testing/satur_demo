*** Settings ***
Library  RequestsLibrary
Library  JSONLibrary
Library  jsonLibrary.py
Library  excel_to_json_convertor.py
Library  json_to_excel_convertor.py
Library  send_data_to_db.py
Library  String
Library  Collections
Library  OperatingSystem
Library  DateTime
Resource  helper.resource
Suite Setup  Create Session  Invia  ${HOST}  disable_warnings=1
Suite Teardown  Delete All Sessions

*** Variables ***
#MySQL configuration
${DBHOST}=  localhost
${DBUSER}=  root
${DBPASS}=  Create1234+
${DBNAME}=  Satur


*** Test Cases ***
Get info
    Log to console  -- Start script --
    @{output}=  Create List
    ${current_date}=  Get Current Date  result_format=%Y_%m_%d    
    ${current_timestamp}=  Get Current Date
    ${excel_json}=  Excel To Json Convertor  input.xls      
    ${excel_string}=  Convert Json To String  ${excel_json}
    Pretty Print Json  ${excel_string}
    FOR  ${item}  IN  @{excel_json}  #go excel by rows
        log  ${item}
        ${hotel_id}  Get Hotel Id   ${item['url']}
        #prepare and counting some values 
        ${date_from_orig}  Replace String  ${item['termin satur']}  /  .   #change date format
        ${date_from}=  Add Time To Date  ${date_from_orig}  time=${item['terminovy posun']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        ${date_to}=  Add Time To Date  ${date_from_orig}  time=${item['pocet noci']} days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        #${date_to}=  Add Time To Date  ${date_to}  time=1 days  date_format=%d.%m.%Y  result_format=%d.%m.%Y
        ${meal_id}=  Set Variable   ${MEAL['${item['strava']}']}                      
        ${transportation_id}=  Set Variable   ${TRANSPORTATION['${item['odlet']}']}        
        IF  ${item['tuzemske CK']} == 1
            ${CK} =  Set Variable  domestic
        ELSE  
            ${CK} =  Set Variable  foreign
        END
        @{occupancies}=  Split String  ${item['PAX']}  +   #get number of adults and children from PAX
        ${adults}=  Set Variable  ${occupancies}[0]
        ${children}=  Set Variable  ${occupancies}[1]
        IF  ${children} == 1
            ${children_age} =  Set Variable  9
        ELSE IF  ${children} == 2
            ${children_age} =  Set Variable  9,9
        ELSE 
            ${children_age} =  Set Variable  ${EMPTY}
        END        
        ${pocet_vysledku}=  Set Variable  ${item['max pocet vysledkov']}
        ${resp_json}=  Call Invia API     #call API with data from current row in excel
        ...                            start_from=${date_from}
        ...                            hotel_id=${hotel_id}  
        ...                            duration_days=${item['pocet noci']}
        ...                            meal=${meal_id}
        ...                            transport=${transportation_id}
        ...                            adults=${adults}   
        ...                            children=${children}
        ...                            children_age=${children_age}
        ...                            end_to=${date_to}
        ...                            tour_operator=${CK}        
        ${cnt_data}=  Get Length  ${resp_json['data']}
        log  Pocet zaznamu: ${cnt_data}   #we can parse datas only from non-empty response                
        IF  ${cnt_data} > 0
            ${pocitadlo}=  Set Variable  0
            FOR  ${dataItem}  IN  @{resp_json['data']}  #each "dates" field contains one tour
                log  ${dataItem}                              
                log  priceGroup ${dataItem['priceGroup']}                
                log  pricePerPerson: ${dataItem['pricePerPerson']}
                log  meal: ${dataItem['meal']}
                log  OfferID: ${dataItem['favouriteData']['offerData']['offerId']}
                @{dateStart}=  Split String   ${dataItem['favouriteData']['offerData']['dateStart']}  T   #format: 2023-09-13T00:00:00+02:00
                @{dateEnd}=  Split String   ${dataItem['favouriteData']['offerData']['dateEnd']}  T                
                ${resp_json_availability}=   Call Invia API Availability
                ...                          type=1  
                ...                          source_id=${dataItem['favouriteData']['offerData']['offerSourceId']}
                ...                          offer_id=${dataItem['favouriteData']['offerData']['offerId']}  
                ...                          hotel_id=${hotel_id}
                ...                          transportation_id=${transportation_id}  
                ...                          total_price=${dataItem['priceGroup']}  
                ...                          tourop_id=${dataItem['favouriteData']['offerData']['tourOperatorId']}  
                ...                          tourop_code=${dataItem['favouriteData']['offerData']['offerTouropCode']}  
                ...                          num_passenger=${adults}  
                ...                          num_children=${children}  
                ...                          departure_date_from=${dateStart}[0]  
                ...                          departure_date_to=${dateEnd}[0]  
                ...                          country_id=${dataItem['favouriteData']['offerData']['countryId'][0]}
                ...                          locality_id=${dataItem['favouriteData']['offerData']['localityId'][0]}
                ...                          referer=${item['url']}
                ...                          length_days=${item['pocet noci']}       
                ...                          children_age=${children_age}         
                ${available}=  Set Variable  ${resp_json_availability['customData']['isAvailable']}
                IF  ${available}
                    #output: izba, CK, termin CK, cena za osobu, cena za zajezd, datum
                    Log To Console  ${item['hotel']} ; izba=${dataItem['roomType']} ; CK=${dataItem['tourOperatorNameForClient']} ; termin CK=${dataItem['outboundDate']}T${dataItem['outboundTimes']} - ${dataItem['returnDate']}T${dataItem['returnTimes']} ; priceGroup ${dataItem['priceGroup']} ; PAX ${item['PAX']}
                    ${pocitadlo}=  Set Variable  ${pocitadlo} + 1
                    &{output_excel_row}=  Copy Dictionary  ${item}  #we use origin excel row and we can add values from result (as output)
                    Set To Dictionary  ${output_excel_row}  izba=${dataItem['roomType']}  CK=${dataItem['tourOperatorNameForClient']}  termin CK=${dataItem['outboundDate']}T${dataItem['outboundTimes']}  cena za osobu=${dataItem['pricePerPerson']}  cena za zajezd=${dataItem['priceGroup']}  timestamp=${current_timestamp}
                    log  ${output_excel_row}
                    Append To List  ${output}  ${output_excel_row}   #add output excel row to do final output array
                    IF  ${pocitadlo} == ${pocet_vysledku}                        
                        BREAK
                    END
                END                
            END
            IF  ${pocitadlo} == 0  #all tours for this row were unavailable , write empty data to output                       
                Log To Console  ${item['hotel']} ; N/A , 0 records for date: ${date_from} - ${date_to} , PAX ${item['PAX']}
                &{output_excel_row}=  Copy Dictionary  ${item}
                Set To Dictionary  ${output_excel_row}  izba=N/A  CK=N/A  termin CK=N/A  cena za osobu=0  cena za zajezd=0  timestamp=${current_timestamp}
                log  ${output_excel_row}
                Append To List  ${output}  ${output_excel_row}
            END
        ELSE  #If we get empty result, to excel we put N/A values
            Log To Console  ${item['hotel']} ; N/A , 0 records for date: ${date_from} - ${date_to} , PAX ${item['PAX']}
            &{output_excel_row}=  Copy Dictionary  ${item}
            Set To Dictionary  ${output_excel_row}  izba=N/A  CK=N/A  termin CK=N/A  cena za osobu=0  cena za zajezd=0  timestamp=${current_timestamp}
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
    Send Data To Db  jsonfile=data_output.json  dbhost=${DBHOST}  dbuser=${DBUSER}  dbpassword=${DBPASS}  database_name=${DBNAME}
    
    
