/* Import the dataset */
filename health '/home/u63986830/health.csv';

data health;
    infile health dsd firstobs=1;
    input Death_Rate Doctor_Availability Hospital_Availability Capital_income Population_Density;
run;

/* Full model */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density;
    title 'Full Model';
run;

/* All possible subsets regression */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density
        / selection=rsquare adjrsq cp bic best=5;
    title 'All Possible Subsets Regression';
run;

/* Stepwise selection */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density
        / selection=stepwise slentry=0.05 slstay=0.05;
    title 'Stepwise Selection';
run;

/* Forward selection */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density
        / selection=forward slentry=0.05;
    title 'Forward Selection';
run;

/* Backward selection */
proc reg data=health;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density
        / selection=backward slstay=0.05;
    title 'Backward Selection';
run;

/* Compare models */
proc glmselect data=health plots=all;
    model Death_Rate = Doctor_Availability Hospital_Availability Capital_income Population_Density
        / selection=stepwise(select=cp) stats=all;
    title 'Model Comparison using GLMSELECT';
run;