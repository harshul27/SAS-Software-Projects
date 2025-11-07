/* Import the data */
filename FHS '/home/u63986830/FramHeartStudy_data.csv';
data heart;
    infile FHS dsd firstobs=2;
    input AGE TOTAL_CHOL SBP DBP BMI CIGS_PER_DAY GLUCOSE HEART_RATE CVD HYPERTENSION;
run;

/* (a) Association between hypertension and CVD */
proc freq data=heart;
    tables HYPERTENSION*CVD / chisq;
run;

/* (b) Summary statistics and plots for CIGS_PER_DAY */
proc univariate data=heart plot;
    var CIGS_PER_DAY;
    histogram CIGS_PER_DAY;
run;

/* Parametric test (t-test) for CIGS_PER_DAY by CVD */
proc ttest data=heart;
    class CVD;
    var CIGS_PER_DAY;
run;

/* Non-parametric test (Wilcoxon rank-sum) for CIGS_PER_DAY by CVD */
proc npar1way data=heart wilcoxon;
    class CVD;
    var CIGS_PER_DAY;
run;

/* (c) Scatter plot of BMI vs GLUCOSE by CVD */
proc sgplot data=heart;
    scatter x=BMI y=GLUCOSE / group=CVD;
    reg x=BMI y=GLUCOSE / group=CVD;
run;

/* (d) Test if average SBP is more than 125 */
proc ttest data=heart h0=125 sides=u alpha=0.05;
    var SBP;
run;

/* (e) Create 4-category SBP variable and test association with hypertension */
proc rank data=heart groups=4 out=heart_ranked;
    var SBP;
    ranks SBP_cat;
run;

proc freq data=heart_ranked;
    tables SBP_cat*HYPERTENSION / chisq;
run;

/* (f) Check normality of TOTAL_CHOL */
proc univariate data=heart normal plot;
    var TOTAL_CHOL;
    histogram TOTAL_CHOL / normal;
    qqplot TOTAL_CHOL;
run;