API_KEY="c2e3d491c93df52d1bd1722522cf56de"
CITY="Moscow"
UNITS="metric"
LANG="en"

data=$(curl -sf "https://api.openweathermap.org/data/2.5/weather?q=${CITY}&units=${UNITS}&lang=${LANG}&appid=${API_KEY}")
if [ ! "$data" ]; then
  echo "{}"
  exit 1
fi

temp=$(echo "$data" | jq ".main.temp" | cut -d "." -f 1)
desc=$(echo "$data" | jq -r ".weather[0].description")
icon=$(echo "$data" | jq -r ".weather[0].icon")

# Преобразование иконок в unicode
case $icon in
  01d) weather_icon="☀️" ;;
  01n) weather_icon="🌙" ;;
  02d|02n) weather_icon="⛅" ;;
  03d|03n|04d|04n) weather_icon="☁️" ;;
  09d|09n|10d|10n) weather_icon="🌧️" ;;
  11d|11n) weather_icon="🌩️" ;;
  13d|13n) weather_icon="❄️" ;;
  50d|50n) weather_icon="🌫️" ;;
  *) weather_icon="🌈" ;;
esac

echo "{\"temperature\": \"$temp\", \"description\": \"$desc\", \"icon\": \"$weather_icon\"}"

