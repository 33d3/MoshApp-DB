START TRANSACTION;

-- Stored Procedures
DELIMITER //

-- Creates a new user
DROP PROCEDURE IF EXISTS CreateUser //
CREATE PROCEDURE CreateUser (IN FirstName VARCHAR(30), IN LastName VARCHAR(30), IN Email VARCHAR(100), IN Phone VARCHAR(10), IN StudentNumber VARCHAR(9), OUT UserId INT)
BEGIN
  INSERT INTO users(u_fname, u_lastname, u_email, u_phone, s_num) VALUES
    (FirstName, LastName, Email, Phone, StudentNumber);

  SET UserId = LAST_INSERT_ID();

  INSERT INTO user_options VALUES
    (UserId, TRUE, TRUE);
END //

-- Creates login credentials for a user
DROP PROCEDURE IF EXISTS CreateLoginUser //
CREATE PROCEDURE CreateLoginUser (IN UserId INT, IN LoginName VARCHAR(30), IN Password VARCHAR(64))
BEGIN
  INSERT INTO login(u_id, login_name, login_pass) VALUES
    (UserId, LoginName, Password);
END //

-- Retrieves user information, given a User ID
DROP PROCEDURE IF EXISTS GetUser //
CREATE PROCEDURE GetUser(IN UserId INT)
BEGIN
  SELECT
    users.*,
    user_options.p_vsbl_tm, user_options.e_vsbl_tm
  FROM
    users
      INNER JOIN user_options ON users.u_id = user_options.u_id
  WHERE users.u_id = UserId;
END //

-- Retrieves login and user information given their login name
DROP PROCEDURE IF EXISTS GetLoginUser //
CREATE PROCEDURE GetLoginUser(IN LoginName VARCHAR(30))
BEGIN
  SELECT
    users.*,
    user_options.p_vsbl_tm, user_options.e_vsbl_tm,
    login.login_name, login.login_pass
  FROM
    login
      INNER JOIN users ON login.u_id = users.u_id
      INNER JOIN user_options ON users.u_id = user_options.u_id
  WHERE
    login.login_name = LoginName;
END //

-- Retrieves all information in a team, given a Team ID
DROP PROCEDURE IF EXISTS GetTeam //
CREATE PROCEDURE GetTeam(IN TeamId INT)
BEGIN
  SELECT
    teams.*, users.*, user_options.*
  FROM
    users
      INNER JOIN user_options ON users.u_id = user_options.u_id
      INNER JOIN team_user ON team_user.u_id = users.u_id
      INNER JOIN teams ON team_user.t_id = teams.t_id
  WHERE
    teams.t_id = TeamId;
END //

-- Retrieves all information in a team, given a User ID
DROP PROCEDURE IF EXISTS GetTeamWithUser //
CREATE PROCEDURE GetTeamWithUser(IN UserId INT)
BEGIN
  SELECT
    users.*, teams.*, user_options.*
  FROM
    team_user
      INNER JOIN teams ON team_user.t_id = teams.t_id
      INNER JOIN users ON team_user.u_id = users.u_id
      INNER JOIN user_options ON users.u_id = user_options.u_id,
        (SELECT
           team_user.t_id AS Team,
           team_user.u_id AS User
         FROM
           team_user) TeamMember
  WHERE
    TeamMember.Team = team_user.t_id AND
    TeamMember.User = UserId;
END //

-- Checks if a given login name exists in the database, and if so, returns FALSE
DROP FUNCTION IF EXISTS CheckLoginNameAvailable //
CREATE FUNCTION CheckLoginNameAvailable(LoginName VARCHAR(30))
RETURNS BOOLEAN
BEGIN
  DECLARE LNExists INT;
  SELECT COUNT(login_name) INTO LNExists FROM login WHERE login_name = LoginName;

  IF LNExists > 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END //

-- Updates the given user's phone/email visibility options
DROP PROCEDURE IF EXISTS UpdateUserOption //
CREATE PROCEDURE UpdateUserOption (IN UserId INT, IN PhoneVisible BOOLEAN, IN EmailVisible BOOLEAN)
BEGIN
  UPDATE user_options
  SET
    p_vsbl_tm = PhoneVisible,
    e_vsbl_tm = EmailVisible
  WHERE
    u_id = UserId;
END //

DROP PROCEDURE IF EXISTS GetUserInitInfo //
CREATE PROCEDURE GetUserInitInfo (IN UserId INT)
BEGIN
  SELECT
    user_options.p_vsbl_tm, user_options.e_vsbl_tm,
    teams.t_id, teams.t_name,
    team_game.g_id,
    game.start_time, game.finis_time,
    tasks.tsk_id, tasks.tsk_name, tasks.secret_id,
    campus.c_id, campus.c_name, campus.c_lat, campus.c_lng,
    dic.td_id, dic.direction, dic.audio, dic.image, dic.td_lat, dic.td_lng,
    questions.q_id, questions.q_typ_id, questions.q_text,
    (SELECT MAX(progress.status) FROM progress WHERE progress.tsk_id = tasks.tsk_id AND progress.u_id = UserId) status,
    responses.q_status,
    answers.answer
  FROM
    tasks
      LEFT OUTER JOIN campus       ON tasks.c_id = campus.c_id
      LEFT OUTER JOIN task_dic     ON task_dic.tsk_id = tasks.tsk_id
      LEFT OUTER JOIN dic          ON task_dic.td_id = dic.td_id
      LEFT OUTER JOIN dic_question ON dic_question.td_id = dic.td_id
      LEFT OUTER JOIN questions    ON dic_question.q_id = questions.q_id
      INNER JOIN user_options      ON user_options.u_id = UserId
      LEFT OUTER JOIN team_user    ON team_user.u_id = user_options.u_id
      LEFT OUTER JOIN teams        ON teams.t_id = team_user.t_id
      LEFT OUTER JOIN team_game    ON team_game.t_id = teams.t_id
      LEFT OUTER JOIN game         ON game.g_id = team_game.g_id
      LEFT OUTER JOIN progress     ON progress.status = 1 AND progress.u_id = UserId AND tasks.tsk_id = progress.tsk_id
      LEFT OUTER JOIN responses    ON responses.q_id =questions.q_id AND responses.q_status = 1 AND responses.u_id = UserId
      LEFT OUTER JOIN answers      ON answers.q_id = questions.q_id
  ORDER BY progress.status DESC;
END //

DELIMITER ;

COMMIT;
