SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
electionId INT, 
countryName VARCHAR(50),
winningParty VARCHAR(100),
closeRunnerUp VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_winners CASCADE;
DROP VIEW IF EXISTS alliances_votes CASCADE;
DROP VIEW IF EXISTS head_with_total_votes CASCADE;
DROP VIEW IF EXISTS alliance_with_total_votes CASCADE;
DROP VIEW IF EXISTS winners_with_head_id CASCADE;
DROP VIEW IF EXISTS single_with_total_votes CASCADE;
DROP VIEW IF EXISTS all_head_votes CASCADE;
DROP VIEW IF EXISTS single_winners CASCADE;
DROP VIEW IF EXISTS all_winners_with_total_votes CASCADE;
DROP VIEW IF EXISTS winners_with_runnerup CASCADE;
DROP VIEW IF EXISTS winners_with_runnerup_name CASCADE;
DROP VIEW IF EXISTS add_country_name CASCADE;
DROP VIEW IF EXISTS final_answer CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW election_winners as
 SELECT election.id as election_id , election.country_id, cabinet_party.party_id
 FROM election JOIN cabinet
   ON election.id = cabinet.election_id
  JOIN cabinet_party
   ON cabinet.id = cabinet_party.cabinet_id
 WHERE cabinet_party.pm = true
 order by election.id ;

create view alliances_votes as
	select alliance_id as id, coalesce(sum(votes),0) as num_votes
	from election_result
	where alliance_id is not null
	group by alliance_id;

create view head_with_total_votes as
	select election_id, id as alliance_id, party_id as head_id, num_votes + coalesce(votes, 0) as total_votes
	from election_result join alliances_votes using(id);

create view alliance_with_total_votes as
	select election_result.election_id, party_id as member_id, head_id, total_votes
	from head_with_total_votes join election_result on head_with_total_votes.alliance_id = election_result.alliance_id and head_with_total_votes.election_id = election_result.election_id;

create view winners_with_head_id as
	select election_winners.election_id, head_id as party_id, total_votes, country_id
	from alliance_with_total_votes join election_winners on alliance_with_total_votes.election_id = election_winners.election_id
	 and ((election_winners.party_id = alliance_with_total_votes.member_id) or (election_winners.party_id = alliance_with_total_votes.head_id));

create view single_with_total_votes as
	select election_id, party_id, votes as total_votes, country_id
	from election_result join election on (election_result.election_id = election.id)
	where election_result.alliance_id is NULL and election_result.id NOT IN (select alliance_id from head_with_total_votes);

create view all_head_votes as
	(select election_id, head_id, total_votes from alliance_with_total_votes) union (select election_id, party_id as head_id, total_votes from single_with_total_votes);

create view single_winners as
	select election_id, party_id, total_votes, country_id
	from single_with_total_votes natural join election_winners;

create view all_winners_with_total_votes as
	(select * from winners_with_head_id) union (select * from single_winners);

create view not_winners as
	select all_head_votes.election_id, all_head_votes.head_id, all_head_votes.total_votes
	from all_winners_with_total_votes join all_head_votes using(election_id)
	where all_head_votes.head_id <> all_winners_with_total_votes.head_id

create view winners_with_runnerup as
	select not_winners.election_id, party_id, country_id, max(not_winners.total_votes) as runnerup_votes
	from all_winners_with_total_votes join not_winners on all_winners_with_total_votes.election_id = not_winners.election_id
	where (not_winners.total_votes > all_winners_with_total_votes.total_votes * 0.9) and (not_winners.total_votes < all_winners_with_total_votes.total_votes)
	group by not_winners.election_id, all_winners_with_total_votes.party_id, all_winners_with_total_votes.country_id;

create view winners_with_runnerup_name as
	select election_id, party_id as winner_id, country_id, head_id as runnerup_id
	from winners_with_runnerup join all_head_votes using(election_id)
	where all_head_votes.total_votes = winners_with_runnerup.runnerup_votes;

create view add_country_name as
	select election_id as electionId, country.name as countryName, winner_id, runnerup_id
	from winners_with_runnerup_name join country on country.id = country_id;

create view final_answer as
	select electionId, countryName, p1.name as winningParty, p2.name as closeRunnerUp
	from add_country_name join party p1 on p1.id = winner_id join party p2 on p2.id = runnerup_id;

-- the answer to the query 
insert into q5 select * from final_answer;
