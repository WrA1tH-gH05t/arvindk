Select * from Classes;
Select * from Teachers;
Select * from Subjects;
Select * from Semesters;
Select * from Students;
Select * from Enrollments;
Select * from Marks;
 

Select *,
row_number() over(order by A.Student_id)  as rows_1,
row_number() over(partition by A.Student_id order by A.Student_id)  as Stu_rows_1,
row_number() over(partition by E.Semester_id order by m.mark_obtained desc)  as SEM_mar_rows_1,
row_number() over(partition by E.Semester_id,E.subject_id  order by m.mark_obtained desc)  as SEM_Sub_mar_rows_1,
row_number() over(partition by E.Semester_id,E.subject_id,M.Exam_type  order by m.mark_obtained desc)  as SEM_Sub_Ex_mar_rows_1
from Students A 
inner join Classes b on a.class_id = b.class_id
inner join Enrollments e on a.Student_id = E.Student_id
inner join Subjects S on S.Subject_id = E.Subject_id
inner join Teachers T on T.Teacher_id = S.Teacher_id
inner join Semesters SM on SM.Semester_id = e.Semester_id
inner join Marks  M on M.Enrollment_id =E.Enrollment_id
order by E.Semester_id,E.subject_id,SEM_Sub_mar_rows_1

SELECT *,
    RANK() OVER (PARTITION BY E.Semester_id, E.subject_id ORDER BY M.mark_obtained DESC) AS SEM_Sub_mar_rank,
    DENSE_RANK() OVER (PARTITION BY E.Semester_id, E.subject_id, M.Exam_type ORDER BY M.mark_obtained DESC) AS SEM_Sub_Ex_mar_dense_rank,
    NTILE(4) OVER (PARTITION BY E.Semester_id, E.subject_id ORDER BY M.mark_obtained DESC) AS SEM_Sub_mar_quartile,
    CUME_DIST() OVER (PARTITION BY E.Semester_id, E.subject_id ORDER BY M.mark_obtained DESC) AS SEM_Sub_mar_cume_dist,
    FIRST_VALUE(M.mark_obtained) OVER (PARTITION BY E.Semester_id, E.subject_id ORDER BY M.mark_obtained DESC) AS SEM_Sub_top_mark,
    LAST_VALUE(M.mark_obtained) OVER (
        PARTITION BY E.Semester_id, E.subject_id
        ORDER BY M.mark_obtained DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS SEM_Sub_lowest_mark,
    LAG(M.mark_obtained, 1, NULL) OVER (PARTITION BY E.Semester_id, E.subject_id ORDER BY M.mark_obtained DESC) AS Prev_Student_Mark,
    LEAD(M.mark_obtained, 1, NULL) OVER (PARTITION BY E.Semester_id, E.subject_id ORDER BY M.mark_obtained DESC) AS Next_Student_Mark,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY M.mark_obtained) OVER (PARTITION BY E.Semester_id, E.subject_id) AS SEM_Sub_median_mark
FROM Students A
INNER JOIN Classes B ON A.class_id = B.class_id
INNER JOIN Enrollments E ON A.Student_id = E.Student_id
INNER JOIN Subjects S ON S.Subject_id = E.Subject_id
INNER JOIN Teachers T ON T.Teacher_id = S.Teacher_id
INNER JOIN Semesters SM ON SM.Semester_id = E.Semester_id
INNER JOIN Marks M ON M.Enrollment_id = E.Enrollment_id
ORDER BY E.Semester_id, E.subject_id, SEM_Sub_mar_rank

Select s.subject_id,count(distinct a.student_id) as student
from Students A 
inner join Classes b on a.class_id = b.class_id
inner join Enrollments e on a.Student_id = E.Student_id
inner join Subjects S on S.Subject_id = E.Subject_id
inner join Teachers T on T.Teacher_id = S.Teacher_id
inner join Semesters SM on SM.Semester_id = e.Semester_id
inner join Marks  M on M.Enrollment_id =E.Enrollment_id
group by s.subject_id

select top 3 top_marks from top_marks=Select rank() over ( partition by s.subject_id,SM.semester_id,m.mark_obtained order by a.student_id ) as top_marks_sem
from Students A 
inner join Classes b on a.class_id = b.class_id
inner join Enrollments e on a.Student_id = E.Student_id
inner join Subjects S on S.Subject_id = E.Subject_id
inner join Teachers T on T.Teacher_id = S.Teacher_id
inner join Semesters SM on SM.Semester_id = e.Semester_id
inner join Marks  M on M.Enrollment_id =E.Enrollment_id
group by s.subject_id,SM.semester_id,m.mark_obtained,a.student_id;


WITH rankedmarks AS (
    SELECT
        
        S.subject_id,
        SM.semester_id,
        M.mark_obtained,
        RANK() OVER (
            PARTITION BY S.subject_id, SM.semester_id
            ORDER BY M.mark_obtained DESC
        ) AS top_mark
    FROM Students A
    INNER JOIN Classes B ON A.class_id = B.class_id
    INNER JOIN Enrollments E ON A.Student_id = E.Student_id
    INNER JOIN Subjects S ON S.Subject_id = E.Subject_id
    INNER JOIN Teachers T ON T.Teacher_id = S.Teacher_id
    INNER JOIN Semesters SM ON SM.Semester_id = E.Semester_id
    INNER JOIN Marks M ON M.Enrollment_id = E.Enrollment_id
)
SELECT
    subject_id,
 
    semester_id,
    mark_obtained AS top_marks
FROM rankedmarks
WHERE top_mark <= 5
ORDER BY subject_id, semester_id, mark_obtained DESC;



