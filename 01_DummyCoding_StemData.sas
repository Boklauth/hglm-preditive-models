libname Field 'C:\Users\Dell\Google Drive\CLASSES\2019 Spring\Professional Field Experience 1\00Field';
/*libname hlm "C:\Users\shh6304\Google Drive\CLASSES\2019 Spring\HLM\MajorAssignment\ma02";*/
/*libname StemData "C:\Users\Dell\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\SAS Analysis\Data";*/

libname StemData 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data';


proc sql;
select * 
from StemData.Dummycoded_ds
where race IS NULL;
quit;
* N of missing race;
* missing is data from survey that has no matches;
proc sql;
select count(random_id)
from Field.Rdata2
where primary_ethnicity IS NULL;
quit;
proc sql;
select distinct (residency)
from Field.Rdata2;
quit;
proc sql;
select distinct (primary_ethnicity)
from Field.Rdata2;
quit;


proc sort data = Field.Rdata2;
by cohort;
run;

Data StemData.Dummycoded_ds (
keep=cohort collegeid deptid sid primary_ethnicity race resident 
dgender	hsgpa	act	stem	fall_gpa	Y2Returned minority y14 y15 y16 y17
/*returned	dummyRegistered	S2Returned*/	 
/*raceWh raceAI raceAsian raceBlack raceHisp raceInt raceHp raceMulti raceUnk*/
);

retain cohort collegeid  dept deptid sid hsgpa act fall_gpa /*S2Returned*/ Y2Returned dgender  
resident minority 		
stem primary_ethnicity race  y14 y15 y16 y17
/*race raceWh raceAI raceAsian raceBlack raceHisp raceInt raceHp raceMulti raceUnk primary_ethnicity	
gender	college	dept_name returned	dummyRegistered	dummy1stChoice*/	
;
set Field.Rdata2;

/*format stemprop 6.4;*/

* code studentid;
sid = _n_;

* code gender;

if gender = 'Male' then dgender=1;
if gender= 'Female' then dgender=0;

* Residency;
if residency = 'Resident' then Resident = 1;
if residency = 'Non-Resi' then Resident = 0;

format race 1.;
* code ethinicity;
If primary_ethnicity = "White" then race = 0;
If primary_ethnicity='American Indian or Alaska Native' then race=1;
	If primary_ethnicity='Asian' then race = 2;
	If primary_ethnicity='Black or African American' then race=3;
	If primary_ethnicity='Hispanic' then race = 4;
	If primary_ethnicity='International' then race = 5;;
	If primary_ethnicity='Native Hawaiian or Other Pacific Islander' then race = 6;;
	If primary_ethnicity='Two or More Races' then race = 7;
	If primary_ethnicity='Unknown' then race= 8;
	If primary_ethnicity="" then race = 8; /*code missing race into Unknown*/

	* dummy code race;
if race=0 then raceWh=1; else raceWh=0;
if race=1 then raceAI=1; else raceAI=0;
if race=2 then raceAsian=1; else raceAsian=0;
if race=3 then raceBlack=1; else raceBlack=0;
if race=4 then raceHisp=1; else raceHisp=0;
if race =5 then raceInt=1; else raceInt=0;
if race=6 then raceHp=1; else raceHp=0;
if race=7 then raceMulti=1; else raceMulti=0;
if race=8 then raceUnk=1; else raceUnk=0;

* Miniority;
if race=0 then minority = 0; else minority=1;

* code college;
if college ='Haworth College of Business' then collegeid = 1;
if college ='Engineering & Applied Sciences' then collegeid = 2;
if college ='Arts & Sciences' then collegeid = 3;
if college ='Education & Human Development' then collegeid = 4;
if college ='Aviation' then collegeid = 5;
if college ='Other' then collegeid = 6;
if college ='Health & Human Services' then collegeid = 7;
if college ='Fine Arts' then collegeid = 8;


* code dept;

if dept ='INTB' then deptid = 1;
if dept ='INTA' then deptid = 2;
if dept ='ENVS' then deptid = 3;
if dept ='ME' then deptid = 4;
if dept ='TLES' then deptid = 5;
if dept ='AVS' then deptid = 6;
if dept ='MGMT' then deptid = 7;
if dept ='FCS' then deptid = 8;
if dept ='BIOS' then deptid = 9;
if dept ='PSY' then deptid = 10;
if dept ='CCE' then deptid = 11;
if dept ='HPHE' then deptid = 12;
if dept ='INTO' then deptid = 13;
if dept ='PAPR' then deptid = 14;
if dept ='NUR' then deptid = 15;
if dept ='ECE' then deptid = 16;
if dept ='COM' then deptid = 17;
if dept ='THEA' then deptid = 18;
if dept ='DANC' then deptid = 19;
if dept ='CHEM' then deptid = 20;
if dept ='SPPA' then deptid = 21;
if dept ='PSCI' then deptid = 22;
if dept ='MKTG' then deptid = 23;
if dept ='MUS' then deptid = 24;
if dept ='HIST' then deptid = 25;
if dept ='SOC' then deptid = 26;
if dept ='IHP' then deptid = 27;
if dept ='ART' then deptid = 28;
if dept ='ACTY' then deptid = 29;
if dept ='INTD' then deptid = 30;
if dept ='SWRK' then deptid = 31;
if dept ='SPAN' then deptid = 32;
if dept ='CS' then deptid = 33;
if dept ='MATH' then deptid = 34;
if dept ='PHYS' then deptid = 35;
if dept ='ENGL' then deptid = 36;
if dept ='SPLS' then deptid = 37;
if dept ='LANG' then deptid = 38;
if dept ='BIS' then deptid = 39;
if dept ='GWS' then deptid = 40;
if dept ='EDMM' then deptid = 41;
if dept ='IEM' then deptid = 42;
if dept ='FCL' then deptid = 43;
if dept ='ANTH' then deptid = 44;
if dept ='STAT' then deptid = 45;
if dept ='GEOG' then deptid = 46;
if dept ='ECON' then deptid = 47;
if dept ='GEOS' then deptid = 48;

* code for year effect;

if cohort = 2014 then y14 = 1; else y14 = 0;
if cohort = 2015 then y15 = 1; else y15 = 0;
if cohort = 2016 then y16 = 1;else y16 = 0;
if cohort = 2017 then y17 = 1;else y17 = 0;

run;


* this will lock the data for you to access;

LOCK StemData.Dummycoded_ds ; 

/*proc sql;*/
/*unlock StemData.Dummycoded_ds;*/
/*quit;*/


* Find stem departments;


* Add a column to the dataset;
proc sql;
   alter table StemData.Dummycoded_ds
      add stem_dept num format=1.;
quit;
* Insert values for stem department;
* if a student has a stem status = 1, then the stem_dept =1;
proc sql;
UPDATE StemData.Dummycoded_ds
SET stem_dept = 1
WHERE stem=1;
quit;

* sort to select stem_dept;
proc sort data=StemData.Dummycoded_ds;
by deptid;
run;

* select stem department;
proc sql;
select distinct deptid, stem_dept
from StemData.Dummycoded_ds
where stem = 1;
quit; 


* this is how you unlock it so that you can update the table;
LOCK StemData.Dummycoded_ds clear ;


* identifying stem departments;
proc sql;
UPDATE StemData.Dummycoded_ds
SET stem_dept = 1
WHERE 
deptid = 2 OR
deptid = 3 OR
deptid = 4 OR
deptid = 9 OR
deptid = 11 OR
deptid = 14 OR
deptid = 16 OR
deptid = 20 OR
deptid = 30 OR
deptid = 33 OR
deptid = 34 OR
deptid = 35 OR
deptid = 39 OR
deptid = 41 OR
deptid = 42 OR
deptid = 45 OR
deptid = 48;
quit;

proc sql;
UPDATE StemData.Dummycoded_ds
SET stem_dept = 0
WHERE 
stem_dept IS NULL;
quit;

* verifying;
* stemid that is NULL means observations are unmatched from the SIS;
proc sql;
select distinct deptid
from stemData.Dummycoded_ds
where stem_dept IS NOT NULL;
run;

* a stem department cannot be both STEM and NON-STEM; 
proc freq data = StemData.Dummycoded_ds;
tables deptid*stem_dept;
run;



