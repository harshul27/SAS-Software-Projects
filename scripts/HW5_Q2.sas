/* Step 1: Define the Group Variable and Plot LOESS Curves */
data combined_data;
    input Age EyeContact Gender Personnel SuccessRating;
    datalines;
   11.0      1      1      1   42.0
    7.0      1      1      2   30.0
   12.0      1      1      3   47.0
    6.0      1      1      4   31.0
   10.0      1      1      5   35.0
   15.0      1      2      1   51.0
   12.0      1      2      2   35.0
   14.0      1      2      3   48.0
   11.0      1      2      4   38.0
   16.0      1      2      5   49.0
   12.0      2      1      1   43.0
   16.0      2      1      2   53.0
   10.0      2      1      3   40.0
   13.0      2      1      4   50.0
   14.0      2      1      5   49.0
   14.0      2      2      1   42.0
   17.0      2      2      2   47.0
   13.0      2      2      3   46.0
   20.0      2      2      4   59.0
   18.0      2      2      5   56.0
    ;
run;

/* Create a grouping variable */
data combined_data;
    set combined_data;
    if EyeContact = 1 and Gender = 1 then Group = '11';
    else if EyeContact = 1 and Gender = 2 then Group = '12';
    else if EyeContact = 2 and Gender = 1 then Group = '21';
    else if EyeContact = 2 and Gender = 2 then Group = '22';
run;

/* Plot LOESS curves */
proc sgplot data=combined_data;
    loess x=Age y=SuccessRating / group=Group;
    title "Success Rating vs Age with LOESS Curves by Group";
run;

---

/* Step #2: Fit the ANCOVA Model and Test Interaction Effect */
proc glm data=combined_data;
    class EyeContact Gender;
    model SuccessRating = Age EyeContact Gender EyeContact*Gender / solution;
    title "ANCOVA Model with Interaction";
run;

/* Test H0: (αβ)ij = Interaction Effect */
proc glm data=combined_data;
    class EyeContact Gender;
    model SuccessRating = Age EyeContact Gender EyeContact*Gender / solution type3;
    title "Type III Test for Interaction Effect";
run;

---

/* Step #3: Refit ANCOVA Model Without Interaction Term */
proc glm data=combined_data;
    class EyeContact Gender;
    model SuccessRating = Age EyeContact Gender / solution type3;
    title "ANCOVA Model Without Interaction";
run;

---

/* Step #4: Quantify Change in Success Rating with Age (γ̂) */
proc glm data=combined_data;
    class EyeContact Gender;
    model SuccessRating = Age / solution;
    title "Effect of Age on Success Rating";
run;

---

/* Step #5: Diagnostic Panel for Model Assumptions */
proc glm data=combined_data plots=(diagnostics);
    class EyeContact Gender;
    model SuccessRating = Age EyeContact Gender / solution type3;
    title "Diagnostic Panel for ANCOVA Model";
run;

---

/* Step #6: Residual Plots for Constant Variance Check */
/* Residuals vs i (EyeContact) */
proc sgplot data=combined_data;
    reg x=EyeContact y=Residual / cli; /* Residuals can be obtained from diagnostic output */
    title "Residuals vs Eye Contact";
run;

/* Residuals vs j (Gender) */
proc sgplot data=combined_data;
    reg x=Gender y=Residual / cli; /* Residuals can be obtained from diagnostic output */
    title "Residuals vs Gender";
run;

/* Residuals vs xijk (Age) */
proc sgplot data=combined_data;
    reg x=Age y=Residual / cli; /* Residuals can be obtained from diagnostic output */
    title "Residuals vs Age";
run;

