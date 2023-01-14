# Ruby Zappi

This scripts generates a day-to-day CSV-like overview of the kWhs charged through your [Zappi V2][2]. It differentiates 
for two (high and low) tariffs. Example:

```csv
2022-01-01,13.301355555555556,0.0
2022-01-02,0.0,0.0
2022-01-03,0.0,0.0
```

## Gotchas

* I've written the script to support my local differentiated tariffs. For me this means a low tariff between 21:00 and 7:00
and on weekends. If you have no differentiated tariffs you can just combine both fields. If you have different cutoffs
you'll have to edit the script to suit your needs.
* This is based on knowledge from the Zappi forum and similar integrations in other languages. It can probably break
at any moment. I do not guarantee correctness of the data.

## Run the script

You need to set three ENV variables to run the script:

* `ZAPPI_DEVICE_ID`, the ID of your Zappi's serial number, prefixed with Z.
* `ZAPPI_USERNAME`, your Hub's serial number.
* `ZAPPI_PASSWORD`, the API key you can set in the [MyEnergi web interface][1] under "Advanced" for your Hub.

`$ ZAPPI_DEVICE_ID=... ZAPPI_USERNAME=... ZAPPI_PASSWORD=... ruby zappi.rb`

Optionally you can set:

* `UTC_OFFSET` o customize the timezone offset. The data is in UTC. By default offset is 2, since that's my timezone.
* `START_DATE` to customize the start date. By default it runs from the start of the current year. Format:
  YYYY-MM-DD or anything Ruby accepts.
* `END_DATE` to customize the end date. By default it runs to the end of the current year. Same format as `START_DATE`.

[1]: https://myaccount.myenergi.com/location#products
[2]: https://www.myenergi.com/zappi-ev-charger/
