/*  These sql statements are example of minimum setup for Oracle Database for use with JIRA applications.
This file is not being used by the docker image, but is rather an example of what is required according to
https://confluence.atlassian.com/adminjiraserver071/connecting-jira-applications-to-oracle-802592181.html */

create tablespace jira_tbs_01 datafile 'jira_tbs_f2.dat' size 100m autoextend on online;
create user jiradbuser identified by password default tablespace jira_tbs_01 quota unlimited on jira_tbs_01;
grant connect to jiradbuser;
grant create table to jiradbuser;
grant create sequence to jiradbuser;
grant create trigger to jiradbuser; 