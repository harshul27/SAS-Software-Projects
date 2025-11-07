/* Load the data */
DATA helicopter;
    INPUT Response Group Subject;
    DATALINES;
    4.0 1 1
    3.0 1 2
    5.0 1 3
    4.0 1 4
    6.0 1 5
    3.0 1 6
    2.0 1 7
    5.0 1 8
    7.0 1 9
    1.0 1 10
    2.0 1 11
    5.0 1 12
    4.0 1 13
    7.0 1 14
    4.0 1 15
    5.0 1 16
    0.0 1 17
    4.0 1 18
    1.0 1 19
    6.0 1 20
    0.0 2 1
    2.0 2 2
    0.0 2 3
    3.0 2 4
    2.0 2 5
    1.0 2 6
    0.0 2 7
    3.0 2 8
    1.0 2 9
    0.0 2 10
    0.0 2 11
    1.0 2 12
    1.0 2 13
    0.0 2 14
    1.0 2 15
    3.0 2 16
    1.0 2 17
    2.0 2 18
    2.0 2 19
    0.0 2 20
    2.0 3 1
    1.0 3 2
    0.0 3 3
    3.0 3 4
    4.0 3 5
    1.0 3 6
    3.0 3 7
    4.0 3 8
    2.0 3 9
    0.0 3 10
    1.0 3 11
    3.0 3 12
    2.0 3 13
    4.0 3 14
    0.0 3 15
    1.0 3 16
    3.0 3 17
    0.0 3 18
    2.0 3 19
    4.0 3 20
    5.0 4 1
    2.0 4 2
    4.0 4 3
    4.0 4 4
    6.0 4 5
    5.0 4 6
    3.0 4 7
    5.0 4 8
    7.0 4 9
    3.0 4 10
    1.0 4 11
    0.0 4 12
    2.0 4 13
    3.0 4 14
    3.0 4 15
    4.0 4 16
    1.0 4 17
    5.0 4 18
    2.0 4 19
    3.0 4 20
    ;
RUN;

/* (a) Side-by-side boxplots */
PROC SGPLOT DATA=helicopter;
    VBOX Response / CATEGORY=Group;
    TITLE 'Boxplots of Response by Group';
RUN;

/* (b) ANOVA model */
PROC GLM DATA=helicopter;
    CLASS Group;
    MODEL Response = Group;
    MEANS Group / TUKEY;
    TITLE 'ANOVA Model Testing Equality of Means';
RUN;

/* (c) Diagnostic Panel */
PROC UNIVARIATE DATA=helicopter NORMAL;
    VAR Response;
    HISTOGRAM / NORMAL;
    QQPLOT;
    TITLE 'Diagnostic Plots for Residual Analysis';
RUN;

/* (d) Levene’s Test for Equal Variance */
PROC GLM DATA=helicopter;
    CLASS Group;
    MODEL Response = Group;
    MEANS Group / HOVTEST=LEVENE;
    TITLE 'Levene’s Test for Homogeneity of Variance';
RUN;

/* (e) Non-Parametric Test */
PROC NPAR1WAY DATA=helicopter WILCOXON DSCF;
    CLASS Group;
    VAR Response;
    TITLE 'Non-Parametric Test with Multiple Comparisons';
RUN;

/* (f) ANOVA with separate variances using PROC MIXED */
PROC MIXED DATA=helicopter;
    CLASS Group;
    MODEL Response = Group;
    REPEATED / GROUP=Group;
    TITLE 'ANOVA with Separate Group Variances';
RUN;

/* (g) Box-Cox Transformation */
DATA helicopter;
    SET helicopter;
    ResponsePlus1 = Response + 1;
RUN;

PROC TRANSREG DATA=helicopter; 
    MODEL BOXCOX(ResponsePlus1) = CLASS(Group); 
    TITLE 'Box-Cox Transformation Analysis';
RUN;

/* (h) Refit Model with Transformed Data */
PROC GLM DATA=helicopter;
    CLASS Group;
    MODEL ResponsePlus1 = Group;
    TITLE 'Refitted ANOVA Model After Box-Cox Transformation';
RUN;
