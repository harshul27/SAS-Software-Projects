/* Step 1: Input the data */
data car_purchase;
   input Y X1 X2; /* Y = Purchase (1 = Yes, 0 = No), X1 = Annual Income (in $1000s), X2 = Age of Oldest Car (in years) */
   datalines;
0 32 3
0 45 2
1 60 2
0 53 1
0 25 4
1 68 1
1 82 2
1 38 5
0 67 2
1 92 2
1 72 3
0 21 5
0 26 3
1 40 4
0 33 3
0 45 1
1 61 2
0 16 3
1 18 4
0 22 6
0 27 3
1 35 3
1 40 3
0 10 4
0 24 3
1 15 4
0 23 3
0 19 5
1 22 2
0 61 2
0 21 3
1 32 5
0 17 1
;
run;

/* Step 2: Fit the logistic regression model */
proc logistic data=car_purchase descending;
   /* The descending option ensures that Y=1 (purchase) is modeled as the event of interest */
   model Y = X1 X2 / expb; /* Include both predictors: annual income (X1) and age of car (X2) */
   title "Logistic Regression Model for Car Purchase";
run;


/* Step B: Calculate and interpret odds ratios */
title "Odds Ratios for Predictors";
proc logistic data=car_purchase descending;
   model Y = X1 X2 / expb; /* expb outputs exponentiated coefficients (odds ratios) */
run;


/* Step C: Predict probability for a family with X1=50 (income $50,000) and X2=3 (oldest car age =3 years) */
data new_family;
   input X1 X2; /* Input new data for prediction */
   datalines;
50 3 /* Family with $50,000 income and a car age of three years */
;
run;

proc logistic data=car_purchase descending;
   model Y = X1 X2; /* Use the same model as before */
   score data=new_family out=predicted; /* Predict probabilities for new observations */
run;

proc print data=predicted;
   title "Predicted Probability for Family with Income=$50k and Car Age=3 Years";
run;


