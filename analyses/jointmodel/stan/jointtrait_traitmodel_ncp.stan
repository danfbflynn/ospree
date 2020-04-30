/* running a joint model to try and see how trait variation might help 
predict phenology. BAsed off Lizzie's joint model exqation 
By Faith Jones, extracted from JointModelSim_fj.R on 21 Feb 2020 by Lizzie */


data {
	// Model of trait 
	int < lower = 1 > N; // Sample size for trait data 
 	int < lower = 1 > nstudy; // number of random effect levels (study) 
	int < lower = 1, upper = nstudy > study[N]; // id of random effect (study)
 	vector[N] traitdat; // y trait data 
	int < lower = 1 > nsp; // number of random effect levels (species) 
	int < lower = 1, upper = nsp > species[N]; // id of random effect (species)
}


parameters{
	// Model of trait
	real <lower =0> sigma_y; // overall variation accross observations
        real agrand; // grand mean for trait
	real <lower = 0> sigma_sp; // variation of intercept amoung species
	real <lower = 0> sigma_study; // variation of intercept amoung studies
	
	
	real mua_sp_ncp[nsp]; // NCP mean of alpha value for species 
  real mua_study_ncp[nstudy]; // NCP mean of alpha value for study
  
}  

transformed parameters{
  real mua_sp[nsp]; // mean of the alpha value for species
  real mua_study[nstudy]; // mean of the alpha value for studies 
  
  //Study and Species means
  for (j in 1:nsp){
    mua_sp[j] = agrand + mua_sp_ncp[j] * sigma_sp; // non-centred effect of variety on alpha  
  }
  
  for (j in 1:nstudy){
    mua_study[j] = agrand + mua_study_ncp[j] * sigma_study; // non-centred effect of variety on alpha  
  }

  
}
  
model{ 
  real ypred[N];
  
	for (i in 1:N){
	    ypred[i] = mua_sp[species[i]] + mua_study[study[i]];  
	}
	// Model of trait priors
	//mua_sp_ncp ~ normal(0, sigma_mua_sp_ncp);
	//mua_study_ncp ~ normal(0, sigma_mua_study_ncp);
	//sigma_mua_sp_ncp ~ normal(0, 10);
	//sigma_mua_study_ncp ~ normal(0, 10);
	
	mua_sp_ncp ~ normal(0, sigma_sp);
	mua_study_ncp ~ normal(0, sigma_study);
	sigma_y ~ normal(0, 3);
        agrand ~ normal(30, 10);
	sigma_sp ~ normal(0, 10);
	sigma_study ~ normal(0, 10);

	// likelihood
        traitdat ~ normal(ypred, sigma_y);
}


/*generated quantities {
   real y_ppc[N];
   for (n in 1:N)
      y_ppc[n] = agrand + a_sp[species[n]] + a_study[study[n]];
    for (n in 1:N)
      y_ppc[n] = normal_rng(y_ppc[n], sigma_y);
} // The posterior predictive distribution*/
