/* Step 0: Load the Imitation Pearls dataset */
data pearls;
input y a b rep;
datalines;
72.0 1 1 1
74.6 1 1 2
67.4 1 1 3
72.8 1 1 4
72.1 1 2 1
76.9 1 2 2
74.8 1 2 3
73.3 1 2 4
75.2 1 3 1
73.8 1 3 2
75.7 1 3 3
77.8 1 3 4
70.4 1 4 1
68.1 1 4 2
72.4 1 4 3
72.4 1 4 4
76.9 2 1 1
78.1 2 1 2
72.9 2 1 3
74.2 2 1 4
80.3 2 2 1
79.3 2 2 2
76.6 2 2 3
77.2 2 2 4
80.2 2 3 1
76.6 2 3 2
77.3 2 3 3
79.9 2 3 4
74.3 2 4 1
77.6 2 4 2
74.4 2 4 3
72.9 2 4 4
76.3 3 1 1
74.1 3 1 2
77.1 3 1 3
75.0 3 1 4
80.9 3 2 1
73.7 3 2 2
78.6 3 2 3
80.2 3 2 4
79.2 3 3 1
78.0 3 3 2
77.6 3 3 3
81.2 3 3 4
71.6 3 4 1
77.7 3 4 2
75.2 3 4 3
74.4 3 4 4
;
run;

/* Step 1: Interaction Plot */
proc means data=pearls noprint;
   class a b;
   var y;
   output out=means mean=mean;
run;

proc sgplot data=means;
   where _TYPE_ = 3;
   series x=b y=mean / group=a markers;
   xaxis label="Factor B";
   yaxis label="Mean Response";
   title "Interaction Plot for A and B";
run;

/* Step 2a: GLM model with interaction */
proc glm data=pearls;
   class a b;
   model y = a b a*b;
   title "GLM: Interaction Model (Fixed Effects)";
run;
quit;

/* Step 2b: GLIMMIX with RSPL (Unrestricted) */
proc glimmix data=pearls method=rspl;
   class a b;
   model y = a / solution;
   random b a*b;
   title "GLIMMIX: RSPL Estimation (Unrestricted Model)";
run;

/* Step 2c: GLIMMIX with MSPL (Unrestricted) */
proc glimmix data=pearls method=mspl;
   class a b;
   model y = a / solution;
   random b a*b;
   title "GLIMMIX: MSPL Estimation (Unrestricted Model)";
run;

/* Step 3a: GLM - Main effects only (no interaction) */
proc glm data=pearls;
   class a b;
   model y = a b;
   title "GLM: Main Effects (A and B)";
run;
quit;

/* Step 3b: GLIMMIX - A as fixed, B as random */
proc glimmix data=pearls method=rspl;
   class a b;
   model y = a / solution;
   random b;
   title "GLIMMIX: Fixed A, Random B (Variance Component for B)";
run;

/* Step 4: LSMeans for A in GLIMMIX with Tukey adjustment */
proc glimmix data=pearls method=rspl;
   class a b;
   model y = a / solution;
   random b a*b;
   lsmeans a / diff cl adjust=tukey;
   title "GLIMMIX: Multiple Comparisons of Factor A Means";
run;

/* Step 5: MSPL estimates for fixed A and random B + A*B */
proc glimmix data=pearls method=mspl;
   class a b;
   model y = a / solution;
   random b a*b;
   title "GLIMMIX: MSPL Estimation - Fixed A and Random B, AB";
run;

/* Step 6a: Test if variance component for B is zero */
proc glimmix data=pearls method=mspl;
   class a b;
   model y = a / solution;
   random b a*b;
   covtest 'Test for Variance Component of B' 0;
   title "GLIMMIX: Testing if Variance Component for B is Zero";
run;

/* Step 6b: Confidence Interval for Variance Component of B */
proc glimmix data=pearls method=mspl;
   class a b;
   model y = a;
   random b / cl;
   random a*b;
   title "GLIMMIX: Confidence Interval for Variance of B";
run;

/* Step 6c: Compare A Means Again */
proc glimmix data=pearls method=mspl;
   class a b;
   model y = a / solution;
   random b a*b;
   lsmeans a / diff cl adjust=tukey;
   title "GLIMMIX: A Mean Comparison (Post Variance Component Check)";
run;
