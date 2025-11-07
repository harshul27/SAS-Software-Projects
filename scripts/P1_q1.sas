/* Data Import */

FILENAME senic "/home/u63986830/senic.csv";

DATA senic_data;
  INFILE senic DELIMITER=',' DSD FIRSTOBS=2;
  INPUT Hospital stay age infprob culratio xratio nbeds medschl region census nurses service;
RUN;

/* Question 1: Infection Risk by Region */
/* (a) ANOVA for Mean Infection Risk */
/* Tests if mean infection risk is the same across regions (alpha = 0.05) */

PROC GLM DATA=senic_data;
  TITLE "Question 1(a): ANOVA for Infection Risk by Region";
  CLASS region;
  MODEL infprob = region;
  MEANS region / TUKEY ALPHA=0.05;
RUN;


/* (c) Different Pairwise Comparison Procedure (e.g., Bonferroni) */
/* Performs pairwise comparisons using Bonferroni adjustment */

PROC GLM DATA=senic_data;
  TITLE "Question 1(c): Bonferroni Pairwise Comparisons";
  CLASS region;
  MODEL infprob = region;
  MEANS region / BON ALPHA=0.05;
RUN;


/* Line plot */
/* Creates a line plot of the mean infection risk for each region */
proc means data = senic_data noprint;
class region;
var infprob;
output out = mean_infprob mean = mean_infprob;
run;

proc sgplot data = mean_infprob;
TITLE "Question 1(b): Line Plot of Mean Infection Risk by Region";
series x = region y = mean_infprob;
run;
