% Get Data:
Data_Location={'Local'};
Asset={'SPX_Index'};
Num_Serial_Choosen=[];
[Paths ] = Give_Paths(Data_Location);
[TSout] = Take_TSout(Asset,Num_Serial_Choosen,Paths);
[Index] = Take_Index(Asset,Paths);
% Prep Data:
%      After loading consec data & Tsout files for asset:
Short_Hand_Bands={'PBS','PBM','PBL','TBS','TBM','TBL','PSS','PSM','PSL','TSS','TSM','TSL'};
TSout=TSout(:,[{'Date'} Short_Hand_Bands]);
Index(Index{:,'Trading'}==0,:)=[];
TSout=TSout(ismember(TSout{:,'Date'},Index{:,'Date'}),:);
Index=Index(ismember(Index{:,'Date'},TSout{:,'Date'}),:);

%      Check Table lengths:
      % Possibility #1:
%if ~(size(Dependent_Var_Consec,1)==size(TSoutmm,1))
%    msgbox(sprintf('matrix Length for %s TSoutmm And Index table could not be made equal',Index),'Error','error')
%    return
%elseif ~(Dependent_Var_Consec{1,'Date'}==TSoutmm{1,'Date'}) 
%    msgbox(sprintf('matrix Length for %s TSoutmm And Index table dont start on the same date',Index),'Error','error')
%    return
%elseif ~(Dependent_Var_Consec{end,'Date'}==TSoutmm{end,'Date'}) 
%    msgbox(sprintf('matrix Length for %s TSoutmm And Index table dont end on the same date',Index),'Error','error')
%    return
%end

     % Possibility #2:
if ~(sum(ismember(Index{:,'Date'},TSout{:,'Date'}))==size(Index,1))
   msgbox(sprintf('matrix Length for %s TSoutmm And Index table dont have the same date composition',Index),'Error','error')
   return 
end

Ret_By='PX_OPEN';
Daily_Return=tick2tack(Index{:,Ret_By});
if strcmp(Ret_By,'PX_OPEN')   
Daily_Return=[Daily_Return ; Index{end,'PX_LAST'}./Index{end,'PX_OPEN'}-1];   
elseif strcmp(Ret_By,'PX_LAST')
Daily_Return=[Index{1,'PX_LAST'}./Index{1,'PX_OPEN'}-1 ; Daily_Return];   
end

Index(:,'Daily_Ret')=table(Daily_Return);
Index(:,'Daily_Movement')=table(zeros(size(Daily_Return)));
Index{Index{:,'Daily_Ret'}>=0,'Daily_Movement'}=1;


Train_Size=0.9; %from 0 to 1
Final_Train_Location=round(size(Index,1)*Train_Size);
% Y Seperate:
Y_Train=Index(1:Final_Train_Location,{'Date','Daily_Movement'});
Y_Test=Index(Final_Train_Location+1:end,{'Date','Daily_Movement'});
% X Seperate:
X_Train=TSout(1:Final_Train_Location,:);
X_Test=TSout(Final_Train_Location+1:end,:);

% Quantile:
Index_Train=Index(1:Final_Train_Location,:);
Index_Test=Index(Final_Train_Location+1:end,:);
Num_quantiles=5;
quant=linspace(0,1,Num_quantiles);
quant=quant(2:end);
Y_quant=quantile(Index_Train{:,'Daily_Ret'},quant);
Index_Train(:,'Daily_Movement_Quant')=table(ones(size(Index_Train,1),1));
Index_Test(:,'Daily_Movement_Quant')=table(ones(size(Index_Test,1),1));
for i=2:Num_quantiles-1
Index_Train{Index_Train{:,'Daily_Ret'}>=Y_quant(i-1),'Daily_Movement_Quant'}=i;
Index_Test{Index_Test{:,'Daily_Ret'}>=Y_quant(i-1),'Daily_Movement_Quant'}=i;
end

Y_Train_Quant=Index_Train(:,{'Date','Daily_Movement_Quant'});
Y_Test_Quant=Index_Test(:,{'Date','Daily_Movement_Quant'});
% hist(Y_Train_Quant{:,{'Daily_Movement_Quant'}})
%% Display Train Data:
% Test for close distribution of non negative days between test & train periods. 
Non_negative_days_train=sum(Y_Train{:,'Daily_Movement'})/length(Y_Train{:,'Daily_Movement'});
Non_negative_days_test=sum(Y_Test{:,'Daily_Movement'})/length(Y_Test{:,'Daily_Movement'});

% Bivariate histogram plot
for i=1:length(Short_Hand_Bands)
    figure(1)
    histogram2(X_Train{:,Short_Hand_Bands{i}},Y_Train{:,2})
    % histogram2(X_Train{:,Short_Hand_Bands{i}},Y_Train{:,2},'DisplayStyle','tile','ShowEmptyBins','on')
    xlabel(strcat('X Train','_',Short_Hand_Bands{i}))
    ylabel('Y Train')
    title(sprintf('correl. coeff.: %s \n R Sqr: %s',...
          num2str(corr(X_Train{:,Short_Hand_Bands{i}},Y_Train{:,2})),...
          num2str((corr(X_Train{:,Short_Hand_Bands{i}},Y_Train{:,2}))^2)))
    uiwait
end

% Quantile histogram:
for i=1:length(Short_Hand_Bands)
    figure(2)
    % histogram2(X_Train{:,Short_Hand_Bands{i}},Y_Train_Quant{:,2})
    histogram2(X_Train{:,Short_Hand_Bands{i}},Y_Train_Quant{:,2},'DisplayStyle','tile','ShowEmptyBins','on')
    colorbar
    xlabel(strcat('X Train','_',Short_Hand_Bands{i}))
    ylabel('Y Train Quant')
    title(sprintf('correl. coeff.: %s \n R Sqr: %s',...
          num2str(corr(X_Train{:,Short_Hand_Bands{i}},Y_Train_Quant{:,2})),...
          num2str((corr(X_Train{:,Short_Hand_Bands{i}},Y_Train_Quant{:,2}))^2)))
    uiwait
end
%% Find largest R^2 :
R_Sqr_table_Train=array2table(nan(2,length(Short_Hand_Bands)),'VariableNames',Short_Hand_Bands);
for i=1:length(Short_Hand_Bands)
        %R_Sqr=(corr(X_Train{:,Short_Hand_Bands{i}},Y_Train{:,2}))^2;
        R_Sqr=(corr(X_Train{:,Short_Hand_Bands{i}},Y_Train_Quant{:,2}))^2;
        R_Sqr_table_Train{1,i}=R_Sqr;
    if R_Sqr>0.001
        R_Sqr_table_Train{2,i}=1;
    end
end
%% Train Model:
%Use_Bands=[1 2 3 9 10 11 12];
Use_Bands=[6];
Mdl_1 = fitcnb(X_Train(:,Use_Bands+1),Y_Train(:,'Daily_Movement'));
Mdl_1 = fitcnb(X_Train(:,Use_Bands+1),Y_Train_Quant(:,'Daily_Movement_Quant'));
Crros_Val_Mdl_1 = crossval(Mdl_1);
Loss = kfoldLoss(Crros_Val_Mdl_1)
% classErr1 = kfoldLoss(Crros_Val_Mdl_1,'LossFun','ClassifErr')
Mdl_2 = fitcnb(X_Train(:,2:end),Y_Train(:,'Daily_Movement'),'CategoricalPredictors',true(1,size(X_Train(:,2:end),2)));
% CrossVal:

Mdl_3 = fitcnb(X_Train(:,2:end),Y_Train(:,'Daily_Movement'),'CategoricalPredictors',true(1,size(X_Train(:,2:end),2)),...
               'CrossVal','on');
Mdl_3 = crossval(Mdl_2);
Loss = kfoldLoss(Mdl_3);

%confusionmat
isLabels1 = resubPredict(Mdl_1);
ConfusionMat1 = confusionmat(Y_Train{:,'Daily_Movement'},isLabels1);
% Use Prior:
prior = 0.5 ;

% train an error-correcting, output codes multiclass model.
t = templateNaiveBayes();
CVMdl2 = fitcecoc(X_Train(:,Use_Bands+1),Y_Train_Quant(:,'Daily_Movement_Quant'),'CrossVal','on','Learners',t);

classErr2 = kfoldLoss(CVMdl2,'LossFun','ClassifErr')

%% Feature Selection: (From: https://www.mathworks.com/help/stats/fscnca.html)

%% Binary depedent variable
Xtrain=X_Train{:,2:end};
ytrain=Y_Train{:,2:end};

Xtest=X_Test{:,2:end};
ytest=Y_Test{:,2:end};

%% Quentile depedent variable

ytrain=Y_Train_Quant{:,2:end};
ytest=Y_Test_Quant{:,2:end};
%%
nca = fscnca(Xtrain,ytrain,'FitMethod','none');
L = loss(nca,Xtest,ytest)

cvp = cvpartition(ytrain,'kfold',5);
numvalidsets = cvp.NumTestSets;

n = length(ytrain);
lambdavals = linspace(0,20,20)/n;
lossvals = zeros(length(lambdavals),numvalidsets);

for i = 1:length(lambdavals)
    for k = 1:numvalidsets
        X = Xtrain(cvp.training(k),:);
        y = ytrain(cvp.training(k),:);
        Xvalid = Xtrain(cvp.test(k),:);
        yvalid = ytrain(cvp.test(k),:);

        nca = fscnca(X,y,'FitMethod','exact', ...
             'Solver','sgd','Lambda',lambdavals(i), ...
             'IterationLimit',30,'GradientTolerance',1e-4, ...
             'Standardize',true);

        lossvals(i,k) = loss(nca,Xvalid,yvalid,'LossFunction','classiferror');
    end
end

meanloss = mean(lossvals,2);

figure()
plot(lambdavals,meanloss,'ro-')
xlabel('Lambda')
ylabel('Loss (MSE)')
grid on

[~,idx] = min(meanloss)
bestlambda = lambdavals(idx) % Find the best lambda value
bestloss = meanloss(idx)

nca = fscnca(Xtrain,ytrain,'FitMethod','exact','Solver','sgd',...
    'Lambda',bestlambda,'Standardize',true,'Verbose',1);

figure()
plot(nca.FeatureWeights,'ro')
xlabel('Feature index')
ylabel('Feature weight')
grid on

tol    = 1e-6;
tol    = 0.2;
selidx = find(nca.FeatureWeights > tol*max(1,max(nca.FeatureWeights)))

L = loss(nca,Xtest,ytest)

features = Xtrain(:,selidx);

svmMdl = fitcsvm(features,ytrain);
Mdl = fitcecoc(features,ytrain); %% https://www.mathworks.com/help/stats/fitcecoc.html
svmMdl = fitrsvm(features,ytrain);
L = loss(svmMdl,Xtest(:,selidx),ytest)

%% https://www.mathworks.com/help/stats/fitcdiscr.html

Mdl = fitcdiscr(Xtrain,ytrain);
Cost=[0 1 ; 1 0];
rng(1)
Mdl = fitcdiscr(Xtrain,ytrain,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'))

label = predict(Mdl,Xtest);
[C,order] = confusionmat(ytest,label)