/* Step 1: Input the data */
data premium_distribution;
    input TimeLapse Group Subject;
    datalines;
   24.0      1      1
   24.0      1      2
   29.0      1      3
   20.0      1      4
   21.0      1      5
   25.0      1      6
   28.0      1      7
   27.0      1      8
   23.0      1      9
   21.0      1     10
   24.0      1     11
   26.0      1     12
   23.0      1     13
   24.0      1     14
   28.0      1     15
   23.0      1     16
   23.0      1     17
   27.0      1     18
   26.0      1     19
   25.0      1     20
   18.0      2      1
   20.0      2      2
   20.0      2      3
   24.0      2      4
   22.0      2      5
   29.0      2      6
   23.0      2      7
   24.0      2      8
   28.0      2      9
   19.0      2     10
   24.0      2     11
   25.0      2     12
   21.0      2     13
   20.0      2     14
   24.0      2     15
   22.0      2     16
   19.0      2     17
   26.0      2     18
   22.0      2     19
   21.0      2     20
   10.0      3      1
   11.0      3      2
    8.0      3      3
   12.0      3      4
   12.0      3      5
   10.0      3      6
   14.0      3      7
    9.0      3      8
    8.0      3      9
   11.0      3     10
   16.0      3     11
   12.0      3     12
   18.0      3     13
   14.0      3     14
   13.0      3     15
   11.0      3     16
   14.0      3     17
    9.0      3     18
   11.0      3     19
   12.0      3     20
   15.0      4      1
   13.0      4      2
   18.0      4      3
   16.0      4      4
   12.0      4      5
   19.0      4      6
   10.0      4      7
   18.0      4      8
   11.0      4      9
   17.0      4     10
   15.0      4     11
   12.0      4     12
   13.0      4     13
   13.0      4     14
   14.0      4     15
   17.0      4     16
   16.0      4     17
   17.0      4     18
   14.0      4     19
   16.0      4     20
   33.0      5      1
   22.0      5      2
   28.0      5      3
   35.0      5      4
   29.0      5      5
   28.0      5      6
   30.0      5      7
   31.0      5      8
   29.0      5      9
   28.0      5     10
   33.0      5     11
   30.0      5     12
   32.0      5     13
   33.0      5     14
   29.0      5     15
   35.0      5     16
   32.0      5     17
   26.0      5     18
   30.0      5     19
   29.0      5     20
;
run;

/* Step (a): Fit the ANOVA model */
proc glm data=premium_distribution;
    class Group; /* Declare Group as a categorical variable */
    model TimeLapse = Group / NOINT; /* Fit the ANOVA model without intercept */
    means Group / hovtest=levene; /* Test for equal variances using Levene's test */
run;

/* Step (b): Boxplot for each group */
proc sgplot data=premium_distribution;
    vbox TimeLapse / category=Group;
    title "Boxplot of Time Lapse by Group";
run;

/* Step (c): Qualitative description of relationship */
proc means data=premium_distribution mean stddev min max;
    class Group;
    var TimeLapse;
run;

/* Step (d): Tukey's test and confidence intervals */
/* Part b: Tukey's pairwise comparisons */
proc glm data=premium_distribution;
    class Group;
    model TimeLapse = Group / NOINT;
    means Group / tukey alpha=0.10; /* Tukey test with alpha = .10 */
run;

/* Part c: Confidence interval for mean of Group = Agent (Group = "1") */
/* The output confirms Group is numeric, so use numeric comparison */
proc means data=premium_distribution mean clm alpha=0.10;
    where Group = 1; /* Corrected WHERE clause for numeric variable */
    var TimeLapse;
run;

/* Part d: Confidence interval for D = M2 - M1 */
proc glm data=premium_distribution;
    class Group;
    model TimeLapse = Group / NOINT solution; /* No intercept, request solutions */
    estimate 'D = M2 - M1' Group -1 1 0 0 0; /* Estimate difference between Groups */
run;

/* Step (e): Contrast estimation */
/* Part a: Estimate L = ((nu1 + nu2)/2) - ((nu3 + nu4)/2) */
proc glm data=premium_distribution;
    class Group;
    model TimeLapse = Group / NOINT solution;
    estimate 'Contrast L' Group .5 .5 -.5 -.5 0; /* Correct contrast for five levels */
run;

/* Part b: Scheffe procedure for comparisons */
proc glm data=premium_distribution;
    class Group;
    model TimeLapse = Group / NOINT solution;
    estimate 'D1 = nu1 - nu2' Group +1 -1 0 0 0;
    estimate 'D2 = nu3 - nu4' Group 0 0 +1 -1 0;
    estimate 'L1 = ((nu1 + nu2)/2) - nu5' Group .5 .5 0 0 -1;
    estimate 'L2 = ((nu3 + nu4)/2) - nu5' Group 0 0 .5 .5 -1;
    estimate 'L3 = ((nu1 + nu2)/2) - ((nu3 + nu4)/2)' Group .5 .5 -.5 -.5 0;
run;

/* Step (f): Residual analysis */
/* Residual plots and diagnostics */
proc glm data=premium_distribution plots=residuals diagnostics;
    class Group;
    model TimeLapse = Group / NOINT solution; /* Fit the ANOVA model with residual diagnostics */
run;