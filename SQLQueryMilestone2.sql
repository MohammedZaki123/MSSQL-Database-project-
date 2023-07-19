CREATE PROC createALLTables
AS
CREATE TABLE SystemUser(
username varchar(20) PRIMARY KEY,
password VARCHAR(20) not null,
constraint US_User UNIQUE(username,password)
)
CREATE TABLE Stadium(
id INT PRIMARY KEY identity(1,1),
name VARCHAR(20) ,
location VARCHAR(20) ,
capacity int,
status bit default '1'
)
CREATE TABLE Stadium_Manager(
id int PRIMARY KEY identity(1,1),
name VARCHAR(20) ,
stadium_id int foreign key references Stadium(id) on delete cascade on update cascade, 
username varchar(20) foreign key references SystemUser(username) on delete cascade 
on update cascade not null
)

CREATE TABLE Club(
club_id INT PRIMARY KEY identity(1,1),
name VARCHAR(20) ,
location VARCHAR(20) 
)
CREATE TABLE Match(
match_id INT PRIMARY KEY identity(1,1),
start_time DATETIME,
end_time DATETIME,
host_club_id int,
guest_club_id int,
stadium_id int foreign key references Stadium(id) on delete cascade on update cascade,
constraint match_host_fk foreign key(host_club_id) references Club(club_id) 
on delete cascade on update no action,
constraint match_guest_fk foreign key(guest_club_id) references Club(club_id) on delete no action
on update cascade
)
CREATE TABLE Club_Representative(
id int primary key identity(1,1),
name VARCHAR (20) ,
username VARCHAR(20) foreign key references SystemUser(username) on delete cascade 
on update cascade not null,
club_id int foreign key references Club(club_id) on delete cascade on update cascade,
)
CREATE TABLE Host_request(
id INT PRIMARY KEY IDENTITY(1,1),
representitive_id int foreign key references Club_Representative(id) on delete cascade on update cascade,
manager_id int foreign key references Stadium_Manager(id) on delete no action on update no action,
match_id int foreign key references Match(match_id) on delete no action on update no action,
status varchar(20)  default 'unhandled',
)
CREATE TABLE Sports_association_manager(
id INT PRIMARY KEY identity(1,1),
name VARCHAR (20),
username VARCHAR(20) foreign key references SystemUser(username) on delete cascade on update cascade not null,
)
CREATE TABLE System_Admin(
id INT PRIMARY KEY identity(1,1),
name VARCHAR(20) ,
username VARCHAR(20) foreign key references SystemUser(username) on delete cascade
on update cascade not null, 
)
CREATE TABLE Fan(
national_id varchar(20) PRIMARY KEY,
name VARCHAR(20) ,
username varchar(20) foreign key references SystemUser(username) on delete cascade on update cascade not null,  
phone_no int,
birth_date datetime ,
address VARCHAR(20) ,
status bit default '1',
)
CREATE TABLE Ticket(
id int primary key identity(1,1),
status bit default '1',
match_id int foreign key references Match(match_id) on delete no action on update no action,
)
Create Table Ticket_Buying_Transaction(
fan_national_id varchar(20) foreign key references Fan(national_id) on delete cascade
on update cascade,
ticket_id int foreign key references Ticket(id) on delete cascade on update cascade
)
GO
CREATE PROC dropALLTables
AS
drop table Ticket_Buying_Transaction
drop table dbo.Ticket
drop table dbo.Fan
drop table dbo.System_Admin
drop table dbo.Sports_association_manager
drop table dbo.Host_request
drop table dbo.Club_Representative
drop table dbo.Match
drop table dbo.Club
drop table dbo.Stadium_Manager
drop table dbo.Stadium
drop table dbo.SystemUser
GO
CREATE PROC dropAllProceduresFunctionsViews
AS
drop PROC createALLTables
drop PROC dropAllTables
drop PROC clearAllTables
drop View allAssocManagers
drop View allClubRepresentatives
drop View allStadiumManagers
drop View allFans
drop view allMatches
drop View allTickets
drop View allClubs
drop View allStadiums
drop View allRequests
drop PROC addAssociationManager
drop PROC addNewMatch
drop view clubsWithNoMatches
drop Proc deleteMatch
drop Proc addRepresentative
drop Proc addStadiumManager
drop Proc addStadium
drop Proc addTicket
drop Proc addClub
drop Proc deleteClub
drop view matchesPerTeam
drop Proc deleteStadium
drop Proc blockFan
drop Proc unblockFan
drop function viewAvailableStadiumsOn
drop PROC addHostRequest
drop function AllUnassignedMatches
drop function allPendingRequests
drop PROC acceptRequest
drop Proc rejectRequest
drop PROC addFan
drop function upcomingMatchesOfClub
drop PROC purchaseTicket
drop proc updateMatchHost
drop view clubsNeverMatched
drop function clubsNeverPlayed
drop function dbo.requestsFromClub
drop PROC deleteMatchesOnStadium
drop function dbo.availableMatchesToAttend
drop function matchesRankedByAttendance
drop function matchWithHighestAttendance
drop Proc userlogin
GO
CREATE PROC clearAllTables
AS
Delete from dbo.Ticket_Buying_Transaction
Delete from dbo.Ticket
Delete from dbo.Fan
Delete from dbo.System_Admin
Delete from dbo.Sports_association_manager
Delete from dbo.Host_request
Delete from dbo.Club_Representative 
Delete from dbo.Match
Delete from dbo.Club
Delete from dbo.Stadium_Manager
Delete from dbo.Stadium
Delete from dbo.SystemUser
GO
CREATE VIEW allAssocManagers As 
Select sm.username,su.password,sm.name from Sports_association_manager sm,SystemUser su
where sm.username = su.username
GO
CREATE VIEW allClubRepresentatives As
Select c.username,su.password,c.name,club.name as 'Club_name'
from Club club, Club_Representative c, SystemUser su
where  c.club_id = club.club_id and c.username = su.username
GO 
CREATE VIEW allStadiumManagers AS
Select s.username,su.password,s.name,st.name as 'stadium_name' 
from Stadium_Manager s , Stadium st, SystemUser su
where s.stadium_id = st.id and su.username = s.username

GO
CREATE VIEW allFans AS
Select name username , password ,national_id,birth_date,status from Fan f, SystemUser su
where su.username = f.username 

GO
CREATE VIEW allMatches AS
Select c1.name as 'first_component',c2.name as 'second_component',m.start_time as 'Match_time'
from Match m
inner join Club c1 on  m.host_club_id = c1.club_id
inner join Club c2 on m.guest_club_id= c2.club_id
GO
CREATE VIEW allTickets AS
Select c1.name as 'first_club', c2.name as 'second_club',s.name as 'Stadium_name'
, m.start_time as 'match_time' from Ticket t
inner join Match m on m.match_id = t.match_id
inner join Club c1 on c1.club_id = m.guest_club_id
inner join Club c2 on c2.club_id = m.host_club_id
inner join Stadium s on  m.stadium_id = s.id
GO
GO
CREATE VIEW allClubs AS
Select name,location from Club

GO
Create VIEW allStadiums AS
Select name,location,capacity,status from Stadium

GO 
CREATE VIEW allRequests AS
Select c.username as 'Representative_username',sm.username as 'manager_username',r.status
from Host_request r,Stadium_Manager sm,Club_Representative c
where r.representitive_id = c.id and r.manager_id = sm.id 
GO
CREATE VIEW alreadyPlayedsMatches AS
Select c1.name AS 'first_club',c2.name AS 'Second_Club',m.start_time,m.end_time from Match m
inner join Club c1 on c1.club_id = m.host_club_id
inner join Club c2 on c2.club_id = m.guest_club_id
where m.end_time<=CURRENT_TIMESTAMP 
GO
GO
CREATE PROC addSystemAdmin @name varchar(20),@username varchar(20),@password varchar(20) AS 
insert into SystemUser values (@username,@password)
insert into System_Admin(name,username)
select @name, su.username from SystemUser su where su.username = @username 
and su.password = @password
GO
CREATE PROC addAssociationManager @name varchar(20),@username varchar(20),@password varchar(20) AS 
insert into SystemUser values (@username,@password)
insert into Sports_association_manager(name,username)
select @name, su.username from SystemUser su where su.username = @username 
and su.password = @password
GO 
CREATE PROC addNewMatch @first_component varchar(20),
@second_component varchar(20),@start_time datetime,@end_time datetime AS
insert into Match(start_time,end_time,host_club_id,guest_club_id) 
Select @start_time,@end_time,c1.club_id  ,c2.club_id
from  Club c1,Club c2 , Stadium s where 
c1.name = @first_component and c2.name = @second_component 
GO
CREATE VIEW clubsWithNoMatches AS
Select name from Club where Club.club_id not in(Select Club.club_id from Club, Match
where Club.club_id = Match.host_club_id) and Club.club_id not in (Select Club.club_id from Club, Match
where Club.club_id = Match.guest_club_id)
GO
CREATE PROC deleteMatch @first_component varchar(20),@second_component varchar(20),
@start_time datetime,@end_time datetime AS
delete from Match where Match.host_club_id IN 
(Select c1.club_id from Club c1 where c1.name = @first_component)
AND  Match.guest_club_id IN (Select c2.club_id from Club c2 where c2.name = @second_component)
AND Match.start_time = @start_time and Match.end_time = @end_time
Go
CREATE VIEW allUpcomingMatches AS
Select c1.name AS 'first_club',c2.name AS 'Second_Club',m.start_time,m.end_time from Match m
inner join Club c1 on c1.club_id = m.host_club_id
inner join Club c2 on c2.club_id = m.guest_club_id
where m.start_time>=CURRENT_TIMESTAMP 
GO
Select * from Match
Select * from allUpcomingMatches
GO
CREATE PROC addClub @name varchar(20), @location varchar(20)
AS
insert into Club (name,location) values (@name,@location)
GO
CREATE PROC viewclub @username varchar(20) as
Select c.* from Club c , Club_Representative cr where cr.club_id = c.club_id 
and cr.username = @username 

GO
CREATE PROC deleteClub @name varchar(20) AS
delete from Club where Club.name = @name

GO
CREATE PROC addStadium @name varchar(20),@location varchar(20),@capacity int AS
insert into Stadium (name,location,capacity) VALUES (@name,@location,@capacity)

GO
CREATE PROC deleteStadium @name varchar(20) AS
delete from Stadium where Stadium.name = @name
GO
CREATE PROC blockFan @national_id varchar(20) AS
update Fan
set Fan.status = 0 where national_id = @national_id
GO
CREATE PROC unblockFan @national_id varchar(20) AS
update Fan
set Fan.status = 1 where national_id = @national_id
Exec unblockFan @national_id = 'ABCDE'
GO
CREATE PROC addRepresentative @username varchar(20),@name varchar(20),@club_name varchar(20), @password varchar(20) AS
insert into SystemUser values(@username,@password)
insert into  Club_Representative(name,club_id,username) 
Select @name, c.club_id, su.username from Club c,SystemUser su
where su.username = @username and su.password = @password  and c.name = @club_name  
GO
CREATE PROC addStadiumManager @name varchar(20),@stadium_name varchar(20),@username varchar(20),@password varchar(20) AS
insert into SystemUser values(@username,@password)
insert into Stadium_Manager(name,stadium_id,username)
Select @name,s.id,su.username from Stadium s,SystemUser su
where s.name = @stadium_name and su.username = @username and su.password = @password

GO
CREATE PROC addHostRequest @username varchar(20),@stadium_name varchar(20),
@start_time datetime AS
insert into Host_request(representitive_id,manager_id,match_id)
Select cr.id,sm.id,m.match_id from Stadium_Manager sm, Stadium s,Match m, 
Club_representative cr , Club c where  s.id = sm.stadium_id and cr.club_id = c.club_id
and cr.username = @username and m.host_club_id = c.club_id 
and s.name = @stadium_name and m.start_time = @start_time
GO
CREATE PROC addTicket @host_name varchar(20), @guest_name varchar(20),@start_time datetime AS
insert into Ticket(match_id)
Select m.match_id from Match m,Club c1,Club c2 where m.host_club_id = c1.club_id
and m.guest_club_id= c2.club_id and c1.name = @host_name and c2.name = @guest_name and
m.start_time = @start_time
GO
CREATE PROC addFan @name varchar(20) ,@username varchar (20),
@password varchar(20),@national_id varchar(20), 
@birth_date datetime, @address varchar(20),@phone_no int AS
insert into SystemUser values(@username,@password)
insert into Fan(national_id,name,username,phone_no,birth_date,address) values(@national_id,@name,@username,@phone_no,@birth_date,@address)
GO 
CREATE VIEW matchesPerTeam AS
Select c.name as 'Club_name',COUNT(m.match_id) as 'Number of Matches' from Club c,Match m
where (c.club_id = m.host_club_id or c.club_id = m.guest_club_id) AND 
m.end_time < CURRENT_TIMESTAMP
group by c.name 
GO
CREATE VIEW clubsNeverMatched AS
Select  c1.name as 'First_club', c2.name as 'Second_club'from club c1,club c2 where 
(c1.club_id  in (Select host_club_id from match)  and c2.club_id  not in 
(select  guest_club_id from match))  and (c2.club_id  in ( select host_club_id from match where c1.club_id  not in 
(select guest_club_id from match ))) and c1.name <> c2.name
GO
create function viewAvailableStadiumsOn (@date_time datetime)
RETURNS TABLE
AS
RETURN
(
SELECT distinct S.name, S.capacity, S.location
FROM Stadium S, Match M  
WHERE  m.stadium_id = s.id and (@date_time < m.start_time OR @date_time > m.end_time) AND s.status = 1  
)
GO
CREATE PROC viewhostRequest @username varchar(20) as
Select cr.name as 'Representative_name ',c1.name as 'Host_Club'
,c2.name as 'Guest_Club', m.start_time,m.end_time,hr.status from Host_request hr
inner join Club_Representative cr on cr.id = hr.representitive_id
inner join Club c1 on c1.club_id = cr.club_id
inner join Match m on m.match_id = hr.match_id
inner join Club c2 on c2.club_id = m.guest_club_id
inner join Stadium_Manager sm on sm.id = hr.manager_id
where sm.username = @username
GO
create function allPendingRequests (@username varchar(20))
RETURNS TABLE
AS
RETURN
( 
 Select cr.name as 'Representative_name ',c1.name as 'Host_Club'
,c2.name as 'Guest_Club', m.start_time,m.end_time,hr.status from Host_request hr
inner join Club_Representative cr on cr.id = hr.representitive_id
inner join Club c1 on c1.club_id = cr.club_id
inner join Match m on m.match_id = hr.match_id
inner join Club c2 on c2.club_id = m.guest_club_id
inner join Stadium_Manager sm on sm.id = hr.manager_id
where sm.username = @username and hr.status = 'unhandled'
)
GO
CREATE FUNCTION matchWithHighestAttendance ()
RETURNS @table TABLE(first_name varchar(20),second_name varchar(20),number_of_tickets int) 
AS 
Begin
insert into @table(first_name,second_name,number_of_tickets)
SELECT  c1.name as 'First_club', c2.name as 'Second_club', MAX (t.id) AS 'numberoftickets'
FROM Club c1, Club c2, Match m, Ticket t, Stadium s
WHERE  c1.club_id = m.host_club_id AND 
c2.club_id = m.guest_club_id and m.match_id = t.match_id and t.status=0
GROUP BY c1.name,c2.name
Return
end
GO
CREATE FUNCTION matchesRankedByAttendance()
RETURNS @table TABLE(first_name varchar(20),second_name varchar(20),number_of_tickets int) 
AS 
Begin
insert into @table(first_name,second_name,number_of_tickets)
SELECT c1.name as 'First_club', c2.name as 'Second_club', COUNT(t.id) AS total_number_of_tickets
FROM Club c1, Club c2, Match m, Ticket t
WHERE c1.club_id = m.host_club_id AND 
c2.club_id = m.guest_club_id AND m.match_id = t.match_id and t.status = 0
GROUP BY c1.name,c2.name
ORDER BY  COUNT(t.id) DESC
Return
end
GO
create function upcomingMatchesOfClub (@username varchar(20))
RETURNS TABLE
AS
RETURN
SELECT C1.name AS 'first_club', C2.name AS 'second_club', M.start_time,M.end_time, s.name AS 'stadium_name'
FROM Club C1, Match M, Stadium S, Club c2,Club_Representative cr
WHERE  c1.club_id= m.host_club_id  AND c2.club_id = m.guest_club_id and (cr.club_id = c1.club_id) and 
cr.username = @username and (s.id =m.stadium_id or m.stadium_id IS NULL)  AND m.start_time>CURRENT_TIMESTAMP  

GO
CREATE PROC	deleteMatchesOnStadium @name varchar(20) AS
delete from Match where Match.start_time > CURRENT_TIMESTAMP and stadium_id IN
(Select s.id from Stadium s where s.name = @name)
GO
CREATE FUNCTION AllUnassignedMatches (@Club_name VARCHAR(20))
Returns TABLE 
AS 
RETURN 
SELECT c2.name, m.start_time 
FROM Club c1 , Match m , Club c2
WHERE c2.club_id = m.guest_club_id  AND c1.club_id =m.host_club_id and 
c1.name = @Club_name and m.stadium_id IS NULL 


GO
CREATE PROC addticket @host_name varchar(20), @guest_name varchar(20) ,
@start datetime AS
insert into Ticket(match_id) 
Select m.match_id from Match m, Club c1, Club c2 where m.guest_club_id = c2.club_id
and m.host_club_id = c1.club_id and c1.name = @host_name and c2.name = @guest_name
and m.start_time = @start
GO
CREATE FUNCTION availableMatchesToAttend(@date_time DATETIME)
RETURNS TABLE
AS 
RETURN (
SELECT distinct c1.name as 'First_Club', c2.name as 'Second_Club', s.name as 'Stadium_name',s.location  
FROM Club c1, Club c2, Match m, Stadium s, Ticket t
WHERE c1.club_id = m.host_club_id
AND c2.club_id = m.guest_club_id 
AND m.start_time >= @date_time 
AND m.stadium_id = s.id
AND  T.match_id = m.match_id 
AND t.status = 1)
GO
CREATE PROC purchaseTicket @national_id varchar(20),@host_name varchar(20),
@guest_name varchar(20) , @location varchar(20)AS
insert into Ticket_Buying_Transaction(fan_national_id,ticket_id) 
Select  distinct f.national_id,t.id from Ticket t,Match m,Club c1,Club c2,Stadium s,Fan f
where m.match_id = t.match_id and
c1.club_id = m.host_club_id and
c2.club_id = m.guest_club_id and
s.id = m.stadium_id and 
c1.name = @host_name and c2.name = @guest_name and s.location = @location and f.national_id = @national_id
update Ticket 
set  status = 0 where Ticket.id IN (Select  tbt.ticket_id from Ticket_Buying_Transaction tbt  where 
tbt.fan_national_id = @national_id) AND Ticket.match_id IN (Select  m.match_id from Match m 
inner join Club c1 on c1.club_id = m.host_club_id
inner join Club c2 on c2.club_id = m.guest_club_id
inner join Stadium s on s.id = m.stadium_id
where c1.name = @host_name and c2.name = @guest_name and s.location = @location)
GO
CREATE PROC updateMatchHost @host_name varchar(20),@guest_name varchar(20),@start_time datetime AS
update Match
set host_club_id = guest_club_id , guest_club_id = host_club_id where host_club_id 
IN(Select c1.club_id from Club c1, Match m where m.host_club_id = c1.club_id and c1.name = @host_name)
AND guest_club_id IN (Select c2.club_id from Club c2,Match m1 where m1.guest_club_id = c2.club_id 
and c2.name = @guest_name ) AND Match.start_time = @start_time
GO
CREATE FUNCTION clubsNeverPlayed(@club_name VARCHAR(20))
RETURNS @table TABLE(club_names VARCHAR(20))
AS
BEGIN
	DECLARE @id INT
	SELECT  @id=club_id FROM Club WHERE name=@club_name
	INSERT INTO @table
	SELECT C.name FROM Match M
	INNER JOIN Club C ON M.host_club_id=C.club_id
	WHERE M.guest_club_id NOT IN (
		SELECT guest_club_id FROM Match
		WHERE host_club_id=@id 
	) AND M.guest_club_id <> @id
	UNION
	SELECT C.name FROM Match M
	INNER JOIN Club C ON M.guest_club_id=C.club_id
	WHERE M.host_club_id NOT IN (
		SELECT host_club_id FROM Match
		WHERE guest_club_id=@id 
	) AND M.host_club_id <> @id
	RETURN
END
GO
CREATE PROCEDURE acceptRequest @username varchar(20), @host_name varchar(20), @guest_name varchar(20), @start datetime
AS
UPDATE Host_request SET  status = 'accepted' 
WHERE manager_id IN (SELECT id FROM Stadium_Manager WHERE Stadium_Manager.username=@username)
AND
representitive_id IN 
(SELECT cr.ID From Club_Representative cr WHERE  
cr.club_id IN (Select c.club_id from Club c where c.name = @host_name))
AND match_id IN 
(SELECT match_id From Match WHERE start_time = @start AND guest_club_id IN (SELECT club_id FROM Club WHERE name = @guest_name))
Update Match set stadium_id =(Select s.id from Stadium s 
inner join Stadium_Manager sm on sm.stadium_id = s.id where sm.username = @username) where 
Match.host_club_id = (Select club_id from Club where name = @host_name) and Match.guest_club_id =
(Select club_id from Club where name = @guest_name) and Match.start_time = @start
Declare @count int = 0;
Declare @stadium_capacity int;
Select @stadium_capacity = s.capacity from Stadium s
inner join Match m on m.stadium_id = s.id
inner join Club c1 on c1.club_id = m.host_club_id
inner join Club c2 on c2.club_id = m.guest_club_id
where c1.name = @host_name and c2.name = @guest_name and m.start_time = @start
while @count< @stadium_capacity
Begin
Exec addTicket @host_name = @host_name, @guest_name = @guest_name , @start = @start
set @count = @count + 1;
END
GO
CREATE PROCEDURE rejectRequest @username varchar(20), @host_name varchar(20), @guest_name varchar(20), @start_time datetime
AS
UPDATE host_request SET status = 'rejected' 
WHERE manager_ID IN (SELECT id FROM Stadium_Manager WHERE Stadium_Manager.username=@username)
AND
representitive_id IN
(SELECT cr.ID From Club_Representative cr WHERE  
cr.club_id IN (Select c.club_id from Club c where c.name = @host_name))
AND Match_ID IN 
(SELECT match_id From Match WHERE start_time = @start_time AND guest_club_id IN (SELECT club_id FROM Club WHERE Club.name = @guest_name))
GO
CREATE FUNCTION requestsFromClub (@stadium_name VARCHAR(20), @club_name VARCHAR(20))
RETURNS @table table(host_club_name VARCHAR(20), guest_club_name VARCHAR(20))
AS
BEGIN
DECLARE @stadium_id INT
SELECT @stadium_id=s.id FROM Stadium s
inner join Stadium_Manager sm on sm.stadium_id = s.id
inner join Host_request hr on hr.manager_id = sm.id
inner join Club_Representative cr on cr.id = hr.representitive_id
inner join Club c on c.club_id = cr.club_id
WHERE s.name=@stadium_name and c.name = @club_name
insert into @table(host_club_name,guest_club_name)
SELECT c1.name, c2.name
FROM Club c1, Club c2, Match m
WHERE c1.club_id = m.host_club_id AND c2.club_id=m.guest_club_id AND 
m.stadium_id= @stadium_id 
RETURN
END
GO
CREATE PROC userlogin @username varchar(20),@password varchar(20) ,
@success bit output, @type int output as
if exists(select sm.* from Sports_association_manager sm inner join SystemUser su on  sm.username = su.username 
where sm.username = @username and su.password = @password) 
begin
set @success = 1
set @type = 1 
end
else if exists(select cr.* from Club_Representative cr inner join SystemUser su on cr.username = su.username 
where cr.username = @username and su.password = @password)
begin
set @success = 1
set @type = 2 
end
else if exists(select f.* from Fan f inner join SystemUser su on f.username = su.username 
where f.username = @username and su.password = @password and f.status=1)
begin 
set @success = 1
set @type = 3 
end
else if exists(select sm.* from Stadium_Manager sm inner join SystemUser su on sm.username = su.username 
where sm.username = @username and su.password = @password)
begin 
set @success = 1
set @type = 4 
end
else if exists(select sa.* from System_Admin sa inner join SystemUser su on sa.username = su.username 
where sa.username = @username and su.password = @password)
begin 
set @success = 1
set @type = 5 
end
else
begin
set @success = 0
set @type = 0
end
GO
Create proc viewStadium @username varchar(20) as
Select s.* from Stadium s 
inner join Stadium_Manager sm on sm.id = s.id where sm.username = @username;

