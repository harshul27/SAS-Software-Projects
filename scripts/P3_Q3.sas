/* Import the dataset */
filename health '/home/u63986830/health.csv';

data health;
    infile health dsd firstobs=1;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Full model with all predictors */
proc reg data=health plots(only)=(residuals diagnostics);
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density / vif;
    output out=residuals r=resid p=pred;
    title 'Full Model: Multiple Linear Regression';
run;

/* Calculate absolute residuals */
data residuals;
    set residuals;
    abs_resid = abs(resid);
run;

/* Plot of absolute residuals */
proc sgplot data=residuals;
    scatter x=pred y=abs_resid;
    title 'Plot of Absolute Residuals vs Predicted Values';
run;

/* Normality test for residuals */
proc univariate data=residuals normal;
    var resid;
    title 'Normality Test for Residuals';
run;

/* Stepwise regression using Type III SS */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density 
        / selection=stepwise slentry=0.05 slstay=0.05;
    title 'Stepwise Regression using Type III SS';
run;

/* Reduced model based on stepwise results */
proc reg data=health;
    model Death_Rate = Doctor_Availability Population_Density;
    title 'Reduced Model';
run;

/* Compare full and reduced models using extra sum of squares */
proc glm data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density;
    contrast 'Full vs Reduced' Hospital_Availability 1, Capital_income 1;
    title 'Comparison of Full and Reduced Models';
run;