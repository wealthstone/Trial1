%% Conclusiorns:
%1) seems like the original results are rubbish. no specific success for
%the model's Recommendations.
%2) for "Long" Recomm the model yields lower Std. on asset's daily return for "Band"==1 & for
%"Short" the model Yields higher Std. for "Band"==1 the the option of "Band"==0;

% further research:
% 1) Test All Possible couples of band multiplications.
% 2) Do ML w Undl. Asset Std data (all possible convolutions).

%% BoxPlot

for i=1:12
boxplot(Index{1:size(X_Train,1),'Daily_Ret'},X_Train{:,i+1})
ylabel('Daily Return')
xlabel('Daily Recomm')
title(Short_Hand_Bands{i})
uiwait(msgbox('Click here to display next plot'))
end

%% Histogram
Short_Hand_Bands={'PBS','PBM','PBL','TBS','TBM','TBL','PSS','PSM','PSL','TSS','TSM','TSL'};
Y_Train2=Index{1:size(X_Train,1),'Daily_Ret'};
for i=1:12 
Y_Train2_T=Y_Train2(X_Train{:,i+1}==1);
Prob_T=1-cdf('Normal',0,mean(Y_Train2_T),std(Y_Train2_T));

Y_Train2_F=Y_Train2(X_Train{:,i+1}==0);
Prob_F=cdf('Normal',0,mean(Y_Train2_F),std(Y_Train2_F));
plot (1)
subplot(1,2,1)
histogram(Y_Train2_T)
title(sprintf('Daily return hist. for %s == 1 \n P(Y>0)= %s',Short_Hand_Bands{i},num2str(Prob_T)))
subplot(1,2,2)
histogram(Y_Train2_F)
title(sprintf('Daily return hist. for %s == 0 \n P(Y<0)= %s',Short_Hand_Bands{i},num2str(Prob_F)))
uiwait(msgbox('Click here to display next plot'))
end


%% distrib_Table:
VarNames=[strcat(Short_Hand_Bands,'_True') ; strcat(Short_Hand_Bands,'_False')];
VarNames=reshape(VarNames,1,numel(VarNames));
RowNames={'Num_Obs';'Median';'Mean';'Std.';'P(Y>0)';'P(Y<0)'};
distrib_Table=array2table(nan(length(RowNames),length(VarNames)),'VariableNames',VarNames,'Rownames',RowNames);
% Insert_Vals
for i=1:length(Short_Hand_Bands)
    % True:
Y_Train2_T=Y_Train2(X_Train{:,i+1}==1);   
Num_Obs_True=numel(Y_Train2_T);
Median_True=median(Y_Train2_T);
Mean_True=mean(Y_Train2_T);
Std_True=std(Y_Train2_T);
Prob_G_T=1-cdf('Normal',0,Mean_True,Std_True);
Prob_S_T=cdf('Normal',0,Mean_True,Std_True);
    % False:
Y_Train2_F=Y_Train2(X_Train{:,i+1}==0); 
Num_Obs_False=numel(Y_Train2_F);
Median_False=median(Y_Train2_F);
Mean_False=mean(Y_Train2_F);
Std_False=std(Y_Train2_F);
Prob_G_F=1-cdf('Normal',0,Mean_False,Std_False);
Prob_S_F=cdf('Normal',0,Mean_False,Std_False);

distrib_Table{:,{strcat(Short_Hand_Bands{i},'_True'), strcat(Short_Hand_Bands{i},'_False')}}=...
           [Num_Obs_True Num_Obs_False ; Median_True Median_False ; Mean_True Mean_False ; Std_True Std_False ; ...
            Prob_G_T Prob_G_F ; Prob_S_T Prob_S_F];
end

Num_Obs=numel(Y_Train2);
Median=median(Y_Train2);
Mean=mean(Y_Train2);
Std=std(Y_Train2);
Prob_G=1-cdf('Normal',0,Mean,Std);
Prob_S=cdf('Normal',0,Mean,Std);

Entire_Pop=table([Num_Obs ; Median ; Mean ; Std ; Prob_G ; Prob_S],'VariableNames',{'Entire_Pop'},'Rownames',RowNames);
distrib_Table=[Entire_Pop  distrib_Table];