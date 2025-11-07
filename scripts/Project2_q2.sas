OPTIONS NONOTES NOSTIMER NOSOURCE NOSYNTAXCHECK;

/* Step 1: Import the CSV dataset using your file path */
filename FHS '/home/u63986830/FramHeartStudy_data.csv';

data heart;
    infile FHS dsd firstobs=2;
    input AGE TOTAL_CHOL SBP DBP BMI CIGS_PER_DAY GLUCOSE HEART_RATE CVD HYPERTENSION;
run;

/* Print the first few observations to verify data import */
proc print data=heart (obs=5);
    title "Preview of Imported Heart Dataset";
run;

/* Step 2: Calculate mean and standard deviation for TOTAL_CHOL */
proc means data=heart noprint;
    var TOTAL_CHOL;
    output out=stats mean=mean_chol std=std_chol;
run;

/* Step 3: Monte Carlo simulation */
%let num_simulations = 1000;

data mc_simulation;
    if _n_ = 1 then set stats; /* Get mean and std from stats */
    do i = 1 to &num_simulations;
        simulated_chol = rand('NORMAL', mean_chol, std_chol);
        output;
    end;
run;

/* Step 4: Perform chi-square test on original data */
ods output TestsForNormality=chisq_orig;
proc univariate data=heart normal;
    title "Chi-Square Test for Normality on Original Data";
    var TOTAL_CHOL;
    histogram TOTAL_CHOL / normal (mu=est sigma=est);
run;

/* Step 5: Perform chi-square test on simulated data */
ods output TestsForNormality=mc_chisq;
proc univariate data=mc_simulation normal;
    title "Chi-Square Test for Normality on Monte Carlo Simulated Data";
    var simulated_chol;
    histogram simulated_chol / normal (mu=est sigma=est);
run;

/* Step 6: Perform Shapiro-Wilk test */
ods output TestsForNormality=shapiro;
proc univariate data=heart normal;
    title "Shapiro-Wilk Test for Normality on Original Data";
    var TOTAL_CHOL;
run;

/* Step 7: Compare p-values */
data compare_pvals;
    merge chisq_orig (in=a keep=pValue) 
          mc_chisq (in=b keep=pValue) 
          shapiro (in=c keep=pValue);
    
    if a and b and c; /* Only keep rows that exist in all three datasets */
    length chi_pval mc_pval shapiro_pval 8; /* Set consistent length */
    chi_pval = pValue; /* Ensure to get the correct variable from each dataset */
    mc_pval = pValue;
    shapiro_pval = pValue;
run;

/* Step 8: Print the results to check */
proc print data=compare_pvals;
    title "Comparison of P-Values from Tests for Normality";
run;

/* Step 9: Comment on results */
data _null_;
    set compare_pvals;
    put "Chi-Square p-value (Original) = " chi_pval;
    put "Monte Carlo Chi-Square p-value = " mc_pval;
    put "Shapiro-Wilk p-value = " shapiro_pval;
    
    if chi_pval < 0.05 then put "Original data is not normal.";
    else put "Original data is normal.";
    
    if mc_pval < 0.05 then put "Monte Carlo simulated data is not normal.";
    else put "Monte Carlo simulated data is normal.";
    
    if shapiro_pval < 0.05 then put "Shapiro-Wilk test indicates non-normality.";
    else put "Shapiro-Wilk test indicates normality.";
run;

OPTIONS NONOTES NOSTIMER NOSOURCE NOSYNTAXCHECK;
