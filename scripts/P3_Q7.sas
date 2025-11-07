/* Import the dataset */
filename health '/home/u63986830/health.csv';

data health;
    infile health dsd firstobs=2;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Calculate mean values for predictors */
proc means data=health noprint;
    var Doctor_Availability Population_Density;
    output out=means mean=mean_Doctor mean_Population;
run;

/* Create dataset for Doctor_Availability prediction range */
data Doctor_range;
    set means;
    do Doctor_Availability = 60 to 240 by 5;
        Population_Density = mean_Population;
        output;
    end;
run;

/* Create dataset for Population_Density prediction range */
data Population_range;
    set means;
    do Population_Density = 35 to 300 by 5;
        Doctor_Availability = mean_Doctor;
        output;
    end;
run;

/* Fit the model */
proc reg data=health;
    model Death_Rate = Doctor_Availability Population_Density;
    output out=diagnostics p=pred r=resid;
    store RegModel;
run;
quit;

/* Calculate intervals for Doctor_Availability */
proc plm restore=RegModel;
    score data=Doctor_range out=Doctor_intervals 
          predicted=yhat lclm=ci_lower uclm=ci_upper
          lcl=pi_lower ucl=pi_upper;
run;

/* Calculate intervals for Population_Density */
proc plm restore=RegModel;
    score data=Population_range out=Population_intervals 
          predicted=yhat lclm=ci_lower uclm=ci_upper
          lcl=pi_lower ucl=pi_upper;
run;

/* Calculate simultaneous confidence bands for Doctor_Availability */
data Doctor_intervals;
    set Doctor_intervals;
    alpha = 0.05;
    p = 3; /* Number of parameters in the model */
    n = 54; /* Number of observations in the original dataset */
    F_value = finv(1-alpha, p, n-p);
    t_value = tinv(1-alpha/2, n-p);
    se_mean = (ci_upper - ci_lower) / (2 * t_value);
    sim_lower = yhat - sqrt(p * F_value) * se_mean;
    sim_upper = yhat + sqrt(p * F_value) * se_mean;
run;

/* Calculate simultaneous confidence bands for Population_Density */
data Population_intervals;
    set Population_intervals;
    alpha = 0.05;
    p = 3; /* Number of parameters in the model */
    n = 54; /* Number of observations in the original dataset */
    F_value = finv(1-alpha, p, n-p);
    t_value = tinv(1-alpha/2, n-p);
    se_mean = (ci_upper - ci_lower) / (2 * t_value);
    sim_lower = yhat - sqrt(p * F_value) * se_mean;
    sim_upper = yhat + sqrt(p * F_value) * se_mean;
run;

/* Remove any observations with missing values */
data Doctor_intervals;
    set Doctor_intervals;
    if not(missing(sim_upper) or missing(pi_upper) or missing(ci_upper));
run;

data Population_intervals;
    set Population_intervals;
    if not(missing(sim_upper) or missing(pi_upper) or missing(ci_upper));
run;

/* Plot intervals for Doctor_Availability */
proc sgplot data=Doctor_intervals;
    band x=Doctor_Availability lower=sim_lower upper=sim_upper / fillattrs=(color=lightblue transparency=0.5) legendlabel="Simultaneous CB" name="sim";
    band x=Doctor_Availability lower=pi_lower upper=pi_upper / fillattrs=(color=lightgreen transparency=0.5) legendlabel="Prediction Interval" name="pi";
    band x=Doctor_Availability lower=ci_lower upper=ci_upper / fillattrs=(color=lightyellow transparency=0.5) legendlabel="Confidence Interval" name="ci";
    series x=Doctor_Availability y=yhat / lineattrs=(color=black thickness=2) legendlabel="Fitted Line" name="fit";
    xaxis label="Doctor Availability";
    yaxis label="Death Rate";
    keylegend "sim" "pi" "ci" "fit" / location=outside position=bottom across=2;
    title "Intervals for Doctor Availability (Population Density fixed at mean)";
run;

/* Plot intervals for Population_Density */
proc sgplot data=Population_intervals;
    band x=Population_Density lower=sim_lower upper=sim_upper / fillattrs=(color=lightblue transparency=0.5) legendlabel="Simultaneous CB" name="sim";
    band x=Population_Density lower=pi_lower upper=pi_upper / fillattrs=(color=lightgreen transparency=0.5) legendlabel="Prediction Interval" name="pi";
    band x=Population_Density lower=ci_lower upper=ci_upper / fillattrs=(color=lightyellow transparency=0.5) legendlabel="Confidence Interval" name="ci";
    series x=Population_Density y=yhat / lineattrs=(color=black thickness=2) legendlabel="Fitted Line" name="fit";
    xaxis label="Population Density";
    yaxis label="Death Rate";
    keylegend "sim" "pi" "ci" "fit" / location=outside position=bottom across=2;
    title "Intervals for Population Density (Doctor Availability fixed at mean)";
run;