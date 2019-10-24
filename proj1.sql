-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as 
	select r.unswid,r.longname 
	from Rooms r join room_facilities f 
	on (r.id=f.room and f.facility=19)
;

-- Q2:
create or replace view Q2(unswid,name)
as 
	select distinct p.unswid,p.name 
	from People p, staff s, course_enrolments c0, course_staff c1 
	where (c0.course=c1.course and c1.staff=s.id and p.id=s.id and c0.student=(
		select p.id 
		from people p, students s 
		where s.id=p.id and p.name='Hemma Margareta'
	))
;

-- Q3:
create or replace view tmp(unswid, name)
as 
	select distinct p.unswid,p.name, cc.mark
	from subjects s, courses c, course_enrolments cc, people p 
	where ((s.code='COMP9311' or s.code='COMP9024') and c.subject=s.id and cc.course=c.id and p.id=cc.student)
;

create or replace view Q3(unswid, name)
as 
	select p.unswid,p.name  
	from subjects s, courses c, course_enrolments cc, people p 
	where ((s.code='COMP9311' or s.code='COMP9024') and c.subject=s.id and cc.course=c.id and p.id=cc.student and cc.mark > 84) 
	group by p.unswid,p.name having count(p.name) > 1
;
-- Q4:

create or replace view Q4(num_student)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

--Q5:
create or replace view Q5(code, name, semester)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
create or replace view Q6(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
create or replace view Q7(year, term, average_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8: 
create or replace view Q8(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view Q9(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10:
create or replace view Q10(unswid, longname, num, rank)
as
--... SQL statements, possibly using other views/functions defined by you ...
;
