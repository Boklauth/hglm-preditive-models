libname StemData "C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\SAS Analysis\Data";


/* THE DATA SET WILL BE USED: cent_lw_combined*/
/* THE DATA SET HAS BEEN GROUP-MEAN AND GRAND-MEAN CENTERED*/

/*DESCRIPTIVE STATISTICS*/
/*# of students before data cleaning*/
proc sql;
select count(*)
from StemData.trimmed_ds_
/*where fall_gpa IS NULL;*/
quit;

data stemdata.cent_lw_combined;
set stemdata.cent_lw_combined;
cohortj=yearj;
drop yearj;
run;

/*Note: MCAR test showed that missginess mechanism was MCAR.*/
/*=> list wise deletion is ok. */

/*# students remained after missing data cleaning using list wise procedure*/
proc sql;
select count(*)
from cent_lw_combined;
quit;

/*students by cohorts*/
ods trace on;
proc freq data=cent_lw_combined;
tables cohort/out=a_table;
ods output CrossTabFreqs=a_table;
run;
ods trace off;

proc means data= cent_lw_combined n mean min max std;
var hsgpa act  fall_gpa stem_dept dgender minority resident y2returned;
class cohort;
run;
proc freq data = StemData.cent_lw_combined;
tables dgender*y2returned;
run;
proc freq data = StemData.cent_lw_combined;
tables y2returned*deptid;
where dgender=1;
run;

/*CODING RECAP*/
/*
* Gender
if gender = 'Male' then dgender=1;
if gender= 'Female' then dgender=0;
----
* Residency;
if residency = 'Resident' then Resident = 1;
if residency = 'Non-Resi' then Resident = 0;
----
* Minority
0 = white
1 = miniority 
----
stem_dept =1 => STEM department
----







/*HLM ANALYSIS*/
/*MODEL BUILDING*/
*How much of the variation in the second year FTIAC student retention attributable to students and to departments across four cohorts? ;
/*The unconditional model, no predictors, just random effect for the intercept*/
/*output used to calculate ICC, which tells how much variation in the outcome exists between level-2 units*/
*the null model is provided;
/*DO WE HAVE TO DO YEAR BY YEAR?*/

/*
Updated note: the null model is not needed for binary distribution.
*/
title 'the null model';
proc mixed data=StemData.Cent_lw_combined covtest;
class deptid;
model Y2Returned = y15 y16 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
/*where cohort =2014;*/
run;

/*
Covariance Parameter Estimates
Intercept's Estimate is variance for level 2. 
Residual's Estimate is variance for level 1. 
So, ICC = Var_l2/(Var_l1 + var_L2)
*/

*############################################;

*prefix: dc = department centered;
*prefix: gdc = grand mean centered;


/* 
GROUP MEAN CENTERED
What to know: 
- group mean centering produces scores that are uncorrelated with level 2 variables
- but it still makes the group mean centered varialbe correlate with the outcome variable.
- group mean centering takes away the difference between groups. It's like standardizing but no division with SD.
- So, it removes the between-cluster variation/effect from the predictor variable and yield a slope coefficient gamma_10
  that is unambigously interpreted as pooled within-cluster (i.e., Level 1) regression of outcome on the predictor.
- when group mean centering produces, the intercept variance (tau00) is the between-cluster variation in the outcome score.
--------------------
- grand mean centering does not change the ranking of scores so variabless have the same structures
- grand mean centering includes both within and between weighed combination (compositional effect). 
    In other words, grand mean centering contains variation at both levels 1 and 2. 
    So, this grand mean centered variable should be more highly correlated with the outcome variable than the group mean centered one.

*/
*make some variables; 

data StemData.Cent2;
set StemData.Cent_lw_combined;
dc_male=dc_dgender;
gdc_male=gdc_dgender;
group_grand_hsgpa=gpm_hsgpa - gdm_hsgpa;
group_grand_act=gpm_act - gdm_act;
group_grand_fall_gpa=gpm_fall_gpa - gdm_fall_gpa;
group_grand_resident=gpm_resident - gdm_resident;
group_grand_minority=gpm_minority - gdm_minority;
group_grand_male=gpm_dgender - gdm_dgender;
group_grand_resident=gpm_resident - gdm_resident;
run;
* export to spss for HLM;
proc sort data =StemData.Cent2;
by deptid;
run;
proc export data=StemData.Cent2
outfile ="C:\Users\Dell\Google Drive\CLASSES\2020_Spring\Field_HLM_predicting retention\2017_STEMandNonSTEM_HLM\HLM_Analysis\Cent2.sav"
dbms=sav
replace;
run;
* too bad HLM won't let me import this big of file;

*RQ1;

title1 "full- group mean centering";
proc mixed data=StemData.Cent2 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  dc_hsgpa dc_act dc_fall_gpa dc_dgender dc_minority dc_resident y14 y15 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;
title1;

/*title1 "a reduced model: group mean centering";*/
/*proc mixed data=StemData.Cent2 covtest  /*method=ML*/;*/
/*class deptid;*/
/*model Y2Returned =  dc_fall_gpa dc_act  y14 y15 y17*/
/*/solution ddfm = bw;*/
/*random intercept / sub = deptid type=vc;*/
/*run;*/
/*title1;*/

* what is the group mean for ACT by department?;

/*proc sql;*/
/*select distinct deptid, gpm_act, gpm_fall_gpa*/
/*from StemData.Cent2*/
/*order by gpm_act, gpm_fall_gpa;*/

*RQ2;

* all variables were grand mean centered;

title1 "Full model: grand mean centered";
title2 "level 1 variables were grand mean centered.";
proc mixed data=StemData.Cent2 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  stem_dept 
gdc_hsgpa gdc_act gdc_fall_gpa  gdc_dgender gdc_minority gdc_resident y14 y15 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;
title2;
title1;

/*title1 "Full model: grand mean centered--interaction";*/
/*title2 "level 1 variables were grand mean centered.";*/
/*proc mixed data=StemData.Cent2 covtest  /*method=ML*/;*/
/*class deptid;*/
/*model Y2Returned =  stem_dept */
/*gdc_hsgpa gdc_act gdc_fall_gpa  gdc_dgender gdc_minority gdc_resident stem_dept*gdc_minority y14 y15 y17*/
/*/solution ddfm = bw;*/
/*random intercept / sub = deptid type=vc;*/
/*run;*/
/*title2;*/
/*title1;*/

/* end of analysis*/





/* exploratory analyses*/
/*dummy variables were not significant and thus removed from the model*/
title1 "Reduced Model: between and within effects with stem_dept";
title2 "level 1 variables were group mean centered. agregate variables were grand mean centered. stem_dept was not grand/group centered.";
proc mixed data=StemData.Cent2 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  group_grand_act group_grand_fall_gpa /*group_grand_resident group_grand_male group_grand_minority*/
dc_act dc_fall_gpa  /*dc_resident dc_dgender dc_minority*/ y14 y15 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;
title1;

/*add stem_dept variable*/
title1 "Reduced Model: between and within effects with stem_dept";
title2 "level 1 variables were group mean centered. agregate variables were grand mean centered. stem_dept was not grand/group centered.";

proc mixed data=StemData.Cent2 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  stem_dept group_grand_act group_grand_fall_gpa dc_act dc_fall_gpa  y14 y15 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;
title2;
title1;

********************;
*another way to testing within and between effects or level 1 and level 2 effects on y;

/*add stem_dept variable*/
title1 "between and within effects stem_dept";
proc mixed data=StemData.Cent2 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  stem_dept group_grand_act group_grand_fall_gpa gdc_act gdc_fall_gpa  y14 y15 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;
title1;
******************************;

*STEM DEPT EFFECT AFER CONTROLLING FOR ACT AND FALL GPA (GRAND MEAN CENTERING AT LEVEL 1);
title1 "grand mean at level 1 and add stem_dept at level 2";
proc mixed data=StemData.Cent2 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  stem_dept gdc_act gdc_fall_gpa y14 y15 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;
title1;

*--------------------END---------------------------;

/*NOT SURE WHAT THE CLASS WITH REF DOES BELOW*/
/*title1 "with level-2 var, stem_dept";*/
/*proc mixed data=StemData.Cent_lw_combined covtest  /*method=ML*/;*/
/*class deptid dgender (ref='0')resident (ref='0') minority (ref='0') stem_dept (ref='0');*/
/*model Y2Returned =  gdc_hsgpa gdc_act gdc_fall_gpa dgender resident minority stem_dept dgender y15 y16 y17*/
/*/solution ddfm = bw;*/
/*random intercept stem_dept/ sub = deptid type=vc;*/
/*run;*/
/*title1;*/



/*
Dr. Spybrook, said that I don't need to exclude the variables that are not significant from the model. 

*/


/*
Add deptsize (departmetn size)
This size is measured by the n of students. It is not helpful. If it is measured by n of factuy and staff, it would be more helpful. 
*/



*add level 2 variable; 
proc mixed data=StemData.Cent_lw_combined covtest  /*method=ML*/;
class deptid;
model Y2Returned =  gdc_act gdc_fall_gpa minority stem_dept deptsize/*dgender*/ y15 y16 y17
/solution ddfm = bw;
random intercept / sub = deptid type=vc;
run;



proc sql;
select count (distinct deptid)
from stemdata.cent_lw_combined
where stem_dept=0;

/*
For the code above, to let level-1 variables to vary between department, 
then include them at the level 2 in the random statement. 
Eg., "random intercept stem dgender
*/

/*LEVEL 2*/
/*random intercept stem_dept/ sub = deptid type=un;*/
/*lsmeans;*/
/*where y14=1;*/

proc sql;
select *
from StemData.Cent_lw_combined
where fall_gpa IS NULL;
quit;





/*OLD DRAFT*/
*######################################################;
title 'List wise deletion 2017';

* Model buidling;
* it shows that 2015 dataset should be used in order to have stem_dept as a significant variable;
proc logistic data=StemData.cent_lw_combined; 

model Y2Returned (event='1') = hsgpa act  fall_gpa stem_dept dgender minority resident stem_dept y14
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;
proc logistic data=StemData.Cent_MI_ds14; 

model Y2Returned (event='1') = hsgpa act  fall_gpa stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;


proc logistic data=StemData.Cent_MI_ds16; 

model Y2Returned (event='1') = hsgpa act  fall_gpa stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;


* but dataset for 2017 shows more significant variables ;
/*
  var		chi squ 	p
1 fall_gpa  604.1790   	<.0001 
2 resident  14.2963   	0.0002 
3 dgender   5.7865   	0.0161 
4 hsgpa   	5.4810   	0.0192 
*/
proc logistic data=StemData.Cent_MI_ds17; 

model Y2Returned (event='1') = hsgpa act  fall_gpa stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;

* Starting proc mixed;



title1 'Y 2017';

title2 'Mutliple Imputation dataset';


proc mixed data=StemData.Cent_MI_ds17 covtest  /*method=ML*/;
class deptid;
model Y2Returned =  gdc_hsgpa gdc_act gdc_fall_gpa  stem_dept /solution ddfm = bw;
random intercept/ sub = deptid type=un;
run;

title1 'Y 2015';
/*
significant variables
fall_gpa
stem_dept
*/

title2 'Mutliple Imputation dataset';
proc mixed data=StemData.Cent_MI_ds15 covtest  /*method=ML*/;
class deptid;
model Y2Returned = hsgpa act  fall_gpa stem_dept dgender minority resident stem_dept /solution ddfm = bw;
/*model Y2Returned =  gdc_hsgpa gdc_act gdc_fall_gpa  stem_dept /solution ddfm = bw;*/
random intercept stem_dept/ sub = deptid type=un;
run;



