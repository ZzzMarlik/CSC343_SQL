DROP SCHEMA IF EXISTS carschema CASCADE;
CREATE SCHEMA carschema;

SET SEARCH_PATH TO carschema;

CREATE TABLE q3(
	MODEL_NAME TEXT
);

DROP VIEW IF EXISTS intermediate_step CASCADE;

CREATE VIEW all_fit_cars_with_frequency AS
    SELECT car_id, count(car_id) as frequency
    FROM reservation JOIN car ON reservation.car_id = car.id
    JOIN rentalstation ON rentalstation.station_code = car.station_code
    WHERE '2017-01-01 00:00:00' <= reservation.from_date and reservation.from_date < '2018-01-01 00:00:00' and rentalstation.city = 'Toronto'
    GROUP BY car_id;

CREATE VIEW answer AS
    SELECT model.name as MODEL_NAME
    FROM all_fit_cars_with_frequency JOIN car ON all_fit_cars_with_frequency.car_id = car.id
    JOIN model ON all_fit_cars_with_frequency.model_id = model.id
    HAVING max(frequency);

INSERT INTO q3 SELECT * FROM answer;