/* Import the dataset */
filename health '/home/u63986830/health.csv';

data health;
    infile health dsd firstobs=2;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Final model */
proc reg data=health outest=estimates;
    model Death_Rate = Doctor_Availability Population_Density;
    output out=diagnostics p=pred r=resid;
    title 'Final Model: Multiple Linear Regression';
run;

/* Calculate correlations */
proc corr data=health nosimple;
    var Death_Rate Doctor_Availability Population_Density;
    title 'Correlations';
run;

/* Calculate R-square for individual predictors and full model */
proc reg data=health;
    model Death_Rate = Doctor_Availability Population_Density / vif;
    ods output FitStatistics=model_full;
    title 'Full Model';
run;

/* Calculate partial correlations and determination coefficients */
proc reg data=health;
    model Death_Rate = Doctor_Availability Population_Density;
    output out=residuals r=resid_full;
run;

proc reg data=health;
    model Death_Rate = Population_Density;
    output out=residuals_doc r=resid_doc;
run;

proc reg data=health;
    model Death_Rate = Doctor_Availability;
    output out=residuals_pop r=resid_pop;
run;

data partial_stats;
    if _N_ = 1 then do;
        set model_full(where=(Label1='R-Square'));
        R2_full = input(cValue1, best12.);
        R = sqrt(R2_full);
    end;
    set residuals;
    set residuals_doc;
    set residuals_pop;
    partial_corr_doctor = -corr(resid_full, resid_doc);
    partial_corr_density = -corr(resid_full, resid_pop);
    partial_r2_doctor = partial_corr_doctor**2;
    partial_r2_density = partial_corr_density**2;
run;

proc print data=partial_stats;
    var R2_full R partial_corr_doctor partial_corr_density partial_r2_doctor partial_r2_density;
    title 'Coefficients of Determination, Correlation, and Partial Determination';
run;