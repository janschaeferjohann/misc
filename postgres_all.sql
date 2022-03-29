
CREATE schema mtext;
	
create table mtext.MOMS_SYSDATA (
  DBVERSION 		decimal(4,3) 	NOT NULL
) ;
insert into mtext.MOMS_SYSDATA (DBVERSION) VALUES (3.14);

create sequence mtext.MOMS_NEXT_INPUT_ID INCREMENT BY 10;
create sequence mtext.MOMS_NEXT_SPLIT_ID INCREMENT BY 20;
create sequence mtext.MOMS_NEXT_RUN_ID INCREMENT BY 1;
create sequence mtext.MOMS_NEXT_COLLECTFILE_ID INCREMENT BY 1;
create sequence mtext.MOMS_NEXT_PRINTJOB_ID INCREMENT BY 1;
create sequence mtext.MOMS_NEXT_TIMED_STACKRUN_ID INCREMENT BY 1;
create sequence mtext.MOMS_NEXT_TIMED_ERASER_ID INCREMENT BY 1;

create table mtext.MOMS_INPUT_DOC (
  INPUT_ID 		decimal(10,0) 	NOT NULL,
  INPUT_TIME		timestamp	NOT NULL,
  STATUS 		integer 	NOT NULL,
  ERROR_MSG      varchar(256),
  CONSTRAINT MOMS_INPUT_DOC_PK PRIMARY KEY (INPUT_ID)
) ;

create index MOMS_INP_ITIME_IDX on mtext.MOMS_INPUT_DOC (INPUT_TIME) ;

create table mtext.MOMS_SPLIT_DOC (
  KW_SPLIT_ID 		decimal(10,0) 	NOT NULL,
  KW_INPUT_ID 		decimal(10,0) 	NOT NULL,
  KW_SPLIT_TIME		timestamp	NOT NULL,
  KW_STATUS 		integer 	NOT NULL,
  KW_ERROR_MSG		varchar(256),
  KW_MEDIUM 		varchar(40)	NOT NULL,
  KW_TYPE_FLAG 		decimal(1,0) 	NOT NULL,
  KW_TYPE_NUM		decimal(10,0)	NOT NULL,
  KW_SPLIT_PAGES		decimal(10,0)	NOT NULL,
  KW_SPLIT_SHEETS		decimal(10,0) 	NOT NULL,
  KW_STACK_SHEETS		decimal(10,0) 	NOT NULL,
  KW_COLLECTFILE_ID 		decimal(10,0),
  KW_STACK_POS 		decimal(10,0),
  KW_ONLINESTACK_RUNID decimal(10,0),
  KW_TYPE_FORMAT		varchar(1),
  KW_PRIORITY		decimal(10,0),
  KW_RENDERER_DESTINATION		varchar(40),
  KW_FORM			varchar(40),
  KW_SPOOLER_ID		varchar(100),
  KW_RUN_ID		decimal(10,0),
  KW_GROUP_ID		decimal(10,0),
  KW_GROUP_POS		decimal(10,0),
  KW_BATCH			varchar(50),
  KW_BATCH_ID		varchar(30),
  KW_BATCH_TYP		decimal(10,0),
  KW_BATCH_DOKNR		decimal(10,0),
  KW_GROUP_SHEETS 		decimal(10,0),
  KW_GROUP_DOCS 		decimal(10,0),
  CONSTRAINT MOMS_SPLIT_DOC_PK PRIMARY KEY (KW_SPLIT_ID),
  CONSTRAINT SPLIT_INPUT_FK FOREIGN KEY (KW_INPUT_ID) REFERENCES mtext.MOMS_INPUT_DOC(INPUT_ID) ON DELETE CASCADE
) ;

create index MOMS_SPL_INPUT_IDX on mtext.MOMS_SPLIT_DOC (KW_INPUT_ID) ;
create index MOMS_SPL_RUNID_IDX on mtext.MOMS_SPLIT_DOC (KW_RUN_ID) ;
create index MOMS_SPL_STIME_IDX on mtext.MOMS_SPLIT_DOC (KW_SPLIT_TIME) ;
create index MOMS_SPL_GRPID_IDX on mtext.MOMS_SPLIT_DOC (KW_GROUP_ID) ;
create index MOMS_SPL_STAT_IDX  on mtext.MOMS_SPLIT_DOC (KW_STATUS) ;

create table mtext.MOMS_RESOURCE
(
	INPUT_ID 		decimal(10,0) 	NOT NULL,
	SPLIT_ID 		decimal(10,0) 	default 0 NOT NULL ,
	RESOURCE_NAME		varchar(40) 	NOT NULL,
	RESOURCE_TYPE		varchar(10)		NOT NULL,
	RESOURCE_SIZE 		decimal(10,0) 	NOT NULL,
	RESOURCE_COMPR_SIZE	decimal(10,0) 	NOT NULL,
	RESOURCE_DATA		oid,
	RESOURCE_CL 		int2,
	CONSTRAINT MOMS_RESOURCE_PK PRIMARY KEY(INPUT_ID, SPLIT_ID, RESOURCE_NAME),
	CONSTRAINT MOMS_RESOURCE_INPUT_ID_FK FOREIGN KEY (INPUT_ID) references mtext.MOMS_INPUT_DOC(INPUT_ID) ON DELETE CASCADE
) ;

CREATE RULE DROP_RESOURCE_DATA AS ON DELETE TO mtext.MOMS_RESOURCE
  DO SELECT lo_unlink( OLD.RESOURCE_DATA );
CREATE RULE UPDATE_RESOURCE_DATA AS ON UPDATE TO mtext.MOMS_RESOURCE
  DO SELECT lo_unlink( OLD.RESOURCE_DATA )
   where OLD.RESOURCE_DATA <> NEW.RESOURCE_DATA;    

create table mtext.MOMS_STACKRUN (
  STACK_NAME		varchar(40)	NOT NULL,
  DISPLAY_NAME		varchar(40),
  RUN_ID 		decimal(10,0) 	NOT NULL,
  PARENT_RUN_ID 	decimal(10,0),
  REPRINT_ORIG_STACK_RUNID decimal(10,0),
  STATUS 		integer 	NOT NULL,
  START_TIME		timestamp	NOT NULL,
  STOP_TIME 		timestamp,
  STOP_REQUEST_TIME timestamp,
  FIRST_DOC_STACK_POS	decimal(10,0),
  LAST_DOC_STACK_POS	decimal(10,0),
  ONLINESTACK_RUNID decimal(10,0),
  DOCUMENT_COLLECTION_COUNT decimal(10,0) NOT NULL,
  ERROR_COUNT decimal(10,0) NOT NULL,
  REPRINT_STACKPOS_RANGES varchar(2000),
  NODE_ID varchar(80),
  SELECT_HASHCODE decimal(10,0),
  STACK_SELECT oid,
  ERROR_MSG		varchar(256),
  NEXT_TIMEOUT 		timestamp,
  LAST_TIMEOUT 		timestamp,
  ONLINE_STACK_START_PARAMETERS oid,
  RESET_SPLIT_DOCS char(1),
  USERINFO			varchar(32),
  CONSTRAINT MOMS_STACKRUN_PK PRIMARY KEY (RUN_ID),
  CONSTRAINT MOMS_STACKRUN_PARENT_RUN_ID_FK FOREIGN KEY (PARENT_RUN_ID) references mtext.MOMS_STACKRUN(RUN_ID) ON DELETE CASCADE,
  CONSTRAINT MOMS_STACKRUN_RP_ORGSTKRNID_FK FOREIGN KEY (REPRINT_ORIG_STACK_RUNID) references mtext.MOMS_STACKRUN(RUN_ID) ON DELETE CASCADE
) ;

CREATE RULE DROP_STACK_SELECT AS ON DELETE TO mtext.MOMS_STACKRUN
  DO SELECT lo_unlink( OLD.STACK_SELECT );
CREATE RULE UPDATE_STACK_SELECT AS ON UPDATE TO mtext.MOMS_STACKRUN
  DO SELECT lo_unlink( OLD.STACK_SELECT )
   where OLD.STACK_SELECT <> NEW.STACK_SELECT;    

CREATE RULE DROP_ONLINE_STACK_START_PARAMETERS AS ON DELETE TO mtext.MOMS_STACKRUN
  DO SELECT lo_unlink( OLD.ONLINE_STACK_START_PARAMETERS );
CREATE RULE UPDATE_ONLINE_STACK_START_PARAMETERS AS ON UPDATE TO mtext.MOMS_STACKRUN
  DO SELECT lo_unlink( OLD.ONLINE_STACK_START_PARAMETERS )
   where OLD.ONLINE_STACK_START_PARAMETERS <> NEW.ONLINE_STACK_START_PARAMETERS;    
   
create index MOMS_STKR_PRUNID_IDX on mtext.MOMS_STACKRUN (PARENT_RUN_ID) ;
create index MOMS_STKR_RORUNID_IDX on mtext.MOMS_STACKRUN (REPRINT_ORIG_STACK_RUNID) ;

create table mtext.MOMS_COLLECTFILE (
  COLLECTFILE_ID decimal(10,0) NOT NULL,
  STACK_COLLECTFILE_NO decimal(10,0) not null,
  COLLECT_FILE_NAME varchar(255) not null,
  RUN_ID		decimal(10,0) NOT NULL,
  DOCUMENT_COUNT 	decimal(10,0) NOT NULL,
  SHEET_COUNT		decimal(10,0) NOT NULL,
  FIRST_DOC_STACK_POS	decimal(10,0) NOT NULL,
  LAST_DOC_STACK_POS 	decimal(10,0) NOT NULL,
  FILE_SIZE decimal(12,0) NOT NULL,
  STATUS 		integer 	NOT NULL,
  CREATION_TIME timestamp NOT NULL,
  COLLECT_CL 		int2,
  CONSTRAINT MOMS_COLLECTFILE_PK PRIMARY KEY (COLLECTFILE_ID),
  CONSTRAINT MOMS_COLLECTFILE_RUN_ID_FK FOREIGN KEY (RUN_ID) REFERENCES mtext.MOMS_STACKRUN(RUN_ID) ON DELETE CASCADE
) ;

create index MOMS_COL_RUNID_IDX on mtext.MOMS_COLLECTFILE (RUN_ID) ;

create table mtext.MOMS_REPRINTSTACK_COLLECTFILE (
  RUN_ID decimal(10,0) not null,
  COLLECTFILE_ID decimal(10,0) not null,
  CONSTRAINT MOMS_REPRINTSTK_COLFLE_PK PRIMARY KEY (RUN_ID),
  CONSTRAINT MOMS_REPRNTSTK_COLFLE_RUNID_FK FOREIGN KEY (RUN_ID) references mtext.MOMS_STACKRUN(RUN_ID) ON DELETE CASCADE,
  CONSTRAINT MOMS_REPRNTSTK_COLFLE_COLID_FK FOREIGN KEY (COLLECTFILE_ID) references mtext.MOMS_COLLECTFILE(COLLECTFILE_ID) ON DELETE CASCADE 
) ;

create index MOMS_REP_COLID_IDX on mtext.MOMS_REPRINTSTACK_COLLECTFILE (COLLECTFILE_ID) ;

create table mtext.MOMS_PRINTJOB (
  PRINTJOB_ID       decimal(10,0) NOT NULL,
  COLLECTFILE_ID    decimal(10,0) NOT NULL,
  LOCK_ID_PARALLEL  decimal(25,0) NOT NULL,
  LOCK_ID_ORG       decimal(25,0) NOT NULL,
  PRINTTIME         timestamp       NOT NULL,
  ERRORMESSAGE      varchar(100),      
  USERINFO          varchar(32),       
  STATUS            integer    NOT NULL,
  QUEUENAME         varchar(100),
  SPOOLER_ID        varchar(100),      
  NODE_ID   varchar(80),
  CONSTRAINT MOMS_PRINTJOB_PK PRIMARY KEY (PRINTJOB_ID),
  CONSTRAINT MOMS_PRINTJOB_COLECTFILE_ID_FK FOREIGN KEY (COLLECTFILE_ID) REFERENCES mtext.MOMS_COLLECTFILE(COLLECTFILE_ID) ON DELETE CASCADE,
  CONSTRAINT MOMS_PRINTJOB_U1 UNIQUE(COLLECTFILE_ID, LOCK_ID_PARALLEL),
  CONSTRAINT MOMS_PRINTJOB_U2 UNIQUE(COLLECTFILE_ID, LOCK_ID_ORG)
) ;

create index MOMS_PRJ_COLID_IDX on mtext.MOMS_PRINTJOB (COLLECTFILE_ID) ;

create table mtext.MOMS_TIMED_STACKRUN
(
  TIMED_STACKRUN_ID decimal(10,0) NOT NULL,
  STACK_NAME		varchar(40)	NOT NULL,
  START_TIME		timestamp	NOT NULL,
  SELECT_HASHCODE decimal(10,0) NOT NULL,
  STACK_START_PARAMETERS oid,
  USERINFO			varchar(32),
  CONSTRAINT MOMS_TIMED_STACKRUN_PK PRIMARY KEY (TIMED_STACKRUN_ID)
) ;

CREATE RULE DROP_STACK_START_PARAMETERS AS ON DELETE TO mtext.MOMS_TIMED_STACKRUN
  DO SELECT lo_unlink( OLD.STACK_START_PARAMETERS );
CREATE RULE UPDATE_STACK_START_PARAMETERS AS ON UPDATE TO mtext.MOMS_TIMED_STACKRUN
  DO SELECT lo_unlink( OLD.STACK_START_PARAMETERS )
   where OLD.STACK_START_PARAMETERS <> NEW.STACK_START_PARAMETERS;    

create table mtext.MOMS_TIMED_ERASER
(
  TIMED_ERASER_ID decimal(10,0) NOT NULL,
  START_TIME		timestamp	NOT NULL,
  ERASER_PARAMETERS oid,
  USERINFO			varchar(32),
  CONSTRAINT MOMS_TIMED_ERASER_PK PRIMARY KEY (TIMED_ERASER_ID)
) ;

CREATE RULE DROP_ERASER_PARAMETERS AS ON DELETE TO mtext.MOMS_TIMED_ERASER
  DO SELECT lo_unlink( OLD.ERASER_PARAMETERS );
CREATE RULE UPDATE_ERASER_PARAMETERS AS ON UPDATE TO mtext.MOMS_TIMED_ERASER
  DO SELECT lo_unlink( OLD.ERASER_PARAMETERS )
   where OLD.ERASER_PARAMETERS <> NEW.ERASER_PARAMETERS;    

create table mtext.MOMS_ONLINE_ERASER_RUN
(
  NAME varchar(40) NOT NULL,
  STATUS integer not null,
  START_TIME		timestamp NOT NULL,
  ERASER_PARAMETERS oid,
  NODE_ID varchar(80),
  NEXT_TIMEOUT 		timestamp,
  LAST_TIMEOUT 		timestamp,
  DELETED_OBJECT_COUNT decimal(10,0),
  USERINFO			varchar(32),
  CONSTRAINT MOMS_ONLINE_ERASER_RUN_PK PRIMARY KEY (NAME)
) ;

CREATE RULE DROP_ERASER_PARAMETERS AS ON DELETE TO mtext.MOMS_ONLINE_ERASER_RUN
  DO SELECT lo_unlink( OLD.ERASER_PARAMETERS );
CREATE RULE UPDATE_ERASER_PARAMETERS AS ON UPDATE TO mtext.MOMS_ONLINE_ERASER_RUN
  DO SELECT lo_unlink( OLD.ERASER_PARAMETERS )
   where OLD.ERASER_PARAMETERS <> NEW.ERASER_PARAMETERS;    

create table mtext.MOMS_CONFIGUPDATE_LOCK
(
	LOCK_ID decimal(10,0) not null,
	UPDATE_TIME timestamp not null,
	CONSTRAINT MOMS_CONFIGUPDATE_LOCK_PK PRIMARY KEY(LOCK_ID)
) ;

create table mtext.MOMS_CREATE_LOCK_SYNC 
(
	SYNC integer not null,
	CONSTRAINT MOMS_CREATE_LOCK_SYNC_U UNIQUE(SYNC)
) ;

insert into mtext.MOMS_CREATE_LOCK_SYNC values (1);

create table mtext.MOMS_APP_LOCK 
(
	RESOURCE_ID varchar(80) not null, 
	DESCRIPTION varchar(80), 
	LOCK_TIME timestamp not null, 
	NODE_ID varchar(80),
	CONSTRAINT MOMS_APP_LOCK_PK PRIMARY KEY(RESOURCE_ID)
) ;

create table mtext.MOMS_ACTIVE_NODES (
	NODE_ID 			varchar(80) not null,
	LAST_ACTIVE_TIME 	timestamp not null, 
	CONSTRAINT MOMS_ACTIVE_NODES_PK PRIMARY KEY (NODE_ID)
) ;

create table mtext.MOMS_INSTANT_STACKRUN (
  STACK_NAME		varchar(40)	NOT NULL,
  LAST_ACTIVATION_TIME timestamp NOT NULL,
  DOCUMENT_COUNT	decimal(10,0) NOT NULL,
  ERROR_COUNT 		decimal(10,0) NOT NULL,
  ACTIVE_COUNT  	decimal(10,0) NOT NULL,
  CONSTRAINT MOMS_INSTANT_STACKRUN_PK PRIMARY KEY (STACK_NAME)
) ;

create table mtext.MOMS_STACKRUN_CASCADE (
    RUN_ID decimal(10,0) NOT NULL,
    ROOT_RUN_ID decimal(10,0) NOT NULL,
    PARENT_RUN_ID decimal(10,0),
    STACKRUN_DATA oid,
    CONSTRAINT MOMS_CHILD_RUN_ID_PK PRIMARY KEY (RUN_ID)
) ;

CREATE RULE DROP_STACKRUN_CASCADE_DATA AS ON DELETE TO mtext.MOMS_STACKRUN_CASCADE
  DO SELECT lo_unlink( OLD.STACKRUN_DATA );
CREATE RULE UPDATE_STACKRUN_CASCADE_DATA AS ON UPDATE TO mtext.MOMS_STACKRUN_CASCADE
  DO SELECT lo_unlink( OLD.STACKRUN_DATA )
   where OLD.STACKRUN_DATA <> NEW.STACKRUN_DATA;    

create index MOMS_STKRCASCADE_RRUNID_IDX on mtext.MOMS_STACKRUN_CASCADE (ROOT_RUN_ID) ;

-- =================================================
-- ====== SQL script for M/TEXT CS database   ======
-- ====== objects creation                    ======
-- =================================================

-- This script was generated by the Assembly Tool.
-- All variable parts should have been replaced. Please check if
-- any placeholders are remaining (placeholders begin with the
-- characters '${') and replace them by actual values.

-- Please pay attention to database tablespaces organization. For a standard
-- installation, you might want to have separate storage for blobs and other data.
-- In this case it is necessary that <tablespace_name> and <blob_tablespace_name>
-- point to different tablespaces on different storages.
-- Please check the PostgreSQL documentation

-- ======================================================
--      connect
-- ======================================================
-- connect to ${DATABASE_NAME} user ${DATABASE_USER} using "${DATABASE_PASSWORD}"

-- ==============================================
--    Tables
-- ==============================================

create table mtext.MXCSDOCFOLDERS (
    FLDRIDENT          bigint       NOT NULL,
    FLDRPARENT         bigint       NOT NULL,
    FLDRMODELVERSION   bigint       NOT NULL,
    FLDRNAME           varchar(128) NOT NULL,
    FLDRSYSATTR        bigint,
    FLDRDESCRIPTION    varchar(254)
) ;

create table mtext.MXCSDOCUMENT (
    DOCIDENT          bigint       NOT NULL,
    DOCTYPE           bigint       NOT NULL,
    DOCFOLDER         bigint       NOT NULL,
    DOCNAME           varchar(254) NOT NULL,
    DOCACTIVEVERSION  bigint,
    DOCLASTVERSION    bigint,
    DOCCHARSET        varchar(40),
    DOCCREATORGUID    varchar(36),
    DOCCREATEDDATE    timestamp,
    DOCDESCRIPTION    varchar(254),
    DOCCHANGERGUID    varchar(36),
    DOCCHANGEDDATE    timestamp,
    DOCPASSWORD       varchar(72),
    DOCSGNCOUNT       bigint,
    DOCLOCKEDBYGUID   varchar(36),
    DOCLOCKEDUSERGUID varchar(36),
    DOCLOCKEDDATE     timestamp,
    DOCLOCKTYPE       bigint,
    DOCPRINTEDBYGUID  varchar(36),
    DOCPRINTEDDATE    timestamp,
    DOCUSEVERSIONS    smallint,
	DOCTITLE 		  varchar(128),
	DOCCONTENTHASH    CHAR(40),
	DOCSTATE		  bigint NOT NULL default 0,
	DOCMETASTATE      varchar(254),
	DOCMETAASSIGNEE   varchar(254)
) ;


create table mtext.MXCSDOCUMENTBLOBS (
    RBLBIDENT       bigint NOT NULL,
    RBLBVERSION     bigint NOT NULL,
    RBLBTYPE        bigint NOT NULL,
    RBLBCOMPRESSION bigint NOT NULL,
    RBLBDATA        bytea
) ;

create table mtext.MXCSDOCUMENTPROPERTIES (
    DCPPSEQ   bigserial,
    DCPPIDENT bigint      NOT NULL,
    DCPPNAME  varchar(254) NOT NULL,
    DCPPVALUE varchar(254)
) ;

create table mtext.MXCSDOCUMENTVERSIONS (
    VERIDENT       bigint      NOT NULL,
    VERVERSION     bigint      NOT NULL,
    VERDESCRIPTION varchar(254),
    VERCHANGERGUID varchar(36),
    VERCHANGEDDATE timestamp,
    VERPASSWORD    varchar(72),
    VERSGNCOUNT    bigint,
    VERCHARSET     varchar(20) NOT NULL,
	VERTITLE varchar(128),
	VERCONTENTHASH CHAR(40),
	VERSTATE		bigint NOT NULL default 0
) ;

create table mtext.MXCSDUAL (
    ONEVAL bigint
) ;

create table mtext.MXCSMODPREVIEW (
    MPDOCIDENT    bigint NOT NULL,
    MPDOCVERSION  bigint NOT NULL,
    MPCOMPRESSION bigint NOT NULL,
    MPDATA        bytea
) ;

create table mtext.MXCSINSTFOLDERS (
    INSFIDENT         bigint       NOT NULL,
    INSFPARENT        bigint       NOT NULL,
    INSFNAME          varchar(254) NOT NULL,
    INSFSYSATTR       bigint,
    INSFACTIVEVERSION bigint
) ;

create table mtext.MXCSINSTPCKGS (
    IPIDENT         bigint NOT NULL,
    IPFOLDER        bigint NOT NULL,
    IPVERSION       bigint NOT NULL,
    IPTYPE          bigint NOT NULL,
    IPCREATORGUID   varchar(36),
    IPCREATEDDATE   timestamp,
    IPACTIVATEDATE  timestamp,
    IPACTIVATEGROUP bigint NOT NULL
) ;

create table mtext.MXCSINSTBLOBS (
    IPBIDENT       bigint NOT NULL,
    IPBCOMPRESSION bigint NOT NULL,
    IPBDATA        bytea
) ;

create table mtext.MXCSPACKAGEGROUPS (
    PGIDENT         bigint       NOT NULL,
    PGNAME          varchar(128) NOT NULL,
    PGVERSIONLABEL  varchar(32)  NOT NULL,
    PGVERSION       bigint       NOT NULL,
    PGCREATORGUID   varchar(72),
    PGCREATORNAME   varchar(254),
    PGCREATEDDATE   timestamp,
    PGACTIVATEDATE  timestamp,
    PGDESCRIPTION   varchar(512),
    PGTYPE          bigint       NOT NULL,
    PGDEPENDS       bigint       NOT NULL,
    PGDEPENDENCIES  varchar(254),
    PGSCHEDULERGUID varchar(72),
    PGSCHEDULEDDATE timestamp
) ;

create table mtext.MXCSMTEXTSERVERS (
    MSSERVERID     varchar(200) NOT NULL,
    MSTYPE         bigint       NOT NULL,
    MSCALLBACKDATA bytea
) ;

create table mtext.MXCSSERVERINFO (
    SIGUID                 varchar(36)  NOT NULL,
    SISERVER               varchar(50)  NOT NULL,
    SIDESCRIPTION          varchar(255),
    SIDATABASEVERSION      bigint       NOT NULL,
    SIUNCOMMITTEDPACKAGES  integer,
    SILATESTACTIVATIONDATE timestamp,
	SIREPOSITORYURL VARCHAR(254)
) ;

create table mtext.MXCSFLDRTREEVER (
    VERSION bigserial
) ;

create table mtext.MXCSMODKEYS (
    MKIDENT      bigserial,
    MKDOCIDENT   bigint NOT NULL,
    MKDOCVERSION bigint NOT NULL,
    MKVALUE      varchar(254)
) ;

create table mtext.MXCSDOCUMENTPROPDESCRIPTORS (
    DCPPDSNAME        varchar(254)  NOT NULL,
    DCPPDSVALUE       varchar(254) NOT NULL,
    DCPPDSLOCALE      varchar(5)   NOT NULL,
    DCPPDSDESCRIPTION text
) ;

create table mtext.MXCSDOCI18N (
	I18NIDENT bigint not null,
	I18NLOCALE varchar(5) not null,
	I18NTITLE varchar(128),
	I18NDESCRIPTION varchar(254)
) ;

create table mtext.MXCSRESI18N (
	RI18NIDENT bigint not null,
	RI18NLOCALE varchar(5) not null,
	RI18NTITLE varchar(128),
	RI18NDESCRIPTION varchar(254)
) ;

create table mtext.MXCSERASER (
    ERIDENT				bigint       NOT NULL,
    ERNAME				varchar(128) NOT NULL,
    ERSTATE				smallint,
	ERSCHEDULEDATE		timestamp,
	ERALIVETIMESTAMP 	timestamp
) ;

create table mtext.MXCSDOCPRINTINFO (
    PIFDocIdent bigint NOT NULL,
    PIFSequence bigint NOT NULL,
    PIFDestination varchar(128),
    PIFUserGUID varchar(36),
    PIFTimestamp timestamp
) ;

create table mtext.MXCSDOCPRINTINFOKEYS (
    PIKDocIdent bigint NOT NULL,
    PIKPIFSequence bigint NOT NULL,
    PIKSequence bigint NOT NULL,
    PIKKey varchar(128) NOT NULL,
    PIKValue varchar(255)
) ;

create table mtext.MXCSPACKAGEINFO (
    PICURRENTVERSION integer
) ;

create table mtext.MXCSRESOURCE (
	RESIDENT bigint NOT NULL,
	RESTYPE bigint NOT NULL,
	RESFOLDER bigint NOT NULL,
	RESNAME Varchar(254) NOT NULL,
	RESACTIVEVERSION bigint,
	RESLASTVERSION bigint,
	RESCHARSET Varchar(40),
	RESCREATORGUID Varchar(36),
	RESCREATEDDATE Timestamp,
	RESDESCRIPTION Varchar(254),
	RESCHANGERGUID Varchar(36),
	RESCHANGEDDATE Timestamp,
	RESUSEVERSIONS Smallint,
	RESTITLE Varchar(128),
	RESCONTENTHASH    CHAR(40),
	RESSTATE bigint NOT NULL default 0
);

create table mtext.MXCSRESOURCEBLOBS (
	RSBLIDENT bigint NOT NULL,
	RSBLVERSION bigint NOT NULL,
	RSBLTYPE bigint NOT NULL,
	RSBLCOMPRESSION bigint NOT NULL,
	RSBLDATA bytea
);

create table mtext.MXCSRESOURCEPROPERTIES (
    RSPPSEQ bigserial,
    RSPPIDENT bigint NOT NULL,
    RSPPNAME Varchar(254) NOT NULL,
    RSPPVALUE Varchar(254)
);

create table mtext.MXCSRESOURCEVERSIONS (
	RSVRIDENT bigint NOT NULL,
	RSVRVERSION bigint NOT NULL,
	RSVRDESCRIPTION Varchar(254),
	RSVRCHANGERGUID Varchar(36),
	RSVRCHANGEDDATE Timestamp,
	RSVRCHARSET Varchar(20) NOT NULL,
	RSVRTITLE Varchar(128),
	RSVRCONTENTHASH CHAR(40),
	RSVRSTATE bigint NOT NULL default 0
);

-- ==============================================
--    Sequences
-- ==============================================

create sequence mtext.MXCSFOLSEQ      increment by  1;
create sequence mtext.MXCSDOCSEQ      increment by 50;
create sequence mtext.MXCSFLDRTREESEQ increment by  1;
create sequence mtext.MXCSINSTFOLSEQ  increment by  1 minvalue 0 cache 1;
create sequence mtext.MXCSINSTPKGSEQ  increment by 50;
create sequence mtext.MXCSINSTVERSEQ  increment by  1;
create sequence mtext.MXCSINSTGRPSEQ  increment by  1;
create sequence mtext.MXCSERSEQ		  increment by  1;

-- ==============================================
--    Constraints
-- ==============================================

-- primary keys
alter table mtext.MXCSDOCFOLDERS
    add constraint PK_MXCSDOCFOLDERS primary key (FLDRIDENT);
    
alter table mtext.MXCSDOCUMENT
    add constraint PK_MXCSDOCUMENT primary key (DOCIDENT);
    
alter table mtext.MXCSDOCUMENTBLOBS
    add constraint PK_MXCSDOCUMENTBLO primary key (RBLBIDENT,RBLBVERSION,RBLBTYPE);
    
alter table mtext.MXCSDOCUMENTPROPERTIES
    add constraint PK_MXCSDOCUMENTPRO primary key (DCPPSEQ);
    
alter table mtext.MXCSDOCUMENTVERSIONS
    add constraint PK_MXCSDOCUMENTVER primary key (VERIDENT,VERVERSION);
        
alter table mtext.MXCSMODKEYS
    add constraint PK_MXCSMODKEYS primary key (MKIDENT);
    
alter table mtext.MXCSMODPREVIEW
    add constraint PK_MXCSMODPREVIEW primary key (MPDOCIDENT, MPDOCVERSION);
    
alter table mtext.MXCSINSTFOLDERS
    add constraint PK_MXCSINSTFOLDERS primary key (INSFIDENT);
    
alter table mtext.MXCSINSTPCKGS
    add constraint PK_MXCSINSTPCKGS primary key (IPIDENT);
    
alter table mtext.MXCSINSTBLOBS
    add constraint PK_MXCSINSTBLOBS primary key (IPBIDENT);
    
alter table mtext.MXCSPACKAGEGROUPS
    add constraint PK_MXCSPCKGGROUPS primary key (PGIDENT);
    
alter table mtext.MXCSMTEXTSERVERS
    add constraint PK_MXCSMTEXTSRVS primary key (MSSERVERID);

alter table mtext.MXCSDOCUMENTPROPDESCRIPTORS
    add constraint PK_MXCSDOCPROPDESCRIPTORS primary key (DCPPDSNAME, DCPPDSVALUE, DCPPDSLOCALE);
	
alter table mtext.MXCSERASER
    add constraint PK_MXCSERASER primary key (ERIDENT);

alter table mtext.MXCSDOCPRINTINFO 
    add constraint PK_MXCSDOCPRINTINFO primary key (PIFDocIdent, PIFSequence);
alter table mtext.MXCSDOCPRINTINFOKEYS 
    add constraint PK_MXCSDOCPRINTINFOKEYS primary key (PIKDocIdent, PIKPIFSequence, PIKSequence);

alter table mtext.MXCSDOCI18N 
    add constraint PK_MXCSDOCI18N primary key (I18NIDENT, I18NLOCALE);

alter table mtext.MXCSRESI18N 
    add constraint PK_MXCSRESI18N primary key (RI18NIDENT, RI18NLOCALE);

alter table mtext.MXCSRESOURCE 
    add constraint PK_MXCSRESOURCE primary key (RESIDENT);
alter table mtext.MXCSRESOURCEBLOBS 
    add constraint PK_MXCSRESBLOB primary key (RSBLIDENT,RSBLVERSION,RSBLTYPE);
alter table mtext.MXCSRESOURCEPROPERTIES 
    add constraint PK_MXCSRESPROP primary key (RSPPSEQ);
alter table mtext.MXCSRESOURCEVERSIONS 
    add constraint PK_MXCSRESVERSION primary key (RSVRIDENT,RSVRVERSION);

-- foreign keys
alter table mtext.MXCSDOCFOLDERS add constraint MXCSDOCFOLDOCFO_FK
    foreign key (FLDRPARENT) references mtext.MXCSDOCFOLDERS (FLDRIDENT);
    
alter table mtext.MXCSDOCUMENT add constraint MXCSDOCFOLDOC_FK
    foreign key (DOCFOLDER) references mtext.MXCSDOCFOLDERS (FLDRIDENT);
    
alter table mtext.MXCSDOCUMENTVERSIONS add constraint MXCSDOCDOCVER_FK
    foreign key (VERIDENT) references mtext.MXCSDOCUMENT (DOCIDENT)
    on delete cascade;
    
alter table mtext.MXCSDOCUMENTPROPERTIES add constraint MXCSDOCDOCPROP_FK
    foreign key (DCPPIDENT) references mtext.MXCSDOCUMENT (DOCIDENT)
    on delete cascade;
    
alter table mtext.MXCSDOCUMENTBLOBS add constraint MXCSDOCVERDOCBL_FK
    foreign key (RBLBIDENT,RBLBVERSION) references mtext.MXCSDOCUMENTVERSIONS (VERIDENT,VERVERSION)
    on delete cascade;
    
alter table mtext.MXCSMODKEYS add constraint MXCSMODKEYS_FK
    foreign key (MKDOCIDENT, MKDOCVERSION) references mtext.MXCSRESOURCEVERSIONS (RSVRIDENT, RSVRVERSION)
    on delete cascade;
    
alter table mtext.MXCSMODPREVIEW add constraint MXCSMODPREVIEW_FK
    foreign key (MPDOCIDENT, MPDOCVERSION) references mtext.MXCSRESOURCEVERSIONS (RSVRIDENT, RSVRVERSION)
    on delete cascade;
    
alter table mtext.MXCSINSTFOLDERS add constraint MXCSINSTFO_FK
    foreign key (INSFPARENT) references mtext.MXCSINSTFOLDERS (INSFIDENT);
    
alter table mtext.MXCSINSTPCKGS add constraint MXCSINSTPCKGS_FK
    foreign key (IPFOLDER) references mtext.MXCSINSTFOLDERS (INSFIDENT);
    
alter table mtext.MXCSINSTBLOBS add constraint MXCSINSTBLOBS_FK
    foreign key (IPBIDENT) references mtext.MXCSINSTPCKGS (IPIDENT)
    on delete cascade;

alter table mtext.MXCSINSTPCKGS add constraint MXCSINSTPCKGS_FK1
    foreign key (IPACTIVATEGROUP) references mtext.MXCSPACKAGEGROUPS(PGIDENT)
    on delete cascade;

alter table mtext.MXCSDOCPRINTINFO add constraint MXCSDOCPRINTINFO_FK 
     foreign key (PIFDocIdent)references mtext.MXCSDOCUMENT(DOCIDENT) 
     on delete cascade;

alter table mtext.MXCSDOCPRINTINFOKEYS add Constraint MXCSDOCPRINTINFOKEYS_FK 
     foreign key (PIKDocIdent, PIKPIFSequence) references mtext.MXCSDOCPRINTINFO(PIFDOCIDENT, PIFSequence) 
     on delete cascade;

alter table mtext.MXCSDOCI18N add Constraint MXCSDOCI18N_FK foreign key (I18NIDENT) 
      references mtext.MXCSDOCUMENT(DOCIDENT) on delete cascade;
alter table mtext.MXCSRESI18N add Constraint MXCSRESI18N_FK foreign key (RI18NIDENT) 
      references mtext.MXCSRESOURCE(RESIDENT) on delete cascade;

alter table mtext.MXCSRESOURCE add Constraint MXCSRESFOLDOC_FK foreign key (RESFOLDER) 
      references mtext.MXCSDOCFOLDERS (FLDRIDENT)  on delete  restrict;
alter table mtext.MXCSRESOURCEVERSIONS add Constraint MXCSRESVER_FK foreign key (RSVRIDENT) 
      references mtext.MXCSRESOURCE (RESIDENT)  on delete  cascade;
alter table mtext.MXCSRESOURCEPROPERTIES add Constraint MXCSRESPROP_FK foreign key (RSPPIDENT) 
      references mtext.MXCSRESOURCE (RESIDENT)  on delete  cascade;
alter table mtext.MXCSRESOURCEBLOBS add Constraint MXCSRESVERDOCBL_FK foreign key (RSBLIDENT,RSBLVERSION) 
      references mtext.MXCSRESOURCEVERSIONS(RSVRIDENT,RSVRVERSION) on delete cascade;
	  
-- ==============================================
--    Indices
-- ==============================================
create unique index MXCSDOCFOLUNIQNAME on mtext.MXCSDOCFOLDERS (FLDRPARENT,FLDRNAME) ;
create unique index MXCSDOCUNIQNAME    on mtext.MXCSDOCUMENT (DOCFOLDER,DOCNAME) ;
create unique index MXCSPCKGGROUPSIDX  on mtext.MXCSPACKAGEGROUPS (PGNAME, PGVERSIONLABEL) ;
create unique index MXCSERUNIQNAME on mtext.MXCSERASER (ERNAME) ;
create unique index MXCSRESUNIQNAME on mtext.MXCSRESOURCE (RESFOLDER,RESNAME) ;

create index MXCSINSTVERIDX on mtext.MXCSINSTPCKGS (IPVERSION) ;
create index MXCSINSTGRPIDX on mtext.MXCSINSTPCKGS (IPACTIVATEGROUP) ;

create index MXCSPROPNAMEVALUEIDX on mtext.MXCSDOCUMENTPROPERTIES (DCPPNAME, DCPPVALUE) ;

create index MXCSDOCDESCRIPTIONIDX on mtext.MXCSDOCUMENT(DOCDESCRIPTION) ;
create index MXCSDOCMSTATEIDX on mtext.MXCSDOCUMENT (DOCMETASTATE) ;
create index MXCSDOCMASSIGNEEIDX on mtext.MXCSDOCUMENT (DOCMETAASSIGNEE) ;

create index MXCSDCPPIDENTIDX on mtext.MXCSDOCUMENTPROPERTIES(DCPPIDENT) ;
create index MXCSDPIDX1 ON mtext.MXCSDOCUMENTPROPERTIES (DCPPVALUE ASC, DCPPIDENT DESC) ;
create index MXCSDPIDX2 ON mtext.MXCSDOCUMENTPROPERTIES (DCPPNAME ASC, DCPPVALUE ASC, DCPPIDENT ASC) ;
create index MXCSDPIDX3 ON mtext.MXCSDOCUMENTPROPERTIES (DCPPNAME ASC, DCPPIDENT ASC, DCPPVALUE ASC) ;
create index MXCSMXCSMODKEYSIDX on mtext.MXCSMODKEYS(MKDOCIDENT, MKDOCVERSION) ;
create index MXCSINSTFPARENTIDX on mtext.MXCSInstFolders(INSFPARENT) ;
create index MXCSINSTPCKGFLRDIDX on mtext.MXCSInstPckgs(IPFOLDER) ;

create index MXCSDOCPIK_KEYIDX on mtext.MXCSDOCPRINTINFOKEYS(PIKKey) ;
create index MXCSDOCPIK_VALUEIDX on mtext.MXCSDOCPRINTINFOKEYS(PIKValue) ;
create index MXCSDOCSTATEIDX on mtext.MXCSDOCUMENT(DOCSTATE) ;
create index MXCSVERSTATEIDX on mtext.MXCSDOCUMENTVERSIONS(VERSTATE) ;

create index MXCSRSPPIDENTIDX ON mtext.MXCSRESOURCEPROPERTIES(RSPPIDENT) ;
create index MXCSRESSTATEIDX ON mtext.MXCSRESOURCE(RESSTATE) ;
create index MXCSRESVERSTATEIDX ON mtext.MXCSRESOURCEVERSIONS(RSVRSTATE) ;
create index MXCSRESIDX1 ON mtext.MXCSRESOURCEPROPERTIES (RSPPVALUE ASC, RSPPIDENT DESC) ;
create index MXCSRESIDX2 ON mtext.MXCSRESOURCEPROPERTIES (RSPPNAME ASC, RSPPVALUE ASC, RSPPIDENT ASC) ;
create index MXCSRESIDX3 ON mtext.MXCSRESOURCEPROPERTIES (RSPPNAME ASC, RSPPIDENT ASC, RSPPVALUE ASC) ;
create index MXCSRESTYPEIDX ON mtext.MXCSRESOURCE(RESTYPE) ;
-- ==============================================
--    Initial data
-- ==============================================

-- to make sure we have just 1 record in MXCSDUAL table and a starting value
delete from mtext.MXCSDUAL;
insert into mtext.MXCSDUAL values(0);

delete from mtext.MXCSFLDRTREEVER;
insert into mtext.MXCSFLDRTREEVER (VERSION) values(0);

insert into mtext.MXCSPACKAGEGROUPS(PGIDENT, PGNAME, PGVERSIONLABEL, PGVERSION, PGDEPENDS)
    select IPACTIVATEGROUP, 'no name ' || IPACTIVATEGROUP, '1.0.0', IPVERSION, IPACTIVATEGROUP
    from mtext.MXCSINSTPCKGS group by IPACTIVATEGROUP,IPVERSION;

insert into mtext.MXCSDOCFOLDERS
    (FLDRIDENT, FLDRPARENT, FLDRMODELVERSION, FLDRNAME, FLDRSYSATTR, FLDRDESCRIPTION)
    values (-1,-1,0,'root',0,'');

insert into mtext.MXCSINSTFOLDERS(INSFIDENT, INSFPARENT, INSFNAME, INSFSYSATTR, INSFACTIVEVERSION)
    values (-1,-1,'root',0,-1);

-- Please fill in a database name and description which will identify the M/TEXT server instance
-- Leave the SIGUID field empty, it will be automatically generated during the first startup of the server
-- SIUncommittedPackages value greater than 0 allows activating packages with uncommitted resources, default is 0
-- SILatestActivationDate default is Date(0)
insert into mtext.MXCSSERVERINFO(SIGUID, SISERVER, SIDESCRIPTION, SIDATABASEVERSION, SIUNCOMMITTEDPACKAGES, SILATESTACTIVATIONDATE)
    values (' ', 'SerieM', 'Description', 23, 0, null);
update mtext.MXCSSERVERINFO set SILATESTACTIVATIONDATE=(select CURRENT_TIMESTAMP);

-- ======================================================
--      connect
-- ======================================================
-- connect to ${DATABASE_NAME} user ${DATABASE_USER} using "${DATABASE_PASSWORD}"

-- ==============================================
--    Triggers            
-- ==============================================

create function mtext.PROC_MXCSDOCFOLDERS() returns trigger as $PROC_MXCSDOCFOLDERS$
   begin
      update mtext.MXCSFLDRTREEVER set VERSION = nextval('mtext.MXCSFLDRTREESEQ');
      return null;
   end;
$PROC_MXCSDOCFOLDERS$ language plpgsql;


create function mtext.PROC_MXCSDOCFOLDERS_RECURRENT() returns trigger as $PROC_MXCSDOCFOLDERS_RECURRENT$
   begin
      if (new.FLDRIDENT != old.FLDRIDENT) then
         update mtext.MXCSDOCFOLDERS set FLDRPARENT = new.FLDRIDENT where FLDRPARENT = old.FLDRIDENT;
         update mtext.MXCSDOCUMENT   set DOCFOLDER  = new.FLDRIDENT where DOCFOLDER  = old.FLDRIDENT;
      end if;
      return null;
   end;
$PROC_MXCSDOCFOLDERS_RECURRENT$ language plpgsql;

create function mtext.PROC_MXCSDOCVERSIONS() returns trigger as $PROC_MXCSDOCVERSIONS$
   begin
      if ((new.VERIDENT != old.VERIDENT) or (new.VERVERSION != old.VERVERSION)) then
         update mtext.MXCSDOCUMENTBLOBS
         set RBLBIDENT = new.VERIDENT, RBLBVERSION = new.VERVERSION
         where RBLBIDENT = old.VERIDENT and RBLBVERSION = old.VERVERSION;
      end if;
      return null;
   end;
$PROC_MXCSDOCVERSIONS$ language plpgsql;

create function mtext.PROC_MXCSINSTFOLDERS() returns trigger as $PROC_MXCSINSTFOLDERS$
   begin
      if ((new.INSFIDENT != old.INSFIDENT)) then
         update mtext.MXCSINSTPCKGS set IPFOLDER = new.INSFIDENT where IPFOLDER = old.INSFIDENT;
      end if;
      return null;
   end;
$PROC_MXCSINSTFOLDERS$ language plpgsql;

create trigger TAU_MXCSDOCFOLDERS_RECURRENT
after update on mtext.MXCSDOCFOLDERS
for each row execute procedure mtext.PROC_MXCSDOCFOLDERS_RECURRENT();

create trigger TBI_MXCSDOCFOLDERS
after insert on mtext.MXCSDOCFOLDERS
for each row execute procedure mtext.PROC_MXCSDOCFOLDERS();

create trigger TAU_MXCSDOCFOLDERS
after update on mtext.MXCSDOCFOLDERS
for each row execute procedure mtext.PROC_MXCSDOCFOLDERS();

create trigger TAD_MXCSDOCFOLDERS
after delete on mtext.MXCSDOCFOLDERS
for each row execute procedure mtext.PROC_MXCSDOCFOLDERS();

create trigger TAU_MXCSDOCVERSIONS
after update on mtext.MXCSDOCUMENTVERSIONS
for each row execute procedure mtext.PROC_MXCSDOCVERSIONS();

create trigger TAU_MXCSINSTFOLDERS
after update on mtext.MXCSINSTFOLDERS
for each row execute procedure mtext.PROC_MXCSINSTFOLDERS();

-- Create m/user tables

-- In case of manual execution please do following replacements:
-- 'mtext' with database user schema name. In case of default user schema
--    delete all 'mtext.' ocurrences. (including trailing dot) 
-- '' with 'TABLESPACE <tablespace_name>' or remove when
--    default tablespace is used. 
-- '' with 'TABLESPACE <blob_tablespace_name>' 
--   or remove when default tablespace is used.

-- Please pay attention to database tablespaces oraganization. In many cases
-- you will like to have separate storage for blobs and other data.
-- In this cases is necessary the <tablespace_name> and <blob_tablespace_name>
-- point to different tablespaces on different storages.
-- Please check the PostgreSQL documentation


START TRANSACTION;
-- /* ************************************************************************ */
-- /* Create tables */
-- /* ************************************************************************ */
-- /* Company                                                                  */
create table mtext.muCompany (
  company_key integer NOT NULL,
  comp_parent_key integer,
  obj_id integer NOT NULL,
  name varchar(50),
  description varchar(50),
  readonly smallint,
  PRIMARY KEY (company_key),
  FOREIGN KEY (comp_parent_key) REFERENCES mtext.muCompany(company_key)
) ;
create UNIQUE index i_muCompany_name on mtext.muCompany(comp_parent_key, name) ;

-- /* ************************************************************************ */
-- /* Department                                                               */
create table mtext.muDepartment (
  department_key integer NOT NULL,
  dep_parent_key integer,
  obj_id integer NOT NULL,
  company_key integer NOT NULL,
  name varchar(50),
  description varchar(50),
  readonly smallint,
  PRIMARY KEY (department_key),
  FOREIGN KEY (company_key) REFERENCES mtext.muCompany(company_key),
  FOREIGN KEY (dep_parent_key) REFERENCES mtext.muDepartment(department_key)
) ;
create UNIQUE index i_muDepartment_name on mtext.muDepartment(company_key, dep_parent_key, name) ;

-- /* ************************************************************************ */
-- /* User                                                                     */
create table mtext.muUser (
   guid varchar(36) NOT NULL,
   obj_id integer NOT NULL,
   department_key integer,
   loginid varchar(50) NOT NULL,
   name varchar(50),
   firstname varchar(50),
   shortname varchar(50) NOT NULL,
   pwd varchar(50),
   reportsto varchar(36),
   valid_from date,
   valid_to date,
   valid_always integer,
   location varchar(50),
   room varchar(50),
   telephone varchar(50),
   fax varchar(50),
   emailaddress varchar(50),
   pop3name varchar(50),
   pop3password varchar(50),
   isexternal integer,
   language integer,
   basicattr integer,
   readonly smallint,
   absentfrom date,
   absentto date,
   absentreason varchar(255),
   cpositionnr varchar(50),
   ctitle varchar(50),
   cposition varchar(50),
   isContact smallint,
   PRIMARY KEY (guid),
   FOREIGN KEY (department_key) REFERENCES mtext.muDepartment (department_key)
) ;
create index i_muUser_loginid on mtext.muUser(loginid) ;

-- /* ************************************************************************ */
-- /* Proxy                                                                    */
create table mtext.muProxy (
  proxy_key integer NOT NULL,
  obj_id integer NOT NULL,
  guid varchar(36),
  proxy_guid varchar(36),
  valid_from date,
  valid_to date,
  readonly smallint,
  PRIMARY KEY (proxy_key),
  FOREIGN KEY (guid) REFERENCES mtext.muUser(guid),
  FOREIGN KEY (proxy_guid) REFERENCES mtext.muUser(guid)
) ;
create index i_muProxy_guid on mtext.muProxy(guid) ;

-- /* ************************************************************************ */
-- /* MText                                                                    */
create table mtext.muMText (
  guid varchar(36) NOT NULL,
  obj_id integer NOT NULL,
  user_class varchar(20),
  printer varchar(20),
  fax smallint,
  env smallint,
  pgm smallint,
  PRIMARY KEY (guid),
  FOREIGN KEY (guid) REFERENCES mtext.muUser (guid)
) ;


-- /* ************************************************************************ */
-- /* Sections                                                                 */
create table mtext.muSections (
  guid varchar(36) NOT NULL,
  obj_id integer NOT NULL,
  section varchar(255),
  element char(1),
  document char(1),
  print char(1),
  templateKey integer,
  PRIMARY KEY (obj_id),
  FOREIGN KEY (guid) REFERENCES mtext.muUser (guid)
) ;
create index i_muSections_guid on mtext.muSections(guid) ;

-- /* ************************************************************************ */
-- /* Nodes                                                                    */
create table mtext.muNodes(
  node_key integer NOT NULL,
  obj_id integer  NOT NULL,
  readonly smallint,
  name varchar(50),
  description varchar(50),
  PRIMARY KEY (node_key)
) ;

-- /* ************************************************************************ */
-- /* SysData                                                                  */
create table mtext.muSysData (
  dbversion integer,
  last_obj_id integer,
  ournode integer,
  FOREIGN KEY (ournode) REFERENCES mtext.muNodes(node_key)
) ;

-- /* ************************************************************************ */
-- /* NodesUser                                                                */
create table mtext.muNodesUser (
  guid varchar(36) NOT NULL,
  node_key integer  NOT NULL,
  PRIMARY KEY (guid, node_key),
  FOREIGN KEY (guid) REFERENCES mtext.muUser (guid),
  FOREIGN KEY (node_key) REFERENCES mtext.muNodes (node_key)
) ;
create index i_muNodesUser_guid on mtext.muNodesUser(guid) ;

-- /* ************************************************************************ */
-- /* TemplateDictionary                                                       */
create table mtext.muTemplateDictionary (
  templatedict_key integer NOT NULL,
  parent_key integer,
  obj_id integer NOT NULL,
  name varchar(50),
  description varchar(255),
  readonly smallint,
  PRIMARY KEY (templatedict_key),
  FOREIGN KEY (parent_key) REFERENCES mtext.muTemplateDictionary(templatedict_key)
) ;
create UNIQUE index i_muTemplateDictionary_name on mtext.muTemplateDictionary(parent_key, name) ;

-- /* ************************************************************************ */
-- /* Template                                                                 */
create table mtext.muTemplate (
  template_key integer NOT NULL,
  templatedict_key integer NOT NULL,
  obj_id integer NOT NULL,
  name varchar(50),
  description varchar(255),
  muType integer,
  valid_from date,
  valid_to date,
  valid_always smallint,
  readonly smallint,
  PRIMARY KEY (template_key),
  FOREIGN KEY (templatedict_key) REFERENCES mtext.muTemplateDictionary(templatedict_key)
) ;
create UNIQUE index i_muTemplate_name on mtext.muTemplate(templatedict_key, name) ;

-- /* ************************************************************************ */
-- /* AttrDefDictionary                                                        */
create table mtext.muAttrDefDictionary(
  attrdefdict_key integer NOT NULL,
  parent_key integer,
  obj_id integer NOT NULL,
  name varchar(50),
  description varchar(255),
  readonly smallint,
  PRIMARY KEY (attrdefdict_key),
  FOREIGN KEY (parent_key) REFERENCES mtext.muAttrDefDictionary(attrdefdict_key)
) ;
create UNIQUE index i_muAttrDefDictionary_name on mtext.muAttrDefDictionary(parent_key, name) ;

-- /* ************************************************************************ */
-- /* AttributeDefinition                                                      */
create table mtext.muAttributeDefinition(
  attributedef_key integer NOT NULL,
  attrdefdict_key integer NOT NULL,
  obj_id integer NOT NULL,
  name varchar(50),
  description varchar(255),
  muType integer,
  valid_from date,
  valid_to date,
  valid_always smallint,
  readonly smallint,
  muEncrypted smallint,
  muCompressed smallint,
  PRIMARY KEY (attributedef_key),
  FOREIGN KEY (attrdefdict_key) REFERENCES mtext.muAttrDefDictionary(attrdefdict_key)
) ;
create UNIQUE index i_muAttributeDefinition_name on mtext.muAttributeDefinition(attrdefdict_key, name) ;

-- /* ************************************************************************ */
-- /* TemplateAttribute                                                        */
create table mtext.muTemplateAttribute (
  attributedef_key integer NOT NULL,
  template_key integer NOT NULL,
  counter integer NOT NULL,
  obj_id integer NOT NULL,
  lower_value varchar(255),
  upper_value varchar(255),
  muIsEncrypted smallint,
  muBlobValue bytea,
  muIsCompressed smallint,
  muUncompressedSize integer,
  muCompressType integer,
  muCanBeOverwritten smallint,
  PRIMARY KEY (attributedef_key, template_key, counter),
  FOREIGN KEY (attributedef_key) REFERENCES mtext.muAttributeDefinition(attributedef_key),
  FOREIGN KEY (template_key) REFERENCES mtext.muTemplate(template_key)
) ;

-- /* ************************************************************************ */
-- /* TemplateUser                                                             */
create table mtext.muTemplateUser (
  guid varchar(36) NOT NULL,
  template_key integer NOT NULL,
  PRIMARY KEY (guid, template_key),
  FOREIGN KEY (guid) REFERENCES mtext.muUser(guid),
  FOREIGN KEY (template_key) REFERENCES mtext.muTemplate(template_key)
) ;

-- /* ************************************************************************ */
-- /* UserAttribute                                                            */
create table mtext.muUserAttribute (
  attributedef_key integer NOT NULL,
  guid varchar(36) NOT NULL,
  counter integer NOT NULL,
  obj_id integer NOT NULL,
  template_key integer,
  lower_value varchar(255),
  upper_value varchar(255),
  muIsEncrypted smallint,
  muBlobValue bytea,
  muIsCompressed smallint,
  muUncompressedSize integer,
  muCompressType integer,
  muCanBeOverwritten smallint,
  PRIMARY KEY (attributedef_key, guid, counter),
  FOREIGN KEY (guid) REFERENCES mtext.muUser(guid),
  FOREIGN KEY (attributedef_key) REFERENCES mtext.muAttributeDefinition(attributedef_key)
) ;

-- /* ************************************************************************ */
-- /* muLogInfo                                                                */
create table mtext.muLogInfo (
  log_key integer NOT NULL,
  obj_id integer  NOT NULL,
  muTimestamp date,
  guid varchar(36),
  tabletype integer,
  text varchar(255),
  btext bytea,
  PRIMARY KEY (log_key)
) ;

-- /* ****************************************************** */
CREATE TABLE mtext.muScript_pattern_folders (
  folder_key integer NOT NULL,
  parent_key integer,
  obj_id integer NOT NULL,
  name varchar(50),
  description bytea,
  readonly smallint,
  PRIMARY KEY (folder_key),
  FOREIGN KEY (parent_key) REFERENCES mtext.muScript_pattern_folders(folder_key)
) ;

-- /* ****************************************************** */
CREATE TABLE mtext.muScript_patterns (
  script_key integer NOT NULL,
  folder_key integer NOT NULL,
  obj_id integer NOT NULL,
  readonly smallint ,
  last_version integer NOT NULL,
  PRIMARY KEY (script_key),
  FOREIGN KEY (folder_key) REFERENCES mtext.muScript_pattern_folders(folder_key)
) ;

-- /* ****************************************************** */
CREATE TABLE mtext.muScript_pattern_data (
  script_key integer NOT NULL,
  version integer NOT NULL,
  muType integer ,
  name varchar(50) ,
  script bytea,
  description bytea,
  version_date date NOT NULL,
  usr_key char(36) NOT NULL,
  usr_name varchar(50) ,
  PRIMARY KEY (script_key, version),
  FOREIGN KEY (script_key) REFERENCES mtext.muScript_patterns(script_key)
) ;

-- /* ************************************************************************ */
-- /* PublicGroup                                                              */
create table mtext.muPublicGroup(
  group_key integer NOT NULL,
  obj_id integer NOT NULL,
  owner varchar(36),
  name varchar(50),
  description varchar(255),
  readonly smallint,
  PRIMARY KEY (group_key)
) ;

-- /* ************************************************************************ */
-- /* UserPublicGroup                                                          */
create table mtext.muUserPublicGroup(
  group_key integer NOT NULL,
  guid varchar(36) NOT NULL,
  PRIMARY KEY (group_key, guid),
  FOREIGN KEY (group_key) REFERENCES mtext.muPublicGroup(group_key),
  FOREIGN KEY (guid) REFERENCES mtext.muUser(guid)
) ;

-- /* ************************************************************************ */
-- /* muDescOverrun                                                            */
create table mtext.muDescOverrun(
  obj_id integer NOT NULL, counter integer NOT NULL, text varchar(255),
  primary key (obj_id, counter)
) ;

COMMIT;

-- Insert minimal data into m/user tables

-- In case of manual execution please do following replacements:
-- 'mtext' with database user schema name. In case of default user schema
--    delete all 'mtext.' ocurrences. (including trailing dot) 

START TRANSACTION;
DELETE FROM mtext.muUser;
INSERT INTO mtext.muUser (guid, obj_id, loginid, shortname, name,
                    pwd, valid_always, language, basicattr, isContact)
           VALUES ('000-000-000', 1, 'MASTER', 'M/User Master', 'M/User Master',
                   'eb0a191797624dd3a48fa681d3061212', -1, 0, 1, 0);

INSERT INTO mtext.muAttrDefDictionary (attrdefdict_key, obj_id, name,
       description, readonly)
       VALUES (2, 2, 'Attribute', '', -1);

INSERT INTO mtext.muTemplateDictionary (templatedict_key, obj_id, name, description)
       VALUES(3, 3, 'Templates', '');
DELETE FROM  mtext.muScript_pattern_folders;
INSERT INTO  mtext.muScript_pattern_folders ( folder_key, parent_key, obj_id, name) 
       VALUES ( 4, NULL, 4, 'Scripte');


DELETE FROM mtext.muNodes;
INSERT INTO mtext.muNodes(node_key, obj_id, name, description)
       VALUES(5, 5, 'DEFAULT', 'Default M/User node');

DELETE FROM mtext.muSysData;
INSERT INTO mtext.muSysData (dbversion, last_obj_id, ournode) VALUES (18, 10, 5);

COMMIT;

-- ================================================================================
--  M/OMS Dispatch Optimizer, PostgreSQL
--  
--  Description: Creation of all tables of the M/OMS Dispatch Optimizer
-- ================================================================================
-- This script was generated by the Assembly Tool.
-- All variable parts should have been replaced. Please check if
-- any placeholders are remaining (placeholders begin with the
-- characters '${') and replace them by actual values.

-- Please pay attention to database tablespaces organization. For a standard
-- installation, you might want to have separate storage for blobs and other data.
-- In this case it is necessary that <tablespace_name> and <blob_tablespace_name>
-- point to different tablespaces on different storages.
-- Please check the PostgreSQL documentation

------------------------------------------------------------
-- System
------------------------------------------------------------
CREATE TABLE mtext.MDOPRODUCTCODES
(
  ID              DECIMAL(10)	NOT NULL,
  TARIFFID        DECIMAL(10),
  ADDSERVICEID    VARCHAR(200),
  NAME            VARCHAR(20),
  DESCRIPTION     VARCHAR(200),
  PRODUCTNUMBER   DECIMAL(10)	DEFAULT null,
  PRODUCTCODE     DECIMAL(10)	DEFAULT null,
  PRODUCTCODE_PA  DECIMAL(10)	DEFAULT null,
  PRIMARY KEY(ID)
) ;

CREATE TABLE mtext.MDOSYSDATA
(
  DBVERSION  VARCHAR(5)
) ;

INSERT INTO mtext.MDOSYSDATA (DBVERSION) VALUES ('6.706');
COMMIT;

------------------------------------------------------------
-- Runtime
------------------------------------------------------------
CREATE TABLE mtext.MDOACCLIST
(
  ID              DECIMAL(10)	NOT NULL,
  ADDRESSERID     VARCHAR(255)	NOT NULL,
  SENDERID        VARCHAR(255)	NOT NULL,
  FEEACCOUNTNO    DECIMAL(10),
  GROSSPOSTAGE    DECIMAL(10)	NOT NULL,
  NETPOSTAGE      DECIMAL(10)	NOT NULL,
  NUMBERMAILINGS  DECIMAL(10)	NOT NULL,
  CANCELLEDAT     TIMESTAMP,
  CLASS           VARCHAR(255),
  PRIMARY KEY(ID)
) ;

CREATE TABLE mtext.MDOADDSERVICELIST
(
  ID                DECIMAL(10)	 NOT NULL,
  TARIFFRESULTID    DECIMAL(10)	 NOT NULL,
  ADDSERVICETYPEID	VARCHAR(255) NOT NULL,
  POSTAGE           DECIMAL(10)	 NOT NULL,
  NUMBERMAILINGS    DECIMAL(10)	 NOT NULL,
  PRIMARY KEY(ID)
) ;

CREATE TABLE mtext.MDOB2BPROTOCOL
(
  ID         DECIMAL(10)	NOT NULL,
  ACCLISTID  DECIMAL(10)	NOT NULL,
  JOBID      DECIMAL(10)	NOT NULL,
  MSGID      VARCHAR(40)	NOT NULL,
  SYSTEMID   VARCHAR(15)	NOT NULL,
  ACTION     VARCHAR(2)		NOT NULL,
  FILENAME   VARCHAR(100),
  TIMESTAMP  TIMESTAMP,
  STATUS     DECIMAL(10),
  PRIMARY KEY(ID)
) ;

CREATE TABLE mtext.MDODISCOUNTLIST
(
  ID              DECIMAL(10)	NOT NULL,
  TARIFFRESULTID  DECIMAL(10)	NOT NULL,
  DISCOUNTNAME    VARCHAR(255)	NOT NULL,
  DISCOUNTVALUE   DECIMAL(10)	NOT NULL,
  DISCOUNTAMOUNT  DECIMAL(10),
  NUMBERMAILINGS  DECIMAL(10)	NOT NULL,
  ADDCHARGE       DECIMAL(10)	DEFAULT 0,
  PRIMARY KEY(ID)
) ;

CREATE TABLE mtext.MDOJOBS
(
  ID                     DECIMAL(10)	NOT NULL,
  ADDRESSERID            VARCHAR(255)	NOT NULL,
  OPTIMIZERID            VARCHAR(255)	NOT NULL,
  SENDERID               VARCHAR(255)	NOT NULL,
  DEBTORID               VARCHAR(255)	NOT NULL,
  SUBMITTER              VARCHAR(1)		DEFAULT 'O'	NOT NULL,
  TIMESTART              TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
  TIMEEND                TIMESTAMP		NOT NULL,
  STATUS                 DECIMAL(10)	NOT NULL,
  ERROR                  DECIMAL(10)	NOT NULL,
  STATUSDESCRIPTION      VARCHAR(255),
  TOTALPOSTAGE           DECIMAL(10)	DEFAULT 0,
  BZA                    DECIMAL(10)	DEFAULT 0,
  BZE                    DECIMAL(10)	DEFAULT 0,
  SENDING                TIMESTAMP		NOT NULL,
  BOXPROD                DECIMAL(10)	DEFAULT 0,
  PALETTESPROD           DECIMAL(10)	DEFAULT 0,
  FREEING                VARCHAR(10),
  PRINTLIST              DECIMAL(10),
  XMLLIST                DECIMAL(10),
  NAME                   VARCHAR(255),
  COOPERATIONAGREEMENT   DECIMAL(10)	DEFAULT 0,
  DOCCOUNTTOTAL          DECIMAL(10)	DEFAULT 0,
  DOCCOUNTERROR          DECIMAL(10)	DEFAULT 0,
  DOCCOUNTINTERNATIONAL  DECIMAL(10)	DEFAULT 0,
  DOCCOUNTNATIONAL       DECIMAL(10)	DEFAULT 0,
  PRICEVERSION           VARCHAR(20)	DEFAULT 0,
  B2BXML                 DECIMAL(10)	DEFAULT 0,
  ADDSERVICES            DECIMAL(10)	DEFAULT 0,
  PRIMARY KEY(ID)
) ;

CREATE TABLE mtext.MDOMETHODNO
(
  ID            DECIMAL(10)	NOT NULL,
  CUSTOMERID 	VARCHAR(40) NOT NULL,
  METHODNO		VARCHAR(4)	NOT NULL,
  ACCOUNTNO     DECIMAL(10)	DEFAULT 0,
  LASTPROCDATE  TIMESTAMP,
  PRIMARY KEY(ID),
  CONSTRAINT UCNUMBERRANGE UNIQUE (CUSTOMERID,METHODNO)
) ;

CREATE TABLE mtext.MDOSERVICEIDENTCODE
(
  ID              DECIMAL(10)	NOT NULL,
  PROVIDER        VARCHAR(200),
  ADDSERVICEID    VARCHAR(200),
  TRANSMISSIONNUMBER_LAST  DECIMAL(10)	NOT NULL,
  PRIMARY KEY(ID),
  CONSTRAINT MDOSERVICEIDENTCODE_UC UNIQUE (PROVIDER,ADDSERVICEID)
) ;

CREATE TABLE mtext.MDOTARIFFRESULT
(
  ID               DECIMAL(10)	NOT NULL,
  MDOJOBID         DECIMAL(10)	NOT NULL,
  MAILINGCLASS     VARCHAR(40)	NOT NULL,
  MAILINGTYPE      VARCHAR(50)	NOT NULL,
  TARIFFID         DECIMAL(10)	NOT NULL,
  DOCTYPE          VARCHAR(40)	NOT NULL,
  NUMDOCS          DECIMAL(10)	NOT NULL,
  ADDCHARGE        DECIMAL(10)	DEFAULT 0,
  POSTAGE          DECIMAL(10)	NOT NULL,
  PORTOEFFECTIVE   DECIMAL(10)	NOT NULL,
  PORTOTARIFF      DECIMAL(10)	NOT NULL,
  SORTED           DECIMAL(10)	DEFAULT 1,
  COUNTRYGROUP 	   VARCHAR(10) DEFAULT NULL,
  TRANSPORT        VARCHAR(10) DEFAULT 'LAND',
  FINALSTACKID     DECIMAL(10)	NOT NULL,
  ACCLISTID        DECIMAL(10),
  DISCOUNT         DECIMAL(10),
  ADDSERVICE       DECIMAL(10),
  ACCOUNTFILENAME  VARCHAR(255),
  SENDFILENAME     VARCHAR(255),
  POSTINGFILENAME  VARCHAR(255),
  BOXCOUNT         DECIMAL(10)	DEFAULT 0,
  PALCOUNT         DECIMAL(10)	DEFAULT 0,
  FEEACCOUNTNO     DECIMAL(10),
  BZAACCOUNTNO     DECIMAL(10),
  BZEACCOUNTNO     DECIMAL(10),
  VARIANTNAME 	   VARCHAR(255) DEFAULT NULL,
  PREMIUMADRESS    VARCHAR(255) DEFAULT NULL,
  PIECESOFEVIDENCE VARCHAR(255) DEFAULT NULL,
  PRIORITY         DECIMAL(1)	DEFAULT 1,
  PRIMARY KEY(ID),
  FOREIGN KEY(MDOJOBID) REFERENCES mtext.MDOJOBS,
  FOREIGN KEY(ACCLISTID) REFERENCES mtext.MDOACCLIST
) ;

CREATE TABLE mtext.MDORESOURCE
(
  	ID         			DECIMAL(10) NOT NULL,
	MDOJOBID         	DECIMAL(10) NOT NULL,
	RESOURCE_NAME		VARCHAR(255) NOT NULL,
	RESOURCE_TYPE		VARCHAR(20) NOT NULL,
	RESOURCE_SIZE 		DECIMAL(10,0) NOT NULL,
	RESOURCE_COMPR_SIZE	DECIMAL(10,0) NOT NULL,
	RESOURCE_DATA		BYTEA,
  	PRIMARY KEY(ID),
	FOREIGN KEY(MDOJOBID) REFERENCES mtext.MDOJOBS,
	UNIQUE (MDOJOBID, RESOURCE_NAME, RESOURCE_TYPE)
) ;

------------------------------------------------------------
-- Sequences
------------------------------------------------------------
CREATE SEQUENCE mtext.MDO_NEXT_ACCLIST_ID MINVALUE 1 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mtext.MDO_NEXT_ADDSERVICE_ID MINVALUE 1 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mtext.MDO_NEXT_DISCOUNT_ID MINVALUE 1 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mtext.MDO_NEXT_JOB_ID MINVALUE 1 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mtext.MDO_NEXT_TARIFFRESULT_ID MINVALUE 1 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mtext.MDO_NEXT_OBJECT_ID MINVALUE 1 START WITH 1 INCREMENT BY 1;

------------------------------------------------------------
-- Views
------------------------------------------------------------
CREATE VIEW mtext.MDOCOCKPIT_B2B_VIEW
(
  JOBID,
  NAME,
  FEEACCOUNTNO,
  ACCLISTID,
  MSGID,
  SYSTEMID,
  ACTION,
  B2BTIMESTAMP,
  STATUS,
  NEWESTSTATUS,
  FILENAME,  
  NUMBERMAILINGS,
  TIMESTART,
  TIMEEND,
  ADDRESSERID
)
AS
SELECT B2B.JOBID, JOB.NAME, ACC.FEEACCOUNTNO, B2B.ACCLISTID, B2B.MSGID, B2B.SYSTEMID, B2B.ACTION, B2B.TIMESTAMP, B2B.STATUS, SUB.STATUS, B2B.FILENAME, ACC.NUMBERMAILINGS, JOB.TIMESTART, JOB.TIMEEND, JOB.ADDRESSERID
FROM mtext.MDOB2BPROTOCOL B2B
JOIN mtext.MDOJOBS JOB ON B2B.JOBID = JOB.ID
JOIN mtext.MDOACCLIST ACC ON B2B.ACCLISTID = ACC.ID
JOIN (
  SELECT DISTINCT ON (MSGID) * FROM mtext.MDOB2BPROTOCOL ORDER BY MSGID DESC, TIMESTAMP DESC
) SUB ON B2B.JOBID = SUB.JOBID AND B2B.MSGID = SUB.MSGID;

CREATE VIEW mtext.MDOCOCKPIT_TARIFFTREE_VIEW
(
  CLASS,
  MSGID,
  STATUS,
  NUMBERMAILINGS,
  SUMADDCHARGE,
  GROSSPOSTAGE,
  JOBID,
  ACCLISTID,
  FEEACCOUNTNO
)
AS
SELECT ACC.CLASS, B2B.MSGID, B2B.STATUS, ACC.NUMBERMAILINGS, SUB.SUMADDCHARGE, ACC.GROSSPOSTAGE, B2B.JOBID, B2B.ACCLISTID, ACC.FEEACCOUNTNO
FROM mtext.MDOACCLIST ACC
JOIN mtext.MDOB2BPROTOCOL B2B ON ACC.ID = B2B.ACCLISTID AND B2B.TIMESTAMP = (SELECT MAX(TIMESTAMP) FROM mtext.MDOB2BPROTOCOL WHERE ACCLISTID = B2B.ACCLISTID)
JOIN (
  SELECT MDOJOBID, ACCLISTID, SUM(ADDCHARGE) SUMADDCHARGE
  FROM mtext.MDOTARIFFRESULT
  GROUP BY MDOJOBID, ACCLISTID
) SUB ON SUB.ACCLISTID = B2B.ACCLISTID;

CREATE VIEW mtext.MDOCOCKPIT_TARIFFRESULTS_VIEW
(
  ID,
  NAME,
  MAILING,
  NUMBERMAILINGS
)
AS
SELECT TR.ID, JOB.NAME, CASE WHEN TR.MAILINGTYPE like '%International%' THEN TR.MAILINGTYPE ELSE TR.MAILINGCLASS || ' ' || TR.MAILINGTYPE END, ACC.NUMBERMAILINGS
FROM mtext.MDOTARIFFRESULT TR
JOIN mtext.MDOJOBS JOB ON TR.MDOJOBID = JOB.ID
LEFT OUTER JOIN mtext.MDOACCLIST ACC ON TR.ACCLISTID = ACC.ID;

COMMIT; 

-- ================================================================================
--  M/OMS Dispatch Optimizer, PostgreSQL
--  
--  Description: Filling initial data into the tables of the M/OMS Dispatch Optimizer
-- ================================================================================
-- This script was generated by the Assembly Tool.
-- All variable parts should have been replaced. Please check if
-- any placeholders are remaining (placeholders begin with the
-- characters '${') and replace them by actual values.

DELETE FROM mtext.MDOPRODUCTCODES;
COMMIT;

--------------------------------------------------------------------------------
-- Briefpost
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(1,0,NULL,'EE_DV','Entgeltermäßigung DV-Freimachung',239036248,NULL,NULL),
(2,10,NULL,'TARIFF','Briefpost Standardbrief',102100001,1,NULL),
(3,10,'EW','TARIFF','Briefpost Standardbrief + Einschreiben Einwurf',102100001,1002,NULL),
(4,10,'NA','TARIFF','Briefpost Standardbrief + Nachnahme',102100001,1003,NULL),
(5,10,'ES','TARIFF','Briefpost Standardbrief + Einschreiben',102100001,1007,NULL),
(6,10,'ES;RS','TARIFF','Briefpost Standardbrief + Einschreiben Rückschein',102100001,1008,NULL),
(7,10,'ES;EH','TARIFF','Briefpost Standardbrief + Einschreiben Eigenhändig',102100001,1009,NULL),
(8,10,'ES;EH;RS','TARIFF','Briefpost Standardbrief + Einschreiben Eigenhändig Rückschein',102100001,1010,NULL),
(9,10,NULL,'PA_BASIS','Briefpost Standardbrief + Premiumadress Basis',102100001,9501,9991),
(10,10,'NA','PA_BASIS','Briefpost Standardbrief + Premiumadress Basis + Nachnahme',102100001,9508,9991),
(11,10,NULL,'PA_PLUS','Briefpost Standardbrief + Premiumadress Plus',102100001,9001,9992),
(12,10,'EW','PA_PLUS','Briefpost Standardbrief + Premiumadress Plus + Einschreiben Einwurf',102100001,9003,9992),
(13,10,'NA','PA_PLUS','Briefpost Standardbrief + Premiumadress Plus + Nachnahme',102100001,9005,9992),
(14,10,'ES','PA_PLUS','Briefpost Standardbrief + Premiumadress Plus + Einschreiben',102100001,9010,9992),
(15,10,'ES;RS','PA_PLUS','Briefpost Standardbrief + Premiumadress Plus + Einschreiben Rückschein',102100001,9011,9992),
(16,10,'ES;EH','PA_PLUS','Briefpost Standardbrief + Premiumadress Plus + Einschreiben Eigenhändig',102100001,9012,9992),
(17,10,'ES;EH;RS','PA_PLUS','Briefpost Standardbrief + Premiumadress Plus + Einschreiben Eigenhändig Rückschein',102100001,9013,9992),
(18,10,NULL,'PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus',102100001,9014,9993),
(19,10,'EW','PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus + Einschreiben Einwurf',102100001,9016,9993),
(20,10,'NA','PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus + Nachnahme',102100001,9018,9993),
(21,10,'ES','PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus + Einschreiben',102100001,9023,9993),
(22,10,'ES;RS','PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus + Einschreiben Rückschein',102100001,9024,9993),
(23,10,'ES;EH','PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus + Einschreiben Eigenhändig',102100001,9025,9993),
(24,10,'ES;EH;RS','PA_FOKUS','Briefpost Standardbrief + Premiumadress Fokus + Einschreiben Eigenhändig Rückschein',102100001,9026,9993),
(25,10,NULL,'PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure',102100001,9541,9994),
(26,10,'EW','PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure + Einschreiben Einwurf',102100001,9543,9994),
(27,10,'NA','PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure + Nachnahme',102100001,9545,9994),
(28,10,'ES','PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure + Einschreiben',102100001,9550,9994),
(29,10,'ES;RS','PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure + Einschreiben Rückschein',102100001,9551,9994),
(30,10,'ES;EH','PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure + Einschreiben Eigenhändig',102100001,9552,9994),
(31,10,'ES;EH;RS','PA_RETOURE','Briefpost Standardbrief + Premiumadress Retoure + Einschreiben Eigenhändig Rückschein',102100001,9553,9994),
(32,10,NULL,'PA_REPORT','Briefpost Standardbrief + Premiumadress Report',102100001,9301,9995),
(33,10,'NA','PA_REPORT','Briefpost Standardbrief + Premiumadress Report + Nachnahme',102100001,9510,9995),
(34,10,NULL,'PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid',102100001,9631,9996),
(35,10,'EW','PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid + Einschreiben Einwurf',102100001,9633,9996),
(36,10,'NA','PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid + Nachnahme',102100001,9635,9996),
(37,10,'ES','PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid + Einschreiben',102100001,9640,9996),
(38,10,'ES;RS','PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid + Einschreiben Rückschein',102100001,9641,9996),
(39,10,'ES;EH','PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid + Einschreiben Eigenhändig',102100001,9642,9996),
(40,10,'ES;EH;RS','PA_HYBRID','Briefpost Standardbrief + Premiumadress Hybrid + Einschreiben Eigenhändig Rückschein',102100001,9643,9996),
(41,10,NULL,'PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra',102100001,9734,9997),
(42,10,'EW','PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra + Einschreiben Einwurf',102100001,9736,9997),
(43,10,'NA','PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra + Nachnahme',102100001,9738,9997),
(44,10,'ES','PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra + Einschreiben',102100001,9743,9997),
(45,10,'ES;RS','PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra + Einschreiben Rückschein',102100001,9744,9997),
(46,10,'ES;EH','PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig',102100001,9745,9997),
(47,10,'ES;EH;RS','PA_RETOURE_EXTRA','Briefpost Standardbrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig Rückschein',102100001,9746,9997),
(48,10,NULL,'BZA','Briefpost Standardbrief + BZA',1102130,NULL,NULL),
(49,10,NULL,'BZE','Briefpost Standardbrief + BZE',1102122,NULL,NULL),
(50,10,'ES','BZL','Briefpost Standardbrief + Einschreiben',1013,NULL,NULL),
(51,10,'EH','BZL','Briefpost Standardbrief + Eigenhändig',1014,NULL,NULL),
(52,10,'RS','BZL','Briefpost Standardbrief + Rückschein',1015,NULL,NULL),
(53,10,'NA','BZL','Briefpost Standardbrief + Nachnahme',1016,NULL,NULL),
(54,10,'EW','BZL','Briefpost Standardbrief + Einwurf',1067,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(55,11,NULL,'TARIFF','Briefpost Kompaktbrief',102200001,11,NULL),
(56,11,'EW','TARIFF','Briefpost Kompaktbrief + Einschreiben Einwurf',102200001,1012,NULL),
(57,11,'NA','TARIFF','Briefpost Kompaktbrief + Nachnahme',102200001,1013,NULL),
(58,11,'ES','TARIFF','Briefpost Kompaktbrief + Einschreiben',102200001,1017,NULL),
(59,11,'ES;RS','TARIFF','Briefpost Kompaktbrief + Einschreiben Rückschein',102200001,1018,NULL),
(60,11,'ES;EH','TARIFF','Briefpost Kompaktbrief + Einschreiben Eigenhändig',102200001,1019,NULL),
(61,11,'ES;EH;RS','TARIFF','Briefpost Kompaktbrief + Einschreiben Eigenhändig Rückschein',102200001,1020,NULL),
(62,11,NULL,'PA_BASIS','Briefpost Kompaktbrief + Premiumadress Basis',102200001,9502,9991),
(63,11,'NA','PA_BASIS','Briefpost Kompaktbrief + Premiumadress Basis + Nachnahme',102200001,9512,9991),
(64,11,NULL,'PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus',102200001,9027,9992),
(65,11,'EW','PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus + Einschreiben Einwurf',102200001,9029,9992),
(66,11,'NA','PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus + Nachnahme',102200001,9031,9992),
(67,11,'ES','PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus + Einschreiben',102200001,9036,9992),
(68,11,'ES;RS','PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus + Einschreiben Rückschein',102200001,9037,9992),
(69,11,'ES;EH','PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus + Einschreiben Eigenhändig',102200001,9038,9992),
(70,11,'ES;EH;RS','PA_PLUS','Briefpost Kompaktbrief + Premiumadress Plus + Einschreiben Eigenhändig Rückschein',102200001,9039,9992),
(71,11,NULL,'PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus',102200001,9040,9993),
(72,11,'EW','PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus + Einschreiben Einwurf',102200001,9042,9993),
(73,11,'NA','PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus + Nachnahme',102200001,9044,9993),
(74,11,'ES','PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus + Einschreiben',102200001,9049,9993),
(75,11,'ES;RS','PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus + Einschreiben Rückschein',102200001,9050,9993),
(76,11,'ES;EH','PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus + Einschreiben Eigenhändig',102200001,9051,9993),
(77,11,'ES;EH;RS','PA_FOKUS','Briefpost Kompaktbrief + Premiumadress Fokus + Einschreiben Eigenhändig Rückschein',102200001,9052,9993),
(78,11,NULL,'PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure',102200001,9554,9994),
(79,11,'EW','PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure + Einschreiben Einwurf',102200001,9556,9994),
(80,11,'NA','PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure + Nachnahme',102200001,9558,9994),
(81,11,'ES','PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure + Einschreiben',102200001,9563,9994),
(82,11,'ES;RS','PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure + Einschreiben Rückschein',102200001,9564,9994),
(83,11,'ES;EH','PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure + Einschreiben Eigenhändig',102200001,9565,9994),
(84,11,'ES;EH;RS','PA_RETOURE','Briefpost Kompaktbrief + Premiumadress Retoure + Einschreiben Eigenhändig Rückschein',102200001,9566,9994),
(85,11,NULL,'PA_REPORT','Briefpost Kompaktbrief + Premiumadress Report',102200001,9314,9995),
(86,11,'NA','PA_REPORT','Briefpost Kompaktbrief + Premiumadress Report + Nachnahme',102200001,9514,9995),
(87,11,NULL,'PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid',102200001,9644,9996),
(88,11,'EW','PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid + Einschreiben Einwurf',102200001,9646,9996),
(89,11,'NA','PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid + Nachnahme',102200001,9648,9996),
(90,11,'ES','PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid + Einschreiben',102200001,9653,9996),
(91,11,'ES;RS','PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid + Einschreiben Rückschein',102200001,9654,9996),
(92,11,'ES;EH','PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid + Einschreiben Eigenhändig',102200001,9655,9996),
(93,11,'ES;EH;RS','PA_HYBRID','Briefpost Kompaktbrief + Premiumadress Hybrid + Einschreiben Eigenhändig Rückschein',102200001,9656,9996),
(94,11,NULL,'PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra',102200001,9747,9997),
(95,11,'EW','PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra + Einschreiben Einwurf',102200001,9749,9997),
(96,11,'NA','PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra + Nachnahme',102200001,9751,9997),
(97,11,'ES','PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra + Einschreiben',102200001,9756,9997),
(98,11,'ES;RS','PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra + Einschreiben Rückschein',102200001,9757,9997),
(99,11,'ES;EH','PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig',102200001,9758,9997),
(100,11,'ES;EH;RS','PA_RETOURE_EXTRA','Briefpost Kompaktbrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig Rückschein',102200001,9759,9997),
(101,11,NULL,'BZA','Briefpost Kompaktbrief + BZA',1102230,NULL,NULL),
(102,11,NULL,'BZE','Briefpost Kompaktbrief + BZE',1102222,NULL,NULL),
(103,11,'ES','BZL','Briefpost Kompaktbrief + Einschreiben',1013,NULL,NULL),
(104,11,'EH','BZL','Briefpost Kompaktbrief + Eigenhändig',1014,NULL,NULL),
(105,11,'RS','BZL','Briefpost Kompaktbrief + Rückschein',1015,NULL,NULL),
(106,11,'NA','BZL','Briefpost Kompaktbrief + Nachnahme',1016,NULL,NULL),
(107,11,'EW','BZL','Briefpost Kompaktbrief + Einwurf',1067,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(108,12,NULL,'TARIFF','Briefpost Großbrief',102300001,21,NULL),
(109,12,'EW','TARIFF','Briefpost Großbrief + Einschreiben Einwurf',102300001,1022,NULL),
(110,12,'NA','TARIFF','Briefpost Großbrief + Nachnahme',102300001,1023,NULL),
(111,12,'ES','TARIFF','Briefpost Großbrief + Einschreiben',102300001,1027,NULL),
(112,12,'ES;RS','TARIFF','Briefpost Großbrief + Einschreiben Rückschein',102300001,1028,NULL),
(113,12,'ES;EH','TARIFF','Briefpost Großbrief + Einschreiben Eigenhändig',102300001,1029,NULL),
(114,12,'ES;EH;RS','TARIFF','Briefpost Großbrief + Einschreiben Eigenhändig Rückschein',102300001,1030,NULL),
(115,12,NULL,'PA_BASIS','Briefpost Großbrief + Premiumadress Basis',102300001,9503,9991),
(116,12,'NA','PA_BASIS','Briefpost Großbrief + Premiumadress Basis + Nachnahme',102300001,9516,9991),
(117,12,NULL,'PA_PLUS','Briefpost Großbrief + Premiumadress Plus',102300001,9053,9992),
(118,12,'EW','PA_PLUS','Briefpost Großbrief + Premiumadress Plus + Einschreiben Einwurf',102300001,9055,9992),
(119,12,'NA','PA_PLUS','Briefpost Großbrief + Premiumadress Plus + Nachnahme',102300001,9057,9992),
(120,12,'ES','PA_PLUS','Briefpost Großbrief + Premiumadress Plus + Einschreiben',102300001,9062,9992),
(121,12,'ES;RS','PA_PLUS','Briefpost Großbrief + Premiumadress Plus + Einschreiben Rückschein',102300001,9063,9992),
(122,12,'ES;EH','PA_PLUS','Briefpost Großbrief + Premiumadress Plus + Einschreiben Eigenhändig',102300001,9064,9992),
(123,12,'ES;EH;RS','PA_PLUS','Briefpost Großbrief + Premiumadress Plus + Einschreiben Eigenhändig Rückschein',102300001,9065,9992),
(124,12,NULL,'PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus',102300001,9066,9993),
(125,12,'EW','PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus + Einschreiben Einwurf',102300001,9068,9993),
(126,12,'NA','PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus + Nachnahme',102300001,9070,9993),
(127,12,'ES','PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus + Einschreiben',102300001,9075,9993),
(128,12,'ES;RS','PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus + Einschreiben Rückschein',102300001,9076,9993),
(129,12,'ES;EH','PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus + Einschreiben Eigenhändig',102300001,9077,9993),
(130,12,'ES;EH;RS','PA_FOKUS','Briefpost Großbrief + Premiumadress Fokus + Einschreiben Eigenhändig Rückschein',102300001,9078,9993),
(131,12,NULL,'PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure',102300001,9567,9994),
(132,12,'EW','PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure + Einschreiben Einwurf',102300001,9569,9994),
(133,12,'NA','PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure + Nachnahme',102300001,9571,9994),
(134,12,'ES','PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure + Einschreiben',102300001,9576,9994),
(135,12,'ES;RS','PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure + Einschreiben Rückschein',102300001,9577,9994),
(136,12,'ES;EH','PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure + Einschreiben Eigenhändig',102300001,9578,9994),
(137,12,'ES;EH;RS','PA_RETOURE','Briefpost Großbrief + Premiumadress Retoure + Einschreiben Eigenhändig Rückschein',102300001,9579,9994),
(138,12,NULL,'PA_REPORT','Briefpost Großbrief + Premiumadress Report',102300001,9327,9995),
(139,12,'NA','PA_REPORT','Briefpost Großbrief + Premiumadress Report + Nachnahme',102300001,9518,9995),
(140,12,NULL,'PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid',102300001,9657,9996),
(141,12,'EW','PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid + Einschreiben Einwurf',102300001,9659,9996),
(142,12,'NA','PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid + Nachnahme',102300001,9661,9996),
(143,12,'ES','PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid + Einschreiben',102300001,9666,9996),
(144,12,'ES;RS','PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid + Einschreiben Rückschein',102300001,9667,9996),
(145,12,'ES;EH','PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid + Einschreiben Eigenhändig',102300001,9668,9996),
(146,12,'ES;EH;RS','PA_HYBRID','Briefpost Großbrief + Premiumadress Hybrid + Einschreiben Eigenhändig Rückschein',102300001,9669,9996),
(147,12,NULL,'PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra',102300001,9760,9997),
(148,12,'EW','PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra + Einschreiben Einwurf',102300001,9762,9997),
(149,12,'NA','PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra + Nachnahme',102300001,9764,9997),
(150,12,'ES','PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra + Einschreiben',102300001,9769,9997),
(151,12,'ES;RS','PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra + Einschreiben Rückschein',102300001,9770,9997),
(152,12,'ES;EH','PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig',102300001,9771,9997),
(153,12,'ES;EH;RS','PA_RETOURE_EXTRA','Briefpost Großbrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig Rückschein',102300001,9772,9997),
(154,12,NULL,'BZA','Briefpost Großbrief + BZA',1102330,NULL,NULL),
(155,12,NULL,'BZE','Briefpost Großbrief + BZE',1102322,NULL,NULL),
(156,12,'ES','BZL','Briefpost Großbrief + Einschreiben',1013,NULL,NULL),
(157,12,'EH','BZL','Briefpost Großbrief + Eigenhändig',1014,NULL,NULL),
(158,12,'RS','BZL','Briefpost Großbrief + Rückschein',1015,NULL,NULL),
(159,12,'NA','BZL','Briefpost Großbrief + Nachnahme',1016,NULL,NULL),
(160,12,'EW','BZL','Briefpost Großbrief + Einwurf',1067,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(161,13,NULL,'TARIFF','Briefpost Maxibrief',102400001,31,NULL),
(162,13,'EW','TARIFF','Briefpost Maxibrief + Einschreiben Einwurf',102400001,1032,NULL),
(163,13,'NA','TARIFF','Briefpost Maxibrief + Nachnahme',102400001,1033,NULL),
(164,13,'ES','TARIFF','Briefpost Maxibrief + Einschreiben',102400001,1037,NULL),
(165,13,'ES;RS','TARIFF','Briefpost Maxibrief + Einschreiben Rückschein',102400001,1038,NULL),
(166,13,'ES;EH','TARIFF','Briefpost Maxibrief + Einschreiben Eigenhändig',102400001,1039,NULL),
(167,13,'ES;EH;RS','TARIFF','Briefpost Maxibrief + Einschreiben Eigenhändig Rückschein',102400001,1040,NULL),
(168,13,NULL,'PA_BASIS','Briefpost Maxibrief + Premiumadress Basis',102400001,9504,9991),
(169,13,'NA','PA_BASIS','Briefpost Maxibrief + Premiumadress Basis + Nachnahme',102400001,9520,9991),
(170,13,NULL,'PA_PLUS','Briefpost Maxibrief + Premiumadress Plus',102400001,9079,9992),
(171,13,'EW','PA_PLUS','Briefpost Maxibrief + Premiumadress Plus + Einschreiben Einwurf',102400001,9081,9992),
(172,13,'NA','PA_PLUS','Briefpost Maxibrief + Premiumadress Plus + Nachnahme',102400001,9083,9992),
(173,13,'ES','PA_PLUS','Briefpost Maxibrief + Premiumadress Plus + Einschreiben',102400001,9088,9992),
(174,13,'ES;RS','PA_PLUS','Briefpost Maxibrief + Premiumadress Plus + Einschreiben Rückschein',102400001,9089,9992),
(175,13,'ES;EH','PA_PLUS','Briefpost Maxibrief + Premiumadress Plus + Einschreiben Eigenhändig',102400001,9090,9992),
(176,13,'ES;EH;RS','PA_PLUS','Briefpost Maxibrief + Premiumadress Plus + Einschreiben Eigenhändig Rückschein',102400001,9091,9992),
(177,13,NULL,'PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus',102400001,9092,9993),
(178,13,'EW','PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus + Einschreiben Einwurf',102400001,9094,9993),
(179,13,'NA','PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus + Nachnahme',102400001,9096,9993),
(180,13,'ES','PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus + Einschreiben',102400001,9101,9993),
(181,13,'ES;RS','PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus + Einschreiben Rückschein',102400001,9102,9993),
(182,13,'ES;EH','PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus + Einschreiben Eigenhändig',102400001,9103,9993),
(183,13,'ES;EH;RS','PA_FOKUS','Briefpost Maxibrief + Premiumadress Fokus + Einschreiben Eigenhändig Rückschein',102400001,9104,9993),
(184,13,NULL,'PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure',102400001,9580,9994),
(185,13,'EW','PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure + Einschreiben Einwurf',102400001,9582,9994),
(186,13,'NA','PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure + Nachnahme',102400001,9584,9994),
(187,13,'ES','PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure + Einschreiben',102400001,9589,9994),
(188,13,'ES;RS','PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure + Einschreiben Rückschein',102400001,9590,9994),
(189,13,'ES;EH','PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure + Einschreiben Eigenhändig',102400001,9591,9994),
(190,13,'ES;EH;RS','PA_RETOURE','Briefpost Maxibrief + Premiumadress Retoure + Einschreiben Eigenhändig Rückschein',102400001,9592,9994),
(191,13,NULL,'PA_REPORT','Briefpost Maxibrief + Premiumadress Report',102400001,9340,9995),
(192,13,'NA','PA_REPORT','Briefpost Maxibrief + Premiumadress Report + Nachnahme',102400001,9522,9995),
(193,13,NULL,'PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid',102400001,9670,9996),
(194,13,'EW','PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid + Einschreiben Einwurf',102400001,9672,9996),
(195,13,'NA','PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid + Nachnahme',102400001,9674,9996),
(196,13,'ES','PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid + Einschreiben',102400001,9679,9996),
(197,13,'ES;RS','PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid + Einschreiben Rückschein',102400001,9680,9996),
(198,13,'ES;EH','PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid + Einschreiben Eigenhändig',102400001,9681,9996),
(199,13,'ES;EH;RS','PA_HYBRID','Briefpost Maxibrief + Premiumadress Hybrid + Einschreiben Eigenhändig Rückschein',102400001,9682,9996),
(200,13,NULL,'PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra',102400001,9773,9997),
(201,13,'EW','PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra + Einschreiben Einwurf',102400001,9775,9997),
(202,13,'NA','PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra + Nachnahme',102400001,9777,9997),
(203,13,'ES','PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra + Einschreiben',102400001,9782,9997),
(204,13,'ES;RS','PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra + Einschreiben Rückschein',102400001,9783,9997),
(205,13,'ES;EH','PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig',102400001,9784,9997),
(206,13,'ES;EH;RS','PA_RETOURE_EXTRA','Briefpost Maxibrief + Premiumadress Retoure Extra + Einschreiben Eigenhändig Rückschein',102400001,9785,9997),
(207,13,NULL,'BZA','Briefpost Maxibrief + BZA',1102430,NULL,NULL),
(208,13,NULL,'BZE','Briefpost Maxibrief + BZE',1102422,NULL,NULL),
(209,13,'ES','BZL','Briefpost Maxibrief + Einschreiben',1013,NULL,NULL),
(210,13,'EH','BZL','Briefpost Maxibrief + Eigenhändig',1014,NULL,NULL),
(211,13,'RS','BZL','Briefpost Maxibrief + Rückschein',1015,NULL,NULL),
(212,13,'NA','BZL','Briefpost Maxibrief + Nachnahme',1016,NULL,NULL),
(213,13,'EW','BZL','Briefpost Maxibrief + Einwurf',1067,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(214,14,NULL,'TARIFF','Briefpost Maxibrief (bis 2.000 g)',102400001,41,NULL),
(215,14,'EW','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Einwurf',102400001,1042,NULL),
(216,14,'NA','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Nachnahme',102400001,1043,NULL),
(217,14,'ES','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben',102400001,1047,NULL),
(218,14,'ES;RS','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Rückschein',102400001,1048,NULL),
(219,14,'ES;EH','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Eigenhändig',102400001,1049,NULL),
(220,14,'ES;EH;RS','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Eigenhändig Rückschein',102400001,1050,NULL),
(221,14,NULL,'PA_BASIS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Basis',102400001,9504,9991),
(222,14,'NA','PA_BASIS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Basis + Nachnahme',102400001,9524,9991),
(223,14,NULL,'PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus',102400001,9079,9992),
(224,14,'EW','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Einwurf',102400001,9107,9992),
(225,14,'NA','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Nachnahme',102400001,9109,9992),
(226,14,'ES','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben',102400001,9114,9992),
(227,14,'ES;RS','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Rückschein',102400001,9115,9992),
(228,14,'ES;EH','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Eigenhändig',102400001,9116,9992),
(229,14,'ES;EH;RS','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Eigenhändig Rückschein',102400001,9117,9992),
(230,14,NULL,'PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus',102400001,9092,9993),
(231,14,'EW','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Einwurf',102400001,9120,9993),
(232,14,'NA','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Nachnahme',102400001,9122,9993),
(233,14,'ES','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben',102400001,9127,9993),
(234,14,'ES;RS','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Rückschein',102400001,9128,9993),
(235,14,'ES;EH','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Eigenhändig',102400001,9129,9993),
(236,14,'ES;EH;RS','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Eigenhändig Rückschein',102400001,9130,9993),
(237,14,NULL,'PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure',102400001,9580,9994),
(238,14,'EW','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Einwurf',102400001,9595,9994),
(239,14,'NA','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Nachnahme',102400001,9596,9994),
(240,14,'ES','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben',102400001,9602,9994),
(241,14,'ES;RS','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Rückschein',102400001,9603,9994),
(242,14,'ES;EH','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Eigenhändig',102400001,9604,9994),
(243,14,'ES;EH;RS','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Eigenhändig Rückschein',102400001,9605,9994),
(244,14,NULL,'PA_REPORT','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Report',102400001,9340,9995),
(245,14,'NA','PA_REPORT','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Report + Nachnahme',102400001,9525,9995),
(246,14,NULL,'PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid',102400001,9670,9996),
(247,14,'EW','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Einwurf',102400001,9685,9996),
(248,14,'NA','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Nachnahme',102400001,9687,9996),
(249,14,'ES','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben',102400001,9692,9996),
(250,14,'ES;RS','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Rückschein',102400001,9693,9996),
(251,14,'ES;EH','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Eigenhändig',102400001,9694,9996),
(252,14,'ES;EH;RS','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Eigenhändig Rückschein',102400001,9695,9996),
(253,14,NULL,'PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra',102400001,9773,9997),
(254,14,'EW','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Einwurf',102400001,9788,9997),
(255,14,'NA','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Nachnahme',102400001,9790,9997),
(256,14,'ES','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben',102400001,9795,9997),
(257,14,'ES;RS','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Rückschein',102400001,9796,9997),
(258,14,'ES;EH','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Eigenhändig',102400001,9797,9997),
(259,14,'ES;EH;RS','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Eigenhändig Rückschein',102400001,9798,9997),
(260,14,NULL,'BZA','Briefpost Maxibrief (bis 2.000 g) + BZA',1102430,NULL,NULL),
(261,14,NULL,'BZE','Briefpost Maxibrief (bis 2.000 g) + BZE',1102422,NULL,NULL),
(262,14,NULL,'SC','Briefpost Maxibrief (bis 2.000 g) + Zusatzentgelt',1296,NULL,NULL),
(263,14,'ES','BZL','Briefpost Maxibrief (bis 2.000 g) + Einschreiben',1013,NULL,NULL),
(264,14,'EH','BZL','Briefpost Maxibrief (bis 2.000 g) + Eigenhändig',1014,NULL,NULL),
(265,14,'RS','BZL','Briefpost Maxibrief (bis 2.000 g) + Rückschein',1015,NULL,NULL),
(266,14,'NA','BZL','Briefpost Maxibrief (bis 2.000 g) + Nachnahme',1016,NULL,NULL),
(267,14,'EW','BZL','Briefpost Maxibrief (bis 2.000 g) + Einwurf',1067,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(268,15,NULL,'TARIFF','Briefpost Maxibrief (bis 2.000 g)',102400001,41,NULL),
(269,15,'EW','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Einwurf',102400001,1042,NULL),
(270,15,'NA','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Nachnahme',102400001,1043,NULL),
(271,15,'ES','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben',102400001,1047,NULL),
(272,15,'ES;RS','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Rückschein',102400001,1048,NULL),
(273,15,'ES;EH','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Eigenhändig',102400001,1049,NULL),
(274,15,'ES;EH;RS','TARIFF','Briefpost Maxibrief (bis 2.000 g) + Einschreiben Eigenhändig Rückschein',102400001,1050,NULL),
(275,15,NULL,'PA_BASIS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Basis',102400001,9504,9991),
(276,15,'NA','PA_BASIS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Basis + Nachnahme',102400001,9524,9991),
(277,15,NULL,'PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus',102400001,9079,9992),
(278,15,'EW','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Einwurf',102400001,9107,9992),
(279,15,'NA','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Nachnahme',102400001,9109,9992),
(280,15,'ES','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben',102400001,9114,9992),
(281,15,'ES;RS','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Rückschein',102400001,9115,9992),
(282,15,'ES;EH','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Eigenhändig',102400001,9116,9992),
(283,15,'ES;EH;RS','PA_PLUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Plus + Einschreiben Eigenhändig Rückschein',102400001,9117,9992),
(284,15,NULL,'PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus',102400001,9092,9993),
(285,15,'EW','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Einwurf',102400001,9120,9993),
(286,15,'NA','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Nachnahme',102400001,9122,9993),
(287,15,'ES','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben',102400001,9127,9993),
(288,15,'ES;RS','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Rückschein',102400001,9128,9993),
(289,15,'ES;EH','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Eigenhändig',102400001,9129,9993),
(290,15,'ES;EH;RS','PA_FOKUS','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Fokus + Einschreiben Eigenhändig Rückschein',102400001,9130,9993),
(291,15,NULL,'PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure',102400001,9580,9994),
(292,15,'EW','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Einwurf',102400001,9595,9994),
(293,15,'NA','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Nachnahme',102400001,9596,9994),
(294,15,'ES','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben',102400001,9602,9994),
(295,15,'ES;RS','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Rückschein',102400001,9603,9994),
(296,15,'ES;EH','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Eigenhändig',102400001,9604,9994),
(297,15,'ES;EH;RS','PA_RETOURE','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure + Einschreiben Eigenhändig Rückschein',102400001,9605,9994),
(298,15,NULL,'PA_REPORT','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Report',102400001,9340,9995),
(299,15,'NA','PA_REPORT','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Report + Nachnahme',102400001,9525,9995),
(300,15,NULL,'PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid',102400001,9670,9996),
(301,15,'EW','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Einwurf',102400001,9685,9996),
(302,15,'NA','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Nachnahme',102400001,9687,9996),
(303,15,'ES','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben',102400001,9692,9996),
(304,15,'ES;RS','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Rückschein',102400001,9693,9996),
(305,15,'ES;EH','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Eigenhändig',102400001,9694,9996),
(306,15,'ES;EH;RS','PA_HYBRID','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Hybrid + Einschreiben Eigenhändig Rückschein',102400001,9695,9996),
(307,15,NULL,'PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra',102400001,9773,9997),
(308,15,'EW','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Einwurf',102400001,9788,9997),
(309,15,'NA','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Nachnahme',102400001,9790,9997),
(310,15,'ES','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben',102400001,9795,9997),
(311,15,'ES;RS','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Rückschein',102400001,9796,9997),
(312,15,'ES;EH','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Eigenhändig',102400001,9797,9997),
(313,15,'ES;EH;RS','PA_RETOURE_EXTRA','Briefpost Maxibrief (bis 2.000 g) + Premiumadress Retoure Extra + Einschreiben Eigenhändig Rückschein',102400001,9798,9997),
(314,15,NULL,'BZA','Briefpost Maxibrief (bis 2.000 g) + BZA',1102430,NULL,NULL),
(315,15,NULL,'BZE','Briefpost Maxibrief (bis 2.000 g) + BZE',1102422,NULL,NULL),
(316,15,NULL,'SC','Briefpost Maxibrief (bis 2.000 g) + Zusatzentgelt',1296,NULL,NULL),
(317,15,'ES','BZL','Briefpost Maxibrief (bis 2.000 g) + Einschreiben',1013,NULL,NULL),
(318,15,'EH','BZL','Briefpost Maxibrief (bis 2.000 g) + Eigenhändig',1014,NULL,NULL),
(319,15,'RS','BZL','Briefpost Maxibrief (bis 2.000 g) + Rückschein',1015,NULL,NULL),
(320,15,'NA','BZL','Briefpost Maxibrief (bis 2.000 g) + Nachnahme',1016,NULL,NULL),
(321,15,'EW','BZL','Briefpost Maxibrief (bis 2.000 g) + Einwurf',1067,NULL,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Dialogpost
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(322,40,NULL,'TARIFF','Dialogpost Standard',250200001,90,NULL),
(323,40,NULL,'PA_BASIS','Dialogpost Standard + Premiumadress Basis',250200001,9191,9991),
(324,40,NULL,'PA_PLUS','Dialogpost Standard + Premiumadress Plus',250200001,9192,9992),
(325,40,NULL,'PA_FOKUS','Dialogpost Standard + Premiumadress Fokus',250200001,9193,9993),
(326,40,NULL,'PA_RETOURE','Dialogpost Standard + Premiumadress Retoure',250200001,9194,9994),
(327,40,NULL,'PA_REPORT','Dialogpost Standard + Premiumadress Report',250200001,9195,9995),
(328,40,NULL,'PA_HYBRID','Dialogpost Standard + Premiumadress Hybrid',250200001,9720,9996),
(329,40,NULL,'PA_RETOURE_EXTRA','Dialogpost Standard + Premiumadress Retoure Extra',250200001,9823,9997),
(330,40,NULL,'BZE','Dialogpost Standard + BZE',1000539,NULL,NULL),
(331,40,NULL,'EE_BEH_LR','Dialogpost Standard + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(332,40,NULL,'EE_PAL_LZ','Dialogpost Standard + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(333,40,NULL,'EE_PAL_LR','Dialogpost Standard + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(334,41,NULL,'TARIFF','Dialogpost Standard (bis 50 g)',250200001,90,NULL),
(335,41,NULL,'PA_BASIS','Dialogpost Standard (bis 50 g) + Premiumadress Basis',250200001,9191,9991),
(336,41,NULL,'PA_PLUS','Dialogpost Standard (bis 50 g) + Premiumadress Plus',250200001,9192,9992),
(337,41,NULL,'PA_FOKUS','Dialogpost Standard (bis 50 g) + Premiumadress Fokus',250200001,9193,9993),
(338,41,NULL,'PA_RETOURE','Dialogpost Standard (bis 50 g) + Premiumadress Retoure',250200001,9194,9994),
(339,41,NULL,'PA_REPORT','Dialogpost Standard (bis 50 g) + Premiumadress Report',250200001,9195,9995),
(340,41,NULL,'PA_HYBRID','Dialogpost Standard (bis 50 g) + Premiumadress Hybrid',250200001,9720,9996),
(341,41,NULL,'PA_RETOURE_EXTRA','Dialogpost Standard (bis 50 g) + Premiumadress Retoure Extra',250200001,9823,9997),
(342,41,NULL,'BZE','Dialogpost Standard (bis 50 g) + BZE',1000539,NULL,NULL),
(343,41,NULL,'EE_BEH_LR','Dialogpost Standard (bis 50 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(344,41,NULL,'EE_PAL_LZ','Dialogpost Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(345,41,NULL,'EE_PAL_LR','Dialogpost Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(346,42,NULL,'TARIFF','Dialogpost Groß',250300001,3107,NULL),
(347,42,NULL,'PA_BASIS','Dialogpost Groß + Premiumadress Basis',250300001,9216,9991),
(348,42,NULL,'PA_PLUS','Dialogpost Groß + Premiumadress Plus',250300001,9217,9992),
(349,42,NULL,'PA_FOKUS','Dialogpost Groß + Premiumadress Fokus',250300001,9218,9993),
(350,42,NULL,'PA_RETOURE','Dialogpost Groß + Premiumadress Retoure',250300001,9219,9994),
(351,42,NULL,'PA_REPORT','Dialogpost Groß + Premiumadress Report',250300001,9220,9995),
(352,42,NULL,'PA_HYBRID','Dialogpost Groß + Premiumadress Hybrid',250300001,9723,9996),
(353,42,NULL,'PA_RETOURE_EXTRA','Dialogpost Groß + Premiumadress Retoure Extra',250300001,9826,9997),
(354,42,NULL,'BZE','Dialogpost Groß + BZE',1000544,NULL,NULL),
(355,42,NULL,'EE_BEH_LR','Dialogpost Groß + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(356,42,NULL,'EE_BEH_PLZ','Dialogpost Groß + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(357,42,NULL,'EE_PAL_LZ','Dialogpost Groß + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(358,42,NULL,'EE_PAL_LR','Dialogpost Groß + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(359,43,NULL,'TARIFF','Dialogpost Groß (bis 100 g)',250300001,3107,NULL),
(360,43,NULL,'PA_BASIS','Dialogpost Groß (bis 100 g) + Premiumadress Basis',250300001,9216,9991),
(361,43,NULL,'PA_PLUS','Dialogpost Groß (bis 100 g) + Premiumadress Plus',250300001,9217,9992),
(362,43,NULL,'PA_FOKUS','Dialogpost Groß (bis 100 g) + Premiumadress Fokus',250300001,9218,9993),
(363,43,NULL,'PA_RETOURE','Dialogpost Groß (bis 100 g) + Premiumadress Retoure',250300001,9219,9994),
(364,43,NULL,'PA_REPORT','Dialogpost Groß (bis 100 g) + Premiumadress Report',250300001,9220,9995),
(365,43,NULL,'PA_HYBRID','Dialogpost Groß (bis 100 g) + Premiumadress Hybrid',250300001,9723,9996),
(366,43,NULL,'PA_RETOURE_EXTRA','Dialogpost Groß (bis 100 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(367,43,NULL,'BZE','Dialogpost Groß (bis 100 g) + BZE',1000544,NULL,NULL),
(368,43,NULL,'EE_BEH_LR','Dialogpost Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(369,43,NULL,'EE_BEH_PLZ','Dialogpost Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(370,43,NULL,'EE_PAL_LZ','Dialogpost Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(371,43,NULL,'EE_PAL_LR','Dialogpost Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(372,44,NULL,'TARIFF','Dialogpost Groß (bis 250 g)',250300001,3107,NULL),
(373,44,NULL,'PA_BASIS','Dialogpost Groß (bis 250 g) + Premiumadress Basis',250300001,9216,9991),
(374,44,NULL,'PA_PLUS','Dialogpost Groß (bis 250 g) + Premiumadress Plus',250300001,9217,9992),
(375,44,NULL,'PA_FOKUS','Dialogpost Groß (bis 250 g) + Premiumadress Fokus',250300001,9218,9993),
(376,44,NULL,'PA_RETOURE','Dialogpost Groß (bis 250 g) + Premiumadress Retoure',250300001,9219,9994),
(377,44,NULL,'PA_REPORT','Dialogpost Groß (bis 250 g) + Premiumadress Report',250300001,9220,9995),
(378,44,NULL,'PA_HYBRID','Dialogpost Groß (bis 250 g) + Premiumadress Hybrid',250300001,9723,9996),
(379,44,NULL,'PA_RETOURE_EXTRA','Dialogpost Groß (bis 250 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(380,44,NULL,'BZE','Dialogpost Groß (bis 250 g) + BZE',1000544,NULL,NULL),
(381,44,NULL,'EE_BEH_LR','Dialogpost Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(382,44,NULL,'EE_BEH_PLZ','Dialogpost Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(383,44,NULL,'EE_PAL_LZ','Dialogpost Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(384,44,NULL,'EE_PAL_LR','Dialogpost Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(385,45,NULL,'TARIFF','Dialogpost Groß (bis 500 g)',250300001,3107,NULL),
(386,45,NULL,'PA_BASIS','Dialogpost Groß (bis 500 g) + Premiumadress Basis',250300001,9216,9991),
(387,45,NULL,'PA_PLUS','Dialogpost Groß (bis 500 g) + Premiumadress Plus',250300001,9217,9992),
(388,45,NULL,'PA_FOKUS','Dialogpost Groß (bis 500 g) + Premiumadress Fokus',250300001,9218,9993),
(389,45,NULL,'PA_RETOURE','Dialogpost Groß (bis 500 g) + Premiumadress Retoure',250300001,9219,9994),
(390,45,NULL,'PA_REPORT','Dialogpost Groß (bis 500 g) + Premiumadress Report',250300001,9220,9995),
(391,45,NULL,'PA_HYBRID','Dialogpost Groß (bis 500 g) + Premiumadress Hybrid',250300001,9723,9996),
(392,45,NULL,'PA_RETOURE_EXTRA','Dialogpost Groß (bis 500 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(393,45,NULL,'BZE','Dialogpost Groß (bis 500 g) + BZE',1000544,NULL,NULL),
(394,45,NULL,'EE_BEH_LR','Dialogpost Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(395,45,NULL,'EE_BEH_PLZ','Dialogpost Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(396,45,NULL,'EE_PAL_LZ','Dialogpost Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(397,45,NULL,'EE_PAL_LR','Dialogpost Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(398,46,NULL,'TARIFF','Dialogpost Groß (bis 1.000 g)',250300001,3107,NULL),
(399,46,NULL,'PA_BASIS','Dialogpost Groß (bis 1.000 g) + Premiumadress Basis',250300001,9216,9991),
(400,46,NULL,'PA_PLUS','Dialogpost Groß (bis 1.000 g) + Premiumadress Plus',250300001,9217,9992),
(401,46,NULL,'PA_FOKUS','Dialogpost Groß (bis 1.000 g) + Premiumadress Fokus',250300001,9218,9993),
(402,46,NULL,'PA_RETOURE','Dialogpost Groß (bis 1.000 g) + Premiumadress Retoure',250300001,9219,9994),
(403,46,NULL,'PA_REPORT','Dialogpost Groß (bis 1.000 g) + Premiumadress Report',250300001,9220,9995),
(404,46,NULL,'PA_HYBRID','Dialogpost Groß (bis 1.000 g) + Premiumadress Hybrid',250300001,9723,9996),
(405,46,NULL,'PA_RETOURE_EXTRA','Dialogpost Groß (bis 1.000 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(406,46,NULL,'BZE','Dialogpost Groß (bis 1.000 g) + BZE',1000544,NULL,NULL),
(407,46,NULL,'EE_BEH_LR','Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(408,46,NULL,'EE_BEH_PLZ','Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(409,46,NULL,'EE_PAL_LZ','Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(410,46,NULL,'EE_PAL_LR','Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Dialogpost Easy
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(411,50,NULL,'TARIFF','Dialogpost Easy Standard',250200001,90,NULL),
(412,50,NULL,'PA_BASIS','Dialogpost Easy Standard + Premiumadress Basis',250200001,9191,9991),
(413,50,NULL,'PA_PLUS','Dialogpost Easy Standard + Premiumadress Plus',250200001,9192,9992),
(414,50,NULL,'PA_FOKUS','Dialogpost Easy Standard + Premiumadress Fokus',250200001,9193,9993),
(415,50,NULL,'PA_RETOURE','Dialogpost Easy Standard + Premiumadress Retoure',250200001,9194,9994),
(416,50,NULL,'PA_REPORT','Dialogpost Easy Standard + Premiumadress Report',250200001,9195,9995),
(417,50,NULL,'PA_HYBRID','Dialogpost Easy Standard + Premiumadress Hybrid',250200001,9720,9996),
(418,50,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Standard + Premiumadress Retoure Extra',250200001,9823,9997),
(419,50,NULL,'BZE','Dialogpost Easy Standard + BZE',1000539,NULL,NULL),
(420,50,NULL,'EE_BEH_LR','Dialogpost Easy Standard + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(421,50,NULL,'EE_PAL_LZ','Dialogpost Easy Standard + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(422,50,NULL,'EE_PAL_LR','Dialogpost Easy Standard + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL),
(423,50,NULL,'SC','Zuschlag Dialogpost Easy Standard',1995,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(424,51,NULL,'TARIFF','Dialogpost Easy Standard (bis 50 g)',250200001,90,NULL),
(425,51,NULL,'PA_BASIS','Dialogpost Easy Standard (bis 50 g) + Premiumadress Basis',250200001,9191,9991),
(426,51,NULL,'PA_PLUS','Dialogpost Easy Standard (bis 50 g) + Premiumadress Plus',250200001,9192,9992),
(427,51,NULL,'PA_FOKUS','Dialogpost Easy Standard (bis 50 g) + Premiumadress Fokus',250200001,9193,9993),
(428,51,NULL,'PA_RETOURE','Dialogpost Easy Standard (bis 50 g) + Premiumadress Retoure',250200001,9194,9994),
(429,51,NULL,'PA_REPORT','Dialogpost Easy Standard (bis 50 g) + Premiumadress Report',250200001,9195,9995),
(430,51,NULL,'PA_HYBRID','Dialogpost Easy Standard (bis 50 g) + Premiumadress Hybrid',250200001,9720,9996),
(431,51,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Standard (bis 50 g) + Premiumadress Retoure Extra',250200001,9823,9997),
(432,51,NULL,'BZE','Dialogpost Easy Standard (bis 50 g) + BZE',1000539,NULL,NULL),
(433,51,NULL,'EE_BEH_LR','Dialogpost Easy Standard (bis 50 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(434,51,NULL,'EE_PAL_LZ','Dialogpost Easy Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(435,51,NULL,'EE_PAL_LR','Dialogpost Easy Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL),
(436,51,NULL,'SC','Zuschlag Dialogpost Easy Standard (bis 50 g)',1995,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(437,52,NULL,'TARIFF','Dialogpost Easy Groß',250300001,3107,NULL),
(438,52,NULL,'PA_BASIS','Dialogpost Easy Groß + Premiumadress Basis',250300001,9216,9991),
(439,52,NULL,'PA_PLUS','Dialogpost Easy Groß + Premiumadress Plus',250300001,9217,9992),
(440,52,NULL,'PA_FOKUS','Dialogpost Easy Groß + Premiumadress Fokus',250300001,9218,9993),
(441,52,NULL,'PA_RETOURE','Dialogpost Easy Groß + Premiumadress Retoure',250300001,9219,9994),
(442,52,NULL,'PA_REPORT','Dialogpost Easy Groß + Premiumadress Report',250300001,9220,9995),
(443,52,NULL,'PA_HYBRID','Dialogpost Easy Groß + Premiumadress Hybrid',250300001,9723,9996),
(444,52,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Groß + Premiumadress Retoure Extra',250300001,9826,9997),
(445,52,NULL,'BZE','Dialogpost Easy Groß + BZE',1000544,NULL,NULL),
(446,52,NULL,'EE_BEH_LR','Dialogpost Easy Groß + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(447,52,NULL,'EE_BEH_PLZ','Dialogpost Easy Groß + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(448,52,NULL,'EE_PAL_LZ','Dialogpost Easy Groß + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(449,52,NULL,'EE_PAL_LR','Dialogpost Easy Groß + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(450,52,NULL,'SC','Zuschlag Dialogpost Easy Groß',1996,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(451,53,NULL,'TARIFF','Dialogpost Easy Groß (bis 100 g)',250300001,3107,NULL),
(452,53,NULL,'PA_BASIS','Dialogpost Easy Groß (bis 100 g) + Premiumadress Basis',250300001,9216,9991),
(453,53,NULL,'PA_PLUS','Dialogpost Easy Groß (bis 100 g) + Premiumadress Plus',250300001,9217,9992),
(454,53,NULL,'PA_FOKUS','Dialogpost Easy Groß (bis 100 g) + Premiumadress Fokus',250300001,9218,9993),
(455,53,NULL,'PA_RETOURE','Dialogpost Easy Groß (bis 100 g) + Premiumadress Retoure',250300001,9219,9994),
(456,53,NULL,'PA_REPORT','Dialogpost Easy Groß (bis 100 g) + Premiumadress Report',250300001,9220,9995),
(457,53,NULL,'PA_HYBRID','Dialogpost Easy Groß (bis 100 g) + Premiumadress Hybrid',250300001,9723,9996),
(458,53,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Groß (bis 100 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(459,53,NULL,'BZE','Dialogpost Easy Groß (bis 100 g) + BZE',1000544,NULL,NULL),
(460,53,NULL,'EE_BEH_LR','Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(461,53,NULL,'EE_BEH_PLZ','Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(462,53,NULL,'EE_PAL_LZ','Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(463,53,NULL,'EE_PAL_LR','Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(464,53,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 100 g)',1996,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(465,54,NULL,'TARIFF','Dialogpost Easy Groß (bis 250 g)',250300001,3107,NULL),
(466,54,NULL,'PA_BASIS','Dialogpost Easy Groß (bis 250 g) + Premiumadress Basis',250300001,9216,9991),
(467,54,NULL,'PA_PLUS','Dialogpost Easy Groß (bis 250 g) + Premiumadress Plus',250300001,9217,9992),
(468,54,NULL,'PA_FOKUS','Dialogpost Easy Groß (bis 250 g) + Premiumadress Fokus',250300001,9218,9993),
(469,54,NULL,'PA_RETOURE','Dialogpost Easy Groß (bis 250 g) + Premiumadress Retoure',250300001,9219,9994),
(470,54,NULL,'PA_REPORT','Dialogpost Easy Groß (bis 250 g) + Premiumadress Report',250300001,9220,9995),
(471,54,NULL,'PA_HYBRID','Dialogpost Easy Groß (bis 250 g) + Premiumadress Hybrid',250300001,9723,9996),
(472,54,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Groß (bis 250 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(473,54,NULL,'BZE','Dialogpost Easy Groß (bis 250 g) + BZE',1000544,NULL,NULL),
(474,54,NULL,'EE_BEH_LR','Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(475,54,NULL,'EE_BEH_PLZ','Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(476,54,NULL,'EE_PAL_LZ','Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(477,54,NULL,'EE_PAL_LR','Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(478,54,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 250 g)',1996,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(479,55,NULL,'TARIFF','Dialogpost Easy Groß (bis 500 g)',250300001,3107,NULL),
(480,55,NULL,'PA_BASIS','Dialogpost Easy Groß (bis 500 g) + Premiumadress Basis',250300001,9216,9991),
(481,55,NULL,'PA_PLUS','Dialogpost Easy Groß (bis 500 g) + Premiumadress Plus',250300001,9217,9992),
(482,55,NULL,'PA_FOKUS','Dialogpost Easy Groß (bis 500 g) + Premiumadress Fokus',250300001,9218,9993),
(483,55,NULL,'PA_RETOURE','Dialogpost Easy Groß (bis 500 g) + Premiumadress Retoure',250300001,9219,9994),
(484,55,NULL,'PA_REPORT','Dialogpost Easy Groß (bis 500 g) + Premiumadress Report',250300001,9220,9995),
(485,55,NULL,'PA_HYBRID','Dialogpost Easy Groß (bis 500 g) + Premiumadress Hybrid',250300001,9723,9996),
(486,55,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Groß (bis 500 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(487,55,NULL,'BZE','Dialogpost Easy Groß (bis 500 g) + BZE',1000544,NULL,NULL),
(488,55,NULL,'EE_BEH_LR','Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(489,55,NULL,'EE_BEH_PLZ','Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(490,55,NULL,'EE_PAL_LZ','Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(491,55,NULL,'EE_PAL_LR','Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(492,55,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 500 g)',1996,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(493,56,NULL,'TARIFF','Dialogpost Easy Groß (bis 1.000 g)',250300001,3107,NULL),
(494,56,NULL,'PA_BASIS','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Basis',250300001,9216,9991),
(495,56,NULL,'PA_PLUS','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Plus',250300001,9217,9992),
(496,56,NULL,'PA_FOKUS','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Fokus',250300001,9218,9993),
(497,56,NULL,'PA_RETOURE','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Retoure',250300001,9219,9994),
(498,56,NULL,'PA_REPORT','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Report',250300001,9220,9995),
(499,56,NULL,'PA_HYBRID','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Hybrid',250300001,9723,9996),
(500,56,NULL,'PA_RETOURE_EXTRA','Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(501,56,NULL,'BZE','Dialogpost Easy Groß (bis 1.000 g) + BZE',1000544,NULL,NULL),
(502,56,NULL,'EE_BEH_LR','Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(503,56,NULL,'EE_BEH_PLZ','Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(504,56,NULL,'EE_PAL_LZ','Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(505,56,NULL,'EE_PAL_LR','Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(506,56,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 1.000 g)',1996,NULL,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Dialogpost nicht automationsfähig
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(507,401,NULL,'TARIFF','NAF Dialogpost Standard',250200001,90,NULL),
(508,401,NULL,'PA_BASIS','NAF Dialogpost Standard + Premiumadress Basis',250200001,9191,9991),
(509,401,NULL,'PA_PLUS','NAF Dialogpost Standard + Premiumadress Plus',250200001,9192,9992),
(510,401,NULL,'PA_FOKUS','NAF Dialogpost Standard + Premiumadress Fokus',250200001,9193,9993),
(511,401,NULL,'PA_RETOURE','NAF Dialogpost Standard + Premiumadress Retoure',250200001,9194,9994),
(512,401,NULL,'PA_REPORT','NAF Dialogpost Standard + Premiumadress Report',250200001,9195,9995),
(513,401,NULL,'PA_HYBRID','NAF Dialogpost Standard + Premiumadress Hybrid',250200001,9720,9996),
(514,401,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Standard + Premiumadress Retoure Extra',250200001,9823,9997),
(515,401,NULL,'BZE','NAF Dialogpost Standard + BZE',1000539,NULL,NULL),
(516,401,NULL,'EE_BEH_LR','NAF Dialogpost Standard + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(517,401,NULL,'EE_PAL_LZ','NAF Dialogpost Standard + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(518,401,NULL,'EE_PAL_LR','NAF Dialogpost Standard + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL),
(519,401,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Standard',1994,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(520,402,NULL,'TARIFF','NAF Dialogpost Standard (bis 50 g)',250200001,90,NULL),
(521,402,NULL,'PA_BASIS','NAF Dialogpost Standard (bis 50 g) + Premiumadress Basis',250200001,9191,9991),
(522,402,NULL,'PA_PLUS','NAF Dialogpost Standard (bis 50 g) + Premiumadress Plus',250200001,9192,9992),
(523,402,NULL,'PA_FOKUS','NAF Dialogpost Standard (bis 50 g) + Premiumadress Fokus',250200001,9193,9993),
(524,402,NULL,'PA_RETOURE','NAF Dialogpost Standard (bis 50 g) + Premiumadress Retoure',250200001,9194,9994),
(525,402,NULL,'PA_REPORT','NAF Dialogpost Standard (bis 50 g) + Premiumadress Report',250200001,9195,9995),
(526,402,NULL,'PA_HYBRID','NAF Dialogpost Standard (bis 50 g) + Premiumadress Hybrid',250200001,9720,9996),
(527,402,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Standard (bis 50 g) + Premiumadress Retoure Extra',250200001,9823,9997),
(528,402,NULL,'BZE','NAF Dialogpost Standard (bis 50 g) + BZE',1000539,NULL,NULL),
(529,402,NULL,'EE_BEH_LR','NAF Dialogpost Standard (bis 50 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(530,402,NULL,'EE_PAL_LZ','NAF Dialogpost Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(531,402,NULL,'EE_PAL_LR','NAF Dialogpost Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL),
(532,402,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Standard (bis 50 g)',1994,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(533,403,NULL,'TARIFF','NAF Dialogpost Groß',250300001,3107,NULL),
(534,403,NULL,'PA_BASIS','NAF Dialogpost Groß + Premiumadress Basis',250300001,9216,9991),
(535,403,NULL,'PA_PLUS','NAF Dialogpost Groß + Premiumadress Plus',250300001,9217,9992),
(536,403,NULL,'PA_FOKUS','NAF Dialogpost Groß + Premiumadress Fokus',250300001,9218,9993),
(537,403,NULL,'PA_RETOURE','NAF Dialogpost Groß + Premiumadress Retoure',250300001,9219,9994),
(538,403,NULL,'PA_REPORT','NAF Dialogpost Groß + Premiumadress Report',250300001,9220,9995),
(539,403,NULL,'PA_HYBRID','NAF Dialogpost Groß + Premiumadress Hybrid',250300001,9723,9996),
(540,403,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Groß + Premiumadress Retoure Extra',250300001,9826,9997),
(541,403,NULL,'BZE','NAF Dialogpost Groß + BZE',1000544,NULL,NULL),
(542,403,NULL,'EE_BEH_LR','NAF Dialogpost Groß + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(543,403,NULL,'EE_BEH_PLZ','NAF Dialogpost Groß + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(544,403,NULL,'EE_PAL_LZ','NAF Dialogpost Groß + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(545,403,NULL,'EE_PAL_LR','NAF Dialogpost Groß + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(546,403,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Groß',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(547,404,NULL,'TARIFF','NAF Dialogpost Groß (bis 100 g)',250300001,3107,NULL),
(548,404,NULL,'PA_BASIS','NAF Dialogpost Groß (bis 100 g) + Premiumadress Basis',250300001,9216,9991),
(549,404,NULL,'PA_PLUS','NAF Dialogpost Groß (bis 100 g) + Premiumadress Plus',250300001,9217,9992),
(550,404,NULL,'PA_FOKUS','NAF Dialogpost Groß (bis 100 g) + Premiumadress Fokus',250300001,9218,9993),
(551,404,NULL,'PA_RETOURE','NAF Dialogpost Groß (bis 100 g) + Premiumadress Retoure',250300001,9219,9994),
(552,404,NULL,'PA_REPORT','NAF Dialogpost Groß (bis 100 g) + Premiumadress Report',250300001,9220,9995),
(553,404,NULL,'PA_HYBRID','NAF Dialogpost Groß (bis 100 g) + Premiumadress Hybrid',250300001,9723,9996),
(554,404,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Groß (bis 100 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(555,404,NULL,'BZE','NAF Dialogpost Groß (bis 100 g) + BZE',1000544,NULL,NULL),
(556,404,NULL,'EE_BEH_LR','NAF Dialogpost Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(557,404,NULL,'EE_BEH_PLZ','NAF Dialogpost Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(558,404,NULL,'EE_PAL_LZ','NAF Dialogpost Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(559,404,NULL,'EE_PAL_LR','NAF Dialogpost Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(560,404,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Groß (bis 100 g)',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(561,405,NULL,'TARIFF','NAF Dialogpost Groß (bis 250 g)',250300001,3107,NULL),
(562,405,NULL,'PA_BASIS','NAF Dialogpost Groß (bis 250 g) + Premiumadress Basis',250300001,9216,9991),
(563,405,NULL,'PA_PLUS','NAF Dialogpost Groß (bis 250 g) + Premiumadress Plus',250300001,9217,9992),
(564,405,NULL,'PA_FOKUS','NAF Dialogpost Groß (bis 250 g) + Premiumadress Fokus',250300001,9218,9993),
(565,405,NULL,'PA_RETOURE','NAF Dialogpost Groß (bis 250 g) + Premiumadress Retoure',250300001,9219,9994),
(566,405,NULL,'PA_REPORT','NAF Dialogpost Groß (bis 250 g) + Premiumadress Report',250300001,9220,9995),
(567,405,NULL,'PA_HYBRID','NAF Dialogpost Groß (bis 250 g) + Premiumadress Hybrid',250300001,9723,9996),
(568,405,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Groß (bis 250 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(569,405,NULL,'BZE','NAF Dialogpost Groß (bis 250 g) + BZE',1000544,NULL,NULL),
(570,405,NULL,'EE_BEH_LR','NAF Dialogpost Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(571,405,NULL,'EE_BEH_PLZ','NAF Dialogpost Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(572,405,NULL,'EE_PAL_LZ','NAF Dialogpost Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(573,405,NULL,'EE_PAL_LR','NAF Dialogpost Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(574,405,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Groß (bis 250 g)',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(575,406,NULL,'TARIFF','NAF Dialogpost Groß (bis 500 g)',250300001,3107,NULL),
(576,406,NULL,'PA_BASIS','NAF Dialogpost Groß (bis 500 g) + Premiumadress Basis',250300001,9216,9991),
(577,406,NULL,'PA_PLUS','NAF Dialogpost Groß (bis 500 g) + Premiumadress Plus',250300001,9217,9992),
(578,406,NULL,'PA_FOKUS','NAF Dialogpost Groß (bis 500 g) + Premiumadress Fokus',250300001,9218,9993),
(579,406,NULL,'PA_RETOURE','NAF Dialogpost Groß (bis 500 g) + Premiumadress Retoure',250300001,9219,9994),
(580,406,NULL,'PA_REPORT','NAF Dialogpost Groß (bis 500 g) + Premiumadress Report',250300001,9220,9995),
(581,406,NULL,'PA_HYBRID','NAF Dialogpost Groß (bis 500 g) + Premiumadress Hybrid',250300001,9723,9996),
(582,406,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Groß (bis 500 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(583,406,NULL,'BZE','NAF Dialogpost Groß (bis 500 g) + BZE',11403406,NULL,NULL),
(584,406,NULL,'EE_BEH_LR','NAF Dialogpost Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(585,406,NULL,'EE_BEH_PLZ','NAF Dialogpost Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(586,406,NULL,'EE_PAL_LZ','NAF Dialogpost Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(587,406,NULL,'EE_PAL_LR','NAF Dialogpost Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(588,406,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Groß (bis 500 g)',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(589,407,NULL,'TARIFF','NAF Dialogpost Groß (bis 1.000 g)',250300001,3107,NULL),
(590,407,NULL,'PA_BASIS','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Basis',250300001,9216,9991),
(591,407,NULL,'PA_PLUS','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Plus',250300001,9217,9992),
(592,407,NULL,'PA_FOKUS','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Fokus',250300001,9218,9993),
(593,407,NULL,'PA_RETOURE','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Retoure',250300001,9219,9994),
(594,407,NULL,'PA_REPORT','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Report',250300001,9220,9995),
(595,407,NULL,'PA_HYBRID','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Hybrid',250300001,9723,9996),
(596,407,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Groß (bis 1.000 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(597,407,NULL,'BZE','NAF Dialogpost Groß (bis 1.000 g) + BZE',1000544,NULL,NULL),
(598,407,NULL,'EE_BEH_LR','NAF Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(599,407,NULL,'EE_BEH_PLZ','NAF Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(600,407,NULL,'EE_PAL_LZ','NAF Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(601,407,NULL,'EE_PAL_LR','NAF Dialogpost Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(602,407,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Groß (bis 1.000 g)',1993,NULL,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Dialogpost Easy nicht automationsfähig
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(603,501,NULL,'TARIFF','NAF Dialogpost Easy Standard',250200001,90,NULL),
(604,501,NULL,'PA_BASIS','NAF Dialogpost Easy Standard + Premiumadress Basis',250200001,9191,9991),
(605,501,NULL,'PA_PLUS','NAF Dialogpost Easy Standard + Premiumadress Plus',250200001,9192,9992),
(606,501,NULL,'PA_FOKUS','NAF Dialogpost Easy Standard + Premiumadress Fokus',250200001,9193,9993),
(607,501,NULL,'PA_RETOURE','NAF Dialogpost Easy Standard + Premiumadress Retoure',250200001,9194,9994),
(608,501,NULL,'PA_REPORT','NAF Dialogpost Easy Standard + Premiumadress Report',250200001,9195,9995),
(609,501,NULL,'PA_HYBRID','NAF Dialogpost Easy Standard + Premiumadress Hybrid',250200001,9720,9996),
(610,501,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Standard + Premiumadress Retoure Extra',250200001,9823,9997),
(611,501,NULL,'BZE','NAF Dialogpost Easy Standard + BZE',1000539,NULL,NULL),
(612,501,NULL,'EE_BEH_LR','NAF Dialogpost Easy Standard + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(613,501,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Standard + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(614,501,NULL,'EE_PAL_LR','NAF Dialogpost Easy Standard + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL),
(615,501,NULL,'SC','Zuschlag Dialogpost Easy Standard',1995,NULL,NULL),
(616,501,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Standard',1994,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(617,502,NULL,'TARIFF','NAF Dialogpost Easy Standard (bis 50 g)',250200001,90,NULL),
(618,502,NULL,'PA_BASIS','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Basis',250200001,9191,9991),
(619,502,NULL,'PA_PLUS','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Plus',250200001,9192,9992),
(620,502,NULL,'PA_FOKUS','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Fokus',250200001,9193,9993),
(621,502,NULL,'PA_RETOURE','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Retoure',250200001,9194,9994),
(622,502,NULL,'PA_REPORT','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Report',250200001,9195,9995),
(623,502,NULL,'PA_HYBRID','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Hybrid',250200001,9720,9996),
(624,502,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Standard (bis 50 g) + Premiumadress Retoure Extra',250200001,9823,9997),
(625,502,NULL,'BZE','NAF Dialogpost Easy Standard (bis 50 g) + BZE',1000539,NULL,NULL),
(626,502,NULL,'EE_BEH_LR','NAF Dialogpost Easy Standard (bis 50 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000517,NULL,NULL),
(627,502,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000518,NULL,NULL),
(628,502,NULL,'EE_PAL_LR','NAF Dialogpost Easy Standard (bis 50 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000519,NULL,NULL),
(629,502,NULL,'SC','Zuschlag Dialogpost Easy Standard (bis 50 g)',1995,NULL,NULL),
(630,502,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Standard (bis 50 g)',1994,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(631,503,NULL,'TARIFF','NAF Dialogpost Easy Groß',250300001,3107,NULL),
(632,503,NULL,'PA_BASIS','NAF Dialogpost Easy Groß + Premiumadress Basis',250300001,9216,9991),
(633,503,NULL,'PA_PLUS','NAF Dialogpost Easy Groß + Premiumadress Plus',250300001,9217,9992),
(634,503,NULL,'PA_FOKUS','NAF Dialogpost Easy Groß + Premiumadress Fokus',250300001,9218,9993),
(635,503,NULL,'PA_RETOURE','NAF Dialogpost Easy Groß + Premiumadress Retoure',250300001,9219,9994),
(636,503,NULL,'PA_REPORT','NAF Dialogpost Easy Groß + Premiumadress Report',250300001,9220,9995),
(637,503,NULL,'PA_HYBRID','NAF Dialogpost Easy Groß + Premiumadress Hybrid',250300001,9723,9996),
(638,503,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Groß + Premiumadress Retoure Extra',250300001,9826,9997),
(639,503,NULL,'BZE','NAF Dialogpost Easy Groß + BZE',1000544,NULL,NULL),
(640,503,NULL,'EE_BEH_LR','NAF Dialogpost Easy Groß + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(641,503,NULL,'EE_BEH_PLZ','NAF Dialogpost Easy Groß + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(642,503,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Groß + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(643,503,NULL,'EE_PAL_LR','NAF Dialogpost Easy Groß + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(644,503,NULL,'SC','Zuschlag Dialogpost Easy Groß',1996,NULL,NULL),
(645,503,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Groß',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(646,504,NULL,'TARIFF','NAF Dialogpost Easy Groß (bis 100 g)',250300001,3107,NULL),
(647,504,NULL,'PA_BASIS','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Basis',250300001,9216,9991),
(648,504,NULL,'PA_PLUS','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Plus',250300001,9217,9992),
(649,504,NULL,'PA_FOKUS','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Fokus',250300001,9218,9993),
(650,504,NULL,'PA_RETOURE','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Retoure',250300001,9219,9994),
(651,504,NULL,'PA_REPORT','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Report',250300001,9220,9995),
(652,504,NULL,'PA_HYBRID','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Hybrid',250300001,9723,9996),
(653,504,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Groß (bis 100 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(654,504,NULL,'BZE','NAF Dialogpost Easy Groß (bis 100 g) + BZE',1000544,NULL,NULL),
(655,504,NULL,'EE_BEH_LR','NAF Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(656,504,NULL,'EE_BEH_PLZ','NAF Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(657,504,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(658,504,NULL,'EE_PAL_LR','NAF Dialogpost Easy Groß (bis 100 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(659,504,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 100 g)',1996,NULL,NULL),
(660,504,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Groß (bis 100 g)',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(661,505,NULL,'TARIFF','NAF Dialogpost Easy Groß (bis 250 g)',250300001,3107,NULL),
(662,505,NULL,'PA_BASIS','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Basis',250300001,9216,9991),
(663,505,NULL,'PA_PLUS','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Plus',250300001,9217,9992),
(664,505,NULL,'PA_FOKUS','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Fokus',250300001,9218,9993),
(665,505,NULL,'PA_RETOURE','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Retoure',250300001,9219,9994),
(666,505,NULL,'PA_REPORT','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Report',250300001,9220,9995),
(667,505,NULL,'PA_HYBRID','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Hybrid',250300001,9723,9996),
(668,505,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Groß (bis 250 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(669,505,NULL,'BZE','NAF Dialogpost Easy Groß (bis 250 g) + BZE',1000544,NULL,NULL),
(670,505,NULL,'EE_BEH_LR','NAF Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(671,505,NULL,'EE_BEH_PLZ','NAF Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(672,505,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(673,505,NULL,'EE_PAL_LR','NAF Dialogpost Easy Groß (bis 250 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(674,505,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 250 g)',1996,NULL,NULL),
(675,505,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Groß (bis 250 g)',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(676,506,NULL,'TARIFF','NAF Dialogpost Easy Groß (bis 500 g)',250300001,3107,NULL),
(677,506,NULL,'PA_BASIS','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Basis',250300001,9216,9991),
(678,506,NULL,'PA_PLUS','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Plus',250300001,9217,9992),
(679,506,NULL,'PA_FOKUS','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Fokus',250300001,9218,9993),
(680,506,NULL,'PA_RETOURE','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Retoure',250300001,9219,9994),
(681,506,NULL,'PA_REPORT','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Report',250300001,9220,9995),
(682,506,NULL,'PA_HYBRID','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Hybrid',250300001,9723,9996),
(683,506,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Groß (bis 500 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(684,506,NULL,'BZE','NAF Dialogpost Easy Groß (bis 500 g) + BZE',1000544,NULL,NULL),
(685,506,NULL,'EE_BEH_LR','NAF Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(686,506,NULL,'EE_BEH_PLZ','NAF Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(687,506,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(688,506,NULL,'EE_PAL_LR','NAF Dialogpost Easy Groß (bis 500 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(689,506,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 500 g)',1996,NULL,NULL),
(690,506,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Groß (bis 500 g)',1993,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(691,507,NULL,'TARIFF','NAF Dialogpost Easy Groß (bis 1.000 g)',250300001,3107,NULL),
(692,507,NULL,'PA_BASIS','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Basis',250300001,9216,9991),
(693,507,NULL,'PA_PLUS','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Plus',250300001,9217,9992),
(694,507,NULL,'PA_FOKUS','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Fokus',250300001,9218,9993),
(695,507,NULL,'PA_RETOURE','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Retoure',250300001,9219,9994),
(696,507,NULL,'PA_REPORT','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Report',250300001,9220,9995),
(697,507,NULL,'PA_HYBRID','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Hybrid',250300001,9723,9996),
(698,507,NULL,'PA_RETOURE_EXTRA','NAF Dialogpost Easy Groß (bis 1.000 g) + Premiumadress Retoure Extra',250300001,9826,9997),
(699,507,NULL,'BZE','NAF Dialogpost Easy Groß (bis 1.000 g) + BZE',1000544,NULL,NULL),
(700,507,NULL,'EE_BEH_LR','NAF Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Leitregion',1000526,NULL,NULL),
(701,507,NULL,'EE_BEH_PLZ','NAF Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Behälterfertigung Postleitzahl',1000527,NULL,NULL),
(702,507,NULL,'EE_PAL_LZ','NAF Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitzone',1000528,NULL,NULL),
(703,507,NULL,'EE_PAL_LR','NAF Dialogpost Easy Groß (bis 1.000 g) + Entgeltermäßigung Palettenfertigung Leitregion',1000529,NULL,NULL),
(704,507,NULL,'SC','Zuschlag Dialogpost Easy Groß (bis 1.000 g)',1996,NULL,NULL),
(705,507,NULL,'SC','Zuschlag nicht automationsfähig Dialogpost Easy Groß (bis 1.000 g)',1993,NULL,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Briefpost International
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(706,20,NULL,'TARIFF','Standardbrief Intern.',208900001,10001,NULL),
(707,20,'NAI','TARIFF','Standardbrief Intern. + NACHNAHME + EINSCHREIBEN',208900001,11002,NULL),
(708,20,'NRS','TARIFF','Standardbrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',208900001,11003,NULL),
(709,20,'NEH','TARIFF','Standardbrief Intern. + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',208900001,11004,NULL),
(710,20,'NER','TARIFF','Standardbrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',208900001,11005,NULL),
(711,20,'ESI','TARIFF','Standardbrief Intern. + EINSCHREIBEN',208900001,11006,NULL),
(712,20,'RSI','TARIFF','Standardbrief Intern. + EINSCHREIBEN + RÜCKSCHEIN',208900001,11007,NULL),
(713,20,'ERI','TARIFF','Standardbrief Intern. + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',208900001,11008,NULL),
(714,20,'EHI','TARIFF','Standardbrief Intern. + EINSCHREIBEN + EIGENHÄNDIG',208900001,11009,NULL),
(715,20,'EIL','TARIFF','Standardbrief Intern. + EIL INTERNATIONAL',208900001,11010,NULL),
(716,20,NULL,'TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei)',208910001,12001,NULL),
(717,20,'NAI','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN',208910001,12002,NULL),
(718,20,'NRS','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',208910001,13003,NULL),
(719,20,'NEH','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',208910001,13004,NULL),
(720,20,'NER','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',208910001,13005,NULL),
(721,20,'ESI','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN',208910001,13006,NULL),
(722,20,'RSI','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN',208910001,13007,NULL),
(723,20,'ERI','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',208910001,13008,NULL),
(724,20,'EHI','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + EIGENHÄNDIG',208910001,13009,NULL),
(725,20,'EIL','TARIFF_NonEU','Standardbrief Intern. (Non EU/USt-frei) + EIL INTERNATIONAL',208910001,13010,NULL),
(726,20,'ES','BZL','Standardbrief Intern. + Einschreiben',1150,NULL,NULL),
(727,20,'EH','BZL','Standardbrief Intern. + Eigenhändig',1151,NULL,NULL),
(728,20,'RS','BZL','Standardbrief Intern. + Rückschein',1152,NULL,NULL),
(729,20,'NA','BZL','Standardbrief Intern. + Nachnahme',1153,NULL,NULL),
(730,20,'EI','BZL','Standardbrief Intern. + Eil International',1154,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(731,21,NULL,'TARIFF','Kompaktbrief Intern.',209000001,10011,NULL),
(732,21,'NAI','TARIFF','Kompaktbrief Intern. + NACHNAHME + EINSCHREIBEN',209000001,11012,NULL),
(733,21,'NRS','TARIFF','Kompaktbrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209000001,11013,NULL),
(734,21,'NEH','TARIFF','Kompaktbrief Intern. + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209000001,11014,NULL),
(735,21,'NER','TARIFF','Kompaktbrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209000001,11015,NULL),
(736,21,'ESI','TARIFF','Kompaktbrief Intern. + EINSCHREIBEN',209000001,11016,NULL),
(737,21,'RSI','TARIFF','Kompaktbrief Intern. + EINSCHREIBEN + RÜCKSCHEIN',209000001,11017,NULL),
(738,21,'ERI','TARIFF','Kompaktbrief Intern. + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209000001,11018,NULL),
(739,21,'EHI','TARIFF','Kompaktbrief Intern. + EINSCHREIBEN + EIGENHÄNDIG',209000001,11019,NULL),
(740,21,'EIL','TARIFF','Kompaktbrief Intern. + EIL INTERNATIONAL',209000001,11020,NULL),
(741,21,NULL,'TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei)',209010001,12011,NULL),
(742,21,'NAI','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN',209010001,13012,NULL),
(743,21,'NRS','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209010001,13013,NULL),
(744,21,'NEH','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209010001,13014,NULL),
(745,21,'NER','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209010001,13015,NULL),
(746,21,'ESI','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN',209010001,13016,NULL),
(747,21,'RSI','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN',209010001,13017,NULL),
(748,21,'ERI','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209010001,13018,NULL),
(749,21,'EHI','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + EIGENHÄNDIG',209010001,13019,NULL),
(750,21,'EIL','TARIFF_NonEU','Kompaktbrief Intern. (Non EU/USt-frei) + EIL INTERNATIONAL',209010001,13020,NULL),
(751,21,'ES','BZL','Kompaktbrief Intern. + Einschreiben',1150,NULL,NULL),
(752,21,'EH','BZL','Kompaktbrief Intern. + Eigenhändig',1151,NULL,NULL),
(753,21,'RS','BZL','Kompaktbrief Intern. + Rückschein',1152,NULL,NULL),
(754,21,'NA','BZL','Kompaktbrief Intern. + Nachnahme',1153,NULL,NULL),
(755,21,'EI','BZL','Kompaktbrief Intern. + Eil International',1154,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(756,22,NULL,'TARIFF','Großbrief Intern.',209100500,10051,NULL),
(757,22,'NAI','TARIFF','Großbrief Intern. + NACHNAHME + EINSCHREIBEN',209100500,11052,NULL),
(758,22,'NRS','TARIFF','Großbrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209100500,11053,NULL),
(759,22,'NEH','TARIFF','Großbrief Intern. + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209100500,11054,NULL),
(760,22,'NER','TARIFF','Großbrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209100500,11055,NULL),
(761,22,'ESI','TARIFF','Großbrief Intern. + EINSCHREIBEN',209100500,11056,NULL),
(762,22,'RSI','TARIFF','Großbrief Intern. + EINSCHREIBEN + RÜCKSCHEIN',209100500,11057,NULL),
(763,22,'ERI','TARIFF','Großbrief Intern. + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209100500,11058,NULL),
(764,22,'EHI','TARIFF','Großbrief Intern. + EINSCHREIBEN + EIGENHÄNDIG',209100500,11059,NULL),
(765,22,'EIL','TARIFF','Großbrief Intern. + EIL INTERNATIONAL',209100500,11060,NULL),
(766,22,NULL,'TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei)',209110500,12051,NULL),
(767,22,'NAI','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN',209110500,13052,NULL),
(768,22,'NRS','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209110500,13053,NULL),
(769,22,'NEH','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209110500,13054,NULL),
(770,22,'NER','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209110500,13055,NULL),
(771,22,'ESI','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN',209110500,13056,NULL),
(772,22,'RSI','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN',209110500,13057,NULL),
(773,22,'ERI','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209110500,13058,NULL),
(774,22,'EHI','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + EIGENHÄNDIG',209110500,13059,NULL),
(775,22,'EIL','TARIFF_NonEU','Großbrief Intern. (Non EU/USt-frei) + EIL INTERNATIONAL',209110500,13060,NULL),
(776,22,'ES','BZL','Großbrief Intern. + Einschreiben',1150,NULL,NULL),
(777,22,'EH','BZL','Großbrief Intern. + Eigenhändig',1151,NULL,NULL),
(778,22,'RS','BZL','Großbrief Intern. + Rückschein',1152,NULL,NULL),
(779,22,'NA','BZL','Großbrief Intern. + Nachnahme',1153,NULL,NULL),
(780,22,'EI','BZL','Großbrief Intern. + Eil International',1154,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(781,23,NULL,'TARIFF','Maxibrief Intern.',209101000,10071,NULL),
(782,23,'NAI','TARIFF','Maxibrief Intern. + NACHNAHME + EINSCHREIBEN',209101000,11072,NULL),
(783,23,'NRS','TARIFF','Maxibrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209101000,11073,NULL),
(784,23,'NEH','TARIFF','Maxibrief Intern. + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209101000,11074,NULL),
(785,23,'NER','TARIFF','Maxibrief Intern. + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209101000,11075,NULL),
(786,23,'ESI','TARIFF','Maxibrief Intern. + EINSCHREIBEN',209101000,11076,NULL),
(787,23,'RSI','TARIFF','Maxibrief Intern. + EINSCHREIBEN + RÜCKSCHEIN',209101000,11077,NULL),
(788,23,'ERI','TARIFF','Maxibrief Intern. + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209101000,11078,NULL),
(789,23,'EHI','TARIFF','Maxibrief Intern. + EINSCHREIBEN + EIGENHÄNDIG',209101000,11079,NULL),
(790,23,'EIL','TARIFF','Maxibrief Intern. + EIL INTERNATIONAL',209101000,11080,NULL),
(791,23,NULL,'TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei)',209111000,12071,NULL),
(792,23,'NAI','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN',209111000,13072,NULL),
(793,23,'NRS','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209111000,13073,NULL),
(794,23,'NEH','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209111000,13074,NULL),
(795,23,'NER','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209111000,13075,NULL),
(796,23,'ESI','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + EINSCHREIBEN',209111000,13076,NULL),
(797,23,'RSI','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN',209111000,13077,NULL),
(798,23,'ERI','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209111000,13078,NULL),
(799,23,'EHI','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + EINSCHREIBEN + EIGENHÄNDIG',209111000,13079,NULL),
(800,23,'EIL','TARIFF_NonEU','Maxibrief Intern. (Non EU/USt-frei) + EIL INTERNATIONAL',209111000,13080,NULL),
(801,23,'ES','BZL','Maxibrief Intern. + Einschreiben',1150,NULL,NULL),
(802,23,'EH','BZL','Maxibrief Intern. + Eigenhändig',1151,NULL,NULL),
(803,23,'RS','BZL','Maxibrief Intern. + Rückschein',1152,NULL,NULL),
(804,23,'NA','BZL','Maxibrief Intern. + Nachnahme',1153,NULL,NULL),
(805,23,'EI','BZL','Maxibrief Intern. + Eil International',1154,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(806,24,NULL,'TARIFF','Maxibrief Intern. (bis 2.000 g)',209102000,10091,NULL),
(807,24,'NAI','TARIFF','Maxibrief Intern. (bis 2.000 g) + NACHNAHME + EINSCHREIBEN',209102000,11092,NULL),
(808,24,'NRS','TARIFF','Maxibrief Intern. (bis 2.000 g) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209102000,11093,NULL),
(809,24,'NEH','TARIFF','Maxibrief Intern. (bis 2.000 g) + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209102000,11094,NULL),
(810,24,'NER','TARIFF','Maxibrief Intern. (bis 2.000 g) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209102000,11095,NULL),
(811,24,'ESI','TARIFF','Maxibrief Intern. (bis 2.000 g) + EINSCHREIBEN',209102000,11096,NULL),
(812,24,'RSI','TARIFF','Maxibrief Intern. (bis 2.000 g) + EINSCHREIBEN + RÜCKSCHEIN',209102000,11097,NULL),
(813,24,'ERI','TARIFF','Maxibrief Intern. (bis 2.000 g) + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209102000,11098,NULL),
(814,24,'EHI','TARIFF','Maxibrief Intern. (bis 2.000 g) + EINSCHREIBEN + EIGENHÄNDIG',209102000,11099,NULL),
(815,24,'EIL','TARIFF','Maxibrief Intern. (bis 2.000 g) + EIL INTERNATIONAL',209102000,11100,NULL),
(816,24,NULL,'TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei)',209112000,12091,NULL),
(817,24,'NAI','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN',209112000,13092,NULL),
(818,24,'NRS','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',209112000,13093,NULL),
(819,24,'NEH','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',209112000,13094,NULL),
(820,24,'NER','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209112000,13095,NULL),
(821,24,'ESI','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + EINSCHREIBEN',209112000,13096,NULL),
(822,24,'RSI','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN',209112000,13097,NULL),
(823,24,'ERI','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',209112000,13098,NULL),
(824,24,'EHI','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + EINSCHREIBEN + EIGENHÄNDIG',209112000,13099,NULL),
(825,24,'EIL','TARIFF_NonEU','Maxibrief Intern. (bis 2.000 g, Non EU/USt-frei) + EIL INTERNATIONAL',209112000,13100,NULL),
(826,24,'ES','BZL','Maxibrief Intern. (bis 2.000 g) + Einschreiben',1150,NULL,NULL),
(827,24,'EH','BZL','Maxibrief Intern. (bis 2.000 g) + Eigenhändig',1151,NULL,NULL),
(828,24,'RS','BZL','Maxibrief Intern. (bis 2.000 g) + Rückschein',1152,NULL,NULL),
(829,24,'NA','BZL','Maxibrief Intern. (bis 2.000 g) + Nachnahme',1153,NULL,NULL),
(830,24,'EI','BZL','Maxibrief Intern. (bis 2.000 g) + Eil International',1154,NULL,NULL);
COMMIT;

INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(831,25,NULL,'TARIFF','Brief Kilotarif International',200200001,30001,NULL),
(832,25,'NAI','TARIFF','Brief Kilotarif International + NACHNAHME + EINSCHREIBEN',200200001,31002,NULL),
(833,25,'NRS','TARIFF','Brief Kilotarif International + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN',200200001,31003,NULL),
(834,25,'NEH','TARIFF','Brief Kilotarif International + NACHNAHME + EINSCHREIBEN + EIGENHÄNDIG',200200001,31004,NULL),
(835,25,'NER','TARIFF','Brief Kilotarif International + NACHNAHME + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',200200001,31005,NULL),
(836,25,'ESI','TARIFF','Brief Kilotarif International + EINSCHREIBEN',200200001,31006,NULL),
(837,25,'RSI','TARIFF','Brief Kilotarif International + EINSCHREIBEN + RÜCKSCHEIN',200200001,31007,NULL),
(838,25,'ERI','TARIFF','Brief Kilotarif International + EINSCHREIBEN + RÜCKSCHEIN + EIGENHÄNDIG',200200001,31008,NULL),
(839,25,'EHI','TARIFF','Brief Kilotarif International + EINSCHREIBEN + EIGENHÄNDIG',200200001,31009,NULL),
(840,25,'EIL','TARIFF','Brief Kilotarif International + EIL INTERNATIONAL',200200001,31010,NULL),
(841,25,'ES','BZL','Brief Kilotarif International + Einschreiben',1090,NULL,NULL),
(842,25,'EH','BZL','Brief Kilotarif International + Eigenhändig',1091,NULL,NULL),
(843,25,'RS','BZL','Brief Kilotarif International + Rückschein',1092,NULL,NULL),
(844,25,'NA','BZL','Brief Kilotarif International + Nachnahme',1093,NULL,NULL),
(845,25,'EI','BZL','Brief Kilotarif International + Eil International',1094,NULL,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Dialogpost International
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(846,0,NULL,'DP_INT_PRIO','Dialogpost International + Beförderungsleistung PRIORITY',108800001,30048,NULL),
(847,0,NULL,'DP_INT_ECO','Dialogpost International + Beförderungsleistung ECONOMY',109000001,30046,NULL),
(848,0,NULL,'VP_INT_PRIO','VarioPlus International + Beförderungsleistung PRIORITY',202900001,30056,NULL),
(849,0,NULL,'VP_INT_ECO','VarioPlus International + Beförderungsleistung ECONOMY',202800001,30054,NULL);
COMMIT;

--------------------------------------------------------------------------------
-- Infrastrukturrabatt
--------------------------------------------------------------------------------
INSERT INTO mtext.MDOPRODUCTCODES (id,tariffid,addserviceid,name,description,productnumber,productcode,productcode_pa) VALUES
(850,0,NULL,'EE_INFRA','Infrastrukturrabatt',1000706,NULL,NULL);
COMMIT;

-- Creates additional tables for Content Hub

CREATE TABLE mtext.MXCS_OVERLAY_INFO (
    ID bigint NOT NULL,
    SCHEMAVERSION bigint NOT NULL,
    DESCRIPTION Varchar(50) NOT NULL
) ;

CREATE SEQUENCE mtext.MXCS_OVERLAY_RESOURCE_ID_SEQ START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

CREATE TABLE mtext.MXCS_OVERLAY_RESOURCE(
    RESIDENT bigint NOT NULL DEFAULT nextval('mtext.MXCS_OVERLAY_RESOURCE_ID_SEQ'),
    RESTYPE bigint NOT NULL,
    RESFOLDER bigint NOT NULL,
    RESNAME Varchar(254) NOT NULL,
    RESACTIVEVERSION bigint,
    RESLASTVERSION bigint,
    RESCHARSET Varchar(40),
    RESCREATORGUID Varchar(36),
    RESCREATEDDATE Timestamp,
    RESDESCRIPTION Varchar(254),
    RESCHANGERGUID Varchar(36),
    RESCHANGEDDATE Timestamp,
    RESUSEVERSIONS Smallint,
    RESTITLE Varchar(128),
    RESCONTENTHASH CHAR(40),
    RESSTATE bigint NOT NULL default 0,
    RESPARENTIDENT BIGINT,
    RESPARENTVERSION BIGINT,
    RESROOTPARENTIDENT BIGINT,
    RESROOTPARENTVERSION BIGINT) ;

ALTER SEQUENCE mtext.MXCS_OVERLAY_RESOURCE_ID_SEQ OWNED BY mtext.MXCS_OVERLAY_RESOURCE.resident;

CREATE TABLE mtext.MXCS_OVERLAY_RESOURCEVERSIONS(
    RSVRIDENT bigint NOT NULL,
    RSVRVERSION bigint NOT NULL,
    RSVRDESCRIPTION Varchar(254),
    RSVRCHANGERGUID Varchar(36),
    RSVRCHANGEDDATE Timestamp,
    RSVRCHARSET Varchar(20) NOT NULL,
    RSVRTITLE Varchar(128),
    RSVRCONTENTHASH CHAR(40),
    RSVRSTATE bigint NOT NULL default 0,
    RSVRPARENTIDENT BIGINT,
    RSVRPARENTVERSION BIGINT,
    RSVRROOTPARENTIDENT BIGINT,
    RSVRROOTPARENTVERSION BIGINT) ;

CREATE TABLE mtext.MXCS_OVERLAY_RESOURCEBLOBS(
    RSBLIDENT bigint NOT NULL,
    RSBLVERSION bigint NOT NULL,
    RSBLTYPE bigint NOT NULL,
    RSBLCOMPRESSION bigint NOT NULL,
    RSBLDATA bytea) ;

CREATE SEQUENCE mtext.MXCS_OVERLAY_RESOURCEPROPERTIES_RSPPSEQ_SEQ INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE mtext.MXCS_OVERLAY_RESOURCEPROPERTIES(
    RSPPSEQ bigint NOT NULL DEFAULT nextval('mtext.MXCS_OVERLAY_RESOURCEPROPERTIES_RSPPSEQ_SEQ'::regclass),
    RSPPIDENT bigint NOT NULL,
    RSPPNAME Varchar(254) NOT NULL,
    RSPPVALUE Varchar(254)) ;

-- ==============================================
--    Primary Keys
-- ==============================================
ALTER TABLE mtext.MXCS_OVERLAY_INFO ADD CONSTRAINT pk_mxcs_overlay_info PRIMARY KEY (ID);
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCE ADD CONSTRAINT pk_mxcs_overlay_resource PRIMARY KEY (RESIDENT);
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEVERSIONS ADD CONSTRAINT pk_mxcs_overlay_resversion PRIMARY KEY (RSVRIDENT, RSVRVERSION);
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEBLOBS ADD CONSTRAINT pk_mxcs_overlay_resblob PRIMARY KEY (RSBLIDENT, RSBLVERSION, RSBLTYPE);
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEPROPERTIES ADD CONSTRAINT pk_mxcs_overlay_resprop PRIMARY KEY (RSPPSEQ);

-- ==============================================
--    Foreign Keys
-- ==============================================
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCE ADD CONSTRAINT mxcsresfoldoc_fk FOREIGN KEY (RESFOLDER) REFERENCES mtext.MXCSDOCFOLDERS (FLDRIDENT) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE RESTRICT;
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCE ADD CONSTRAINT mxcs_overlay_rootparentresver_fk FOREIGN KEY (RESROOTPARENTIDENT, RESROOTPARENTVERSION) REFERENCES mtext.MXCSRESOURCEVERSIONS (RSVRIDENT, RSVRVERSION) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE SET NULL;
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEVERSIONS ADD CONSTRAINT mxcs_overlay_resver_fk FOREIGN KEY (RSVRIDENT) REFERENCES mtext.MXCS_OVERLAY_RESOURCE (RESIDENT) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEVERSIONS ADD CONSTRAINT mxcs_overlay_rootparentrsvrver_fk FOREIGN KEY (RSVRROOTPARENTIDENT, RSVRROOTPARENTVERSION) REFERENCES mtext.MXCSRESOURCEVERSIONS (RSVRIDENT, RSVRVERSION) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE SET NULL;
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEBLOBS ADD CONSTRAINT mxcs_overlay_resverdocbl_fk FOREIGN KEY (RSBLIDENT, RSBLVERSION) REFERENCES mtext.MXCS_OVERLAY_RESOURCEVERSIONS (RSVRIDENT, RSVRVERSION) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE mtext.MXCS_OVERLAY_RESOURCEPROPERTIES ADD CONSTRAINT mxcs_overlay_resprop_fk FOREIGN KEY (RSPPIDENT) REFERENCES mtext.MXCS_OVERLAY_RESOURCE (RESIDENT) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

-- ==============================================
--    Indices
-- ==============================================
CREATE INDEX MXCS_OVERLAY_RESSTATEIDX ON mtext.MXCS_OVERLAY_RESOURCE (RESSTATE) ;
CREATE INDEX MXCS_OVERLAY_RESTYPEIDX ON mtext.MXCS_OVERLAY_RESOURCE (RESTYPE) ;
CREATE UNIQUE INDEX MXCS_OVERLAY_RESUNIQNAME ON mtext.MXCS_OVERLAY_RESOURCE (RESFOLDER, RESNAME) ;
CREATE INDEX MXCS_OVERLAY_RESVERSTATEIDX ON mtext.MXCS_OVERLAY_RESOURCEVERSIONS (RSVRSTATE) ;
CREATE INDEX MXCS_OVERLAY_RESIDX1 ON mtext.MXCS_OVERLAY_RESOURCEPROPERTIES (RSPPVALUE, RSPPIDENT) ;
CREATE INDEX MXCS_OVERLAY_RESIDX2 ON mtext.MXCS_OVERLAY_RESOURCEPROPERTIES (RSPPNAME, RSPPVALUE, RSPPIDENT) ;
CREATE INDEX MXCS_OVERLAY_RESIDX3 ON mtext.MXCS_OVERLAY_RESOURCEPROPERTIES (RSPPNAME, RSPPIDENT, RSPPVALUE) ;
CREATE INDEX MXCS_OVERLAY_RSPPIDENTIDX ON mtext.MXCS_OVERLAY_RESOURCEPROPERTIES (RSPPIDENT) ;
-- Index on parent version which is set to NULL AFTER DELETE in trigger tad_MXCS_OVERLAY_RESOURCEVERSIONS 
-- (DB2 could not handle self-referencing foreign key with clause ON DELETE SET NULL)
CREATE INDEX MXCS_OVERLAY_PARENTRSVRVERIDX ON mtext.MXCS_OVERLAY_RESOURCEVERSIONS (RSVRPARENTIDENT, RSVRPARENTVERSION) ;
CREATE INDEX MXCS_OVERLAY_PARENTRESVERIDX ON mtext.MXCS_OVERLAY_RESOURCE (RESPARENTIDENT, RESPARENTVERSION) ;

-- ==============================================
--    Initial data
-- ==============================================

-- Increment the schema version when schema is updated
DELETE FROM mtext.MXCS_OVERLAY_INFO WHERE 1=1;
INSERT INTO mtext.MXCS_OVERLAY_INFO(ID, SCHEMAVERSION, DESCRIPTION) values (1, 0, 'ContentHub');

