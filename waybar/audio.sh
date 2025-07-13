#!/bin/bash

# Функция для получения списка приложений с ID и громкостью
get_apps() {
  pactl list sink-inputs | awk -v RS= -F'\n' '
  {
    id=""; name=""; vol=""
    for(i=1;i<=NF;i++) {
      if ($i ~ /^Sink Input #/) {match($i, /Sink Input #([0-9]+)/, a); id=a[1]}
      else if ($i ~ /application.name = /) {match($i, /"([^"]+)"/, a); name=a[1]}
      else if ($i ~ /node.name = / && name=="") {match($i, /"([^"]+)"/, a); name=a[1]}
      else if ($i ~ /Volume:/ && vol=="") {
        match($i, /([0-9]+)%/, a)
        vol=a[1]
      }
    }
    if (id != "") print id "|" name "|" vol
  }
  '
}

# Главное меню — выбор приложения
selected=$(get_apps | awk -F'|' '{printf "%s %s%%\n", $2, $3}' | wofi --dmenu --prompt="Выбери приложение:")

if [[ -z "$selected" ]]; then
  exit 0
fi

# Извлечь имя приложения из выбранного
app_name=$(echo "$selected" | awk '{print $1}')

# Найти ID выбранного приложения
app_id=$(get_apps | grep "|$app_name|" | head -n1 | cut -d'|' -f1)

# Получить текущую громкость
current_vol=$(get_apps | grep "|$app_name|" | head -n1 | cut -d'|' -f3)

# Запрашиваем новую громкость с шагом 5%
new_vol=$(seq 0 5 100 | awk -v cur="$current_vol" '{printf "%03d %s%s\n", $1, ($1==cur?"* ":"  "), $1"%"}' | wofi --dmenu --prompt="Громкость $app_name (текущая: $current_vol%):")

if [[ -z "$new_vol" ]]; then
  exit 0
fi

# Извлечь число громкости из выбранного варианта
vol_num=$(echo "$new_vol" | awk '{print $1}' | sed 's/^0*//')
if [[ -z "$vol_num" ]]; then vol_num=0; fi

# Установить громкость выбранного приложения
pactl set-sink-input-volume "$app_id" "${vol_num}%"
