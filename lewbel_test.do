# delimit;
set more off;

timer clear 1;

timer on 1;

use data_lewbel_temp.dta, replace;

/* Doing the Lewbel Estimates, as suggested in the follwing paper
   Arthur Lewbel (2012): Using Heteroscedasticity to Identify and Estimate Mismeasured and Endogenous Regressor
   Models, Journal of Business & Economic Statistics, 30:1, 67-80 [http://dx.doi.org/10.1080/07350015.2012.643126
*/

display "Program Started at :  $S_DATE $S_TIME ";

	
	reg c7 exp exp2 gender marital lang SecDum1 - SecDum3 Owndum1 - Owndum4 dalian;
	hettest;
	predict ep2, residual;
	
	foreach x of varlist exp exp2 gender marital lang SecDum1 - SecDum3 Owndum1 - Owndum4 dalian {;
		egen `x'_bar = mean(`x');
		gen z_`x' = `x' - `x'_bar;
		gen z1_`x' = z_`x' * ep2;
		};
	
	ivregress 2sls lnhwage exp exp2 gender marital lang SecDum1 - SecDum3 Owndum1 - Owndum4 dalian (c7 = z1_*);
	outreg2 using lewbel_output.doc, nolabel replace stats(coef tstat);
	
/* Now doing the same estimate using the inbuild routine ivreg2h */

	ivreg2h lnhwage exp exp2 gender marital lang SecDum1 - SecDum3 Owndum1 - Owndum4 dalian (c7 =);
	
	outreg2 using lewbel_output.doc, nolabel append stats(coef tstat);

/* what about when we use a GMM */
	ivregress gmm lnhwage exp exp2 gender marital lang SecDum1 - SecDum3 Owndum1 - Owndum4 dalian (c7 = z1_*);
	outreg2 using lewbel_output.doc, nolabel append stats(coef tstat);
	
/* Now doing the same estimate using the inbuild routine ivreg2h */

	ivreg2h lnhwage exp exp2 gender marital lang SecDum1 - SecDum3 Owndum1 - Owndum4 dalian (c7 =), gmm2s robust;
	
	outreg2 using lewbel_output.doc, nolabel append stats(coef tstat);


/* A comparision of two estimates suggests that my resutls are identical to the ivreg2h */

display "Program Finished at :  $S_DATE $S_TIME ";

timer off 1;

timer list 1;
