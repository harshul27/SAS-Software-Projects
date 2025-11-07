/* Define the dataset with four income groups and respective means */
DATA hospital_stay;
    INPUT income_group $ mean_stay;
    DATALINES;
    L1 5.1
    L2 6.3
    L3 7.9
    L4 9.5
    ;
RUN;

/* Simulating 100 observations per income group */
DATA hospital_stay_expanded;
    DO i = 1 TO 100;
        SET hospital_stay;
        stay_days = mean_stay + RAND('NORMAL', 0, SQRT(2.8)); /* Introducing variation */
        OUTPUT;
    END;
    DROP i;
RUN;

/* Perform ANOVA to obtain MSTR and MSE */
PROC GLM DATA=hospital_stay_expanded;
    CLASS income_group;
    MODEL stay_days = income_group;
    MEANS income_group / CLM;
    OUTPUT OUT=anova_results RESIDUAL=resid;
    ODS OUTPUT ModelANOVA=anova_stats; /* Capturing ANOVA table */
RUN;
QUIT;

/* Extract MSE and MSTR from the ANOVA table */
PROC PRINT DATA=anova_stats;
RUN;

/* --- Re-run with updated means (nu2 = 5.6, nu3 = 9.0) --- */
DATA hospital_stay_new;
    INPUT income_group $ mean_stay;
    DATALINES;
    L1 5.1
    L2 5.6
    L3 9.0
    L4 9.5
    ;
RUN;

DATA hospital_stay_expanded_new;
    DO i = 1 TO 100;
        SET hospital_stay_new;
        stay_days = mean_stay + RAND('NORMAL', 0, SQRT(2.8));
        OUTPUT;
    END;
    DROP i;
RUN;

PROC GLM DATA=hospital_stay_expanded_new;
    CLASS income_group;
    MODEL stay_days = income_group;
    MEANS income_group / CLM;
    OUTPUT OUT=anova_results_new RESIDUAL=resid;
    ODS OUTPUT ModelANOVA=anova_stats_new;
RUN;
QUIT;

/* Print the new ANOVA table */
PROC PRINT DATA=anova_stats_new;
RUN;
