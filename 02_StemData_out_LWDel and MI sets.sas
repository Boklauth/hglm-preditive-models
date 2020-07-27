libname StemData 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data';


* delete data that cannot be matched with survey data;
* in other words, use only data from SIS;

Data StemData.trimmed_ds_ (keep=cohort collegeid deptid sid /*race primary_ethnicity*/	
dgender	/*college	dept dept_name*/	
hsgpa	act	/*dummy1stChoice*/	
stem	fall_gpa	/*returned	dummyRegistered	S2Returned*/	
/*raceWh raceAI raceAsian raceBlack raceHisp raceInt raceHp raceMulti raceUnk*/
Y2Returned resident minority stem_dept y14 y15 y16 y17);
set StemData.dummycoded_ds;
if cohort=. then delete;
run;

proc sort
data = StemData.trimmed_ds_;
by deptid sid;
run;

* delete the missing data: reason: deceased;
PROC SQL;
DELETE FROM StemData.trimmed_ds_
WHERE y2returned IS NULL;
quit;

proc sql;
select count(*)
from StemData.trimmed_ds_
where hsgpa IS NULL OR act IS NULL or fall_gpa IS NULL;
quit;

proc sql;
select count(*)
from StemData.trimmed_ds_
/*where fall_gpa IS NULL;*/
quit;

proc sql;
select count(*)
from StemData.trimmed_ds_
where fall_gpa IS NULL;
quit;

* Once students were enrolled by the census date,... 
* their stutus will be enrolled although they withdrew after the censuse date ; 
* So, their fall gpa could be missing;
* So, thier gpa shoudl be zero;

proc sql;
update StemData.trimmed_ds_
set fall_gpa=0
where fall_gpa IS NULL;
quit;

proc sql;
select 100*count(*)/(select count(*) from StemData.trimmed_ds_) as total
from StemData.trimmed_ds_
where hsgpa IS NULL OR act IS NULL or fall_gpa IS NULL;
quit;

* percentage of missing;
proc sql;
select count(*)/
from StemData.trimmed_ds_
quit;

* IDENTIFY MISSING-VALUE MECHANISM

* conducting MCAR test on hggpa and act;
%include "C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\Little_MCAR_test_modified_hlm.sas";
* missing value mechanism is MCAR. Therefore, missing values can be omitted.;
* fall_gpa was not involved in the missing data analysis because doing so may biase the data;
* fall_gpa is one of the variables used in the analysis; 



* HANDLE MISSING DATA USING LISTWISE DELETION;
* Create a listwise deletion database;
Data StemData.LW_ds;
set StemData.trimmed_ds_;
if hsgpa=. then delete;
if act=. then delete;
run;



* add that variable to the existing table;
proc sql;
alter StemData.LW_ds add deptsize as 
(select distinct deptid, count(*)*100/(select count(*) from StemData.LW_ds where cohort = 2014) as total
from StemData.LW_ds
where cohort = 2014
group by deptid) b
where StemData.LW_ds.deptid = b.deptid;





* Create a listwise deletion for ds 2017;
data StemData.LW_ds17;
set StemData.LW_ds;
if cohort =2017;
run;
* calculate proportion for each department: level 2 variable;
proc sql;
create table prop17 as select distinct deptid, count(*)*100/(select count(*) from StemData.LW_ds where cohort = 2017) as deptsize
from StemData.LW_ds
where cohort = 2017
group by deptid;

* data with deptsize;
data StemData.LW_ds17;
merge StemData.LW_ds17 prop17;
by deptid;
run;

* Create a listwise deletion for ds 2016;
data StemData.LW_ds16;
set StemData.LW_ds;
if cohort =2016;
run;
* calculate proportion for each department: level 2 variable;
proc sql;
create table prop16 as select distinct deptid, count(*)*100/(select count(*) from StemData.LW_ds where cohort = 2016) as deptsize
from StemData.LW_ds
where cohort = 2016
group by deptid;

* data with deptsize;
data StemData.LW_ds16;
merge StemData.LW_ds16 prop16;
by deptid;
run;


* Create a listwise deletion for ds 2015;
data StemData.LW_ds15;
set StemData.LW_ds;
if cohort =2015;
run;
* calculate proportion for each department: level 2 variable;
proc sql;
create table prop15 as select distinct deptid, count(*)*100/(select count(*) from StemData.LW_ds where cohort = 2015) as deptsize
from StemData.LW_ds
where cohort = 2015
group by deptid;

* data with deptsize;
data StemData.LW_ds15;
merge StemData.LW_ds15 prop15;
by deptid;
run;


* Create a listwise deletion for ds 2014;
data StemData.LW_ds14;
set StemData.LW_ds;
if cohort =2014;
run;

* calculate proportion for each department: level 2 variable;
proc sql;
create table prop14 as select distinct deptid, count(*)*100/(select count(*) from StemData.LW_ds where cohort = 2014) as deptsize
from StemData.LW_ds
where cohort = 2014
group by deptid;

proc sql;
create table lw_ds14 as select a.*, b.deptsize
from StemData.LW_ds14 a, prop14 b
where a.deptid=b.deptid;

* data with deptsize;
data StemData.LW_ds14;
merge StemData.LW_ds14 prop14;
by deptid;
run;




%include "C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Centering macro.sas";

%include "C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\Little_MCAR_test_modified_hlm.sas";
proc copy in=StemData out=Work memtype=data;
select 
lw_ds lw_ds17 lw_ds16 lw_ds15 lw_ds14
;
run;

* checking mean;

/*proc means data=lw_ds14 mean;*/
/*class deptid;*/
/*var act;*/
/*run;*/
/**/
/*proc means data=lw_ds14 mean;*/
/*var dgender;*/
/*class deptid;*/
/*run;*/
/** stem in dept;*/
/*proc means data=lw_ds14 mean;*/
/*var hsgpa act fall_gpa dgender minority resident stem;*/
/*by deptid;*/
/*output out = group_mean2 mean = gpm_hsgpa gpm_act gpm_fall_gpa gpm_dgender gpm_minority gpm_resident gpm_stem;*/
/*run;*/
/**/
/*proc sql; */
/*select distinct deptid, gpm_act*/
/*from cent_lw_ds14;*/
/**/
/*proc sql; */
/*select distinct deptid, gpm_hsgpa, gpm_act, gpm_fall_gpa, gpm_dgender, gpm_stem*/
/*from cent_lw_ds14;*/
/**/
/** checking data: count n of stem in each dept;*/
/*proc sql;*/
/*select deptid, count (stem)*/
/*from cent_lw_ds14*/
/*where stem=1*/
/*group by deptid*/
/*order by deptid;*/
/**/
/** stem department;*/
/*proc sql;*/
/*select distinct deptid*/
/*from cent_lw_ds14*/
/*where stem_dept=1;*/
/*order by deptid;*/
/**/
/*proc means data=lw_ds14 mean;*/
/*class deptid;*/
/*var stem;*/
/*run;*/
/**/

* Variables have to be in order of display in SAS table;
* Each variable entered will be centered;
* prefix "dc_" is department/group mean centering;
* prefix "gdc_" is grand mean centering;
* Centering by cohort;

*%Centering(data=LW_ds, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority, var7 = stem );
%Centering(data=LW_ds17, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority);
%Centering(data=LW_ds16, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority);
%Centering(data=LW_ds15, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority);
%Centering(data=LW_ds14, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority);

* Merged the centerd data as one combined file;
data Cent_lw_combined;
set cent_lw_ds14 cent_lw_ds15 cent_lw_ds16 cent_lw_ds17;
run;
data Cent_lw_combined;
set Cent_lw_combined;
if cohort = '2015' then yearj=1;else yearj=0;
if cohort = '2016' then yearj=2;
if cohort = '2017' then yearj=3;
run;




* copy data set to the library StemData;
proc copy in=work out=StemData memtype=data;
select 
Cent_lw_combined;
run;

* checking missing;
proc sql;
select count (*)
from cent_lw_combined
where fall_gpa IS NULL or act IS NULL or hsgpa IS NULL;
quit;



/*below may be not applicable anymore*/
data stemdata.cent_lw17;
set stemdata.cent_lw_combined;
if y17=1;
run;

data stemdata.cent_lw16;
set stemdata.cent_lw_combined;
if y16=1;
run;
data stemdata.cent_lw15;
set stemdata.cent_lw_combined;
if y15=1;
run;
data stemdata.cent_lw14;
set stemdata.cent_lw_combined;
if y14=1;
run;




*Exporting datasets as SPSS files for HLM;
* Imputed data;

PROC EXPORT DATA=stemdata.cent_lw17
            FILE="C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data\Cent_lw17"
            DBMS=SPSS REPLACE;
RUN;

PROC EXPORT DATA=StemData.Cent_lw16
FILE="C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data\Cent_lw16"
            DBMS=SPSS REPLACE;
RUN;

PROC EXPORT DATA=Stemdata.Cent_lw15
            FILE="C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data\Cent_lw15"
            DBMS=SPSS REPLACE;
RUN;

PROC EXPORT DATA=Stemdata.Cent_lw14
            FILE="C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data\Cent_lw14"
            DBMS=SPSS REPLACE;
RUN;

* List wise deletion data;


PROC EXPORT DATA=Stemdata.Cent_LW_ds17
            FILE="C:\Users\Dell\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\HLM_Analysis\Cent_LW_ds17"
            DBMS=SPSS REPLACE;
RUN;

PROC EXPORT DATA=Stemdata.Cent_LW_ds16
            FILE="C:\Users\Dell\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\HLM_Analysis\Cent_LW_ds16"
            DBMS=SPSS REPLACE;
RUN;

PROC EXPORT DATA=Stemdata.Cent_LW_ds15
            FILE="C:\Users\Dell\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\HLM_Analysis\Cent_LW_ds15"
            DBMS=SPSS REPLACE;
RUN;

PROC EXPORT DATA=Stemdata.Cent_LW_ds14
            FILE="C:\Users\Dell\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\HLM_Analysis\Cent_LW_ds14"
            DBMS=SPSS REPLACE;
RUN;


