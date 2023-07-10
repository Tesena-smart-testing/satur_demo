import json
import mysql.connector

def send_data_to_db(jsonfile="data_output.json",dbhost="localhost",dbuser="root",dbpassword="Create1234+",database_name="Satur"):
    # Read the JSON file
    with open(jsonfile) as file:
        data = json.load(file)

    # Connect to MySQL database
    db = mysql.connector.connect(
        host=dbhost,
        user=dbuser,
        password=dbpassword,
        database=database_name
    )
    cursor = db.cursor()


    # Iterate over the data and insert into MySQL
    for item in data:
        hotel = item['hotel']
        url = item['url']
        termin_satur = item['termin satur']
        terminovy_posun = item['terminovy posun']
        pocet_noci = item['pocet noci']
        pax = item['PAX']
        strava = item['strava']
        odlet = item['odlet']
        tuzemske_ck = item['tuzemske CK']
        max_pocet_vysledkov = item['max pocet vysledkov']
        izba = item['izba']
        ck = item['CK']
        termin_ck = item['termin CK']
        cena_za_osobu = item['cena za osobu']
        cena_za_zajezd = item['cena za zajezd']
        timestamp = item['timestamp']

        # Construct the SQL query
        query = "INSERT INTO Satur (Hotel, URL, termin_satur, terminovy_posun, pocet_noci, PAX, strava, odlet, tuzemske_ck, max_pocet_vysledkov, izba, CK, termin_ck, cena_za_osobu, cena_za_zajezd, timestamp) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        values = (hotel, url, termin_satur, terminovy_posun, pocet_noci, pax, strava, odlet, tuzemske_ck, max_pocet_vysledkov, izba, ck, termin_ck, cena_za_osobu, cena_za_zajezd, timestamp)

        # Execute the query
        cursor.execute(query, values)
        db.commit()

    # Close the database connection
    db.close()


