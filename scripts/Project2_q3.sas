/* Step 1: Import the CSV dataset using your file path */
filename FHS '/home/u63986830/FramHeartStudy_data.csv';

data heart;
    infile FHS dsd firstobs=2;
    input AGE TOTAL_CHOL SBP DBP BMI CIGS_PER_DAY GLUCOSE HEART_RATE CVD HYPERTENSION;
run;

/* (a) Simple linear regression of SBP on BMI */
title 'Part (a): Simple Linear Regression of SBP on BMI';
proc reg data=heart;
    model SBP = BMI / clb;
    output out=reg_output p=predicted r=residuals;
run;

/* (b) Interval estimates for mean and individual responses */
title 'Part (b): Interval Estimates for Mean and Individual Responses';
proc means data=heart noprint;
    var BMI;
    output out=bmi_stats mean=mean_bmi q1=q1_bmi;
run;

data bmi_points;
    set bmi_stats;
    BMI = mean_bmi;
    output;
    BMI = q1_bmi;
    output;
run;

proc reg data=heart;
    model SBP = BMI;
    output out=predictions p=pred lcl=lower ucl=upper 
           lclm=lower_mean uclm=upper_mean;
run;

/* (c) Compare MSR and MSE */
title 'Part (c): Comparison of MSR and MSE';
proc reg data=heart;
    model SBP = BMI;
run;

/* (d) Coefficient of determination */
title 'Part (d): Coefficient of Determination';
proc reg data=heart;
    model SBP = BMI;
run;

/* (e) Simultaneous confidence sets */
title 'Part (e): Simultaneous Confidence Sets for Regression Coefficients';
proc reg data=heart;
    model SBP = BMI / alpha=0.05;
    plot / conf;
run;

/* Clear titles after running all procedures */
title; 