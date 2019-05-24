SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
century VARCHAR(2),
country VARCHAR(50), 
left_right REAL, 
state_market REAL, 
liberty_authority REAL
);


DROP VIEW IF EXISTS election_winners CASCADE;
DROP VIEW IF EXISTS winners_with_alliance_info CASCADE;
DROP VIEW IF EXISTS all_winners_alliance CASCADE;
DROP VIEW IF EXISTS all_winners CASCADE;
DROP VIEW IF EXISTS winners_country_party CASCADE;
DROP VIEW IF EXISTS PE_twentieth_per_cabinet CASCADE;
DROP VIEW IF EXISTS PE_twentieth_ans CASCADE;
DROP VIEW IF EXISTS PE_twenty_first_per_cabinet CASCADE;
DROP VIEW IF EXISTS PE_twenty_first_ans CASCADE;
DROP VIEW IF EXISTS q1_ans CASCADE;

-- get all of the winning parties based on the cabinet
CREATE VIEW election_winners AS
SELECT election.id AS election_id , cabinet_party.party_id AS party_id, cabinet.id AS cabinet_id
FROM election JOIN cabinet
	    ON election.id = cabinet.election_id
    JOIN cabinet_party
	    ON cabinet.id = cabinet_party.cabinet_id
WHERE cabinet_party.pm = true;

-- associate winners with their own alliance_id and election_result_id info
CREATE VIEW winners_with_alliance_info AS
SELECT election_winners.election_id AS election_id, election_winners.party_id AS party_id, alliance_id,
    election_result.id AS e_result_id, cabinet_id
FROM election_winners, election_result
WHERE election_winners.election_id = election_result.election_id AND
    election_winners.party_id = election_result.party_id;

-- alliances of winners
CREATE VIEW all_winners_alliance AS
SELECT election_result.election_id AS election_id, election_result.party_id AS party_id, cabinet_id
-- keep rows if they belong to the same election as winner but not winner
FROM winners_with_alliance_info JOIN election_result ON
    (winners_with_alliance_info.election_id = election_result.election_id AND
    winners_with_alliance_info.party_id <> election_result.party_id)
-- if winner is head -> alliance must have aliance_id = winner's id
-- if winner is not head and has alliance -> alliance' alliance_id must be the same or head's id = alliance_id
WHERE (winners_with_alliance_info.alliance_id IS NULL --AND election_result.alliance_id IS NOT NULL
     AND election_result.alliance_id = winners_with_alliance_info.e_result_id) OR (winners_with_alliance_info.alliance_id
     IS NOT NULL AND (election_result.alliance_id = winners_with_alliance_info.alliance_id OR
     election_result.id = winners_with_alliance_info.alliance_id));

-- all parliamentary election winners from all types of govt
CREATE VIEW all_winners AS
(SELECT election_id, party_id, cabinet_id FROM winners_with_alliance_info)
UNION
(SELECT * FROM all_winners_alliance);

-- get country info and party info of all winners
CREATE VIEW winners_country_party AS
SELECT election.id AS election_id, e_date AS election_date, name, left_right, state_market, liberty_authority,
	cabinet_id
FROM all_winners, election, country, party_position
WHERE all_winners.election_id = election.id AND election.country_id = country.id AND
    party_position.party_id = all_winners.party_id;

-- get per-cabinet avg party info
CREATE VIEW PE_twentieth_per_cabinet AS
SELECT '20'::text AS century, name AS country, avg(left_right) AS left_right, avg(state_market) AS state_market,
--SELECT name AS country, avg(left_right) AS left_right, avg(state_market) AS state_market,
    avg(liberty_authority) AS liberty_authority
FROM winners_country_party
WHERE election_date >= '1901-01-01' AND election_date <= '2000-12-31'
GROUP BY election_id, cabinet_id, name;

-- get answer for 20th century
CREATE VIEW PE_twentieth_ans AS
SELECT century, country, avg(left_right) AS left_right, avg(state_market) AS state_market,
    avg(liberty_authority) AS liberty_authority
FROM PE_twentieth_per_cabinet
GROUP BY century, country;

-- get per-cabinet avg party info
CREATE VIEW PE_twenty_first_per_cabinet AS
SELECT '21'::text AS century, name AS country, avg(left_right) AS left_right, avg(state_market) AS state_market,
--SELECT name AS country, avg(left_right) AS left_right, avg(state_market) AS state_market,
    avg(liberty_authority) AS liberty_authority
FROM winners_country_party
WHERE election_date >= '2001-01-01' AND election_date <= '2100-12-31'
GROUP BY election_id, cabinet_id, name;

-- get answer for 21st century parliamentary elections
CREATE VIEW PE_twenty_first_ans AS
SELECT century, country, avg(left_right) AS left_right, avg(state_market) AS state_market,
    avg(liberty_authority) AS liberty_authority
FROM PE_twenty_first_per_cabinet
GROUP BY century, country;

CREATE VIEW q1_ans AS
(SELECT * FROM PE_twentieth_ans)
UNION ALL
(SELECT * FROM PE_twenty_first_ans);

-- the answer to the query
insert into q1 SELECT DISTINCT * FROM q1_ans;

