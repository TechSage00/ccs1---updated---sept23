CREATE DATABASE IF NOT EXISTS ccs_clearance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ccs_clearance;

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS remember_tokens;
DROP TABLE IF EXISTS clearances;
DROP TABLE IF EXISTS requirements;
DROP TABLE IF EXISTS office_assignments;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(80) NOT NULL UNIQUE,
 email VARCHAR(190) NOT NULL UNIQUE,
 student_no VARCHAR(50) NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 full_name VARCHAR(190) NOT NULL,
 role ENUM('student','lab','library','cashier','sds','adviser','program_head','dean','registrar') NOT NULL DEFAULT 'student',
 course VARCHAR(80) NULL,
 year_level VARCHAR(30) NULL,
 section VARCHAR(50) NULL,
 semester VARCHAR(30) NULL,
 contact_no VARCHAR(40) NULL,
 photo_url VARCHAR(255) NULL,
 is_active TINYINT(1) NOT NULL DEFAULT 1,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE departments (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE,
 sort_order TINYINT UNSIGNED NOT NULL,
 is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE office_assignments (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 department_id INT UNSIGNED NOT NULL,
 user_id INT UNSIGNED NOT NULL,
 course VARCHAR(80) NOT NULL,
 UNIQUE KEY uq_assignment(department_id,course),
 FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE CASCADE,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE requirements (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 department_id INT UNSIGNED NOT NULL,
 requirement_text VARCHAR(255) NOT NULL,
 visibility TINYINT(1) NOT NULL DEFAULT 1,
 is_active TINYINT(1) NOT NULL DEFAULT 1,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE clearances (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 student_id INT UNSIGNED NOT NULL,
 department_id INT UNSIGNED NOT NULL,
 status ENUM('pending','cleared','rejected') NOT NULL DEFAULT 'pending',
 cleared_at DATETIME NULL,
 remarks VARCHAR(255) NULL,
 updated_by INT UNSIGNED NULL,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_clearance(student_id,department_id),
 FOREIGN KEY(student_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE CASCADE,
 FOREIGN KEY(updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NULL,
 action VARCHAR(100) NOT NULL,
 details TEXT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE password_reset_tokens (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NOT NULL,
 token_hash CHAR(64) NOT NULL UNIQUE,
 expires_at DATETIME NOT NULL,
 used_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_reset_user(user_id),
 INDEX idx_reset_expiry(expires_at)
) ENGINE=InnoDB;

CREATE TABLE remember_tokens (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id INT UNSIGNED NOT NULL,
 token_hash CHAR(64) NOT NULL UNIQUE,
 expires_at DATETIME NOT NULL,
 last_used_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_remember_user(user_id),
 INDEX idx_remember_expiry(expires_at)
) ENGINE=InnoDB;

INSERT INTO departments(name,sort_order) VALUES
('Laboratory/Shop',1),('Library',2),('Cashier',3),('Student Development Services',4),
('Class Adviser',5),('Program Head',6),('Dean',7),('Registrar',8);

-- Password for every demo account: Password123!
INSERT INTO users(username,email,student_no,password_hash,full_name,role,course,year_level,section,semester,contact_no) VALUES
('chester.manalo','chester@example.com','2023-00145', '$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi', 'Chester R. Manalo','student','BSIT','3','BSIT 3-2A','1st','09170000001'),
('von.tumaliuan','von@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Von G. Tumaliuan','lab','BSIT',NULL,NULL,NULL,'09170000002'),
('jaypee.ramasasa','jaypee@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Jaypee A. Ramasasa, RL','library','BSIT',NULL,NULL,NULL,'09170000003'),
('denise.lopez','denise@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Denise An C. Lopez','cashier','BSIT',NULL,NULL,NULL,'09170000004'),
('evelyn.diaz','evelyn@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Evelyn V. Diaz, MM','sds','BSIT',NULL,NULL,NULL,'09170000005'),
('yves.candelaria','yves@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Yves Xavier S. Candelaria, Ph D','adviser','BSIT',NULL,NULL,NULL,'09170000006'),
('richelle.go','richelle@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Richelle E. Go, Ph.D. (Cand.)','program_head','BSIT',NULL,NULL,NULL,'09170000007'),
('joy.cruz','joy@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Joy D.G. Cruz, Ph D','dean','BSIT',NULL,NULL,NULL,'09170000008'),
('lorelie.anthony','lorelie@example.com',NULL,'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Lorelie G. Anthony','registrar','BSIT',NULL,NULL,NULL,'09170000009');

INSERT INTO office_assignments(department_id,user_id,course)
SELECT d.id,u.id,'BSIT' FROM departments d JOIN users u ON u.role=CASE d.name
 WHEN 'Laboratory/Shop' THEN 'lab' WHEN 'Library' THEN 'library' WHEN 'Cashier' THEN 'cashier'
 WHEN 'Student Development Services' THEN 'sds' WHEN 'Class Adviser' THEN 'adviser'
 WHEN 'Program Head' THEN 'program_head' WHEN 'Dean' THEN 'dean' WHEN 'Registrar' THEN 'registrar' END;

INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Equipment returned in good condition',1 FROM departments WHERE name='Laboratory/Shop';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'No unpaid breakage/loss fee',1 FROM departments WHERE name='Laboratory/Shop';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'No borrowed books outstanding',1 FROM departments WHERE name='Library';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Library ID Validation',1 FROM departments WHERE name='Library';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Email of Online Library Clearance Form',1 FROM departments WHERE name='Library';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'No outstanding tuition/fee balance',1 FROM departments WHERE name='Cashier';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Student org accountabilities cleared',1 FROM departments WHERE name='Cashier';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Guidance/Scholarship requirements settled',1 FROM departments WHERE name='Cashier';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'No outstanding tuition/fee balance',1 FROM departments WHERE name='Student Development Services';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Student org accountabilities cleared',1 FROM departments WHERE name='Student Development Services';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Guidance/Scholarship requirements settled',1 FROM departments WHERE name='Student Development Services';

INSERT INTO users(username,email,student_no,password_hash,full_name,role,course,year_level,section,semester,contact_no) VALUES
('ana.reyes','ana@example.com','2023-00146','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Reyes, Ana P.','student','BSIT','3','BSIT 3-2A','1st','09170000010'),
('mark.santos','mark@example.com','2023-00147','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Santos, Mark L.','student','BSIT','3','BSIT 3-2A','1st','09170000011');

INSERT INTO clearances(student_id,department_id,status,remarks)
SELECT u.id,d.id, CASE WHEN u.student_no='2023-00146' THEN 'pending' ELSE 'cleared' END,
 CASE WHEN u.student_no='2023-00146' THEN 'Unreturned Item.' ELSE NULL END
FROM users u CROSS JOIN departments d WHERE u.role='student';

INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'No outstanding class requirements',1 FROM departments WHERE name='Class Adviser';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Advisory records and section accountabilities cleared',1 FROM departments WHERE name='Class Adviser';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'Program-level academic requirements settled',1 FROM departments WHERE name='Program Head';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'College academic requirements settled',1 FROM departments WHERE name='Dean';
INSERT INTO requirements(department_id,requirement_text,visibility)
SELECT id,'University clearance records complete',1 FROM departments WHERE name='Registrar';

-- Extra sample students to make dashboard counts/sections useful.
INSERT INTO users(username,email,student_no,password_hash,full_name,role,course,year_level,section,semester)
SELECT CONCAT('sample',n),CONCAT('sample',n,'@example.com'),CONCAT('2023-00',150+n),
'$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi',
CONCAT('Sample Student ',n),'student','BSIT','3',IF(n<=36,'BSIT 3-2A','BSIT 3-3A'),'1st'
FROM (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) x;

INSERT INTO clearances(student_id,department_id,status)
SELECT u.id,d.id,IF(u.student_no='2023-00145' OR u.student_no='2023-00147','cleared','pending')
FROM users u CROSS JOIN departments d WHERE u.role='student' AND NOT EXISTS
(SELECT 1 FROM clearances c WHERE c.student_id=u.id AND c.department_id=d.id);

-- QA wireframe student list: 100 students (2026-0001 to 2026-0100)
INSERT INTO users(username,email,student_no,password_hash,full_name,role,course,year_level,section,semester,contact_no) VALUES
('qa001','qa001@example.com','2026-0001','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Liam Smith','student','BSIT','3','BSIT 3-2A','1st','09180000001'),
('qa002','qa002@example.com','2026-0002','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Olivia Johnson','student','BSIT','3','BSIT 3-2A','1st','09180000002'),
('qa003','qa003@example.com','2026-0003','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Noah Williams','student','BSIT','3','BSIT 3-2A','1st','09180000003'),
('qa004','qa004@example.com','2026-0004','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Emma Brown','student','BSIT','3','BSIT 3-2A','1st','09180000004'),
('qa005','qa005@example.com','2026-0005','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Oliver Jones','student','BSIT','3','BSIT 3-2A','1st','09180000005'),
('qa006','qa006@example.com','2026-0006','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Charlotte Garcia','student','BSIT','3','BSIT 3-2A','1st','09180000006'),
('qa007','qa007@example.com','2026-0007','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','James Miller','student','BSIT','3','BSIT 3-2A','1st','09180000007'),
('qa008','qa008@example.com','2026-0008','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Amelia Davis','student','BSIT','3','BSIT 3-2A','1st','09180000008'),
('qa009','qa009@example.com','2026-0009','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Benjamin Rodriguez','student','BSIT','3','BSIT 3-2A','1st','09180000009'),
('qa010','qa010@example.com','2026-0010','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Sophia Martinez','student','BSIT','3','BSIT 3-2A','1st','09180000010'),
('qa011','qa011@example.com','2026-0011','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Lucas Hernandez','student','BSIT','3','BSIT 3-2A','1st','09180000011'),
('qa012','qa012@example.com','2026-0012','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Isabella Lopez','student','BSIT','3','BSIT 3-2A','1st','09180000012'),
('qa013','qa013@example.com','2026-0013','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Henry Gonzalez','student','BSIT','3','BSIT 3-2A','1st','09180000013'),
('qa014','qa014@example.com','2026-0014','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Ava Wilson','student','BSIT','3','BSIT 3-2A','1st','09180000014'),
('qa015','qa015@example.com','2026-0015','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Alexander Anderson','student','BSIT','3','BSIT 3-2A','1st','09180000015'),
('qa016','qa016@example.com','2026-0016','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Mia Thomas','student','BSIT','3','BSIT 3-2A','1st','09180000016'),
('qa017','qa017@example.com','2026-0017','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Mason Taylor','student','BSIT','3','BSIT 3-2A','1st','09180000017'),
('qa018','qa018@example.com','2026-0018','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Evelyn Moore','student','BSIT','3','BSIT 3-2A','1st','09180000018'),
('qa019','qa019@example.com','2026-0019','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Michael Jackson','student','BSIT','3','BSIT 3-2A','1st','09180000019'),
('qa020','qa020@example.com','2026-0020','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Harper Martin','student','BSIT','3','BSIT 3-2A','1st','09180000020'),
('qa021','qa021@example.com','2026-0021','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Ethan Lee','student','BSIT','3','BSIT 3-2A','1st','09180000021'),
('qa022','qa022@example.com','2026-0022','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Camila Perez','student','BSIT','3','BSIT 3-2A','1st','09180000022'),
('qa023','qa023@example.com','2026-0023','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Daniel Thompson','student','BSIT','3','BSIT 3-2A','1st','09180000023'),
('qa024','qa024@example.com','2026-0024','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Gianna White','student','BSIT','3','BSIT 3-2A','1st','09180000024'),
('qa025','qa025@example.com','2026-0025','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Jacob Harris','student','BSIT','3','BSIT 3-2A','1st','09180000025'),
('qa026','qa026@example.com','2026-0026','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Abigail Sanchez','student','BSIT','3','BSIT 3-2A','1st','09180000026'),
('qa027','qa027@example.com','2026-0027','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Logan Clark','student','BSIT','3','BSIT 3-2A','1st','09180000027'),
('qa028','qa028@example.com','2026-0028','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Luna Ramirez','student','BSIT','3','BSIT 3-2A','1st','09180000028'),
('qa029','qa029@example.com','2026-0029','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Jackson Lewis','student','BSIT','3','BSIT 3-2A','1st','09180000029'),
('qa030','qa030@example.com','2026-0030','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Ella Robinson','student','BSIT','3','BSIT 3-2A','1st','09180000030'),
('qa031','qa031@example.com','2026-0031','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Levi Walker','student','BSIT','3','BSIT 3-2A','1st','09180000031'),
('qa032','qa032@example.com','2026-0032','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Elizabeth Young','student','BSIT','3','BSIT 3-2A','1st','09180000032'),
('qa033','qa033@example.com','2026-0033','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Sebastian Allen','student','BSIT','3','BSIT 3-2A','1st','09180000033'),
('qa034','qa034@example.com','2026-0034','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Sofia King','student','BSIT','3','BSIT 3-2A','1st','09180000034'),
('qa035','qa035@example.com','2026-0035','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Mateo Wright','student','BSIT','3','BSIT 3-2A','1st','09180000035'),
('qa036','qa036@example.com','2026-0036','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Emily Scott','student','BSIT','3','BSIT 3-2A','1st','09180000036'),
('qa037','qa037@example.com','2026-0037','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Jack Torres','student','BSIT','3','BSIT 3-2A','1st','09180000037'),
('qa038','qa038@example.com','2026-0038','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Avery Nguyen','student','BSIT','3','BSIT 3-2A','1st','09180000038'),
('qa039','qa039@example.com','2026-0039','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Owen Hill','student','BSIT','3','BSIT 3-2A','1st','09180000039'),
('qa040','qa040@example.com','2026-0040','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Mila Flores','student','BSIT','3','BSIT 3-2A','1st','09180000040'),
('qa041','qa041@example.com','2026-0041','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Theodore Green','student','BSIT','3','BSIT 3-2A','1st','09180000041'),
('qa042','qa042@example.com','2026-0042','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Arya Adams','student','BSIT','3','BSIT 3-2A','1st','09180000042'),
('qa043','qa043@example.com','2026-0043','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Aiden Nelson','student','BSIT','3','BSIT 3-2A','1st','09180000043'),
('qa044','qa044@example.com','2026-0044','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Scarlett Baker','student','BSIT','3','BSIT 3-2A','1st','09180000044'),
('qa045','qa045@example.com','2026-0045','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Samuel Hall','student','BSIT','3','BSIT 3-2A','1st','09180000045'),
('qa046','qa046@example.com','2026-0046','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Victoria Rivera','student','BSIT','3','BSIT 3-2A','1st','09180000046'),
('qa047','qa047@example.com','2026-0047','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Joseph Campbell','student','BSIT','3','BSIT 3-2A','1st','09180000047'),
('qa048','qa048@example.com','2026-0048','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Madison Mitchell','student','BSIT','3','BSIT 3-2A','1st','09180000048'),
('qa049','qa049@example.com','2026-0049','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','John Carter','student','BSIT','3','BSIT 3-2A','1st','09180000049'),
('qa050','qa050@example.com','2026-0050','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Eleanor Roberts','student','BSIT','3','BSIT 3-2A','1st','09180000050'),
('qa051','qa051@example.com','2026-0051','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','David Gomez','student','BSIT','3','BSIT 3-2A','1st','09180000051'),
('qa052','qa052@example.com','2026-0052','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Grace Phillips','student','BSIT','3','BSIT 3-2A','1st','09180000052'),
('qa053','qa053@example.com','2026-0053','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Wyatt Evans','student','BSIT','3','BSIT 3-2A','1st','09180000053'),
('qa054','qa054@example.com','2026-0054','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Chloe Turner','student','BSIT','3','BSIT 3-2A','1st','09180000054'),
('qa055','qa055@example.com','2026-0055','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Matthew Diaz','student','BSIT','3','BSIT 3-2A','1st','09180000055'),
('qa056','qa056@example.com','2026-0056','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Penelope Parker','student','BSIT','3','BSIT 3-2A','1st','09180000056'),
('qa057','qa057@example.com','2026-0057','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Luke Cruz','student','BSIT','3','BSIT 3-2A','1st','09180000057'),
('qa058','qa058@example.com','2026-0058','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Layla Edwards','student','BSIT','3','BSIT 3-2A','1st','09180000058'),
('qa059','qa059@example.com','2026-0059','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Asher Collins','student','BSIT','3','BSIT 3-2A','1st','09180000059'),
('qa060','qa060@example.com','2026-0060','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Riley Reyes','student','BSIT','3','BSIT 3-2A','1st','09180000060'),
('qa061','qa061@example.com','2026-0061','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Carter Stewart','student','BSIT','3','BSIT 3-2A','1st','09180000061'),
('qa062','qa062@example.com','2026-0062','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Zoey Morris','student','BSIT','3','BSIT 3-2A','1st','09180000062'),
('qa063','qa063@example.com','2026-0063','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Julian Morales','student','BSIT','3','BSIT 3-2A','1st','09180000063'),
('qa064','qa064@example.com','2026-0064','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Nora Murphy','student','BSIT','3','BSIT 3-2A','1st','09180000064'),
('qa065','qa065@example.com','2026-0065','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Grayson Cook','student','BSIT','3','BSIT 3-2A','1st','09180000065'),
('qa066','qa066@example.com','2026-0066','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Lily Rogers','student','BSIT','3','BSIT 3-2A','1st','09180000066'),
('qa067','qa067@example.com','2026-0067','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Leo Gutierrez','student','BSIT','3','BSIT 3-2A','1st','09180000067'),
('qa068','qa068@example.com','2026-0068','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Eleanor Ortiz','student','BSIT','3','BSIT 3-2A','1st','09180000068'),
('qa069','qa069@example.com','2026-0069','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Jayden Morgan','student','BSIT','3','BSIT 3-2A','1st','09180000069'),
('qa070','qa070@example.com','2026-0070','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Hannah Cooper','student','BSIT','3','BSIT 3-2A','1st','09180000070'),
('qa071','qa071@example.com','2026-0071','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Gabriel Peterson','student','BSIT','3','BSIT 3-2A','1st','09180000071'),
('qa072','qa072@example.com','2026-0072','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Lillian Bailey','student','BSIT','3','BSIT 3-2A','1st','09180000072'),
('qa073','qa073@example.com','2026-0073','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Isaac Reed','student','BSIT','3','BSIT 3-2A','1st','09180000073'),
('qa074','qa074@example.com','2026-0074','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Addison Kelly','student','BSIT','3','BSIT 3-2A','1st','09180000074'),
('qa075','qa075@example.com','2026-0075','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Anthony Howard','student','BSIT','3','BSIT 3-2A','1st','09180000075'),
('qa076','qa076@example.com','2026-0076','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Aubrey Ramos','student','BSIT','3','BSIT 3-2A','1st','09180000076'),
('qa077','qa077@example.com','2026-0077','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Dylan Kim','student','BSIT','3','BSIT 3-2A','1st','09180000077'),
('qa078','qa078@example.com','2026-0078','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Ellie Cox','student','BSIT','3','BSIT 3-2A','1st','09180000078'),
('qa079','qa079@example.com','2026-0079','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Lincoln Ward','student','BSIT','3','BSIT 3-2A','1st','09180000079'),
('qa080','qa080@example.com','2026-0080','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Stella Richardson','student','BSIT','3','BSIT 3-2A','1st','09180000080'),
('qa081','qa081@example.com','2026-0081','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Thomas Watson','student','BSIT','3','BSIT 3-2A','1st','09180000081'),
('qa082','qa082@example.com','2026-0082','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Natalie Brooks','student','BSIT','3','BSIT 3-2A','1st','09180000082'),
('qa083','qa083@example.com','2026-0083','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Maverick Chavez','student','BSIT','3','BSIT 3-2A','1st','09180000083'),
('qa084','qa084@example.com','2026-0084','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Zoe Wood','student','BSIT','3','BSIT 3-2A','1st','09180000084'),
('qa085','qa085@example.com','2026-0085','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Josiah James','student','BSIT','3','BSIT 3-2A','1st','09180000085'),
('qa086','qa086@example.com','2026-0086','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Leah Bennett','student','BSIT','3','BSIT 3-2A','1st','09180000086'),
('qa087','qa087@example.com','2026-0087','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Oliver Gray','student','BSIT','3','BSIT 3-2A','1st','09180000087'),
('qa088','qa088@example.com','2026-0088','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Hazel Mendoza','student','BSIT','3','BSIT 3-2A','1st','09180000088'),
('qa089','qa089@example.com','2026-0089','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Charles Rupert','student','BSIT','3','BSIT 3-2A','1st','09180000089'),
('qa090','qa090@example.com','2026-0090','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Violet Hughes','student','BSIT','3','BSIT 3-2A','1st','09180000090'),
('qa091','qa091@example.com','2026-0091','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Christopher Price','student','BSIT','3','BSIT 3-2A','1st','09180000091'),
('qa092','qa092@example.com','2026-0092','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Aurora Alvarez','student','BSIT','3','BSIT 3-2A','1st','09180000092'),
('qa093','qa093@example.com','2026-0093','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Jaxon Castillo','student','BSIT','3','BSIT 3-2A','1st','09180000093'),
('qa094','qa094@example.com','2026-0094','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Savanna Sanders','student','BSIT','3','BSIT 3-2A','1st','09180000094'),
('qa095','qa095@example.com','2026-0095','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Julian Patel','student','BSIT','3','BSIT 3-2A','1st','09180000095'),
('qa096','qa096@example.com','2026-0096','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Brooklyn Myers','student','BSIT','3','BSIT 3-2A','1st','09180000096'),
('qa097','qa097@example.com','2026-0097','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Ezra Long','student','BSIT','3','BSIT 3-2A','1st','09180000097'),
('qa098','qa098@example.com','2026-0098','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Bella Ross','student','BSIT','3','BSIT 3-2A','1st','09180000098'),
('qa099','qa099@example.com','2026-0099','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Isaiah Foster','student','BSIT','3','BSIT 3-2A','1st','09180000099'),
('qa100','qa100@example.com','2026-0100','$2y$12$T13FF/Kdg65eglxgZLMugeA8XsRHS1oLk.3VfDuJ78H/WB9KRLhVi','Claire Jimenez','student','BSIT','3','BSIT 3-2A','1st','09180000100');

INSERT INTO clearances(student_id,department_id,status)
SELECT u.id,d.id,'pending'
FROM users u CROSS JOIN departments d
WHERE u.role='student' AND u.student_no BETWEEN '2026-0001' AND '2026-0100'
AND NOT EXISTS (SELECT 1 FROM clearances c WHERE c.student_id=u.id AND c.department_id=d.id);

SET FOREIGN_KEY_CHECKS=1;
