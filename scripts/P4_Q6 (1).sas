/* Import the dataset */
proc import datafile="/home/u63986830/breast_tumor.csv" 
    out=tumor_data 
    dbms=csv 
    replace;
run;

/* Univariate logistic regression for each predictor */
%macro univariate_logistic(var);
    proc logistic data=tumor_data;
        model Class(event='0') = &var;
        ods output ParameterEstimates=pe_&var;
    run;
%mend;

%univariate_logistic(clump_thickness);
%univariate_logistic(size_uniformity);
%univariate_logistic(shape_uniformity);
%univariate_logistic(marginal_adhesion);
%univariate_logistic(epithelial_size);
%univariate_logistic(bare_nucleoli);
%univariate_logistic(bland_chromatin);
%univariate_logistic(normal_nucleoli);
%univariate_logistic(mitoses);

/* Select significant predictors (p < 0.1) */
data significant_vars;
    set pe_: ;
    where Variable ne 'Intercept' and ProbChiSq < 0.1;
    keep Variable;
run;

proc sql noprint;
    select Variable into :var_list separated by ' '
    from (
        select distinct Variable
        from pe_:
        where Variable ne 'Intercept' and ProbChiSq < 0.1
    );
quit;
/* Multiple logistic regression with selected predictors */
proc logistic data=tumor_data;
    model Class(event='0') = &var_list / selection=none;
    ods output ParameterEstimates=pe_multi;
run;

/* Stepwise logistic regression for comparison */
proc logistic data=tumor_data;
    model Class(event='0') = clump_thickness size_uniformity shape_uniformity
                             marginal_adhesion epithelial_size bare_nucleoli
                             bland_chromatin normal_nucleoli mitoses / selection=stepwise;
    ods output ParameterEstimates=pe_stepwise;
run;

/* Print results */
proc print data=pe_multi;
    title "Final Model Coefficients";
run;

proc print data=pe_stepwise;
    title "Stepwise Model Coefficients";
run;