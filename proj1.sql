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
-- not for sure;

-- semester=10S1, stream.name='Management', student.stype='local'
create or replace view Q6_listAllRelatedRecord(student, offeredByOrgUnit)
as 
	select std.id, s.offeredBy 
	from semesters sem 
	join Program_enrolments pe on (sem.year=2010 and sem.term='S1' and pe.semester=sem.id) 
	join stream_enrolments se on (se.partof=pe.id) 
	join streams s on (s.id=se.stream and s.name='Management') 
	join students std on (std.id=pe.student and std.stype='local')
;

create or replace view Q6_searchOfferedByFE(student)
as 
	select student 
	from Q6_listAllRelatedStudent 
	where offeredByOrgUnit=(select id from OrgUnits where name='Faculty of Engineering')
;

create or replace view Q6(num)
as 
	select count(distinct a1.student) 
	from Q6_listAllRelatedRecord a1 
	where a1.student not in (select student from Q6_listStudentOfferedByFE)
;

-- Q7:
create or replace view Q7_valideSubject(subject) 
as 
	select id from subjects where (name='Database Systems')
;

create or replace view Q7_valideCourse(course, semester)
as 
	select c.id, c.semester 
	from Q7_valideSubject s join courses c 
	on (c.subject=s.subject)
;

create or replace view Q7_aveMark(semester, aveMark)
as 
	select c.semester, cast(avg(ce.mark) as numeric(4,2))
	from Q7_valideCourse c join course_enrolments ce 
	on (ce.course=c.course and ce.mark is not null) group by c.semester
;

create or replace view Q7(year, term, average_mark)
as 
	select sem.year, sem.term, ave.aveMark 
	from Q7_aveMark ave, semesters sem 
	where (ave.semester=sem.id)
;

-- Q8: 
create or replace view Q8_prefixSubject(subject) 
as 
select id from subjects where code like 'COMP93%'
;

create or replace view Q8_matchedSemester(semester)
as 
select distinct id,term,year from semesters s  
where s.term like 'S%' and s.year < 2014 and s.year > 2003 
;
create or replace view Q8_matchedCourse(course) 
as 
-- match code='COMP93%'
select c.subject, c.id, c.semester from courses c join Q8_prefixSubject prefix on c.subject=prefix.subject 
-- only appears in matched semesters
join Q8_matchedSemester sem on c.semester=sem.semester 
-- group by c.subject having count(distinct c.semester) > 5
;

create or replace view Q8(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;
-- Q9:

-- enroll a program in BSc (refer to program_degrees.abbrev) 
create or replace view Q9_enroledStudents(student) 
as 
select distinct student from Program_enrolments e join program_degrees d on (d.abbrev='BSc' and e.program=d.program)
;

-- must pass at least one course in the program in semester 2010 S2.
create or replace view Q9_passCourseIn10S2(student) 
as 
select distinct q.student from 
course_enrolments ce, Q9_enroledStudents q, courses c, semesters s where 
q.student=ce.student and ce.course=c.id and s.id=c.semester and 
ce.mark > 49 and s.year=2010 and s.term='S2'
;
-- average mark >= 80. Average mark means the average mark of all courses a student has passed before 2011(exclusive) in the program.
create or replace view Q9_matchedAveMark(student) 
as 
select distinct ce.student from course_enrolments ce, Q9_passCourseIn10S2 q where 
ce.student=q.student and ce.mark > 49 
group by ce.student having avg(ce.mark) >= 80
;

-- earned UOC
create or replace view Q9_earnedUOC(student, uoc) 
as 
select distinct ce.student, sum(s.UOC) from 
course_enrolments ce, Q9_matchedAveMark q, courses c, subjects s 
where ce.student=q.student and ce.mark >= 50 and c.id=ce.course and c.subject=s.id
group by ce.student 
;
create or replace view Q9(unswid, name) 
as 
select distinct p.unswid, p.name from 
Q9_earnedUOC l, program_enrolments pe, programs pro, people p 
where l.student=pe.student and pro.id=pe.program and p.id=l.student and 
l.uoc>=pro.uoc
;

-- Q10:
create or replace view Q10(unswid, longname, num, rank)
as
--... SQL statements, possibly using other views/functions defined by you ...
;
