/* Data Import */

FILENAME senic "/home/u63986830/senic.csv";

DATA senic_data;
  INFILE senic DELIMITER=',' DSD FIRSTOBS=2;
  INPUT Hospital stay age infprob culratio xratio nbeds medschl region census nurses service;
RUN;

/* Question 2: Infection Risk by Age Group */
/* Classifies average age into four categories and tests for differences in mean infection risk */

/* Create age categories */
DATA senic_data;
  TITLE "Question 2: Creating Age Groups";
  SET senic_data;
  IF age < 50 THEN age_group = 1;
  ELSE IF age >= 50 AND age < 55 THEN age_group = 2;
  ELSE IF age >= 55 AND age < 60 THEN age_group = 3;
  ELSE age_group = 4;
  LABEL age_group = "Age Group (1=<50, 2=50-54.9, 3=55-59.9, 4=60+)";
RUN;

/* Frequency table of age groups */
PROC FREQ DATA=senic_data;
  TITLE "Question 2: Frequency of Age Groups";
  TABLES age_group;
RUN;

/* ANOVA for Infection Risk by Age Group */
PROC GLM DATA=senic_data;
  TITLE "Question 2: ANOVA for Infection Risk by Age Group";
  CLASS age_group;
  MODEL infprob = age_group;
  MEANS age_group / ALPHA=0.1;
RUN;
