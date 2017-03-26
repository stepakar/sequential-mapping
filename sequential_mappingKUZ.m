function [Results]=sequential_mappingKUZ(Inputs,LabelsC,Pars)
% the function finds the best mapping between visual clustering of DataVis
% and language clustering LangLabs where both clusterings are reclustered
% after each clusters mapping
% INPUTS:for each i:
%       Inputs(i).Data - N x M matrix of data features, N - number of datapoints, M -
%                   number of features/datavector
%       LabelsC - correct labels of data
%       Pars - additional parameters
%           - Pars.method(i) - clustering method (GMM,k-means, HMM) used to
%           cluster Inputs(i).Data
%           - Pars.nmbClusters(i) - number of clusters in Inputs(i).Data
%           - Pars.smax - how many iterations of sequential
%               mapping should be used
%           - Pars.regularize(i) - value by which regularize in
%           gmdistribution while fitting Inputs(i).Data 
%           - Pars.recluster(i) - 0 - don't recluster Inputs(i).Data
%                            - 1 - recluster Inputs(i).Data
%           -Pars.useLabs(i) -0 - will use only raw data and cluster them inside the algorithm 
%                           - 1 - will use labels insted of raw data; when
%                           do not want to recluster the data (eg.
%                           clusterization done externaly before)
%           -Pars.GMMregularize(i) - GMM:regularization value (eg.1)
%           -Pars.HMMNmbStates - HMM:number of HMM states (eg.5)
%           -Pars.HMMnmbIterations - HMM: number of iteration (eg. 5, 0-while changing labels)
%           -Pars.HMMInit - HMM:initialization method: 0 - random, 1 - predefined
% OUTPUTS:Results - Results.Process - process of mapping in each step
%           - Results.Mapping - final mapping Inputs(1).Data to Inputs(2).Data eg. [2 3
%           1] means that Data2 clusters [1 2 3] are mapped to Data1
%           clusters [2 3 1]
%           - Results.Fin(i).Obj - final GMM used to cluster Inputs(i).Data
%           - Results.Fin(i).Idx - final indices of Inputs(i).Data found based on Results.Fin(i).Obj

%save original data
Data1O=Inputs(1).Data;
Data2O=Inputs(2).Data;
UpdNC=Pars.nmbClusters; %expected number of clusters
Pars.s=1;
Results=[];
%until there are any resting clusters in Data1 data, sequentially remove
%data which are best matching to Data2 (the highest value from
%confusion matrix)
[Results,nmbPoints,kk]=seqMap(Results,Inputs(1).Data,Inputs(2).Data,LabelsC,UpdNC,Pars)
    while Pars.s<Pars.smax%how many iterations of sequential mapping should be used
        Pars.s=Pars.s+1;
        DataVis=Data1O;
        LangLabs=Data2O;
        UpdNC=Pars.nmbClusters;                  
        for p=1:kk
            Results.FinObj1(Pars.s,1).mu(p,:)=Results.Process(Pars.s-1,p).objL.mu;
            Results.FinObj1(Pars.s,1).Sigma(:,:,p)=Results.Process(Pars.s-1,p).objL.Sigma;
            Results.FinObj1(Pars.s,1).PComponents(p)=nmbPoints/length(Results.Process(Pars.s-1,p).indD);
        end
        %make the gmdistribution object for initial clusterization from the
        %parameters above            
        Results.FinObj(Pars.s,1).All=gmdistribution(Results.FinObj1(Pars.s,1).mu,...
            Results.FinObj1(Pars.s,1).Sigma,Results.FinObj1(Pars.s,1).PComponents);      
        %until there are any resting clusters in visual data, sequentially remove
        %data which are best matching to language labels (the highest value from
        %confusion matrix)
        [Results,nmbPoints,kk]=seqMap(Results,DataVis,LangLabs,LabelsC,UpdNC,Pars)
    end
    
    for p=1:kk
        Results.FinObj1(Pars.s+1,1).mu(p,:)=Results.Process(Pars.s,p).objL.mu;
        Results.FinObj1(Pars.s+1,1).Sigma(:,:,p)=Results.Process(Pars.s,p).objL.Sigma;
        Results.FinObj1(Pars.s+1,1).PComponents(p)=nmbPoints/length(Results.Process(Pars.s,p).indD);
    end
    %make the gmdistribution object for initial clusterization from the
    %parameters above            
    Results.FinObj(Pars.s+1,1).All=gmdistribution(Results.FinObj1(Pars.s+1,1).mu,...
        Results.FinObj1(Pars.s+1,1).Sigma,Results.FinObj1(Pars.s+1,1).PComponents);  
    [idx,a.nlogl,a.P] = cluster(Results.FinObj(Pars.s+1,1).All,Data1O);
    [a.acc a.CM a.zobr]=testingClassificationZobrDC(idx',renumLabs(Data2O));%values used for sequential mapping     
    [a.acc2 a.CM2 a.zobr2]=testingClassificationZobrDC(idx',LabelsC);%final true accuracy of clustering            
    [acc3 accPart] = computeAccuracy(idx,Data2O,LabelsC,a.zobr,a.CM, Pars)
    
    Results.Process(Pars.s+1,1)=a;    
    Results.Mapping=a.zobr;    
    Results.FinAcc=a.acc2;
    Results.FinAcc2=acc3;
    Results.AccPart = accPart;
    
    function [Results,nmbPoints,kk]=seqMap(Results,Data1,Data2,LabelsC,UpdNC,Pars)
    %until there are any resting clusters in visual data sequentially remove
    %data which are best matching to language labels (the highest value from
    %confusion matrix)
    kk=0;
    nmbPoints=0;
        while UpdNC>0 
            kk=kk+1;
            %enlarge data if there are less data than features
            if size(Data1,2)<size(Data2,2)
                [Data1 nmbR]=EnlargeData(Data1);
                [Data2]=EnlargeData(Data2,nmbR);
            else
                [Data1 nmbR]=EnlargeData(Data1);
                [Data2]=EnlargeData(Data2,nmbR);
            end
            if Pars.s==1
                %cluster data by unsupervised GMM        
                a.obj = gmdistribution.fit(Data1,UpdNC,'Regularize',Pars.regularize);
                [idx,a.nlogl,a.P] = cluster(a.obj,Data1);
                %find mapping between visual and language layer
                [a.acc a.CM a.zobr]=testingClassificationZobrDC(idx',renumLabs(Data2)); 
                if kk==1
                   [a.acc2 a.CM2 a.zobr2]=testingClassificationZobrDC(idx',LabelsC);%final true accuracy of clustering
                end
            else
                 if kk==1
                    [idx,a.nlogl,a.P] = cluster(Results.FinObj(Pars.s,1).All,Data1);
                    [a.acc2 a.CM2 a.zobr2]=testingClassificationZobrDC(idx',LabelsC);%final true accuracy of clustering
                 else
                    a.obj = gmdistribution.fit(Data1,UpdNC,'Regularize',Pars.regularize);
                    [idx,a.nlogl,a.P] = cluster(a.obj,Data1);
                 end  
                 [a.acc a.CM a.zobr]=testingClassificationZobrDC(idx',renumLabs(Data2));%values used for sequential mapping

            end
            %find the highest value in confusion matrix to map appropriate
            %visual cluster to language cluster
            [rows,cols]=find(a.CM==max(max(a.CM)));                
            a.slabs=sort(unique(Data2));
            %visual cluster a.Vcl is mapped to a language cluster a.Lcl
            a.Vcl=a.zobr(cols(1));%visual cluster to delete
            a.Lcl=a.slabs(rows(1));%language cluster to delete
            indND=find(~and(idx'==a.Vcl,Data2==a.Lcl));%indices of data to NOT be deleted        
            %train 1 GMM object on the deleted data which are the ones best
            %matching the language labels        
            a.indD=find(and(idx'==a.Vcl,Data2==a.Lcl));%find indices of data to be deleted and use them for training one GMM object which will be used as initialization one
            Data=EnlargeData(Data1(a.indD,:));%enlarge data if there are less data than features (don't have to enlarge labels, because label is only 1)
            a.objL=gmdistribution.fit(Data,1,'Regularize',Pars.regularize);%learn GMM
            nmbPoints=nmbPoints+length(a.indD);
            %delete data which match language well from both DataVis and LangLabs                
            Data1=Data1(indND,:);
            Data2=Data2(indND);                 
            UpdNC=UpdNC-1;%decrease the number of clusters       
            Results.Process(Pars.s,kk)=a;
        end
    end
    function  [acc3 accPart] = computeAccuracy(idx,Data2O,LabelsC,zobr,CM,Pars)
        %renumber vis clusters based on one step mapping to compare to true
            %language labels
            slo = sort(unique(Data2O));
            Vcls = slo(zobr);
            [maxVoM Lcls] = max(CM)
            Lcls = slo(Lcls)
            idxNew = [];
            for i = 1 : length(idx)
                idxNew(i) = Lcls(find(Vcls == idx(i))); 
            end   
        acc3 = sum(idxNew == LabelsC)/length(idxNew);
        for i = 1 : Pars.nmbClusters(1)
                accPart(i) = sum(and(idxNew == LabelsC,LabelsC == i))/sum(LabelsC == i); 
        end 
    end
end
