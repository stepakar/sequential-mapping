%main script used to generate data for the paper
%iterates over amount of datapoints from tactile domain (Pars.NmbDataPerc)
%noise in the language data (Pars.NoisePercAll)
addpath(genpath('/home/tradr/Documents/MATLAB/'));
load('dataset_KUZ_2017.mat') (tactile data from homunculus)
Pars.NmbDataPerc = [0.01 0.05 0.1 0.2 0.5 1 0.01 0.05 0.005]%[1 0.75 0.5 0.25 0.1 0.05 0.01 0.005 0.001]
Pars.NoisePercAll = [0 10 20 30 40 60 70 80 90 100]%[10 20 30 40 50 60 70 80 90]
%PARAMETERS
Pars.generate_inputs=1;
Pars.generate_sentence=1;
Pars.nmbClusters=[9 9]%size color shape%[5 6 3];%number of clusters in visual data
Pars.NT=3;%normalization type for function normalizeK: 3 is mean 0 and std 1
Pars.noiseS=5;%gaussian noise in artificial data - not good since it is not the real noise
Pars.noiseLang=5;%noise in language data which is added after PatPho generation
Pars.moveS=0;
Pars.featureNumbers=[1];
Pars.words_same_length=1;
Pars.fractionNmbDatapoints=[1];%fraction from 4050/nmbwords
Pars.used_types=Pars.featureNumbers %[1:5]size, color, direction,texture,shape
Pars.normalization_type=3;%0 - unnormalize, 3-(v-vmean)/vstd
Pars.init=1%1-random,2-Ikm    
Pars.type_transition_matrixFeat=4;%1-Basic=fixed 5 words sentence,2-Advanced,3 more longer sentences but variable, 4-even more longer
Pars.type_transition_matrixInst=1;%1-Basic=fixed probs for all instances from one feature,2-Advanced-not implemented yet
Pars.nmbData=4050;
Pars.regularize = [1];
Pars.smax = 5;
Pars.kind=[1:Pars.nmbData];%230]%[1:14 16:43 45:67 69:207];%indices of images to be processed - necessary to change also the name of the loaded image
    %ResultsFin = [];
for d = 9%3 : 8%length(Pars.NmbDataPerc) %iterate over number of datapoints in the dataset
        for rep = 1:10%1 : 20
        Pars.nmbData = round(size(activ_homun,1)*Pars.NmbDataPerc(d));
        idxVis = randsample (size(activ_homun,1),Pars.nmbData);
        for p = 1:10%1 : length(Pars.NoisePercAll) %iterate over noise
        fprintf('repetition %d number of datapoints %d and noise percentage %d.\n',rep, Pars.nmbData,Pars.NoisePercAll(p));
            %PARAMETERS
            Pars.NoisePerc = Pars.NoisePercAll(p); %percentage of noise in language data
            %labels to numbers
            labels_list = unique(labels);
            for i = 1: length(labels)
                for j = 1:length(labels_list)
                    if strcmp(labels{i},labels_list{j})
                        labelsNmb(i) = j;
                    end
                end
            end
            Pars.nmbClusters = length(labels_list);
            %Adding noise to language
            rind=randsample (size(labelsNmb,2),ceil(size(labelsNmb,2)*Pars.NoisePerc/100));%ceil(rand(1,round(size(labelsNmb,2)*Pars.NoisePerc/100))*size(labelsNmb,2));
            labels_Noise = labelsNmb;
            labels_Noise(rind) =ceil(rand(1,length(rind))*Pars.nmbClusters);
            for i = 1:9;sumi1(i) = sum(labels_Noise == i);end;
            for i = 1:9;sumi2(i) = sum(labelsNmb == i);end;
            %[a.accI a.CMI a.zobrI]=testingClassificationKUZ(labels_Noise,labelsNmb);%final true accuracy of clustering
            Inputs(1).Data = activ_homun(idxVis,:);
            Inputs(2).Data = labels_Noise(idxVis);

            Results{rep,d,p} = sequential_mappingKUZ(Inputs,labelsNmb(idxVis),Pars)

            [maxVo maxIo] = max(activ_homun(idxVis,:)');
            %renumerate neurons of homunculus to the number of assigned language
            %cluster         
        end
    end
    %save(['2017_03_25_KUZTactileLangMappingGMMCl_data_',num2str(d),'.mat'],'Results','Pars','-v7.3')
end

