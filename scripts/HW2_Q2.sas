/* Step 1: Input the data */
data rehab_therapy;
    input Duration Group Subject;
    datalines;
29.0 1 1
42.0 1 2
38.0 1 3
40.0 1 4
43.0 1 5
40.0 1 6
30.0 1 7
42.0 1 8
30.0 2 1
35.0 2 2
39.0 2 3
28.0 2 4
31.0 2 5
31.0 2 6
29.0 2 7
35.0 2 8
29.0 2 9
33.0 2 10
26.0 3 1
32.0 3 2
21.0 3 3
20.0 3 4
23.0 3 5
22.0 3 6
;
run;

/* Step (a): Fit the ANOVA model and generate the ANOVA table */
proc glm data=rehab_therapy;
    class Group; /* Specify categorical variable */
    model Duration = Group / solution; /* Include 'solution' option for parameter estimates */
run;

/* Step (b): Boxplot for each group */
proc sgplot data=rehab_therapy;
    vbox Duration / category=Group;
    title "Boxplot of Duration by Group";
run;

/* Step (d): Tukey's test for pairwise comparisons */
proc glm data=rehab_therapy;
    class Group;
    model Duration = Group / solution; /* Ensure correct syntax */
    means Group / tukey alpha=0.05; /* Pairwise comparisons using Tukey's test */
run;

/* Step (e): Estimate contrasts */
proc glm data=rehab_therapy;
    class Group;
    model Duration = Group / solution; /* Ensure 'solution' option is included */
    estimate 'Contrast L' Group -1 -1 +2; /* Example contrast calculation */
run;

/* Step (f): Residual analysis */
/* i. eij vs. Yˆij: Scatter plot of residuals vs. predicted values */
proc sgplot data=rehab_residuals;
    scatter x=predicted y=residual;
    title "Residuals vs. Predicted Values";
run;

/* ii. tij vs. Yˆij: Studentized residuals vs. predicted values (requires calculation) */
data rehab_residuals;
    set rehab_residuals;
    t_residual = residual / (sqrt(mserror) * sqrt(1 - hatdiag)); /* Calculate studentized residual */
run;

proc sgplot data=rehab_residuals;
    scatter x=predicted y=t_residual;
    refline 3.53 / axis=y;
    refline -3.53 / axis=y;
    title "Studentized Residuals vs. Predicted Values (Outlier Check)";
run;

/* iii. the normal probability plot and histogram of the eij */
proc univariate data=rehab_residuals normal plot;
    var residual;
    title "Normality Check of Residuals";
run;