/* Step 1: Import the Dataset */
data lipids;
    input reduction age dietfat;
    datalines;
0.73 1 1
0.67 1 2
0.15 1 3
0.86 2 1
0.75 2 2
0.21 2 3
0.94 3 1
0.81 3 2
0.26 3 3
1.40 4 1
1.32 4 2
0.75 4 3
1.62 5 1
1.41 5 2
0.78 5 3
;
run;

proc print data=lipids; /* Print the dataset */
    title "Dataset: Reduction in Lipids by Age and DietFat";
run;

/* Step 2: Interaction Plot */
proc glm data=lipids plots=all;
    class age dietfat; /* Define categorical variables */
    model reduction = age|dietfat; /* Interaction model for reduction in lipids */
    title "Interaction Plot: Reduction = Age | DietFat";
run;

/* Step 3: Tukey’s One-Degree-of-Freedom Test for Additivity */
proc glm data=lipids;
    class age dietfat;
    model reduction = age dietfat age*dietfat / ss3; /* Model with interaction term */
    output out=residuals r=residual p=predicted; /* Save residuals and predicted values */
    contrast 'Tukey Test for Additivity' age*dietfat -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 / e; 
    title "Tukey's One-Degree-of-Freedom Test for Additivity";
run;

proc print data=residuals; /* Print residuals and predicted values */
    title "Residuals and Predicted Values";
run;

/* Step 4: Fit the Additive Model */
proc glm data=lipids;
    class age dietfat;
    model reduction = age dietfat / ss3; /* Additive model without interaction term */
    title "Fit Additive Model: Reduction = Age + DietFat";
run;

/* Step 5: Pairwise Differences Using Tukey’s Procedure */
proc glm data=lipids;
    class dietfat; /* Define dietfat as categorical variable */
    model reduction = dietfat; /* Model to test differences among diets */
    means dietfat / tukey lines alpha=0.05; /* Tukey's test with FER of 5% and lines plot */
    title "Pairwise Differences Among Diets Using Tukey's Procedure";
run;

/* Step 6: Diagnostic Plots */
proc glm data=lipids plots=diagnostics(unpack);
    class age dietfat;
    model reduction = age dietfat / ss3; /* Additive model for diagnostics */
    output out=residuals r=residual p=predicted student=tresidual; /* Save residuals and studentized residuals */
    title "Diagnostic Plots";
run;

/* Step 7: Residual Plots */
proc sgplot data=residuals;
    scatter x=age y=residual; /* Residuals vs Age (blocks) */
    title "Residuals vs Age (Blocks)";
run;

proc sgplot data=residuals;
    scatter x=dietfat y=residual; /* Residuals vs DietFat (treatments) */
    title "Residuals vs DietFat (Treatments)";
run;
