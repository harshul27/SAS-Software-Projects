/* Q14.19(b): Wald Test for Dropping X2 (Age of Oldest Car) */

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

/* Step A: Fit the full model with both predictors (X1 and X2) */
proc logistic data=car_purchase descending;
   model Y = X1 X2 / expb; /* Full model with both predictors */
   ods output ParameterEstimates=FullModelEstimates; /* Save parameter estimates for the full model */
   title "Full Model with Both Predictors (X1 and X2)";
run;

/* Step B: Fit the reduced model with only X1 */
proc logistic data=car_purchase descending;
   model Y = X1 / expb; /* Reduced model without X2 */
   ods output ParameterEstimates=ReducedModelEstimates; /* Save parameter estimates for the reduced model */
   title "Reduced Model with Only Predictor X1";
run;

/* Step C: Perform Wald Test */
/* Combine results from full and reduced models to calculate test statistic */
data WaldTest;
   set FullModelEstimates(where=(Variable="X2")); /* Extract estimate for X2 from full model */
   chisq = (Estimate / StdErr)**2; /* Wald Chi-Square Test Statistic: (Estimate / StdErr)^2 */
   df = DF; /* Degrees of freedom for X2 */
   p_value = probchi(chisq, df); /* Calculate p-value from Chi-Square distribution */
run;

proc print data=WaldTest noobs label;
   label chisq="Wald Chi-Square"
         df="Degrees of Freedom"
         p_value="P-Value";
   title "Wald Test Results for Dropping X2";
run;


