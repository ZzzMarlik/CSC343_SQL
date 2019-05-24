-- Scenario: 1 parliamentary election, 2 parties with vote diff < 10 %. 
-- expected result: one rows with 


insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-1950', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');

insert into party values (0, 0, 'p1', 'p1', 'd1');
insert into party values (1, 0, 'p2', 'p2', 'd2');

insert into     election_result values (0, 0, 0, NULL, 300, 12100000, 'd1');
insert into     election_result values (1, 0, 1, NULL, 300, 12000000, 'd1');

insert into     cabinet values (0, 0, '01-01-1950', 'n1', 'wiki', 'd1', 'c1', NULL, 0);

insert into     cabinet_party values (0, 0, 0, true, 'd1');

-- results of query
--  electionid | countryname | winningparty | closerunnerup 
-- ------------+-------------+--------------+---------------
--           0 | c1          | p1           | p2