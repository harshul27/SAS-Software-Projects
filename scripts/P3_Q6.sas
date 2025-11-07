/* Import the dataset */
filename health '/home/u63986830/health.csv';

data health;
    infile health dsd firstobs=2;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Full model */
proc reg data=health;
    model Death_Rate = Doctor_Availability Population_Density;
    output out=full_residuals r=full_resid;
    title 'Full Model';
run;

/* Model with Doctor_Availability only */
proc reg data=health;
    model Death_Rate = Doctor_Availability;
    output out=doc_residuals r=doc_resid;
    title 'Model with Doctor_Availability only';
run;

/* Model with Population_Density only */
proc reg data=health;
    model Death_Rate = Population_Density;
    output out=pop_residuals r=pop_resid;
    title 'Model with Population_Density only';
run;

/* Calculate partial determination coefficients */
data partial_r2;
    merge full_residuals doc_residuals pop_residuals;
    partial_r2_doctor = 1 - sum(full_resid**2) / sum(pop_resid**2);
    partial_r2_density = 1 - sum(full_resid**2) / sum(doc_resid**2);
run;

proc print data=partial_r2 (obs=1);
    var partial_r2_doctor partial_r2_density;
    title 'Partial Determination Coefficients';
run;

/* Alternative interpretation of largest partial determination coefficient */
proc reg data=health;
    model Population_Density = Doctor_Availability;
    title 'Alternative Interpretation: Population_Density vs Doctor_Availability';
run;

/* Alternative interpretation of coefficient of multiple determination */
proc reg data=health;
    model Death_Rate = Doctor_Availability Population_Density;
    output out=pred_residuals p=predicted;
    title 'Full Model for Alternative Interpretation';
run;

proc corr data=pred_residuals;
    var Death_Rate predicted;
    title 'Correlation between Observed and Predicted Death_Rate';
run;