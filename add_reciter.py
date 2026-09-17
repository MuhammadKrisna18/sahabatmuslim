import json

def add_alaa_aqel():
    with open('reciters.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Check if he is already there just in case
    for reciter in data['reciters']:
        if reciter['name'] == 'Alaa Aqel':
            print("Already exists.")
            return

    new_reciter = {
        "id": 999,
        "name": "Alaa Aqel",
        "letter": "A",
        "date": "2025-08-30T21:47:54.000000Z",
        "moshaf": [
            {
                "id": 9991,
                "name": "Rewayat Hafs A'n Assem - Murattal",
                "rewaya_id": 1,
                "server": "https://archive.org/download/AlaaAql/",
                "surah_total": 114,
                "moshaf_type": 11,
                "surah_list": ",".join(str(i) for i in range(1, 115))
            }
        ]
    }
    
    data['reciters'].append(new_reciter)
    
    # Sort by name if desired, or just append
    data['reciters'].sort(key=lambda x: x['name'])
    
    with open('reciters.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, separators=(',', ':'))
        
    print("Added Alaa Aqel successfully.")

add_alaa_aqel()
