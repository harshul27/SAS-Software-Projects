%let alpha = 0.05;
%let replicates = 10000; /* Increased from 1000 to 10000 for more reliable estimates */

/* Define datasets for each scenario */
%macro generate_data(dist, n1, n2);
  data &dist&n1._&n2;
    do rep = 1 to &replicates;
      do i = 1 to &n1;
        group = 1; 
        %if &dist = Normal %then %do;
          x = rand('Normal', 0, 1);
        %end;
        %else %if &dist = Uniform %then %do;
          x = rand('Uniform');
        %end;
        %else %if &dist = t %then %do;
          x = rand('t', 1);
        %end;
        output;
      end;
      do i = 1 to &n2;
        group = 2; 
        %if &dist = Normal %then %do;
          x = rand('Normal', 0, 1);
        %end;
        %else %if &dist = Uniform %then %do;
          x = rand('Uniform');
        %end;
        %else %if &dist = t %then %do;
          x = rand('t', 1);
        %end;
        output;
      end;
    end;
  run;
%mend;

%generate_data(Normal, 10, 10);
%generate_data(Uniform, 10, 10);
%generate_data(t, 10, 10);
%generate_data(Normal, 30, 30);
%generate_data(Uniform, 30, 30);
%generate_data(t, 30, 30);
%generate_data(Normal, 10, 30);
%generate_data(Uniform, 10, 30);
%generate_data(t, 10, 30);

/* Perform t-tests */
%macro ttest_results(dist, n1, n2);
  proc ttest data=&dist&n1._&n2 alpha=&alpha;
    by rep;
    class group;
    var x;
    ods output TTests=&dist&n1._&n2._Results;
  run;

  data &dist&n1._&n2._Results;
    set &dist&n1._&n2._Results;
    if probt < &alpha then reject = 1;
    else reject = 0;
  run;

  proc means data=&dist&n1._&n2._Results noprint;
    var reject;
    output out=&dist&n1._&n2._MC_results mean=Type_I_Error;
  run;

  proc print data=&dist&n1._&n2._MC_results;
    title "Type I Error Rate for &dist&n1._&n2";
  run;
%mend;

%ttest_results(Normal, 10, 10);
%ttest_results(Uniform, 10, 10);
%ttest_results(t, 10, 10);
%ttest_results(Normal, 30, 30);
%ttest_results(Uniform, 30, 30);
%ttest_results(t, 30, 30);
%ttest_results(Normal, 10, 30);
%ttest_results(Uniform, 10, 30);
%ttest_results(t, 10, 30);

/* Combine and print final results */
data final_results;
  set Normal10_10_MC_results Uniform10_10_MC_results t10_10_MC_results
      Normal30_30_MC_results Uniform30_30_MC_results t30_30_MC_results
      Normal10_30_MC_results Uniform10_30_MC_results t10_30_MC_results;
run;

proc print data=final_results;
  title "Final Type I Error Rates for All Combinations";
run;