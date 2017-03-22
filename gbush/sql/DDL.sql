DROP TABLE IF EXISTS Param;
DROP TABLE IF EXISTS StaffSoldierScore;
DROP TABLE IF EXISTS SoldierScore;
DROP TABLE IF EXISTS ScoreParam;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Soldier;
DROP TABLE IF EXISTS SoldierInTsevet;
DROP TABLE IF EXISTS Tsevet;
DROP TABLE IF EXISTS TsevetStaff;

CREATE TABLE Role(
   RoleId INTEGER  NOT NULL PRIMARY KEY 
  ,Name VARCHAR(8) NOT NULL
);


INSERT INTO Role(RoleId,Name) VALUES (1,'Admin');
INSERT INTO Role(RoleId,Name) VALUES (2,'Megabesh');
INSERT INTO Role(RoleId,Name) VALUES (3,'Viewer');




CREATE TABLE Staff(
   StaffId  INTEGER  NOT NULL PRIMARY KEY 
  ,Initials VARCHAR(3) NOT NULL
);
INSERT INTO Staff(StaffId,Initials) VALUES (1,'OM');
INSERT INTO Staff(StaffId,Initials) VALUES (2,'AM');
INSERT INTO Staff(StaffId,Initials) VALUES (3,'GC');

CREATE TABLE User(
   Initials VARCHAR(2) NOT NULL
  ,UserId   VARCHAR(15) NOT NULL PRIMARY KEY
  ,Pass     VARCHAR(15) NOT NULL
  ,RoleId   INTEGER  NOT NULL
  ,StaffId  INTEGER  NOT NULL
  ,Foreign Key (RoleId) REFERENCES Role(RoleId)
    ,Foreign Key (StaffId,Initials) REFERENCES Staff(StaffId,Initials)
);

INSERT INTO User(Initials,UserId,Pass,RoleId,StaffId) VALUES ('OM','omri123','omri123',1,1);
INSERT INTO User(Initials,UserId,Pass,RoleId,StaffId) VALUES ('GC','guy123','guy123',1,3);
INSERT INTO User(Initials,UserId,Pass,RoleId,StaffId) VALUES ('AM','amir123','amir123',3,2);



CREATE TABLE Event(
   EventId  INTEGER  NOT NULL PRIMARY KEY 
  ,Name     VARCHAR(30) NOT NULL
  ,Type     VARCHAR(20) NOT NULL
  ,IsActive BIT  NOT NULL
);
INSERT INTO Event(EventId,Name,Type,IsActive) VALUES (1,'גיבוש גדסר מרץ 17','Gibush',1);
INSERT INTO Event(EventId,Name,Type,IsActive) VALUES (2,'טירונות 2017','Tironut',0);
INSERT INTO Event(EventId,Name,Type,IsActive) VALUES (3,'סוף מסלול 18','Maslul',0);





CREATE TABLE Tsevet(
   TsevetId      INTEGER  NOT NULL PRIMARY KEY 
  ,Matam		INTEGER NOT NULL
  ,Number		INTEGER	NOT NULL
);
INSERT INTO Tsevet(TsevetId,Matam,Number) VALUES (1,'0',1);
INSERT INTO Tsevet(TsevetId,Matam,Number) VALUES (2,'0',2);
INSERT INTO Tsevet(TsevetId,Matam,Number) VALUES (3,'0',3);

CREATE TABLE TsevetStaff(
   StaffId      INTEGER NOT NULL
  ,EventId      INTEGER  NOT NULL
  ,TsevetId     INTEGER  NOT NULL
  ,TsevetRoleId INTEGER  NOT NULL
   ,PRIMARY KEY(StaffId, EventId, TsevetId, TsevetRoleId)
   ,Foreign Key (StaffId) REFERENCES Staff(StaffId)
   ,Foreign Key (EventId) REFERENCES Event(EventId)
   ,Foreign Key (TsevetId) REFERENCES Tsevet(TsevetId)
);
INSERT INTO TsevetStaff(StaffId,EventId,TsevetId,TsevetRoleId) VALUES (1,1,1,2);


CREATE TABLE Soldier(
   SoldierId   VARCHAR(15) NOT NULL PRIMARY KEY
  ,City        INTEGER  NOT NULL
  ,Liba        BIT  NOT NULL
  ,ReleaseDate DATE  NOT NULL
  ,GiyusDate   DATE  NOT NULL
);
INSERT INTO Soldier(SoldierId,City,Liba,ReleaseDate,GiyusDate) VALUES ('142-2-1',3,1,'2020-04-12','2017-04-12');


CREATE TABLE SoldierInTsevet(
   SoldierId VARCHAR(15) NOT NULL
  ,EventId   INTEGER  NOT NULL
  ,TsevetId  INTEGER  NOT NULL
  ,Hat       INTEGER  NOT NULL
  ,PRIMARY KEY(SoldierId,EventId,TsevetId)
  ,Foreign Key (TsevetId) REFERENCES Tsevet(TsevetId)
  ,Foreign Key (EventId) REFERENCES Event(EventId)
);
INSERT INTO SoldierInTsevet(SoldierId,EventId,TsevetId,Hat) VALUES ('142-2-1',1,1,3);


CREATE TABLE ScoreParam(
   ScoreParamId INTEGER  NOT NULL PRIMARY KEY 
  ,Name         VARCHAR(32) NOT NULL
);
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (1,'מנהיגות');
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (2,'התאמה ליחידה');
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (3,'מוטיבציה');
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (4,'פקטור מילואמיניק');
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (5,'בראור');
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (6,'סוציומטרי');
INSERT INTO ScoreParam(ScoreParamId,Name) VALUES (7,'ציון גיבוש');



CREATE TABLE SoldierScore(
   SoldierId    VARCHAR(15) NOT NULL
  ,EventId      INTEGER  NOT NULL
  ,ScoreParamId     INTEGER  NOT NULL
  ,Value          INTEGER  NOT NULL
  ,Description          VARCHAR(255)
  ,PRIMARY KEY(SoldierId,EventId,ScoreParamId)
  ,Foreign Key (SoldierId) REFERENCES Soldier(SoldierId)
  ,Foreign Key (EventId) REFERENCES Event(EventId)
  ,Foreign Key (ScoreParamId) REFERENCES ScoreParam(ScoreParamId)

);
INSERT INTO SoldierScore(SoldierId,EventId,ScoreParamId,Value,Description) VALUES ('142-2-1',1,5,5,'a');


CREATE TABLE StaffSoldierScore(
   SoldierId    VARCHAR(15) NOT NULL
  ,StaffId      INTEGER  NOT NULL
  ,EventId      INTEGER  NOT NULL
  ,ScoreParamId INTEGER  NOT NULL
  ,Value        NUMERIC(3,3)  NOT NULL
	,PRIMARY KEY(SoldierId, StaffId, EventId, ScoreParamId)
  ,Foreign Key (SoldierId) REFERENCES Soldier(SoldierId)
  ,Foreign Key (StaffId) REFERENCES Staff(StaffId)
  ,Foreign Key (EventId) REFERENCES Event(EventId)
  ,Foreign Key (ScoreParamId) REFERENCES ScoreParam(ScoreParamId)
);
INSERT INTO StaffSoldierScore(SoldierId,StaffId,EventId,ScoreParamId,Value) VALUES ('142-2-1',1,1,2,5);



CREATE TABLE Param(
   ParamId INTEGER  NOT NULL PRIMARY KEY 
  ,Name    VARCHAR(20) NOT NULL
  ,Value   NUMERIC(3,3) NOT NULL
);
INSERT INTO Param(ParamId,Name,Value) VALUES (1,'SocioScore',0.2);
INSERT INTO Param(ParamId,Name,Value) VALUES (2,'BarorScore',0.1);



