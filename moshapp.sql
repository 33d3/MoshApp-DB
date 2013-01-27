CREATE TABLE USERS(
u_id INT AUTO_INCREMENT PRIMARY KEY,
u_nicknme VARCHAR(30) NOT NULL,
u_fname VARCHAR(30),
u_lastname VARCHAR(30),
u_email VARCHAR(100),
u_phone VARCHAR(10),
s_num VARCHAR(9) NOT NULL,
UNIQUE (u_nicknme),
UNIQUE (s_num)
);
INSERT INTO USERS(`u_nicknme`,`u_fname`,`u_lastname`,`u_email`,`u_phone`,`s_num`) values("TestUser","Test","Test","test@test.com","0000000000","000000000");

/* Henuz eklenmedi */
CREATE TABLE USER_OPTIONS{
u_id INT,
p_vsbl_tm TINYINT(1),
e_vsbl_tm TINYINT(1),
FOREIGN KEY (u_id) REFERENCES USERS(u_id),
UNIQUE (u_id)
}


CREATE TABLE PERMISSIONS(
p_id INT PRIMARY KEY,
p_desc VARCHAR(100)
);

INSERT INTO PERMISSIONS values(0,"Regular user, can play game"),(1,"Master Admin, has all the power ower game and players."),(2,"Editor, can change add new tasks and teams"),
(3,"Admin, has ability that editor can do plus able to ban users"),(4,"Banned User");


CREATE TABLE LOGIN(
login_name VARCHAR(30) NOT NULL,
login_pass VARCHAR(34) NOT NULL,
u_id INT,
p_id INT DEFAULT 0,
FOREIGN KEY (u_id) REFERENCES USERS(u_id),
FOREIGN KEY (p_id) REFERENCES PERMISSIONS(p_id),
UNIQUE (login_name),
UNIQUE (u_id)
);
INSERT INTO LOGIN(`login_name`,`login_pass`,`u_id`) values("harme","123654","1");


CREATE TABLE TEAMS(
t_id INT AUTO_INCREMENT PRIMARY KEY,
t_name VARCHAR(30) NOT NULL,
t_chat_id VARCHAR(24) NOT NULL,
UNIQUE (t_name),
UNIQUE (t_chat_id)
);

CREATE TABLE TEAM_USER(
t_id INT,
u_id INT,
FOREIGN KEY (t_id) REFERENCES TEAMS(t_id),
FOREIGN KEY (u_id) REFERENCES USERS(u_id)
);

ALTER TABLE TEAM_USER
ADD CONSTRAINT pk_team_user PRIMARY KEY (t_id,u_id);


CREATE TABLE CAMPUS(
c_id INT AUTO_INCREMENT PRIMARY KEY,
c_name VARCHAR(30) NOT NULL,
c_lat REAL,
c_lng REAL
);

INSERT INTO CAMPUS(`c_name`,`c_lat`,`c_lng`) values("St. James Campus",43.6512279,-79.3693856),("Casa Loma Campus",43.6757552,-79.410208),("Waterfront Campus",43.643929,-79.367659);

/*Changed but not added yet */
CREATE TABLE DIC(
td_id INT AUTO_INCREMENT PRIMARY KEY,
direction TEXT(1000),
audio TEXT(1000),
image TEXT(1000),
td_lat REAL,
td_lng REAL
);

CREATE TABLE TASK_DIC(
tsk_id INT,
td_id INT,
FOREIGN KEY (tsk_id) REFERENCES TASKS(tsk_id),
FOREIGN KEY (td_id) REFERENCES DIC(td_id)
);

ALTER TABLE TASK_QUESTION
ADD CONSTRAINT pk_task_dic PRIMARY KEY (tsk_id,td_id);
/* Changes done until here*/

CREATE TABLE TASKS(
tsk_id INT AUTO_INCREMENT PRIMARY KEY,
td_id INT,
c_id INT,
FOREIGN KEY (td_id) REFERENCES TASK_DIC(td_id),
FOREIGN KEY (c_id) REFERENCES CAMPUS(c_id)
);

CREATE TABLE QUESTION_TYPE(
q_typ_id INT AUTO_INCREMENT PRIMARY KEY,
typ_desc TEXT(1000)
);

CREATE TABLE QUESTIONS(
q_id INT AUTO_INCREMENT PRIMARY KEY,
q_typ_id INT,
q_text TEXT(1000),
FOREIGN KEY (q_typ_id) REFERENCES QUESTION_TYPE(q_typ_id)
);

CREATE TABLE ANSWERS(
a_id INT AUTO_INCREMENT PRIMARY KEY,
q_id INT,
answer TEXT(250),
FOREIGN KEY (q_id) REFERENCES QUESTIONS(q_id)
);


CREATE TABLE TASK_QUESTION(
tsk_id INT,
q_id INT,
FOREIGN KEY (tsk_id) REFERENCES TASKS(tsk_id),
FOREIGN KEY (q_id) REFERENCES QUESTIONS(q_id)
);

ALTER TABLE TASK_QUESTION
ADD CONSTRAINT pk_task_question PRIMARY KEY (tsk_id,q_id);


CREATE TABLE CLUE_TYPE(
clue_typ_id INT AUTO_INCREMENT PRIMARY KEY,
typ_desc TEXT(1000)
);

CREATE TABLE CLUE(
clue_id INT AUTO_INCREMENT PRIMARY KEY,
clue_typ_id INT,
clue_text TEXT(1000),
clue_audio TEXT(1000),
clue_image TEXT(1000),
FOREIGN KEY (clue_typ_id) REFERENCES CLUE_TYPE(clue_typ_id)
);


CREATE TABLE CLUE_QUESTION(
clue_id INT,
q_id INT,
FOREIGN KEY (clue_id) REFERENCES CLUE(clue_id),
FOREIGN KEY (q_id) REFERENCES QUESTIONS(q_id)
);

ALTER TABLE CLUE_QUESTION
ADD CONSTRAINT pk_clue_question PRIMARY KEY (clue_id,q_id);


CREATE TABLE GAME(
g_id INT AUTO_INCREMENT PRIMARY KEY,
start_time datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,
finis_time datetime DEFAULT '0000-00-00 00:00:00' NOT NULL
);

CREATE TABLE TEAM_GAME(
t_id INT,
g_id INT,
FOREIGN KEY (t_id) REFERENCES TEAMS(t_id),
FOREIGN KEY (g_id) REFERENCES GAME(g_id)
);

ALTER TABLE TEAM_GAME
ADD CONSTRAINT pk_team_game PRIMARY KEY (t_id,g_id);


CREATE TABLE GAME_TASK(
tsk_id INT,
g_id INT,
prv_tsk_id INT,
FOREIGN KEY (tsk_id) REFERENCES TASKS(tsk_id),
FOREIGN KEY (prv_tsk_id) REFERENCES TASKS(tsk_id),
FOREIGN KEY (g_id) REFERENCES GAME(g_id)
);

ALTER TABLE GAME_TASK
ADD CONSTRAINT pk_team_game PRIMARY KEY (tsk_id,g_id);



CREATE TABLE PROGRESS(
t_id INT,
u_id INT,
tsk_id INT,
status INT,
currenttime TIMESTAMP,
FOREIGN KEY (t_id) REFERENCES TEAMS(t_id),
FOREIGN KEY (tsk_id) REFERENCES TASKS(tsk_id),
FOREIGN KEY (u_id) REFERENCES USERS(u_id)
);

CREATE TABLE RESPONSES(
r_id INT AUTO_INCREMENT PRIMARY KEY,
t_id INT,
u_id INT,
tsk_id INT,
response TEXT(1000),
location TEXT(1000),
FOREIGN KEY (t_id) REFERENCES TEAMS(t_id),
FOREIGN KEY (tsk_id) REFERENCES TASKS(tsk_id),
FOREIGN KEY (u_id) REFERENCES USERS(u_id)
);