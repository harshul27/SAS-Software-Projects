/* Import the CSV file */
data health;
    infile '/home/u63986830/health.csv' dsd firstobs=1;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Fit multiple linear regression model */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density / vif;
    output out=residuals r=resid p=predicted;
    plot residual.*predicted.;
    plot npp.*resid;
run;

/* Calculate absolute residuals */
data abs_residuals;
    set residuals;
    abs_resid = abs(resid);
run;

/* Plot absolute residuals */
proc sgplot data=abs_residuals;
    scatter x=predicted y=abs_resid;
    xaxis label="Predicted Values";
    yaxis label="Absolute Residuals";
    title "Plot of Absolute Residuals vs Predicted Values";
run;

/* Test for normality of residuals */
proc univariate data=residuals normal;
    var resid;
    qqplot resid / normal(mu=est sigma=est);
    title "Normality Test for Residuals";
run;

/* Test for heteroscedasticity */
proc model data=residuals;
    parms a0 a1;
    abs_resid = a0 + a1*predicted;
    fit abs_resid / white;
run;

/* Test for autocorrelation */
proc autoreg data=residuals;
    model resid = / dw=1;
run;

/* Test for multicollinearity */
proc corr data=health;
    var Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;