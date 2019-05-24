SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
country VARCHAR(50),
electoral_system VARCHAR(100),
single_party INT,
two_to_three INT,
four_to_five INT,
six_or_more INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW election_winners as
 SELECT election.id as election_id , election.country_id, cabinet_party.party_id
 FROM election JOIN cabinet
   ON election.id = cabinet.election_id
  JOIN cabinet_party
   ON cabinet.id = cabinet_party.cabinet_id
 WHERE cabinet_party.pm = true
 order by election.id;

create view find_head_id as
 	select alliance_id as id
 	from election_result
 	where alliance_id is not null

create view all_head_id as
	select election_id, party_id as head_id
	from election_result natural join find_head_id

create view alliance_with_head_id as
	select *
	from election_result natural join all_head_id

-- the answer to the query 
insert into q2 


