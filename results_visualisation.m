%load('2017_03_23_KUZTactileLangMappingGMMCl_data_1.mat')
addpath('/home/tradr/Documents/MATLAB/raacampbell-shadedErrorBar-4c6d623')
for i = 1 : 10%noise
    for r = 1 : 10%repetitions
        for j = 1:9 %dataset size
            for k = 1 : 5 %sequential mapping repetitions
            accOM{k}(r,i) = Results{r,j,i}.Process(k,1).acc2
            accSM{j}(r,i) = Results{r,j,i}.FinAcc2
            accOMo{j}(r,i) = Results{r,j,i}.Process(1,1).acc
            end
        end
    end
end
 
%size data - 0.01 of 63000
%dependence on noise [0 10 30 60 70 80 90 100]
% noise_dep = [mean(accOM{1},1); mean(accOM{2},1); mean(accOM{3},1); mean(accOM{4},1); mean(accOM{5},1)];
% plot(noise_dep')
% 
% figure;hold on;
% 
% H(1) = shadedErrorBar([1:8],accOM{1}, {@mean, @(x) 0.5*std(x)  }, {'-r.',  'LineWidth', 1},0);hold on;
% H(2) = shadedErrorBar([1:8],accOM{2}, {@mean, @(x) 0.5*std(x)  }, {'-b.',  'LineWidth', 1},0);hold on;
% H(3) = shadedErrorBar([1:8],accOM{3}, {@mean, @(x) 0.5*std(x)  }, {'-m.',  'LineWidth', 1},0);hold on;
% H(4) = shadedErrorBar([1:8],accOM{4}, {@mean, @(x) 0.5*std(x)  }, {'-y.',  'LineWidth', 1},0);hold on;
% H(5) = shadedErrorBar([1:8],accOM{5}, {@mean, @(x) 0.5*std(x)  }, {'-p.',  'LineWidth', 1},0);hold on;
% 
% legend([H(3).mainLine, H.patch], ...
%     '\mu', '2\sigma', '\sigma', '0.5\sigma', ...
%     'Location', 'Northwest');

  %visualize accuracy for different algorithms for different levels of noise
     figure(2)
        plot_variance = @(x,lower,upper,color,alpha) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'EdgeColor',color,'FaceAlpha', alpha);
        x=[1:10];
       % y=[mean(accOM{1},1); mean(accOM{2},1); mean(accOM{3},1); mean(accOM{4},1); mean(accOM{5},1);mean(accSM,1);mean(accOMo,1)];
        y=[mean(accSM{1},1);mean(accSM{2},1);mean(accSM{3},1);mean(accSM{4},1);mean(accOMo{1},1);mean(accOMo{2},1);mean(accOMo{3},1);mean(accOMo{4},1)];
        %margin = [std(accOM{1},1); std(accOM{2},1); std(accOM{3},1); std(accOM{4},1); std(accOM{5},1);std(accSM,1);std(accOMo,1)]/2;
        margin = [std(accSM{1},1);std(accSM{2},1);std(accSM{3},1);std(accSM{4},1);std(accOMo{1},1);std(accOMo{2},1);std(accOMo{3},1);std(accOMo{4},1)]/2;
        plot_variance(x,y(1,:)-margin(1,:),y(1,:)+margin(1,:),[0 0.7 0.7],0.2);hold on;
        plot_variance(x,y(2,:)-margin(2,:),y(2,:)+margin(2,:),[0.7 0 0.7],0.2);hold on;
        plot_variance(x,y(3,:)-margin(3,:),y(3,:)+margin(3,:),[0.7 0.7 0],0.2);hold on;
        plot_variance(x,y(4,:)-margin(4,:),y(4,:)+margin(4,:),[0 0 0.7],0.2);hold on;
        plot_variance(x,y(5,:)-margin(5,:),y(5,:)+margin(5,:),[0.9 0.9 0.9],0.2);hold on;
        plot_variance(x,y(6,:)-margin(6,:),y(6,:)+margin(6,:),[0.7 0.7 0.7],0.2);hold on;
        plot_variance(x,y(7,:)-margin(7,:),y(7,:)+margin(7,:),[0.5 0.5 0.5],0.2);hold on;
        plot_variance(x,y(8,:)-margin(8,:),y(8,:)+margin(8,:),[0.3 0.3 0.3],0.2);hold on;


            hold on
            h=plot(x,y(1,:),'Color',[0 0.7 0.7],'LineWidth',1.5);hold on;
            h=plot(x,y(2,:),'Color',[0.7 0 0.7],'LineWidth',1.5);hold on;
            h=plot(x,y(3,:),'Color',[0.7 0.7 0],'LineWidth',1.5);hold on;
            h=plot(x,y(4,:),'Color',[0 0 0.7],'LineWidth',1.5);hold on;
            h=plot(x,y(5,:),'Color',[0.9 0.9 0.9],'LineWidth',1.5);hold on;
            h=plot(x,y(6,:),'Color',[0.7 0.7 0.7],'LineWidth',1.5);hold on;
            h=plot(x,y(7,:),'Color',[0.5 0.5 0.5],'LineWidth',1.5);hold on;
            h=plot(x,y(8,:),'Color',[0.7 0 0],'LineWidth',1.5);hold on;

     %h=plot([1:noiseLength],,...
     %    'LineWidth',2)
     set(gca,'XTick',[0:10]) % This automatically sets 
     set(gca,'XTickLabel',cat(2,0,[0 10 20 30 40 60 70 80 90 100]))
     set(h,'LineWidth',2);
     xlabel('Noise level [%]')
     ylabel('Accuracy [%]')
     
     %set(h(5),'LineWidth',1);
     title(['Accuracy of one step vs. sequential mapping for dif. levels of noise in language'])
