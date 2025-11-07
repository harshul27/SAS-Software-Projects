/* Step 1: Input Data */
data kidney_data;
    input Days Duration Weight PatientID;
    datalines;
    0 1 1 1
    2 1 1 2
    1 1 1 3
    3 1 1 4
    0 1 1 5
    2 1 1 6
    0 1 1 7
    5 1 1 8
    6 1 1 9
    8 1 1 10
    2 1 2 1
    4 1 2 2
    7 1 2 3
    12 1 2 4
    15 1 2 5
    4 1 2 6
    3 1 2 7
    1 1 2 8
    5 1 2 9
    20 1 2 10
    15 1 3 1
    10 1 3 2
    8 1 3 3
    5 1 3 4
    25 1 3 5
    16 1 3 6
    7 1 3 7
    30 1 3 8
    3 1 3 9
    27 1 3 10
    0 2 1 1
    1 2 1 2
    1 2 1 3
    0 2 1 4
    4 2 1 5
    2 2 1 6
    7 2 1 7
    4 2 1 8
    0 2 1 9
    3 2 1 10
    5 2 2 1
    3 2 2 2
    2 2 2 3
    0 2 2 4
    1 2 2 5
    1 2 2 6
    3 2 2 7
    6 2 2 8
    7 2 2 9
    9 2 2 10
    10 2 3 1
    8 2 3 2
    12 2 3 3
    3 2 3 4
    7 2 3 5
    15 2 3 6
    4 2 3 7
    9 2 3 8
    6 2 3 9
    1 2 3 10
;
run;

/* (a) Interaction Plot */
title "Interaction Plot for Days of Hospitalization";
proc sgplot data=kidney_data;
    series x=Weight y=Days / group=Duration markers;
    xaxis label="Weight Group";
    yaxis label="Days of Hospitalization";
run;
/* Interpretation: This plot shows the interaction between weight groups and hospitalization duration. 
   If lines cross, interaction exists; if parallel, no interaction. */

/* (b) Box-Cox Transformation */
data kidney_trans;
    set kidney_data;
    Days1 = Days + 1; /* Adding 1 to avoid zero values */
run;

title "Box-Cox Transformation";
proc transreg data=kidney_trans;
    model boxcox(Days1) = class(Duration | Weight);
run;
/* Interpretation: The "convenient lambda" indicates the best transformation. 
   Common values: 0 (log transform), 1 (no transform), or other values. */

/* (c) ANOVA Model V */
title "ANOVA Model with Interaction Effect";
proc glm data=kidney_trans;
    class Duration Weight;
    model Days1 = Duration Weight Duration*Weight;
    lsmeans Duration*Weight / stderr;
    output out=anova_results p=predicted r=residuals;
run;
quit;
/* Interpretation: If the interaction p-value is <0.05, reject H0, meaning interaction is significant. */

/* (d) Type III Tests for Main Effects */
title "Testing Main Effects";
proc glm data=kidney_trans;
    class Duration Weight;
    model Days1 = Duration Weight Duration*Weight;
    lsmeans Duration Weight / stderr;
run;
quit;
/* Interpretation: If p-value < 0.05 for Duration or Weight, main effects are significant. */

/* (e) Model Diagnostics */
title "Residual Analysis";
proc univariate data=anova_results normal;
    var residuals;
    qqplot residuals / normal;
run;

title "Residuals vs. Duration";
proc sgplot data=anova_results;
    scatter x=Duration y=residuals;
    refline 0 / axis=y;
run;

title "Residuals vs. Weight";
proc sgplot data=anova_results;
    scatter x=Weight y=residuals;
    refline 0 / axis=y;
run;
/* Interpretation: Look for normality in QQ plot and constant variance in residual scatterplots. */

/* (f) Tukey's Pairwise Comparisons */
title "Tukey's Test for Duration and Weight Effects";
proc glm data=kidney_trans;
    class Duration;
    model Days1 = Duration;
    means Duration / tukey alpha=0.05;
run;

proc glm data=kidney_trans;
    class Weight;
    model Days1 = Weight;
    means Weight / tukey alpha=0.05;
run;
/* Interpretation: Significant differences indicate which groups differ significantly in hospitalization duration. */

/* (f) Line Plots for Duration and Weight */
title "Line Plot for Duration Effect";
proc sgplot data=kidney_trans;
    series x=Duration y=Days1 / markers;
run;

title "Line Plot for Weight Effect";
proc sgplot data=kidney_trans;
    series x=Weight y=Days1 / markers;
run;
/* Interpretation: These plots visualize differences in hospitalization days across groups. */
