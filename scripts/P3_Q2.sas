/* Import the CSV file */
data health;
    infile '/home/u63986830/health.csv' dsd firstobs=2;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Log transformation of variables */
data health_transformed;
    set health;
    log_Death_Rate = log(Death_Rate);
    log_Doctor_Availability = log(Doctor_Availability);
    log_Hospital_Availability = log(Hospital_Availability);
    log_Capital_income = log(Capital_income);
    log_Population_Density = log(Population_Density);
run;

/* Fit transformed multiple linear regression model and perform diagnostics */
proc reg data=health_transformed plots(only)=(diagnostics residuals);
    model log_Death_Rate = log_Doctor_Availability log_Hospital_Availability 
                           log_Capital_income log_Population_Density / vif spec;
    output out=residuals r=resid p=predicted;
run;
quit;

/* Calculate absolute residuals */
data residuals_with_abs;
    set residuals;
    abs_resid = abs(resid);
run;

/* Plot absolute residuals */
proc sgplot data=residuals_with_abs;
    scatter x=predicted y=abs_resid;
    xaxis label="Predicted Values (Log-transformed)";
    yaxis label="Absolute Residuals";
    title "Plot of Absolute Residuals vs Predicted Values (Transformed Model)";
run;

/* Test for normality of residuals */
proc univariate data=residuals_with_abs normal;
    var resid;
    qqplot resid / normal(mu=est sigma=est);
    title "Normality Test for Residuals (Transformed Model)";
run;

/* Test for autocorrelation */
proc autoreg data=residuals_with_abs;
    model resid = / dw=1;
run;

/* Test for multicollinearity */
proc corr data=health_transformed;
    var log_Doctor_Availability log_Hospital_Availability log_Capital_income log_Population_Density;
run;