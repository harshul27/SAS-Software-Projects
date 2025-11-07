/* Step 1: Import Data */
FILENAME senic "/home/u63986830/senic.csv";

DATA senic_data;
  INFILE senic DELIMITER=',' DSD FIRSTOBS=2;
  INPUT Hospital stay age infprob culratio xratio nbeds medschl region census nurses service;
RUN;

/* (3a) Initial ANOVA: Length of Stay by Region */

TITLE "Question 3(a): ANOVA for Length of Stay by Region";
PROC GLM DATA=senic_data;
  CLASS region;
  MODEL stay = region;
  MEANS region;
  OUTPUT OUT=residuals_data RESIDUAL=residuals;
RUN;
QUIT;

/* (3a) Residual Dot Plots by Region */
TITLE "Question 3(a): Residual Dot Plots by Region";
PROC SGPLOT DATA=residuals_data;
    SCATTER X=region Y=residuals / JITTER;
    XAXIS LABEL="Region";
    YAXIS LABEL="Residuals";
RUN;

/* (3b) Brown-Forsythe Test for Equal Variances */

TITLE "Question 3(b): Brown-Forsythe Test for Variance Equality Across Regions";
PROC GLM DATA=senic_data;
  CLASS region;
  MODEL stay = region;
  MEANS region / HOVTEST=BF;
RUN;
QUIT;

/* (3c) Checking Means and Standard Deviations */
/* ---------------------- */
TITLE "Question 3(c): Mean and Standard Deviation by Region";
PROC MEANS DATA=senic_data N MEAN STDDEV;
  CLASS region;
  VAR stay;
RUN;

/* (3d) Box-Cox Transformation Analysis */
TITLE "Question 3(d): Box-Cox Transformation for Length of Stay";
PROC TRANSREG DATA=senic_data;
    MODEL BOXCOX(stay) = CLASS(region);
    OUTPUT OUT=boxcox_results;
RUN;

/* (3e) ANOVA After Reciprocal Transformation */
/* ---------------------- */
TITLE "Question 3(e): ANOVA on Reciprocal Transformed Data";
PROC GLM DATA=senic_transformed;
  CLASS region;
  MODEL stay_reciprocal = region;
  OUTPUT OUT=residuals_transformed RESIDUAL=residuals_transformed;
RUN;
QUIT;


/* (3f) Brown-Forsythe Test After Transformation */
/* ---------------------- */
TITLE "Question 3(f): Brown-Forsythe Test on Transformed Data";
PROC GLM DATA=senic_transformed;
  CLASS region;
  MODEL stay_reciprocal = region;
  MEANS region / HOVTEST=BF ALPHA=0.01;
RUN;
QUIT;

