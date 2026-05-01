CREATE DATABASE DEMO;

USE DATABASE DEMO;

CREATE OR REPLACE SCHEMA DEMO_SCHEMA;

CREATE OR REPLACE WAREHOUSE DEMO_WAREHOUSE
  WITH WAREHOUSE_SIZE = 'XLARGE'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE;

CREATE OR REPLACE STAGE DEMO.DEMO_SCHEMA.WEATHER_STAGE
  URL = 's3://snowflake-workshop-lab/weather-nyc/'
  FILE_FORMAT = (TYPE = 'JSON' STRIP_OUTER_ARRAY = TRUE)
  COMMENT = 'External stage for NYC weather data JSON files';

LIST @DEMO.DEMO_SCHEMA.WEATHER_STAGE;

CREATE OR REPLACE TABLE DEMO.DEMO_SCHEMA.WEATHERTABLE (data variant);

COPY INTO DEMO.DEMO_SCHEMA.WEATHERTABLE
  FROM @DEMO.DEMO_SCHEMA.WEATHER_STAGE;

SELECT 
data:city:findname,
data:city:coord:lat,
data:city:coord:lon,
data:clouds:all,
data:main:humidity,
data:main:pressure,
data:main:temp,
data:time,
data:weather[0]:main 
FROM DEMO.DEMO_SCHEMA.WEATHERTABLE;

CREATE OR REPLACE TABLE DEMO.DEMO_SCHEMA.WEATHER (
	CITYNAME STRING,
	LAT FLOAT,
	LON FLOAT,
	CLOUDS INTEGER,
	HUMIDITY INTEGER,
	PRESSURE FLOAT,
	TEMP FLOAT,
	TIME TIMESTAMP,
	WEATHER STRING
	);

SELECT
t.$1,
t.$1:city:findname,
t.$1:city:coord:lat,
t.$1:city:coord:lon,
t.$1:clouds:all,
t.$1:main:humidity,
t.$1:main:pressure,
t.$1:main:temp,
t.$1:time,
t.$1:weather[0]:main
FROM @DEMO.DEMO_SCHEMA.WEATHER_STAGE t;

COPY INTO DEMO.DEMO_SCHEMA.WEATHER
	FROM
	(
	select
	t.$1:city:findname,
	t.$1:city:coord:lat,
	t.$1:city:coord:lon,
	t.$1:clouds:all,
	t.$1:main:humidity,
	t.$1:main:pressure,
	t.$1:main:temp,
	t.$1:time,
	t.$1:weather[0]:main
	FROM @DEMO.DEMO_SCHEMA.weather_stage t);