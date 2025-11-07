/* Create the dataset */
data dues;
    input Y X;
    datalines;
    0 30
    1 30
    0 30
    0 31
    0 32
    0 33
    1 34
    0 35
    0 35
    1 35
    1 36
    0 37
    0 38
    1 39
    0 40
    1 40
    1 40
    0 41
    1 42
    1 43
    1 44
    0 45
    1 45
    1 45
    0 46
    1 47
    1 48
    0 49
    1 50
    1 50
;
run;

/* Logistic regression model */
proc logistic data=dues descending;
    model Y = X / clodds=pl; /* Compute confidence intervals for exp(b1) */
run;

/* Wald Test */
proc logistic data=dues descending;
    model Y = X / waldcl; /* Wald confidence limits */
run;

/* Likelihood Ratio Test */
proc logistic data=dues descending;
    model Y = X;
run;

proc logistic data=dues descending;
    model Y =; /* Reduced model with no predictors */
run;
