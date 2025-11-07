* Important Note: Each SAS command must end with a semi-colon;
* In the following command below, we create a pointer named pulse to the data file. Creating pointer is optional;
filename pulse "/folders/myfolders/pulse.dat";

DATA c; /* Assign name c to data */
INFILE pulse; *reads the file whose pointer is pulse. Alternatively, if pointer was not created, then provide the file pathname here;
INPUT ROW PULSE1 PULSE2 RAN SMOKES SEX HEIGHT WEIGHT ACTIVITY; /* provide the variable names */
RUN;

PROC PRINT DATA=c (obs=5); * prints the first five observations only;
RUN;

PROC PLOT HPERCENT=33 VPERCENT=33; *Reduce the size of plots to 33%;
PLOT WEIGHT*HEIGHT;
PLOT WEIGHT*HEIGHT=SEX; * uses different plotting symbols for men and women;
PLOT PULSE1*WEIGHT='*' PULSE2*WEIGHT='o'/OVERLAY; /* Overlay plots the graphs in the same picture */
RUN;

PROC MEANS;
VAR PULSE1 PULSE2 SMOKES SEX HEIGHT WEIGHT;
RUN;

PROC UNIVARIATE NORMAL PLOT; * options to verify normality;
VAR HEIGHT;
RUN;

PROC FREQ;
TABLES smokes sex activity ran;
RUN;
