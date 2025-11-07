/* example data */
data Fitness;
   input Age Weight Oxygen@@;
   datalines;
44 89.47  44.609     40 75.07  45.313 
44 85.84  54.297     42 68.15  59.571  
38 89.02  49.874     47 77.45  44.811
40 75.98  45.681     43 81.19  49.091 
44 81.42  39.442     38 81.87  60.055 
44 73.03  50.541     45 87.66  37.388
;

proc reg data=Fitness outest=RegOut;
   OxyHat: model Oxygen=Age Weight / i; *use /I option to get the inverse of X'X;
   title 'Regression Scoring Example';
run;

 /* Data for prediction, fix one of the variables to be at it's mean value */                                           
data Fitness2;
   input Age Weight @@; *fix weight to be 70;
   datalines;
44 70     40 70  
44 70     42 70  
38 70     47 70 
40 70     43 70 
44 70     38 70 
44 70     45 70 
;

/* predict yhat, and save the result as NewPred, yhat are saved in the column OxyHat */
proc score data=Fitness2 score=RegOut out=NewPred type = parms
           nostd predict;
   var Age Weight;
run;


/* Calculate CI for the estimation */
proc iml;
   /* suppose this is x'x inverse, check your model for the actual values*/
   A = {4 1 2, 
        1 5 3, 
        2 3 6}; /* 3x3 matrix */

   /* Read the estimation dataset and create the design matrix*/
   use Fitness2; 
   read all var {Age Weight} into X; /* Read variables into matrix X */
   
   /* Read y hat of the estimation dataset */
   use NewPred;
   read all var {OxyHat} into yhat;

   /* Add a column of 1's to represent x1 (intercept term) */
   n = nrow(X); /* Number of observations */
   X = j(n, 1, 1) || X; /* Concatenate a column of 1's for the intercept term */

   /* Initialize a result vector to store vAv' for each row */
   results = j(n, 1, .);  /* Vector to store results */

   /* Loop over each row (vector) and calculate vAv' */
   do i = 1 to n;
      v = X[i,]; 
      results[i] = v * A * v`;  
   end;

   /* Calculate the square root of each result, this is for CI, for PI you need to do sqrt(1+results)*/
   sqrt_results = sqrt(results);

   /* Multiply sqrt_results by the rest value in the equation, different values for differnet intervals,
   for easmple, CI should be t score times S, I used a radom value 2*/
   error = sqrt_results * 2;
   
   lowerCI = yhat - error;
   
   upperCI = yhat + error;
   
   /* Concatenate lowerCI and upperCI into one matrix */
   ci_matrix = lowerCI || upperCI;  /* Concatenate them side by side */

   /* Save the results into a new dataset with lowerCI and upperCI */
   create ci_results_data from ci_matrix[colname={"lowerCI" "upperCI"}]; /* Create the dataset */
   append from ci_matrix; /* Append the concatenated matrix to the dataset */

quit;

/* merge the predictors and estiamted CI for making the plot*/
Data CI_results;
SET Fitness2;
merge ci_results_data;
run;

proc print data = CI_results;
run;
