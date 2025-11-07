/* Part (a): Identify θ, ϕ, a(·), b(·), and c(·) */

/* Define the exponential distribution parameters */
%let lambda = 2; /* Example rate parameter */

/* Output the components of the exponential family */
data exponential_family;
    lambda = &lambda;
    theta = -lambda; /* Natural parameter */
    phi = 1; /* Dispersion parameter */
    a_phi = 1 / phi; /* a(ϕ) */
    b_theta = -log(-theta); /* b(θ) */
    y = 1; /* Example value of y */
    c_y_phi = -y / phi; /* c(y,ϕ) */
    output;
run;

proc print data=exponential_family noobs;
    var lambda theta phi a_phi b_theta c_y_phi;
    title "Components of Exponential Family Distribution";
run;

/* Part (b): Canonical link and variance function for GLM */
data glm_properties;
    canonical_link = "-1 / μ"; /* Canonical link function */
    variance_function = "μ^2"; /* Variance function */
    output;
run;

proc print data=glm_properties noobs;
    title "Canonical Link and Variance Function for GLM";
run;

/* Part (c): Practical difficulty with canonical link */
data practical_difficulty;
    difficulty = "The canonical link g(μ) = -1/μ is undefined for μ = 0.";
    output;
run;

proc print data=practical_difficulty noobs;
    title "Practical Difficulty with Canonical Link";
run;

/* Part (d): Deviance Calculation */

/* Input observed and fitted values */
data deviance_data;
    input y_obs mu_hat;
    datalines;
    0.5 0.6
    1.0 1.1
    1.5 1.4
    2.0 2.2
    ;
run;

/* Calculate deviance for exponential distribution */
data deviance_calc;
    set deviance_data;
    deviance_term = (y_obs / mu_hat) - log(y_obs / mu_hat) - 1; /* Deviance term for each observation */
run;

proc sql;
    select sum(2 * deviance_term) as total_deviance
    from deviance_calc;
quit;

proc print data=deviance_calc noobs;
    title "Deviance Calculation for Each Observation";
run;

