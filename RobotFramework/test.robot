*** Settings ***
Library  RequestsLibrary
Library  ExcelRobot
Library  SeleniumLibrary
Library  JSONLibrary
Library  jsonLibrary.py
Suite Setup  Create Session  Invia  ${HOST}  disable_warnings=1
#Suite Teardown  Save Excel

*** Variables ***
${HOST}=      https://www.invia.sk
${ENDPOINT}=  /direct/tour_hotel/ajax-term-picker-data/?selectedTab=tours&useFilterForm=true


*** Keywords ***
Call Invia API
    [Arguments]  ${start_from}  ${end_to}  ${hotel_id}
    ${headers}=  Create Dictionary   Content-Type=text/plain;charset=UTF-8  x-invia-api-clientrequest-id=a4abe60a7b3e370f78199f027c6108b2
    ${body}=  Catenate
    ...  {
    ...    "filter":
    ...        {
    ...            "nl_transportation_id":[],
    ...            "nl_length_from":7,
    ...            "nl_length_to":10,
    ...            "nl_meal_id":[],
    ...            "nl_occupancy_adults":2,
    ...            "nl_occupancy_children":0,
    ...            "nl_ages_children":[],
    ...            "d_start_from":"${start_from}",
    ...            "d_end_to":"${end_to}",
    ...            "page":1,
    ...            "nl_tourop_id":[],
    ...            "offsets":"",
    ...            "duration":"7-10 days",
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

Get Hotel Id
    [Arguments]  ${ENDPOINT_HOTEL}
    [Documentation]  vyhleda ID hotelu z URL
    [Teardown]  Close All Browsers
    Open Browser  ${HOST}${ENDPOINT_HOTEL}  chrome
    ${datafilter_str}=  SeleniumLibrary.Get Element Attribute   //div[@id="js-tour-term-picker-container"]  data-filter    
    ${datafilter_json}=  JSONLibrary.Convert String To Json  ${datafilter_str}
    ${hotelid}=  JSONLibrary.Get Value From Json  ${datafilter_json}  $.nl_hotel_id
    log  ${datafilter_json}
    ${hotelid}=  Set Variable  ${datafilter_json['nl_hotel_id']}    
    [Return]  ${hotelid}
    

*** Test Cases ***
Get info
    Open Excel   input.xls
    ${hotel_id}=  Get Hotel Id  /hotel/egypt/sharm-el-sheikh/sunrise-montemare-resort-grand-select/
    ${resp_json}=  Call Invia API  start_from=10.06.2023  end_to=17.06.2023  hotel_id=111337    
    ${pocet_radku}    Get Row Count  Sheet1
    FOR  ${radek}  IN RANGE  2  ${pocet_radku}+1
        ${URL_Hote}       Read Cell Data By Name  Sheet1  A${radek}
        ${DateFrom}  Read Cell Data By Name  Sheet1  B${radek}
        ${DateTo}    Read Cell Data By Name  Sheet1  C${radek}
        ${Strava}    Read Cell Data By Name  Sheet1  D${radek}
        ${Doprava}   Read Cell Data By Name  Sheet1  E${radek}
        ${hotel_id}  Get Hotel Id  ${URL_Hote} 
        ${resp_json}=  Call Invia API  start_from=${DateFrom}  end_to=${DateTo}  hotel_id=${hotel_id}
        log  priceGroup ${resp_json['data'][0]['priceGroup']}
        log  pricePerPerson: ${resp_json['data'][0]['pricePerPerson']}
        log  meal: ${resp_json['data'][0]['meal']}
        #Write To Cell By Name  Sheet1  F${radek}  1${radek}        
    END
#//div[@id="js-tour-term-picker-container"]  a zde atribut data-filter obsahuje n1_hotel_id