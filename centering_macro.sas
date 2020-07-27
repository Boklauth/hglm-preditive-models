/*
TESTING MARCRO
*/
/*%let data =Cent_lw_ds14;*/
/*%let groupid = deptid;*/
/*%let var1 = hsgpa;*/
/*%let var2= act;*/
/*%let var3 = fall_gpa;*/
/*%let var4 = dgender;*/
/*%let var5 = resident;*/
/*%let var6 = minority;*/
/*%let var7 = stem_dept;*/

%Macro Centering(data=, groupid=, var1=, var2=, var3=, var4=, var5=, var6=, var7=,);

*libname StemData "C:\Users\shh6304\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\SAS Analysis\Data";

* calculating group mean;
proc means data = &data mean;
var &var1 &var2 &var3 &var4 &var5 &var6 &var7;
by &groupid;
output out = group_mean mean = gpm_&var1 gpm_&var2 gpm_&var3 gpm_&var4 gpm_&var5 gpm_&var6 gpm_&var7;
run;

* merge group mean with original;
proc sql;
CREATE TABLE x AS 
select a.*,  gpm_&var1, gpm_&var2, gpm_&var3, gpm_&var4, gpm_&var5, gpm_&var6, gpm_&var7
from &data a, group_mean
where a.&groupid = group_mean.&groupid;
quit;

*---------------------------------;

* calculating grand mean;
proc means data = &data noprint;
var &var1 &var2 &var3 &var4 &var5 &var6 &var7;
output out = grand_mean mean = gdm_&var1 gdm_&var2 gdm_&var3 gdm_&var4 gdm_&var5 gdm_&var6 gdm_&var7;
run;

* find n. of observation;
proc sql noprint;
select _FREQ_ into: n
from grand_mean;
quit;

data y (drop = _TYPE_ _FREQ_);
set grand_mean;
do i = 1 to &n;
output;
end;
drop i;
run;

* merge the merged data with grand mean data;
data temp;
merge x y;
run;

* ----------------------------------;

* calculating group mean centered and grand mean centered variables;
data cent_&data 
/*(drop = 
gpm_&var1 gpm_&var2 gpm_&var3 gpm_&var4 gpm_&var5 gpm_&var6 gpm_&var7
gdm_&var1 gdm_&var2 gdm_&var3 gdm_&var4 gdm_&var5 gdm_&var6 gdm_&var7)*/;
set temp;



*department centered &variables;
dc_&var1 	= 	&var1 	- 	gpm_&var1;
dc_&var2 	= 	&var2 	- 	gpm_&var2;
dc_&var3 	= 	&var3 	- 	gpm_&var3;
dc_&var4 	= 	&var4 	- 	gpm_&var4;
dc_&var5 	= 	&var5 	- 	gpm_&var5;
dc_&var6 	= 	&var6 	- 	gpm_&var6;
dc_&var7 	= 	&var7 	- 	gpm_&var7;


* grandmean centered &variables;
gdc_&var1 	= 	&var1 	- 	gdm_&var1;
gdc_&var2 	= 	&var2 	- 	gdm_&var2;
gdc_&var3 	= 	&var3 	- 	gdm_&var3;
gdc_&var4 	= 	&var4 	- 	gdm_&var4;
gdc_&var5 	= 	&var5 	- 	gdm_&var5;
gdc_&var6 	= 	&var6 	- 	gdm_&var6;
gdc_&var7 	= 	&var7 	- 	gdm_&var7;


run;

%Mend Centering;


