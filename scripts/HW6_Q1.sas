/* Create dataset */
data marketing;
    input Y Fee WorkScope Supervisory Replicate;
datalines;
  124.3      1      1      1      1
  120.6      1      1      1      2
  120.7      1      1      1      3
  122.6      1      1      1      4
  112.7      1      1      2      1
  110.2      1      1      2      2
  113.5      1      1      2      3
  108.6      1      1      2      4
  115.1      1      2      1      1
  119.9      1      2      1      2
  115.4      1      2      1      3
  117.3      1      2      1      4
   88.2      1      2      2      1
   96.0      1      2      2      2
   96.4      1      2      2      3
   90.1      1      2      2      4
  119.3      2      1      1      1
  118.9      2      1      1      2
  125.3      2      1      1      3
  121.4      2      1      1      4
  113.6      2      1      2      1
  109.1      2      1      2      2
  108.9      2      1      2      3
  112.3      2      1      2      4
  117.2      2      2      1      1
  114.4      2      2      1      2
  113.4      2      2      1      3
  120.0      2      2      1      4
   92.7      2      2      2      1
   91.1      2      2      2      2
   90.7      2      2      2      3
   87.9      2      2      2      4
   90.9      3      1      1      1
   95.3      3      1      1      2
   88.8      3      1      1      3
   92.0      3      1      1      4
   78.6      3      1      2      1
   80.6      3      1      2      2
   83.5      3      1      2      3
   77.1      3      1      2      4
   89.9      3      2      1      1
   83.0      3      2      1      2
   86.5      3      2      1      3
   82.7      3      2      1      4
   58.6      3      2      2      1
   63.5      3      2      2      2
   59.8      3      2      2      3
   62.3      3      2      2      4
;
run;

/* Part (1): Interaction plots */
/* Obtain conditional and averaged interaction plots to examine two-factor interactions */
ods graphics on; /* Enable graphics for interaction plots */
proc glm data=marketing plots=(intplot);
    class Fee WorkScope Supervisory;
    model Y = Fee|WorkScope|Supervisory; /* Full three-way interaction model */
    store fullmodel; /* Save the full model for later use */
run;
ods graphics off;

/* Part (2): Model reduction */
/* Check significance of three-way and two-way interactions using Type III tests */
proc glm data=marketing;
    class Fee WorkScope Supervisory;
    model Y = Fee|WorkScope|Supervisory / ss3; /* Type III tests for significance */
run;

/* If three-way interaction is not significant (p > .05), fit reduced model */
proc glm data=marketing;
    class Fee WorkScope Supervisory;
    model Y = Fee WorkScope Supervisory 
             Fee*WorkScope Fee*Supervisory / ss3; /* Reduced model with two-way interactions */
    store reducedmodel; /* Save reduced model for diagnostics */
run;

/* Part (3): Diagnostics */
/* Obtain diagnostic panel and residual plots for the reduced model */
proc glm data=marketing plots=(diagnostics);
    class Fee WorkScope Supervisory;
    model Y = Fee WorkScope Supervisory 
             Fee*WorkScope Fee*Supervisory / solution; /* Include solution for parameter estimates */
    output out=diag r=residual; /* Save residuals for custom plotting */
run;

/* Residual plots vs each factor */
proc sgplot data=diag;
    scatter x=Fee y=residual / markerattrs=(color=blue);
    refline 0 / axis=y lineattrs=(pattern=solid color=red);
    title "Residuals vs Fee Schedule";
run;

proc sgplot data=diag;
    scatter x=WorkScope y=residual / markerattrs=(color=green);
    refline 0 / axis=y lineattrs=(pattern=solid color=red);
    title "Residuals vs Work Scope";
run;

proc sgplot data=diag;
    scatter x=Supervisory y=residual / markerattrs=(color=purple);
    refline 0 / axis=y lineattrs=(pattern=solid color=red);
    title "Residuals vs Supervisory Control";
run;

/* Part (4): Multiple comparisons */
/* Examine pairwise differences in fee schedule using Tukey's method */
/* Examine differences in work scope across supervisory levels using Bonferroni correction */
proc glm data=marketing;
    class Fee WorkScope Supervisory;
    model Y = Fee WorkScope Supervisory 
             Fee*WorkScope Fee*Supervisory WorkScope*Supervisory; /* Include interaction for comparisons */
    lsmeans Fee / adjust=tukey pdiff alpha=0.05; /* Tukey adjustment for pairwise comparisons of fee schedule */
    lsmeans WorkScope*Supervisory / adjust=bon pdiff alpha=0.05; /* Bonferroni correction for work scope comparisons */
run;
