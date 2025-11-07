/* Step 1: Import the dataset */
data sales_data;
    input Sales_Previous Display_Treatment Store Sales_Current;
    datalines;
    69.0 1 1 92.0
    44.0 1 2 68.0
    58.0 1 3 74.0
    38.0 1 4 52.0
    54.0 1 5 65.0
    74.0 2 1 77.0
    75.0 2 2 80.0
    73.0 2 3 70.0
    78.0 2 4 73.0
    82.0 2 5 79.0
    66.0 3 1 64.0
    49.0 3 2 43.0
    84.0 3 3 81.0
    75.0 3 4 68.0
    77.0 3 5 71.0
    ;
run;

/* ------------------- Question: Part of Section (22.14) ------------------- */

/* Part a: Scatter Plot */
title "22.14 Part a: Scatter Plot of Sales Data by Display Treatment";
proc sgplot data=sales_data;
    scatter x=Sales_Previous y=Sales_Current / group=Display_Treatment;
    xaxis label="Sales in Previous Period";
    yaxis label="Sales in Current Period";
run;

/* Part b: Regression Models */
/* Full regression model */
title "22.14 Part b: Full Regression Model";
proc reg data=sales_data;
    model Sales_Current = Sales_Previous Display_Treatment / clb;
run;

/* Reduced regression model */
title "22.14 Part b: Reduced Regression Model";
proc reg data=sales_data;
    model Sales_Current = Sales_Previous / clb;
run;

/* Part c: Test for Treatment Effects */
title "22.14 Part c: Testing for Treatment Effects Using GLM";
proc glm data=sales_data;
    class Display_Treatment;
    model Sales_Current = Sales_Previous Display_Treatment / solution;
run;

/* Part d: Compare MSE Values */
/* Covariance model */
title "22.14 Part d: Covariance Model MSE";
proc glm data=sales_data;
    class Display_Treatment;
    model Sales_Current = Sales_Previous Display_Treatment / solution;
run;

/* ANOVA model */
title "22.14 Part d: ANOVA Model MSE";
proc glm data=sales_data;
    class Display_Treatment;
    model Sales_Current = Display_Treatment / solution;
run;

/* Part e: Estimate Mean Sales with Confidence Interval */
/* Filter for Treatment =2 and previous sales = $75 */
data filtered_sales_data; 
   set sales_data; 
   if Display_Treatment =2 and Sales_Previous=75; 
run;

title "22.14 Part e: Estimate Mean Sales for Treatment =2 with Confidence Interval";
proc reg data=filtered_sales_data; 
   model Sales_Current = Sales_Previous Display_Treatment / clb alpha=0.05; /* Confidence interval at alpha=0.05 */ 
run;

/* Part f: Pairwise Comparisons Using Bonferroni Procedure */
title "22.14 Part f: Pairwise Comparisons Between Treatments Using Bonferroni Procedure";
proc glm data=sales_data;
    class Display_Treatment;
    model Sales_Current = Display_Treatment / solution;
    means Display_Treatment / bon alpha=0.10; /* Bonferroni adjustment with family confidence coefficient of .90 */
run;

/* ------------------- Question: Part of Section (22.22) ------------------- */

/* Create a new dataset for differences in sales (Yij - Xij) */
data diff_sales_data;
    set sales_data;
    Diff_Sales = Sales_Current - Sales_Previous; /* Calculate difference in sales */
run;

/* Title for ANOVA Analysis on Differences */
title "22.22 Part a: ANOVA Table for Differences in Sales (Yij - Xij)";
proc glm data=diff_sales_data;
    class Display_Treatment;
    model Diff_Sales = Display_Treatment / solution; /* Regular ANOVA on differences */
run;

/* Title for Discussion of Effectiveness Comparison */
title "22.22 Part b: Effectiveness of Differences vs Covariance Model";
/* Covariance model again for comparison */
proc glm data=sales_data; 
    class Display_Treatment; 
    model Sales_Current = Sales_Previous Display_Treatment / solution; 
run;

title "End of Analysis";

