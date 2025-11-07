/* Import the data file */
filename dog '/home/u63986830/Dogs.dat';

data dogs;
	infile dog;
	input T1 T2 T3 T4;
run;

/* Print the dataset */
proc print data=dogs;
	title "Dogs Dataset";
run;

/* Compare Treatment 1 and Treatment 2 */
proc ttest data=dogs alpha=0.004;
	paired T1*T2;
	title "Paired t-test for Treatment 1 vs Treatment 2";
run;

proc univariate data=dogs;
	var T1 T2;
run;

/* Compare Treatment 1 and Treatment 3 */
proc ttest data=dogs alpha=0.004;
	paired T1*T3;
	title "Paired t-test for Treatment 1 vs Treatment 3";
run;

proc univariate data=dogs;
	var T1 T3;
run;

/* Compare Treatment 1 and Treatment 4 */
proc ttest data=dogs alpha=0.004;
	paired T1*T4;
	title "Paired t-test for Treatment 1 vs Treatment 4";
run;

proc univariate data=dogs;
	var T1 T4;
run;

/* Compare Treatment 2 and Treatment 3 */
proc ttest data=dogs alpha=0.004;
	paired T2*T3;
	title "Paired t-test for Treatment 2 vs Treatment 3";
run;

proc univariate data=dogs;
	var T2 T3;
run;

/* Compare Treatment 2 and Treatment 4 */
proc ttest data=dogs alpha=0.004;
	paired T2*T4;
	title "Paired t-test for Treatment 2 vs Treatment 4";
run;

proc univariate data=dogs;
	var T2 T4;
run;

/* Compare Treatment 3 and Treatment 4 */
proc ttest data=dogs alpha=0.004;
	paired T3*T4;
	title "Paired t-test for Treatment 3 vs Treatment 4";
run;

proc univariate data=dogs;
	var T3 T4;
run;