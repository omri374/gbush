--Get all users who have admin role
Select UserId from ROLE r INNER JOIN User u on r.RoleId = u.RoleId where Name = 'Admin';


-- Get all soldiers in one gibush
Select * from soldierInTsevet st INNER JOIN EVENT e on st.eventId = e.eventId where name = 'גיבוש גדסר מרץ 17';

-- Get all staff members in one team in one event
Select * from staff s INNER JOIN TsevetStaff ts on s.staffId = ts.staffId INNER JOIN Event e on e.eventId = ts.eventId where e.name = 'גיבוש גדסר מרץ 17' and tsevetId = 1

-- update soldier details
