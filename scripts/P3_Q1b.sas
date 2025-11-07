/* Create a data step to input the CSV data manually */
data beams;
input site batch y;
datalines;
1 1 45
1 1 46
1 1 43
1 2 44
1 2 47
1 2 45
1 3 55
1 3 60
1 3 56
1 4 49
1 4 58
1 4 50
2 1 44
2 1 45
2 1 50
2 2 55
2 2 51
2 2 54
2 3 68
2 3 74
2 3 76
2 4 55
2 4 59
2 4 63
3 1 49
3 1 47
3 1 44
3 2 53
3 2 54
3 2 51
3 3 48
3 3 51
3 3 47
3 4 65
3 4 57
3 4 55
;
run;

/* Basic statistics and plots */
proc means data=beams;
   class site batch;
   var y;
run;

/* You might need to use SGPLOT if available in your SAS version */
proc sgplot data=beams;
   vbox y / category=site;
   title 'Tensile Strength by Site';
run;

/* Alternative if SGPLOT is not available */
proc boxplot data=beams;
   plot y*site;
   title 'Tensile Strength by Site';
run;

/* Fitting the nested random effects model */
proc mixed data=beams;
   class site batch;
   model y = / solution;
   random site batch(site);
   title 'Nested Random Effects Model';
run;

/* Variance Components Analysis */
proc varcomp data=beams method=reml;
   class site batch;
   model y = site batch(site);
   title 'Variance Components Analysis';
run;

/* Conducting ANOVA analysis */
proc glm data=beams;
   class site batch;
   model y = site batch(site) / ss3;
   random site batch(site) / test;
   title 'Analysis of Variance for Nested Model';
run;