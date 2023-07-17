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
${ENDPOINT_AVAILABILITY}=  /direct/checkout_trip-request-handler/ajax-check-room-availability/
&{TRANSPORTATION}
...  BTS=3_5
...  VIE=3_6
&{MEAL}
...  All Inclusive=5
...  Bez stravy=4
...  Raňajky=6
...  Večera=9
...  Polpenzia=2
...  Plná penzia=1
...  Ultra All inclusive=11



*** Keywords ***
Call Invia API
    [Arguments]  ${start_from}  ${hotel_id}  ${duration_days}  ${meal}  ${transport}  ${adults}=2  ${children}=0  ${end_to}=${EMPTY}  ${tour_operator}=foreign
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
    ...            "nl_transportation_id":["${transport}"],
    ...            "nl_length_from":${duration_days},
    ...            "nl_length_to":${duration_days},
    ...            "nl_meal_id":["${meal}"],
    ...            "nl_occupancy_adults":${adults},
    ...            "nl_occupancy_children":${children},
    ...            "nl_ages_children":[],
    ...            "d_start_from":"${start_from}",
    ...            "d_end_to":"${end_to}",
    ...            "page":1,
    ...            "nl_tourop_id":[],
    ...            "domestic_tour_operator": "${tour_operator}",
    ...            "offsets":"",
    ...            "duration":"Custom range",
    ...            "nl_promotion_category_id":"",
    ...            "nl_hotel_id":${hotel_id}
    ...        },
    ...    "sorter":
    ...        {
    ...            "sort_ascent_by":"price"
    ...        }
    ...  }
    ${resp}=  POST On Session  Invia  ${ENDPOINT}  data=${body}   headers=${headers}  
    Should Be Equal As Strings  ${resp.status_code}  200  Response: status:${resp.status_code} (expected: 200) : ${resp.json()}

    Pretty Print Json  ${resp.text}
    [Return]  ${resp.json()}



Call Invia API Availability
    [Arguments]  ${type}  ${source_id}  ${offer_id}  ${hotel_id}  ${transportation_id}  ${total_price}  ${tourop_id}  ${tourop_code}  ${num_passenger}  ${num_children}  ${departure_date_from}  ${departure_date_to}  ${country_id}  ${locality_id}  ${referer}  ${length_days}=8  
    Update Session  Invia
    ${headers}=  Create Dictionary   content-type=application/json      
    ...                              x-invia-api-clientrequest-id=e45a1f8aead6f3d902507b473d3b7a78
    ...                              sec-ch-ua="Not.A/Brand";v="8", "Chromium";v="114", "Google Chrome";v="114"
    ...                              sec-ch-ua-mobile=?0
    ...                              sec-ch-ua-platform="Windows"
    ...                              user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36
    ...                              sec-fetch-dest=empty
    ...                              sec-fetch-mode=cors
    ...                              sec-fetch-site=same-origin
    ...                              origin=https://www.invia.sk
    ...                              authority=www.invia.sk
    ...                              accept=*/*
    ...                              accept-language=cs-CZ,cs;q=0.9,en;q=0.8,sk;q=0.7
    ...                              dnt=1
    ...                              referer=${referer}
    #https://www.invia.sk/hotel/cyprus/ayia-napa/nissi-beach/
    
    ${cookies}=  Create Dictionary  invia-user-uuid=58d5c02d-a830-4f6d-ad66-01406bb842e6
    ...                             CookieConsent={stamp:%27Z0qR5nZ6Bj4pu9CWtvqJDA5JWpM4feHnv7NZ0HpjoD4kRFuEVnWNsg==%27%2Cnecessary:true%2Cpreferences:true%2Cstatistics:true%2Cmarketing:true%2Cmethod:%27explicit%27%2Cver:1%2Cutc:1685690486352%2Cregion:%27cz%27}
    ...                             _dc_gtm_UA-8698717-3=1
    ...                             _gcl_au=1.1.1407120007.1685690488
    ...                             yottly-client-id=014c34a5-705c-46a8-a203-5d2deea012ba
    ...                             _fbp=fb.1.1685690490979.1369832604
    ...                             gtm-session-start-30=triggered
    ...                             terms_opened=1
    ...                             _uetvid=17ec1370011611ee8d680dc608ba4721
    ...                             cto_bundle=I4cuAV92RzNYaWVXdUk4WnRjYjRWdXRUVlczbCUyQlpqTElUdzNqNTBzd3lURmNxa2x3UHp0clRuNE54JTJGMXJmVUxUeSUyRkttY1FlajBwbzZKR1IlMkJYaVRUdmtHOExtZTVkNE1QNDAwJTJCTkNkRCUyQjdrdEpxWFRyTlQlMkYyUU5LcWZJS2Z1STBGVThmUlo2SlRPZSUyRnF2VWl6N3FuczdTeEVnJTNEJTNE
    ...                             _clck=o5u65i|2|fdd|0|1248
    ...                             _clsk=16lwqyp|1689619064523|2|1|w.clarity.ms/collect
    ...                             PHPSESSID=3ecabc08888483897644573483255f6f
    @{transport} =  Split String  ${transportation_id}  _
    ${body}=  Catenate
    ...  {
    ...    "tripData": {
    ...        "type": ${type},    
    ...        "s_offer_id": "${offer_id}",
    ...        "s_offer_source_id": "${source_id}",
    ...        "nl_form_type": 1,
    ...        "nl_tourop_id": ${tourop_id},
    ...        "s_offer_tourop_code": "${tourop_code}",
    ...        "nl_room_dict_id": null,
    ...        "nl_country_id": ${country_id},
    ...        "nl_tour_id": null,
    ...        "nl_locality_id": ${locality_id},
    ...        "s_departure_date_from": "${departure_date_from}",
    ...        "s_departure_date_to": "${departure_date_to}",
    ...        "nl_stay_length_days": ${length_days},    
    ...        "nl_hotel_id": ${hotel_id},
    ...        "nl_transportation_id": ${transport}[0],
    ...        "nl_airport_id": ${transport}[1],
    ...        "nl_departure_id": null,
    ...        "nl_total_price": ${total_price},
    ...        "passengers": {
    ...          "adults": ${num_passenger},
    ...          "children":  ${num_children},
    ...          "children_age":[],
    ...          "multipleRooms": false
    ...        },
    ...        "roomOccupancy": {
    ...            "adults": 0,
    ...            "children": 0
    ...        },    
    ...        "liveAAPC": true
    ...    }
    ...  }
    ${resp}=  POST On Session  Invia  ${ENDPOINT_AVAILABILITY}  data=${body}   headers=${headers}  cookies=${cookies}
    Pretty Print Json  ${resp.text}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.status_code}  200  Response: status:${resp.status_code} (expected: 200) : ${resp.json()}
    #Run Keyword And Continue On Failure  Should not contain  ${resp.text}  "statusCode":5000

    
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