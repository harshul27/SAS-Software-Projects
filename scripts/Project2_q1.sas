%let alpha = 0.05;
%let replicates = 1000;

/* Define datasets for each scenario */
data Normal10_10;
  do rep = 1 to &replicates;
    do i = 1 to 10;
      group = 1; x = rand('Normal', 0, 1); output;
      group = 2; x = rand('Normal', 0, 1); output;
    end;
  end;
run;

data Uniform10_10;
  do rep = 1 to &replicates;
    do i = 1 to 10;
      group = 1; x = rand('Uniform'); output;
      group = 2; x = rand('Uniform'); output;
    end;
  end;
run;

data t10_10;
  do rep = 1 to &replicates;
    do i = 1 to 10;
      group = 1; x = rand('t', 1); output;
      group = 2; x = rand('t', 1); output;
    end;
  end;
run;

/* Repeat for other sample sizes and distributions */
data Normal30_30;
  do rep = 1 to &replicates;
    do i = 1 to 30;
      group = 1; x = rand('Normal', 0, 1); output;
      group = 2; x = rand('Normal', 0, 1); output;
    end;
  end;
run;

data Uniform30_30;
  do rep = 1 to &replicates;
    do i = 1 to 30;
      group = 1; x = rand('Uniform'); output;
      group = 2; x = rand('Uniform'); output;
    end;
  end;
run;

data t30_30;
  do rep = 1 to &replicates;
    do i = 1 to 30;
      group = 1; x = rand('t', 1); output;
      group = 2; x = rand('t', 1); output;
    end;
  end;
run;

data Normal10_30;
  do rep = 1 to &replicates;
    do i = 1 to 10;
      group = 1; x = rand('Normal', 0, 1); output;
    end;
    do i = 1 to 30;
      group = 2; x = rand('Normal', 0, 1); output;
    end;
  end;
run;

data Uniform10_30;
  do rep = 1 to &replicates;
    do i = 1 to 10;
      group = 1; x = rand('Uniform'); output;
    end;
    do i = 1 to 30;
      group = 2; x = rand('Uniform'); output;
    end;
  end;
run;

data t10_30;
  do rep = 1 to &replicates;
    do i = 1 to 10;
      group = 1; x = rand('t', 1); output;
    end;
    do i = 1 to 30;
      group = 2; x = rand('t', 1); output;
    end;
  end;
run;

/* Perform t-tests */
%macro ttest_results(data);
  proc ttest data=&data alpha=&alpha;
    class group;
    var x;
    ods output TTests=&data._Results;
  run;

  data &data._Results;
    set &data._Results;
    if probt < &alpha then reject = 1;
    else reject = 0;
  run;

  proc means data=&data._Results noprint;
    var reject;
    output out=&data._MC_results mean=Type_I_Error;
  run;

  proc print data=&data._MC_results;
    title "Type I Error Rate for &data";
  run;
%mend;

%ttest_results(Normal10_10);
%ttest_results(Uniform10_10);
%ttest_results(t10_10);
%ttest_results(Normal30_30);
%ttest_results(Uniform30_30);
%ttest_results(t30_30);
%ttest_results(Normal10_30);
%ttest_results(Uniform10_30);
%ttest_results(t10_30);

/* Combine and print final results */
data final_results;
  set Normal10_10_MC_results Uniform10_10_MC_results t10_10_MC_results
      Normal30_30_MC_results Uniform30_30_MC_results t30_30_MC_results
      Normal10_30_MC_results Uniform10_30_MC_results t10_30_MC_results;
run;

proc print data=final_results;
title "Final Type I Error Rates for All Combinations";
run;
