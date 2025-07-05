use ipl;
show tables;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
#1. The percentage of wins of each bidder in the order of highest to lowest percentage.
select * from ipl_bidding_details;
select bidder_id, bid_status, round((sum(case when bid_status ='Won' then 1 else 0 end)*100)/count(*),2) as win_percent
from ipl_bidding_details 
group by bidder_id, bid_status 
order by win_percent desc;

#2.	Display the number of matches conducted at each stadium with the stadium name and city.
select * from ipl_stadium;     
select s.stadium_name, s.city,
 count(m.stadium_id) as total_matches
 from ipl_stadium s join ipl_match_schedule m
 using (stadium_id)
 group by s.stadium_name, s.city;

#3.	In a given stadium, what is the percentage of wins by a team that has won the toss?
select * from ipl_match;
select toss_winner,
round(sum(case when toss_winner=match_winner then 1 else 0 end)*100/count(*),2) as win_percent
from ipl_match
group by toss_winner;
#4.	Show the total bids along with the bid team and team name
select * from ipl_bidding_details;
select count(b.bidder_id) total_bids , b.bid_team, t.team_name from
ipl_bidding_details b
 join ipl_team t 
on b.bid_team=t.team_id
group by b.bid_team, t.team_name;
 
 #5.	Show the team ID who won the match as per the win details.
 select * from ipl_team_standings;
 select b.team_name, a.matches_won,
 total_points
 from ipl_team_standings a join 
 ipl_team b 
 using (team_id);
 #6.	Display the total matches played, total matches won and total matches lost by the team along with its team name.
select * from ipl_team_standings;
select b.team_name, a.matches_won, 
 a.total_points, a.matches_lost, a.matches_played
 from ipl_team_standings a join 
 ipl_team b 
 using (team_id);
#7.	Display the bowlers for the Mumbai Indians team.
select * from ipl_team;
select * from ipl_player;
select * from ipl_team_players;
select t.player_id, t.player_role, 
t.team_id, p.player_name
from ipl_team_players t join ipl_player p
using (player_id)
where t.player_role='Bowler' and t.team_id=5;

#8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.

select * from ipl_team_players;
select team_id, count(player_role) as cnt
 from ipl_team_players
 where player_role='All-Rounder'
 group by team_id 
 having count(player_role) >4 
 order by cnt desc;
 
#9.  Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match 
#in MChinnaswamy Stadium bidding year-wise.
#Note the total bidders’ points in descending order and the year is the bidding year.
select * from ipl_team;  #also has team_id
select * from ipl_bidding_details; # has team_id 

select a.total_points, b.bid_date, b.bid_status, c.team_name 
from ipl_bidder_points a join ipl_bidding_details b
using (bidder_id) join ipl_team c
on b.bid_team=c.team_id 
join ipl_match_schedule d 
on b.bid_date= d.match_date
where c.team_id=1 and bid_status='Won'
and d.stadium_id=7
order by total_points desc;
 #10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
#Note 
#1. Use the performance_dtls column from ipl_player to get the total number of wickets
#4.	Display the following columns teamn_name, player_name, and player_role.
select * from ipl_player;
SELECT tp.player_role, tp.player_id, 
       CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(b.performance_dtls, 'Dot', 1), 'Wkt-', -1) AS UNSIGNED) AS wickets
FROM ipl_team_players tp, ipl_player b
WHERE tp.player_role IN ('Bowler', 'All-Rounder')
  AND tp.player_id = b.player_id
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(b.performance_dtls, 'Dot', 1), 'Wkt-', -1) AS UNSIGNED)
      >17 
      order by wickets desc;

#11. Show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
#--x-x-x-x-x-x-x-x--x-x
#12.	find the IPL season which has a duration and max duration.
# Output columns should be like the below:
# Tournment_ID, Tourment_name, Duration column, Duration
select * from ipl_tournament;
select tournmt_id, tournmt_name,to_date, from_date, datediff(to_date,from_date) as duration
from ipl_tournament
where datediff(to_date,from_date)= (select max(datediff(to_date, from_date)) from ipl_tournament)
or 
datediff(to_date,from_date)= (select min(datediff(to_date, from_date)) from ipl_tournament)
order by tournmt_id ;

#13. Write a query to display to calculate the total points month-wise for the 2017 bid year. 
# sort the results based on total points in descending order and month-wise in ascending order.
#Note: Display the following columns:
#1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
 
 select a.bidder_name, c.bidder_id,
 c.bid_team, month(c.bid_date) as mnt, year(c.bid_date) as yr, 
 sum(b.total_points)as summation from 
 ipl_bidder_details a join ipl_bidder_points b 
 using(bidder_id) 
 join ipl_bidding_details c
 using (bidder_id) 
 where year(c.bid_date) =2017 
 group by c.bid_team, month(c.bid_date), year(c.bid_date)
 ,a.bidder_name, c.bidder_id 
 order by summation desc,
 mnt asc;

#14. Write a query for the above question using sub-queries by having the same constraints as the above question

select sub.bidder_id, sub.mnth,                                                  #a=ipl_bidder_details, b=ipl_bidder_points, c=ipl_bidding_details
 sub.yr, sub.bidder_name, sub.total_points 
 from (
 select month(c.bid_date) as mnth, a.bidder_id,
 year(c.bid_date) as yr, a.bidder_name, sum(total_points) as total_points
 from ipl_bidder_details a, ipl_bidder_points b, ipl_bidding_details c 
 where a.bidder_id=b.bidder_id 
 and b.bidder_id=c.bidder_id 
 and year(bid_date)=2017
 group by a.bidder_id, month(c.bid_date),
 year(c.bid_date), a.bidder_name
 ) as sub 
 order by sub.mnth asc, sub.total_points desc;
 
 #15. Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
 
 select * from ipl_bidding_details; #b
 select * from ipl_bidder_points;   #c
 select * from ipl_bidder_details; #a
 
 select sub.bidder_id, sub.bidder_name, sub.yrs, sub.total_points,
 sub.max_pts, sub.min_pts from (
 select a.bidder_id, a.bidder_name, 
 c.total_points, year(b.bid_date) as yrs, 
 row_number()over(order by c.total_points desc) as max_pts, row_number()over(order by c.total_points asc) as min_pts 
 from ipl_bidding_details b, ipl_bidder_points c, ipl_bidder_details a 
 where a.bidder_id=b.bidder_id and b.bidder_id=c.bidder_id 
 and year(b.bid_date)=2018
 group by a.bidder_id, a.bidder_name, 
 c.total_points, year(b.bid_date)) as sub 
;