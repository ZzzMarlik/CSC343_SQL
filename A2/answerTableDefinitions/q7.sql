SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.
-- http://rextester.com/MDAU39411 for testing

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
partyId INT, 
partyFamily VARCHAR(50) 
);


DROP VIEW IF EXISTS election_winners CASCADE;
DROP VIEW IF EXISTS winners_with_alliances CASCADE;
DROP VIEW IF EXISTS all_winners_with_alliance CASCADE;
DROP VIEW IF EXISTS all_winners CASCADE;
DROP VIEW IF EXISTS all_winner_with_win_time CASCADE;
DROP VIEW IF EXISTS epe_distinct_date CASCADE;
DROP VIEW IF EXISTS epe_date CASCADE;
DROP VIEW IF EXISTS strong_party_candidate CASCADE;
DROP VIEW IF EXISTS strong_party CASCADE;
DROP VIEW IF EXISTS strong_party_with_family CASCADE;


-- get all winning parties with the cabinet id
CREATE VIEW election_winners AS
SELECT election.id AS election_id , cabinet_party.party_id AS party_id, cabinet.id AS cabinet_id
FROM election JOIN cabinet ON election.id = cabinet.election_id
    JOIN cabinet_party ON cabinet.id = cabinet_party.cabinet_id
WHERE cabinet_party.pm = true;

-- get the winners with the alliances' infomation
CREATE VIEW winners_with_alliances AS
SELECT election_winners.election_id AS election_id, election_winners.party_id AS party_id, alliance_id, election_result.id AS e_result_id, cabinet_id
FROM election_winners JOIN election_result ON (election_winners.election_id = election_result.election_id AND election_winners.party_id = election_result.party_id);


-- alliances of winners
CREATE VIEW all_winners_with_alliance AS
SELECT election_result.election_id as election_id, election_result.party_id as party_id, cabinet_id
FROM winners_with_alliances JOIN election_result ON (winners_with_alliances.party_id <> election_result.party_id AND winners_with_alliances.election_id = election_result.election_id)
WHERE ((winners_with_alliances.alliance_id IS NOT NULL) AND (election_result.alliance_id = winners_with_alliances.alliance_id OR election_result.id = winners_with_alliances.alliance_id))
OR ((winners_with_alliances.alliance_id IS NULL) AND (election_result.alliance_id = winners_with_alliances.e_result_id));

-- all PE winners from all types
CREATE VIEW all_winners AS
(SELECT election_id, party_id, cabinet_id FROM winners_with_alliances)
UNION
(SELECT * FROM all_winners_with_alliance);


-- all PE winners with their win time
CREATE VIEW all_winner_with_win_time AS
SELECT party_id, e_date AS election_date
FROM all_winners JOIN election ON election_id = election.id;


-- all EPE distinct times
CREATE VIEW epe_distinct_date AS
SELECT DISTINCT e_date AS election_date
FROM election
WHERE e_type = 'European Parliament';

-- assign each distinct EPE time a row number by time order
CREATE VIEW epe_date_with_row_num AS
SELECT election_date, ROW_NUMBER() OVER (ORDER BY election_date) AS row_num,
 total_epe.epe_num AS epe_num
FROM epe_distinct_date, (SELECT count(*) AS epe_num FROM epe_distinct_date) AS total_epe;


-- Find potential strong parties
CREATE VIEW potential_strong_party AS
SELECT party_id, e2.row_num AS epe2_row_id, e2.epe_num AS epe_num
FROM all_winner_with_win_time, epe_date_with_row_num e1, epe_date_with_row_num e2
WHERE (e1.row_num = 1 AND e2.row_num = 1
            AND all_winner_with_win_time.election_date < e1.election_date) --- must win before first epe
    AND (e1.row_num + 1 = e2.row_num AND all_winner_with_win_time.election_date >= e1.election_date
            AND all_winner_with_win_time.election_date < e2.election_date); --- win all the election between two epe

-- actual strong parties: number of rows of strong_party_canadidate that belong to the party must match
-- with the number of EP election
CREATE VIEW strong_party AS
SELECT DISTINCT party_id
FROM potential_strong_party
GROUP BY party_id
HAVING (max(epe_num) = count(DISTINCT epe2_row_id));

-- get party families
CREATE VIEW strong_party_with_family AS
SELECT DISTINCT party_family.party_id AS partyID, family AS partyFamily
FROM strong_party, party_family
WHERE strong_party.party_id = party_family.party_id;


-- the answer to the query 
insert into q7 SELECT * FROM strong_party_with_family;
