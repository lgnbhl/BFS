# Swiss Stats Explorer fixtures

Real responses of the SSE API, used by `test-offline.R` so the tests see
what the API really sends (e.g. the attribute `DATAFLOW` with the same id as
the first SDMX-CSV column). To refresh them:

```sh
B="https://disseminate.stats.swiss/rest"
curl -s -H "Accept: application/xml" \
  "$B/dataflow/all/DF_LWZ_1/1.1.0?references=datastructure" | sed '/<!--NSI/d' \
  > structure-DF_LWZ_1.xml
curl -s --compressed -H "Accept-Language: en" \
  -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0;labels=both" \
  "$B/data/CH1.LWZ,DF_LWZ_1,1.1.0/ZH+ZG._T._T.OBS.A?startPeriod=2025" > data-DF_LWZ_1-both.csv
curl -s --compressed -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" \
  "$B/data/CH1.LWZ,DF_LWZ_1,1.1.0/ZH+ZG._T._T.OBS.A?startPeriod=2025" > data-DF_LWZ_1-code.csv
```

The tests expect 2025 and 2026 values: update them if the data is revised.
