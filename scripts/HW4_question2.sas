/* Step 1: Import the Dataset */
data lipids;
    input reduction age dietfat;
    datalines;
   0.73      1      1
   0.67      1      2
   0.15      1      3
   0.86      2      1
   0.75      2      2
   0.21      2      3
   0.94      3      1
   0.81      3      2
   0.26      3      3
   1.40      4      1
   1.32      4      2
   0.75      4      3
   1.62      5      1
   1.41      5      2
   0.78      5      3
;
run;

proc print data=lipids; 
    title "Dataset: Reduction in Lipids by Age and DietFat";
run;

/* Step 2: Interaction Plot */
proc glm data=lipids plots=all;
    class age dietfat; 
    model reduction = age|dietfat / ss3; /* Include interaction term */
    title "Interaction Plot: Reduction = Age | DietFat";
run;

/* Step 3: Tukey’s One-Degree-of-Freedom Test for Additivity */
proc glm data=lipids;
    class age dietfat;
    model reduction = age dietfat / ss3; /* Additive model for degrees of freedom */
    output out=residuals r=residual p=predicted; 
    /* Corrected Contrast for Tukey's Test - Testing Linearity */
    contrast 'Tukey Test for Additivity' age 1 -2 1 0 0,
                                           dietfat 1 -2 1 / e;
    title "Tukey's One-Degree-of-Freedom Test for Additivity";
run;

proc print data=residuals; 
    title "Residuals and Predicted Values";
run;

/* Step 4: Fit the Additive Model */
proc glm data=lipids;
    class age dietfat;
    model reduction = age dietfat / ss3; /* Additive model */
    title "Fit Additive Model: Reduction = Age + DietFat";
run;

/* Step 5: Pairwise Differences Using Tukey’s Procedure */
proc glm data=lipids;
    class dietfat; 
    model reduction = dietfat; 
    means dietfat / tukey lines alpha=0.05; 
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
    scatter x=age y=residual; 
    title "Residuals vs Age (Blocks)";
run;

proc sgplot data=residuals;
    scatter x=dietfat y=residual; 
    title "Residuals vs DietFat (Treatments)";
run;
