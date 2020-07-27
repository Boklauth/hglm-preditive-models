libname StemData "C:\Users\Dell\Google Drive\000_Publishing Projects\Retention Studies\2017_STEMandNonSTEM_HLM\SAS Analysis\Data";
title 'List wise deletion 2017';





* comparing MI dataset and LW dataset;
* Will the results different when LW is used?;

proc logistic data=StemData.Cent_MI_ds; 

model Y2Returned (event='1') = hsgpa act fall_gpa  stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;

proc logistic data=StemData.Cent_LW_ds; 

model Y2Returned (event='1') = hsgpa act fall_gpa  stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;

* --------------------------------------------- ;


proc logistic data=StemData.Cent_MI_ds15; 

model Y2Returned (event='1') = hsgpa act  stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;

proc logistic data=StemData.Cent_LW_ds15; 
model Y2Returned (event='1') = hsgpa act  stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;



proc logistic data=StemData.Cent_MI_ds17; 

model Y2Returned (event='1') = hsgpa act fall_gpa stem stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;

proc logistic data=StemData.Cent_LW_ds17; 
model Y2Returned (event='1') = hsgpa act fall_gpa stem stem_dept dgender minority resident stem_dept
/selection = stepwise
	slentry=0.3
	slstay=0.05
	details 
	lackfit;
run;
