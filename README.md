# Sequential mapping algorithm

Sequential mapping algorithm in MATLAB for performing cross-situational learning and mapping language to sensoric modality (or in general any two clusterings together) as used for a paper submitted to conference [KUZ 2017](http://cogsci.fmph.uniba.sk/kuz2017/)

The function finds the best mapping between visual clustering of DataVis and language clustering LangLabs where both clusterings are reclustered after each clusters mapping

### Example usage: 

```
Inputs(1).Data = Visual_data; %now clustered by GMM
Inputs(2).Data = Language_data; 
labelsNmb = True_labels; %vector of numerical values indicating class for each datapoint (just for evaluation purposes)
Pars.nmbClusters=[9]%number of clusters in visual data
Pars.init=1%1-random,2-Ikm    
Pars.regularize = [1];%value by which regularize in gmdistribution while fitting Inputs(i).Data 
Pars.smax = 5;%how many iterations of sequential mapping should be used

Results = sequential_mappingKUZ(Inputs,labelsNmb,Pars)
```


