libname StemData 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data';



proc copy in=StemData out=Work memtype=data;
select 
lw_ds lw_ds17 lw_ds16 lw_ds15 lw_ds14
;
run;



/*Include the centering macro*/
%include 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\centering_macro.sas';

%Centering(data=LW_ds17, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority, var7=stem_dept);
%Centering(data=LW_ds16, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority, var7=stem_dept);
%Centering(data=LW_ds15, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority, var7=stem_dept);
%Centering(data=LW_ds14, groupid=deptid, var1 = hsgpa, var2= act, var3 = fall_gpa, var4 = dgender, var5 = resident, var6=minority, var7=stem_dept);

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
Cent_lw_combined /*combined data set*/
cent_lw_ds14 cent_lw_ds15 cent_lw_ds16 cent_lw_ds17;/*data set separated by cohort*/
run;

* get the file out in SPSS for HLM 7;
proc export data = cent_lw_ds14
outfile = 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\HLM_Analysis\cent_lw_ds14.sav' 
DBMS = SPSS
replace;
run;
proc export data = cent_lw_ds15
outfile = 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\HLM_Analysis\cent_lw_ds15.sav' 
DBMS = SPSS
replace;
run;
proc export data = cent_lw_ds16
outfile = 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\HLM_Analysis\cent_lw_ds16.sav' 
DBMS = SPSS
replace;
run;
proc export data = cent_lw_ds17
outfile = 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\HLM_Analysis\cent_lw_ds17.sav' 
DBMS = SPSS
replace;
run;
proc export data = cent_lw_combined
outfile = 'C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\HLM_Analysis\cent_lw_combined.sav' 
DBMS = SPSS
replace;
run;

***********************************
* checking missing;
proc sql;
select count (*)
from cent_lw_combined
where fall_gpa IS NULL or act IS NULL or hsgpa IS NULL;
quit;


*checking group mean centered;
proc means data =StemData.Cent_lw_combined mean;
class deptid;
var dgender;
where cohort = 2014;
run;

proc sql;
select sid, deptid, dc_dgender, (dgender-0.6232394) as hand_gpmean_dgender, gpm_dgender, gdm_dgender
from StemData.cent_lw_combined
where cohort EQ 2014 and deptid = 1;
* correct;

*checking group mean centered;
proc means data=StemData.Cent_lw_combined mean;
var dgender;
where cohort =2014;
run;

*mean of gender: 0.4882533;

proc sql;
select sid, deptid, gdc_dgender, (dgender-0.4882533) as hand_gdmean_dgender, gpm_dgender, gdm_dgender
from StemData.cent_lw_combined
where cohort EQ 2014 and deptid = 1;
* also correct;
