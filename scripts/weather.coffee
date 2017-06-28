
module.exports = (robot) ->
  robot.respond /tenki|てんき|天気|weather|うぇざー|ウェザー/i, (msg) ->
    robot.http('http://api.openweathermap.org/data/2.5/forecast?q=Kawasaki,jp&APPID=38c8e3f51b7a904a46067f36c9d4f44b')
    .get() (err, res, body) ->
      if err
        msg.send "sorry, failed"

      json = JSON.parse body
      datalists = json['list']
      weathers = []
      storedDay = 0
      for data in datalists
        date = data['dt_txt']
        # year = date[0..3]
        month = parseInt("#{date[5..6]}", 10)
        day = parseInt(date[8..9], 10)
        hour = parseInt("#{date[11..12]}", 10)
        if storedDay == 0 || storedDay != day
          storedDay = day
          weathers.push(">*#{month}月#{day}日*")

        weather = "#{data['weather'][0]['main']}"
        weatherString = (weather) ->
          if weather == 'Clear'
            '晴れ'
          else if weather == 'Clouds'
            '曇り'
          else if weather == 'Rain'
            '雨'
          else
            "登録されていない天気です（#{weather}）"

        icon = (weather) ->
          if weather == 'Clear'
            ':sunny:'
          else if weather == 'Clouds'
            ':cloud:'
          else if weather == 'Rain'
            ':rain_cloud:'
          else
            'sorry, i cannot understand :cry:'

        main = data['main']
        tempNum = parseFloat("#{main['temp']}")
        temperature = (tempNum) ->
          num = (tempNum - 273.15) * 100
          Math.round(num) / 100

        humidity = parseInt("#{main['humidity']}", 10)

        if hour % 6 == 0
          if hour == 18
            weathers.push(">- #{hour}時, #{weatherString(weather)} #{icon(weather)},気温: #{temperature(tempNum)}℃, 湿度: #{humidity}％\n")
          else
            weathers.push(">- #{hour}時, #{weatherString(weather)} #{icon(weather)},気温: #{temperature(tempNum)}℃, 湿度: #{humidity}％")

      msg.send "#{weathers.join("\n")}"
      # msg.send "#{dateStrings}, #{weatherString(weather)}, #{icon(weather)}"

# dt_txt    : 日時
# clouds:
#   all: 雲量
#
# main:
#   grnd_level: 気圧
#   humidity  : 湿度
#   pressure  : 気圧(grnd_levelと同値。謎)
#   temp      : 気温
#
# rain:
#   3h: 過去3時間で降った量
#
# sys:
#   pod: d->day, n->night
#
# weather:
#   main:
