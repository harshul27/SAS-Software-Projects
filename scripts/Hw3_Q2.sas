/* Step 1: Creating the dataset */
data hayfever;
    input Hours Relief Ingredient1 Ingredient2;
    datalines;
    2.4 1 1 1
    2.7 1 1 2
    2.3 1 1 3
    2.5 1 1 4
    4.6 1 2 1
    4.2 1 2 2
    4.9 1 2 3
    4.7 1 2 4
    4.8 1 3 1
    4.5 1 3 2
    4.4 1 3 3
    4.6 1 3 4
    5.8 2 1 1
    5.2 2 1 2
    5.5 2 1 3
    5.3 2 1 4
    8.9 2 2 1
    9.1 2 2 2
    8.7 2 2 3
    9.0 2 2 4
    9.1 2 3 1
    9.3 2 3 2
    8.7 2 3 3
    9.4 2 3 4
    6.1 3 1 1
    5.7 3 1 2
    5.9 3 1 3
    6.2 3 1 4
    9.9 3 2 1
    10.5 3 2 2
    10.6 3 2 3
    10.1 3 2 4
    13.5 3 3 1
    13.0 3 3 2
    13.3 3 3 3
    13.2 3 3 4
    ;
run;

/* Step 2: Creating the Interaction Plot */
proc sgplot data=hayfever;
    series x=Ingredient2 y=Hours / group=Ingredient1 markers;
    xaxis label="Ingredient 2";
    yaxis label="Hours of Relief";
    title "Interaction Plot of Hours of Relief by Ingredients";
run;

/* Step 3: Performing Two-Way ANOVA */
proc glm data=hayfever;
    class Ingredient1 Ingredient2;
    model Hours = Ingredient1 Ingredient2 Ingredient1*Ingredient2;
    means Ingredient1 Ingredient2 / tukey;
    lsmeans Ingredient1*Ingredient2 / stderr cl;
    title "ANOVA Model and Estimated Coefficients";
run;

/* Step 4: Model Diagnostics */
proc univariate data=hayfever normal;
    var Hours;
    histogram / normal;
    qqplot / normal;
run;

proc glm data=hayfever;
    class Ingredient1 Ingredient2;
    model Hours = Ingredient1 Ingredient2 Ingredient1*Ingredient2;
    output out=diagnostics r=residuals p=predicted;
run;

proc sgplot data=diagnostics;
    scatter x=predicted y=residuals;
    xaxis label="Predicted Values";
    yaxis label="Residuals";
    title "Residuals vs. Predicted Values";
run;

/* Step 5: Confidence Intervals for nu23 and D */
proc means data=hayfever mean clm;
    where Ingredient1=2 and Ingredient2=3;
    var Hours;
    title "95% Confidence Interval for nu23";
run;

proc means data=hayfever mean clm;
    where (Ingredient1=1 and Ingredient2=2) or (Ingredient1=1 and Ingredient2=1);
    var Hours;
    title "95% Confidence Interval for D (nu12 - nu11)";
run;

/* Step 6: Contrasts Analysis */
proc glm data=hayfever;
    class Ingredient1 Ingredient2;
    model Hours = Ingredient1 Ingredient2 Ingredient1*Ingredient2;
    estimate 'L1' Ingredient1*Ingredient2 0.5 0.5 -1 0 0 0 0 0 0;
    estimate 'L2' Ingredient1*Ingredient2 0 0 0 0.5 0.5 -1 0 0 0;
    estimate 'L3' Ingredient1*Ingredient2 0 0 0 0 0 0 0.5 0.5 -1;
    estimate 'L4' Ingredient1*Ingredient2 0 0 0 -0.5 -0.5 1 0.5 0.5 -1;
    estimate 'L5' Ingredient1*Ingredient2 -0.5 -0.5 1 0 0 0 0.5 0.5 -1;
    estimate 'L6' Ingredient1*Ingredient2 0 0 0 0.5 0.5 -1 -0.5 -0.5 1;
    title "Scheffe Multiple Comparisons of Contrasts";
run;

/* Step 7: Identifying Treatment with Longest Relief using Tukey Test */
proc glm data=hayfever;
    class Ingredient1 Ingredient2;
    model Hours = Ingredient1 Ingredient2 Ingredient1*Ingredient2;
    means Ingredient1*Ingredient2 / tukey;
    title "Tukey Test for Longest Mean Relief";
run;

/* Step 8: Box-Cox Transformation */
proc transreg data=hayfever;
    model boxcox(Hours) = class(Ingredient1 | Ingredient2);
    title "Box-Cox Transformation Analysis";
run;
