require "./digest_auth_client.rb"

UTC_OFFSET = ENV.fetch("UTC_OFFSET", 2)
START_DATE = ENV.fetch("START_DATE", "#{Date.today.year}-1-1")
END_DATE = ENV.fetch("END_DATE", "#{Date.today.year}-12-31")

def get(path)
  DigestAuthClient.new(
    base_uri: "https://s18.myenergi.net",
    auth: {
      user: ENV["ZAPPI_USERNAME"],
      password: ENV["ZAPPI_PASSWORD"]
    }
  ).get(path)
end

date_range = Date.parse(START_DATE)..Date.parse(END_DATE)

date_range.each do |date|
  kwh_high = 0
  kwh_low = 0

  formatted_date = date.strftime("%F")
  data = get("/cgi-jdayhour-#{ENV.fetch("ZAPPI_DEVICE_ID")}-#{formatted_date}").first[1]

  data.each do |row|
    hour = (row["hr"].to_i || 0) + UTC_OFFSET

    if (hour >= 21 || hour < 7) || (date.wday == 6 || date.wday == 0) # night or weekend (sat = 6, sun = 0)
      # low rate
      kwh_low += row["h1d"] || 0
      kwh_low += row["h2d"] || 0
      kwh_low += row["h3d"] || 0
    else
      kwh_high += row["h1d"] || 0
      kwh_high += row["h2d"] || 0
      kwh_high += row["h3d"] || 0
    end
  end

  puts "#{formatted_date},#{kwh_low/3600000.0},#{kwh_high/3600000.0}"
end
