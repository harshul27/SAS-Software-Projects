/* Import the dataset */
proc import datafile="/home/u63986830/Cardio.csv" out=cardio dbms=csv replace;
run;

/* 1. Fit full model and find best model using adjusted R2 */
proc reg data=cardio;
    model uric = dia hdl choles trig alco / selection=adjrsq best=5;
    title "Best Models Based on Adjusted R-Square";
run;
quit;

/* 2. Check assumptions, detect outliers and influential points, check collinearity */
proc reg data=cardio plots=(diagnostics residuals);
    model uric = dia hdl choles trig alco / vif collin influence;
    output out=diagnostics r=residuals p=predicted cookd=cook;
    title "Model Diagnostics and Assumption Checks";
run;
quit;

proc univariate data=diagnostics normal plot;
    var residuals;
    title "Normality Check of Residuals";
run;

/* 3. Weighted Least Squares Regression */
proc reg data=cardio;
    model uric = dia hdl choles trig alco;
    output out=wls_data r=residuals p=predicted;
run;
quit;

data wls_data;
    set wls_data;
    weight = 1 / (residuals**2);
run;

proc reg data=wls_data;
    model uric = dia hdl choles trig alco;
    weight weight;
    title "Weighted Least Squares Regression";
run;
quit;

/* 4. Iteratively Reweighted Least Squares (IRLS) */
%macro irls(iterations);
    %do i = 1 %to &iterations;
        /* IRLS code here */
        proc reg data=irls_data outest=estimates&i;
            model uric = dia hdl choles trig alco;
            weight bisquare_weight;
            title "IRLS Iteration &i Results";
        run;
    %end;
%mend;

%irls(3);

/* 5. Bootstrap for simple linear regression */
proc reg data=cardio;
    model uric = trig;
    title "Simple Linear Regression of Uric Acid on Triglycerides";
run;
quit;

%macro bootstrap(method, resamples);
    /* Bootstrap macro code here (as in the original) */
    /* ... */
    proc univariate data=bootstrap_results;
        var trig;
        histogram trig;
        qqplot trig;
        title "Bootstrap Distribution of β1 (&method method)";
    run;

    proc means data=bootstrap_results n mean std;
        var trig;
        output out=stats mean=mean std=se;
        title "Bootstrap Estimates (&method method)";
    run;
%mend;

%bootstrap(fixedx, 1000);
%bootstrap(xy, 1000);