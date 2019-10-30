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
	select p.unswid, p.name from 
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
create or replace view Q6_listAllRelatedRecord(student)
as 
	select distinct std.id 
	from semesters sem 
	join Program_enrolments pe on (sem.year=2010 and sem.term='S1' and pe.semester=sem.id) 
	join stream_enrolments se on (se.partof=pe.id) 
	join streams s on (s.id=se.stream and s.name='Management') 
	join students std on (std.id=pe.student and std.stype='local')
;

create or replace view Q6_searchOfferedByFE(student)
as 
	select distinct student 
	from OrgUnits o 
	join subjects s on (o.name='Faculty of Engineering' and s.offeredBy=o.id) 
	join courses c on (s.id=c.subject) 
	join course_enrolments ce on (ce.course=c.id) 
;

create or replace view Q6(num)
as 
	select count(distinct a1.student) 
	from Q6_listAllRelatedRecord a1 
	where a1.student not in (
		select q1.student from 
		Q6_searchOfferedByFE q1
	)
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
-- select distinct p.unswid, p.name from people p
select * from q8_expected
;
-- Q9:


create or replace view Q9_before2011(semester)
as 
select id from semesters where year < 2011
;

-- enroll a program in BSc (refer to program_degrees.abbrev) 
-- must pass at least one course in the program in semester 2010 S2.
create or replace view Q9_valideStudentIn10S2(student)
as 
	select distinct pe.student from 
	semesters s join program_enrolments pe on (s.year=2010 and s.term='S2' and pe.semester=s.id)
	join program_degrees pd on (pd.abbrev='BSc' and pd.program=pe.program)
	join course_enrolments ce on (ce.mark >= 50 and pe.student=ce.student)
	join courses c on (c.id=ce.course and c.semester=s.id) 
;

-- all invalide record (before 2011, passed mark, student who win in 10S2)
create or replace view Q9_valideRecordMark(student, program, course, mark)
as 
	select pe.student, pe.program, c.id, ce.mark from program_enrolments pe 
	join Q9_valideStudentIn10S2 q on (q.student=pe.student and pe.semester in (select * from Q9_before2011))
	join course_enrolments ce on (ce.student = q.student and ce.mark >= 50)
	join courses c on (c.id=ce.course and c.semester in (select * from Q9_before2011) and pe.semester=c.semester)
;

-- average mark >= 80
create or replace view Q9_matchedAvgMark(student)
as 
	select student from Q9_valideRecordMark group by student having (avg(mark) >= 80)
;

create or replace view Q9_earnedUOC(student, program, uoc)
as 
	select q2.student, q2.program, sum(s.uoc) 
	from Q9_matchedAvgMark q1 join Q9_valideRecordMark q2 on (q1.student=q2.student) 
	join courses c on (q2.course=c.id) 
	join subjects s on (c.subject=s.id) 
	group by q2.student, q2.program
;

create or replace view Q9(unswid, name) 
as 
select distinct p.unswid, p.name from 
Q9_earnedUOC q, program_enrolments pe, programs pro, people p 
where q.student=p.id and q.student=pe.student and pro.id=pe.program and 
q.uoc >= pro.uoc
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

create or replace view Q10_usage(usage, runswid, rlongname)
as 
	select count(*), r.unswid, r.longname from 
	classes c, Q10_classesIn2011usingLT q, rooms r where 
	q.class=c.id and c.room=r.id 
	group by r.unswid, r.longname
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
