 /* Revised SAS Code */
 /* Import the data with adjustments */
 proc import datafile="/home/u63986830/proj2_cleaned.csv/proj2_cleaned.csv"
  out=county_data
  dbms=csv
  replace;
  delimiter=",";
  getnames=yes;
  guessingrows=500; /* Increase guessing rows */
 run;

 /* Check the imported data */
 proc contents data=county_data;
 run;

 proc print data=county_data(obs=10); /* Print first 10 observations to verify */
 run;

 /* Create the crime rate variable */
 data county_data;
  set county_data;
  CrimeRate = `Total of serious crimes` / `Total population estimated in 1990`;

  /* Classify poverty levels */
  if `Percent below povery level` < 6 then PovertyLevel = 'Under 6%';
  else if `Percent below povery level` <= 10 then PovertyLevel = '6-10%';
  else PovertyLevel = '10% or More';
 run;

 /* Part I (i): ANOVA and Regression Models */
 /* ANOVA Model:
    CrimeRate = μ + Region_i + PovertyLevel_j + (Region*PovertyLevel)_ij + ε
    where:
    μ is the overall mean,
    Region_i is the effect of the i-th region,
    PovertyLevel_j is the effect of the j-th poverty level,
    (Region*PovertyLevel)_ij is the interaction effect between region and poverty level,
    ε is the random error term.

   Regression Model:
    CrimeRate = β0 + β1*Region2 + β2*Region3 + β3*Region4 + β4*PovertyLevel2 + β5*PovertyLevel3
                + β6*(Region2*PovertyLevel2) + β7*(Region2*PovertyLevel3)
                + β8*(Region3*PovertyLevel2) + β9*(Region3*PovertyLevel3)
                + β10*(Region4*PovertyLevel2) + β11*(Region4*PovertyLevel3) + ε
    where:
    β0 is the intercept,
    β1-β3 are the coefficients for Region dummy variables (Region 1 is the reference),
    β4-β5 are the coefficients for PovertyLevel dummy variables (Under 6% is the reference),
    β6-β11 are the coefficients for the interaction terms.
 */

 /* Part I (ii): Fit the regression model */
 proc glm data=county_data;
  class `Geographic region` PovertyLevel;
  model CrimeRate = `Geographic region`|PovertyLevel / solution;
  output out=residuals r=resid;
 run;
 quit;

 /* Aligned residual dot plots */
 proc sgplot data=residuals;
  title "Residual Plot by Region";
  vbox resid / category=`Geographic region`;
 run;

 proc sgplot data=residuals;
  title "Residual Plot by Poverty Level";
  vbox resid / category=PovertyLevel;
 run;

 /* Findings: Analyze the residual plots to check for homogeneity of variance
    and normality. Look for patterns or outliers. */

 /* Part I (iii): Reduced regression model for testing interaction effects */
 /* Reduced Regression Model:
    CrimeRate = β0 + β1*Region2 + β2*Region3 + β3*Region4 + β4*PovertyLevel2 + β5*PovertyLevel3 + ε
 */

 /* Fit the reduced regression model */
 proc glm data=county_data;
  class `Geographic region` PovertyLevel;
  model CrimeRate = `Geographic region` PovertyLevel / solution;
  /* Store the full and reduced model */
  store full_model;
  store reduced_model;
 run;
 quit;

 /* Likelihood Ratio Test for Interaction Effects */
 proc compare base=full_model compare=reduced_model criterion=3;
 run;

 /* State Alternatives and P-values:
    Null Hypothesis (H0): There are no interaction effects.
    Alternative Hypothesis (H1): There are interaction effects.
    From the output of the `proc compare`, obtain the p-value for the Type III test.
    If the p-value is less than α = 0.05, reject the null hypothesis and conclude that
    there are significant interaction effects. */
