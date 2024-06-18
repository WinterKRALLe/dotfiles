import requests

def get_weather(api_key, lat, lon):
    base_url = "http://api.openweathermap.org/data/2.5/weather"
    params = {
        "lat": lat,
        "lon": lon,
        "appid": api_key,
        "units": "metric"
    }
    response = requests.get(base_url, params=params)
    weather_data = response.json()
    return weather_data

def print_weather(weather_data):
    main_weather = weather_data['weather'][0]['main']
    temp = round(weather_data['main']['temp'], 1)
    print(f"{main_weather}  {temp}˚C")

weather_data = get_weather('6f49735ca7c4f562dbd3984472be8b00', '49.114201', '17.726521')
print_weather(weather_data)

