proc import datafile="/home/u63986830/proj2_cleaned.csv"
  out=county_data
  dbms=csv
  replace;
  delimiter=",";
  getnames=yes;
  guessingrows=500;
  datarow=2;
 run;

 data county_data;
  set county_data;

  rename
  "Identification number" = ID
  "County" = County
  "State" = State
  "Land area (in square miles)" = LandArea
  "Total population estimated in 1990" = TotalPop1990
  "Percent of Population aged 18-24" = PctPop18to24
  "Percent of population 65 or older" = PctPop65Older
  "Number of active physicians" = NumPhysicians
  "Number of hospital beds" = NumHospitalBeds
  "Total of serious crimes" = TotalSeriousCrimes
  "Percent high school graduates" = PctHSDGraduates
  "Percent college graduates" = PctCollegeGraduates
  "Percent below povery level" = PctBelowPoverty
  "Percent unemployment" = PctUnemployment
  "Per capita income" = PerCapitaIncome
  "Total personal income" = TotalPersonalIncome
  "Geographic region" = GeographicRegion;

  CrimeRate = TotalSeriousCrimes / TotalPop1990;

  if PctBelowPoverty < 6 then PovertyLevel = 'Under 6%';
  else if PctBelowPoverty <= 10 then PovertyLevel = '6-10%';
  else PovertyLevel = '10% or More';

  if PctBelowPoverty < 8 then PovertyLevel2 = '< 8%';
  else PovertyLevel2 = '>= 8%';

  if PctPop65Older < 12 then OlderPop = '< 12%';
  else OlderPop = '>= 12%';
 run;

 proc contents data=county_data;
 run;

 proc print data=county_data(obs=10);
 run;

/* Part II */
 /*(i) Conduct a three-way ANOVA then do the diagnostic procedure.*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = GeographicRegion|PovertyLevel2|OlderPop / solution;
  output out=resids r=resid;
 run;
 quit;

 proc sgplot data=resids;
  vbox resid / category=GeographicRegion;
 run;

 proc sgplot data=resids;
  vbox resid / category=PovertyLevel2;
 run;

 proc sgplot data=resids;
  vbox resid / category=OlderPop;
 run;
 /*(ii) Prepare AB interaction plots of the estimated treatment means. Does it appear that any factor
 effects are present?*/
 proc means data=county_data;
  class GeographicRegion PovertyLevel2;
  var CrimeRate;
  output out=means_ab mean=MeanCrimeRate;
 run;

 proc sgplot data=means_ab;
  title "AB Interaction Plot";
  series x=PovertyLevel2 y=MeanCrimeRate / group=GeographicRegion;
 run;

 /*(iii) Test for three-factor interactions and for AB, AC and BC interactions. For each test, use α = .025
 and state the alternatives, reduced regression model and P-values.*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = GeographicRegion PovertyLevel2 OlderPop
  GeographicRegion*PovertyLevel2
  GeographicRegion*OlderPop
  PovertyLevel2*OlderPop / solution;
  store model_no_3way;
 run;
 quit;

 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = GeographicRegion|PovertyLevel2|OlderPop / solution;
  store full_model2;
 run;
 quit;

 proc compare base=full_model2 compare=model_no_3way criterion=3;
 run;

 /*AB Interaction*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = PovertyLevel2 OlderPop
  GeographicRegion
  GeographicRegion*OlderPop
  PovertyLevel2*OlderPop/ solution;
  store AB_reduced;
 run;
 quit;

 proc compare base=model_no_3way compare=AB_reduced criterion=3;
 run;
 /*AC Interaction*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = PovertyLevel2 OlderPop
  GeographicRegion
  GeographicRegion*PovertyLevel2
  PovertyLevel2*OlderPop/ solution;
  store AC_reduced;
 run;
 quit;

 proc compare base=model_no_3way compare=AC_reduced criterion=3;
 run;
 /*BC Interaction*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = PovertyLevel2 GeographicRegion
  OlderPop
  GeographicRegion*PovertyLevel2
  GeographicRegion*OlderPop/ solution;
  store BC_reduced;
 run;
 quit;

 proc compare base=model_no_3way compare=BC_reduced criterion=3;
 run;

 /*(iv) Test for A, B, C main effects. For each test, use α = .025 and state the alternatives, reduced
 regression model and P-values.*/
 /*Testing for A main effects*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = PovertyLevel2 OlderPop
  PovertyLevel2*OlderPop/ solution;
  store A_reduced;
 run;
 quit;

 proc compare base=model_no_3way compare=A_reduced criterion=3;
 run;

 /*Testing for B main effects*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = GeographicRegion OlderPop
  GeographicRegion*OlderPop/ solution;
  store B_reduced;
 run;
 quit;

 proc compare base=model_no_3way compare=B_reduced criterion=3;
 run;

 /*Testing for C main effects*/
 proc glm data=county_data;
  class GeographicRegion PovertyLevel2 OlderPop;
  model CrimeRate = PovertyLevel2 GeographicRegion
  GeographicRegion*PovertyLevel2/ solution;
  store C_reduced;
 run;
 quit;

 proc compare base=model_no_3way compare=C_reduced criterion=3;
 run;