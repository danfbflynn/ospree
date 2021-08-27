//Model started by Faith in Feb 2020 based on Lizzie's notes 
// Modified by Deirdre based on the rangers model 

// running a joint model to try and see how trait variation might help 
    //predict phenology. BAsed off Lizzie's joint model exquation 

//priors are centred around values from Deirdre's similation code: fakedata_3parm_1trait.R   

data {
    //MODEL 1 ------------------------------------------------
    int < lower = 1 > N; // Sample size for trait data 
 
    int < lower = 1 > n_study; // number of random effect levels (study)
    int < lower = 1, upper = n_study > study[N]; // id of random effect (study)

    vector[N] yTraiti; // Outcome trait data 

    //both models --------------------------------------------------------
    int < lower = 1 > n_spec; // number of random effect levels (species) 
    int < lower = 1, upper = n_spec > species[N]; // id of random effect (species)

    //MODEL 2 ------------------------------------------------
    int < lower = 1 > Nph; // Sample size for forcing 
 
    vector[Nph] yPhenoi; // Outcome phenology
    vector[Nph] forcei; // predictor forcing 
    vector[Nph] photoi; // predictor photoperiod
    vector[Nph] chilli; // predictor chilling

    int < lower = 1, upper = n_spec > species2[Nph]; // id of random effect (species)

}

parameters{

    //MODEL 1 ------------------------------------------------
    //level 1
    real <lower =0> sigmaTrait_y; // overall variation accross observations
    real mu_grand; // Grand mean for trait value 
    //level 2
    real <lower = 0> sigma_sp; // variation of intercept amoung species

    real muSp[n_spec]; //The trait effect of each species without study 

    real <lower = 0> sigma_study; // variation of intercept amoung studies
    real muStudy[n_study]; // mean of the alpha value for studies

    //MODEL 2 -----------------------------------------------------
    //level 2
    
    real alphaForceSp[n_spec]; //the distribution of species forcing values
    real muForceSp; // the mean of the effect of forcing
    real <lower = 0> sigmaForceSp; //variation around the mean of the effect of forcing 
    
    real alphaChillSp[n_spec]; //the distribution of species chilling values
    real muChillSp; // the mean of the effect of chilling
    real <lower = 0> sigmaChillSp; //variation around the mean of the effect of chilling

    real alphaPhotoSp[n_spec]; //the distribution of species photoperiod values
    real muPhotoSp; // the mean of the effect of photoperiod
    real <lower = 0> sigmaPhotoSp; //variation around the mean of the effect of photo

    real alphaPhenoSp[n_spec]; //the species level intercept 
    real muPhenoSp; // 
    real <lower = 0> sigmaPhenoSp; 

    real betaTraitxForce; 
    real betaTraitxChill;
    real betaTraitxPhoto;
    // general varience/error
    real <lower =0> sigmapheno_y; // overall variation accross observations
}

transformed parameters{
    //MODEL 1 ----------------------------------------
    //Individual mean for species and study
    real ymu[N]; // the trait value, height, ssd, etc.

    //MODEL 2------------------------------------------------
    real betaForceSp[n_spec];     //species level beta forcing 
    real betaPhotoSp[n_spec];     //species level beta photoperiod
    real betaChillSp[n_spec];     //species level beta chilling

    //MODEL 1
    //Individual mean calculation 
    for (i in 1:N){
        ymu[i] = mu_grand + muSp[species[i]] + muStudy[study[i]];  //muSp is used in 2nd level of model
    }

    //MODEL 2----------------------------------------
    //get beta-cue-Sp values for each species
    for (isp in 1:n_spec){
    betaForceSp[isp] = alphaForceSp[isp] + betaTraitxForce * ( muSp[isp]);
    }
    
    for (isp in 1:n_spec){
    betaPhotoSp[isp] = alphaPhotoSp[isp] + betaTraitxPhoto* ( muSp[isp]);
    }

    for (isp in 1:n_spec){
    betaChillSp[isp] = alphaChillSp[isp] + betaTraitxChill* (muSp[isp]);
    }
}
model{ 
    //MODEL 1 ---------------------------------------------
    //assign priors
    sigmaTrait_y ~ normal(15,1); // trt.var 0.5 Aug 13, lizzie suggested 1 or 0.5 instead
    sigma_sp ~ normal(10,1); //sigma_species 10
    mu_grand ~ normal(10, 1); // 
    muSp ~ normal(0, sigma_sp); //

    sigma_study ~ normal(5,1); //sigma.study 5
    muStudy ~ normal(0, sigma_study);//
    
    // run the actual model - likihood
    for (i in 1:N){
        yTraiti[i] ~ normal(ymu[i], sigmaTrait_y);
    }

    //MODEL 2 -----------------------------------------------
    //priors - level 1
    sigmapheno_y ~ normal(5, 3); // Aug 13, lizzie suggested 1 or 0.5 instead

    //priors level 2

    sigmaForceSp ~ normal(0,30); //
    muForceSp ~ normal(0, 40);//
    alphaForceSp ~ normal(muForceSp, sigmaForceSp);  //
    
    sigmaChillSp ~ normal(0,30); //sigma.chill.sp
    muChillSp ~ normal(0,40);//
    alphaChillSp ~ normal(muChillSp, sigmaChillSp);  //
    // 
    sigmaPhotoSp ~ normal(0,10); //sigma.photo.sp
    muPhotoSp ~ normal(0,40);//
    alphaPhotoSp ~ normal(muPhotoSp, sigmaPhotoSp);  //
    
    sigmaPhenoSp ~ normal(10, 1); // sigma.pheno.sp =2  
    muPhenoSp ~ normal(150, 10);  // mu.pheno.sp = 150
    alphaPhenoSp ~ normal(muPhenoSp, sigmaPhenoSp);//

    betaTraitxForce ~ normal(0, 1); // Aug 5: widen these and see what the impact is
    betaTraitxPhoto ~ normal(0, 1); // # this was 0.5 at first and
    betaTraitxChill ~ normal(0, 1); //

    //likelihood 
    //         for (i in 1:Nph){
    // yPhenoi[i] ~ normal( alphaPhenoSp[species2[i]] + betaForceSp[species2[i]] * forcei[i] + betaChillSp[species2[i]] * chilli[i], sigmapheno_y);
    //     }
        for (i in 1:Nph){
    yPhenoi[i] ~ normal( alphaPhenoSp[species2[i]] + betaForceSp[species2[i]] * forcei[i] + betaPhotoSp[species2[i]] * photoi[i] + betaChillSp[species2[i]] * chilli[i], sigmapheno_y);
        }

}


generated quantities {
} // The posterior predictive distribution


//generated quantities {
//    real y_pred[N];
//    for (i in 1:N) {
//        y_pred[i] = normal_rng(ymu, sigma);
 //   }
    
//    # could have poster for both the trait and the phenology model with two loops in the //generated quantities with different parameters
 //   # could make a 3-D plot, and do indiv comparison, comparing the real trait data to ypre data
//} // The posterior predictive distribution
