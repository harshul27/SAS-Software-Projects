/* Step 1: Create the dataset */
data dues_data;
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

/* Step (a): Fit the logistic regression model */
proc logistic data=dues_data descending;
   model Y = X; /* Logistic regression with X as predictor */
   output out=predicted p=prob lower=lcl upper=ucl; /* Save predicted probabilities and confidence limits */
run;

/* Step (b): Filter for X = $40 to extract predicted probability and confidence interval */
data predict_40;
   set predicted;
   if X = 40; /* Select only observations where X = $40 */
run;

/* Step (c): Display the predicted probability and confidence interval for X = $40 */
proc print data=predict_40 noobs;
   var X prob lcl ucl; /* Display predicted probability and its confidence limits */
run;
