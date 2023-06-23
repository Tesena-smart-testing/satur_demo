*** Settings ***
Library  RequestsLibrary
Library  ExcelRobot
Library  JSONLibrary
Library  jsonLibrary.py
Library  excel_to_json_convertor.py
Library  String
Library  DateTime

*** Variables ***
${HOST}=      https://www.invia.sk
${ENDPOINT}=  /direct/tour_hotel/ajax-term-picker-data/?selectedTab=tours&useFilterForm=true

*** Keywords ***
Call Invia API
    [Arguments]  ${start_from}  ${hotel_id}  ${duration_days}   ${end_to}=${EMPTY}
    Update Session  Invia
    ${headers}=  Create Dictionary   Content-Type=text/plain;charset=UTF-8  
    ...                              X-Invia-Api-Trace-Id=0043d2eb9e5072867bc3f539bafc65fd
    ...                              x-invia-api-clientrequest-id=a4abe60a7b3e370f78199f027c6108b2
    ...                              Cookie="invia-user-uuid=58d5c02d-a830-4f6d-ad66-01406bb842e6"
    ...                              Sec-Ch-Ua="Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"
    ...                              User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36
    ${body}=  Catenate
    ...  {
    ...    "filter":
    ...        {
    ...            "nl_transportation_id":[],
    ...            "nl_length_from":${duration_days},
    ...            "nl_length_to":${duration_days},
    ...            "nl_meal_id":[],
    ...            "nl_occupancy_adults":2,
    ...            "nl_occupancy_children":0,
    ...            "nl_ages_children":[],
    ...            "d_start_from":"${start_from}",
    ...            "d_end_to":"${end_to}",
    ...            "page":1,
    ...            "nl_tourop_id":[],
    ...            "offsets":"",
    ...            "duration":"Custom",
    ...            "nl_promotion_category_id":"",
    ...            "nl_hotel_id":${hotel_id}
    ...        },
    ...    "sorter":
    ...        {
    ...            "sort_ascent_by":"date"
    ...        }
    ...  }
    ${resp}=  POST On Session  Invia  ${ENDPOINT}  data=${body}   headers=${headers}  
    Should Be Equal As Strings  ${resp.status_code}  200  Response: status:${resp.status_code} (expected: 200) : ${resp.json()}

    Pretty Print Json  ${resp.text}
    [Return]  ${resp.json()}



Call Invia API Availability
    [Arguments]  ${type}  ${source_id}  ${offer_id}  ${hotel_id}  ${transportation_id}  ${total_price}  ${tourop_id}  ${num_passenger}  ${departure_date_from}
    Update Session  Invia
    ${headers}=  Create Dictionary   Content-Type=text/plain;charset=UTF-8  
    ...                              X-Invia-Api-Trace-Id=e61cab8a1b2814778cf5ae701a2424be
    ...                              x-invia-api-clientrequest-id=7e1b21fd76343eb47dc41502aede6ae9
    ...                              Cookie="invia-user-uuid=0000-0000-0000-client_is_bot"
    ...                              Sec-Ch-Ua="Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"
    ...                              User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36
    ${body}=  Catenate
    ...  {
    ...    "tripData": {
    ...        "type": ${type},
    ...        "s_offer_source_id": "${source_id}",
    ...        "s_offer_id": "${offer_id}",
    ...        "nl_hotel_id": ${hotel_id},
    ...        "nl_transportation_id": ${transportation_id},
    ...        "nl_total_price": ${total_price},
    ...        "nl_tourop_id": ${tourop_id},
    ...        "passengers": {
    ...          "adults": ${num_passenger},
    ...          "multipleRooms": false
    ...        },
    ...        "s_departure_date_from": "${departure_date_from}",
    ...        "onlineUnavailableReason": ""
    ...    }
    ...  }
    ${resp}=  POST On Session  Invia  ${ENDPOINT}  data=${body}   headers=${headers}  
    Should Be Equal As Strings  ${resp.status_code}  200  Response: status:${resp.status_code} (expected: 200) : ${resp.json()}

    Pretty Print Json  ${resp.text}
    [Return]  ${resp.json()}


Get Hotel Id
    [Arguments]  ${ENDPOINT_HOTEL}
    [Documentation]  vyhleda ID hotelu z URL
    ${resp}=  GET On Session  Invia  ${ENDPOINT_HOTEL}
    Log  ${resp.text}
    ${line}=  Get Lines Containing String  ${resp.text}  ajax-get-hotel-detail-map
    Log  ${line}
    ${line}=  Remove String  ${line}  href="https://www.invia.sk/direct/tour_hotel/ajax-get-hotel-detail-map/nl_hotel_id/
    ${line}=  Remove String  ${line}  /"
    ${line}=  Strip String  ${line}  characters=${SPACE}
    ${hotelID}=  Set Variable  ${line.strip()}
    [Return]  ${hotelID}