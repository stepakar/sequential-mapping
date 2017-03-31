%load('2017_03_23_KUZTactileLangMappingGMMCl_data_1.mat')
addpath('/home/tradr/Documents/MATLAB/raacampbell-shadedErrorBar-4c6d623')
for i = 1 : 10%noise
    for r = [21:36]%repetitions
        for j = [4]%dataset size
            for k = 1 : 5 %sequential mapping repetitions
            accOM{k}(r,i) = Results{r,j,i}.Process(k,1).acc2
            accSM{j}(r,i) = Results{r,j,i}.FinAcc2
            accOMo{j}(r,i) = Results{r,j,i}.Process(1,1).acc
            accParts{j}(r,i,:) = Results{r,j,i}.AccPart
            end
        end
    end
end
 
dataSize = [9 1 2 3 5 6]
BP = [1 2 9 6 4 7 5 3 8]
BP_list = {'chest','forearm','upper arm','palm','little finger','ring finger','middle finger','index finger','thumb'}
for j = [4]
    for p = 1:9
        for n = 1:10
        partM(p,n) = mean(accParts{dataSize(j)}(:,n,BP(p)))
        partS(p,n) = std(accParts{dataSize(j)}(:,n,BP(p)))
        end
        end
end

figure(3)
   h= bar(partM)
    hold on;
   
set(h,'BarWidth',1);    % The bars will now touch each other
set(gca,'YGrid','on')
set(gca,'GridLineStyle','-')
    set(gca,'XTick',[1:9]) % This automatically sets 
     set(gca,'XTickLabel',BP_list)
     xlabel('Body part')
     ylabel('Accuracy [%]')
 legend('Noise: 0%', 'Noise: 10%', 'Noise: 20%', 'Noise: 30%', 'Noise: 40%',...
      'Noise: 60%', 'Noise: 70%', 'Noise: 80%', 'Noise: 90%', 'Noise: 100%',...
    'Location', 'Northeast');

hold on;
numgroups = size(partM, 1); 
numbars = size(partM, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, partM(:,i), partS(:,i)/2, 'k', 'linestyle', 'none');
end
