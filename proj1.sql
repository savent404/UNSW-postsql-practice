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
create or replace view Q3_comp9311(student, semester) 
as 
	select p.id, c.semester from 
	subjects s, courses c, course_enrolments ce, people p, students ss 
	where c.subject=s.id and ce.course=c.id and p.id=ce.student and ss.id=ce.student 
	and s.code='COMP9311' and ss.stype='intl' and ce.mark >= 85
;

create or replace view Q3_comp9024(student, semester) 
as 
	select p.id, c.semester from 
	subjects s, courses c, course_enrolments ce, people p, students ss 
	where c.subject=s.id and ce.course=c.id and p.id=ce.student and ss.id=ce.student 
	and s.code='COMP9024' and ss.stype='intl' and ce.mark >= 85
;

create or replace view Q3(unswid, name)
as 
	select p.unswid, p.name, s.stype from 
	Q3_comp9311 q1, Q3_comp9024 q2, people p, students s 
	where q1.student=q2.student and p.id=q1.student and q1.semester=q2.semester 
	and s.id=p.id
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
create or replace view Q5_valideCourse(course, semester, maxMark)
as 
	select c.id, s.id, max(ce.mark) from 
	courses c, course_enrolments ce, semesters s 
	where c.id=ce.course and ce.mark is not null and c.semester=s.id 
	group by c.id, s.id having count(*) >= 20
;
create or replace view Q5_minList(semester, minMark) 
as 
	select q.semester , min(q.maxMark) 
	from Q5_valideCourse q 
	group by q.semester 
;

create or replace view Q5(code, name, semester)
as 
	select s.code, s.name, sem.name from 
	Q5_valideCourse q1 join Q5_minList q2 on q1.semester=q2.semester and q1.maxMark=q2.minMark ,
	subjects s, courses c, semesters sem 
	where s.id=c.subject and c.semester=sem.id and c.id=q1.course
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
-- select id from subjects where code like 'COMP93%'
select id from subjects
;

create or replace view Q8_matchedSemester(semester)
as 
select distinct id from semesters s  
where s.year < 2014 and s.year > 2003 and name like 'Sem%'
;
create or replace view Q8_matchedCourse(course) 
as 
select c.subject, count(distinct c.id) from 
courses c, Q8_prefixSubject sub,  Q8_matchedSemester sem where 
c.subject=sub.subject and c.semester=sem.semester 
group by c.subject having count(distinct c.id) > 10 
;

create or replace view Q8(zid, name)
as 
select distinct p.unswid, p.name from 
Q8_matchedCourse mc, course_enrolments ce, people p 
where mc.course=ce.course and p.id=ce.student
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
create or replace view Q10_roomHasLT(room, runswid, rlongname)
as 
select distinct r.id, r.unswid, r.longname from rooms r, room_types rt where rt.description='Lecture Theatre' and rt.id=r.rtype
;
create or replace view Q10_classesIn2011usingLT(class)
as 
select distinct c.id from classes c, Q10_roomHasLT q, semesters s 
where c.room=q.room and s.year=2011 and s.term='S1' and (c.startdate, c.enddate) overlaps (s.starting, s.ending)
;
create or replace view Q10_usage(class, room, usage, runswid, rlongname)
as 
select c.id, r.id, ceil(extract(doy from c.enddate) - extract(doy from c.startdate)/7) * c.dayofwk, r.unswid, r.longname from 
classes c, Q10_classesIn2011usingLT q, rooms r where 
q.class=c.id and c.room=r.id
;
create or replace view Q10_usage(usage, runswid, rlongname)
as 
select count(*), r.unswid, r.longname from 
classes c, Q10_classesIn2011usingLT q, rooms r where 
q.class=c.id and c.room=r.id group by r.unswid, r.longname
;

create or replace view Q10_fillWithZero(runswid, rlongname, usage) 
as 
select r.runswid, r.rlongname, case when q.usage is null then 0 else q.usage end from 
Q10_usage q right join Q10_roomHasLT r  on (q.runswid=r.runswid)
;

create or replace view Q10(unswid, longname, num, rank)
as 
select runswid, rlongname, usage, rank() over(order by usage desc) 
from Q10_fillWithZero
;
