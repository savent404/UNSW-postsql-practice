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
create or replace view Q3(unswid, name)
as 
	select p.unswid,p.name  
	from subjects s, courses c, course_enrolments cc, people p 
	where ((s.code='COMP9311' or s.code='COMP9024') and c.subject=s.id and cc.course=c.id and p.id=cc.student and cc.mark > 84) 
	group by p.unswid,p.name having count(p.name) > 1
;
-- Q4:

-- get valide student list (at least one mark is not null)
create or replace view Q4_valideStudent(id)
as 
	select distinct p.unswid 
	from course_enrolments c join people p 
	on (c.student=p.id and c.mark is not null)
;

-- get every record that get more HD
create or replace view Q4_hdRecord(student,course,mark) 
as 
	select p.unswid, c.course, c.mark 
	from course_enrolments c join people p 
	on (c.student=p.id and p.unswid in (select unswid from Q4_valideStudent) and c.mark > 84)
;
-- summary every student has how many HD who has at least one HD
create or replace view Q4_hdSummary(student, count)
as 
	select p.unswid, count(*) 
	from course_enrolments c join people p 
	on (c.student=p.id and p.unswid in (select unswid from Q4_valideStudent) and c.mark > 84)
	group by p.unswid
;

create or replace view Q4(num_student)
as 
	select count(*) 
	from Q4_hdSummary 
	where (count > ((select count(*) from Q4_hdRecord) / (select count(*) from Q4_valideStudent)))
;

--Q5:
create or replace view Q5_summaryEnrolmentsHasValidMark(course, count, maximumMark)
as 
	select course, count(*), MAX(mark)
	from course_enrolments 
	where (mark is not null) group by course
;

create or replace view Q5_valideCourseList(course, subject, semester, maximumMark)
as 
	select c.id, c.subject, c.semester, ans.count 
	from Q5_summaryEnrolmentsHasValidMark ans join courses c 
	on (c.id=ans.course and ans.count > 19)
;
create or replace view Q5_listMin(semester, min)
as 
	select semester, min(maximumMark) 
	from Q5_valideCourseList 
	group by semester
;
create or replace view Q5_listSemesters(subject, semester)
as 
	select a1.subject, a1.semester 
	from Q5_valideCourseList a1 join Q5_listMin a2 
	on (a1.semester=a2.semester and a1.maximumMark=a2.min)
;
create or replace view Q5(code, name, semester)
as 
	select s.code, s.name, ans.semester 
	from Q5_listSemesters ans join subjects s 
	on (ans.subject=s.id)
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
