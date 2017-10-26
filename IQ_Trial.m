Asset_Name='SPX Index';
Asset_Name_BBG=strrep(Asset_Name,' ','_');
Asset_Name_IQ ='BVSP.X';

% Import BBG Data File:
load(strcat('Technical\Data\',Asset_Name_BBG))
VarNamesTaken={'Date','PX_OPEN','PX_HIGH','PX_LOW','PX_LAST','PX_VOLUME'};
Index_BBG=Dependent_Var_Consec(Dependent_Var_Consec{:,'Trading'}==1,VarNamesTaken);
Index_BBG.Properties.VariableNames={'Date','Open','High','Low','Close','Volume'};

% Import IQ Feed Data File:
A=exist('c'); %exist('c','class');
if A==0
   c=iqf('469307','29971545');
end
Years_Back=22;
interval = 252*Years_Back;
period = 'Daily';
history(c,Asset_Name_IQ,interval,period)
%close(c)

% Convert 2 Table format:
Date=dateshift(datetime(IQFeedHistoryData(:,1)),'start','day');
Date.Format='dd/MM/yyyy';
High=str2double(IQFeedHistoryData(:,2));
Low=str2double(IQFeedHistoryData(:,3));
Open=str2double(IQFeedHistoryData(:,4));
Close=str2double(IQFeedHistoryData(:,5));
Volume=str2double(IQFeedHistoryData(:,6));
Open_Int=str2double(IQFeedHistoryData(:,7));

Index_IQ=table(Date,Open,High,Low,Close,Volume,'VariableNames',{'Date','Open','High','Low','Close','Volume'});
Index_IQ=sortrows(Index_IQ,{'Date'},{'ascend'});

% Match dates for two files:
Index_BBG(Index_BBG{:,'Date'}<Index_IQ{1,'Date'},:)=[];
Index_IQ(Index_IQ{:,'Date'}>Index_BBG{end,'Date'},:)=[];

% First Check Date's competability:
  % Extra Dates:
Index_IQ_Extra_Dates=Index_IQ{(~ismember(Index_IQ{:,'Date'},Index_BBG{:,'Date'})),'Date'};
if ~isempty(Index_IQ_Extra_Dates)
       Extra_Dates_Days=weekday(Index_IQ_Extra_Dates)';
       Extra_Dates=datestr(Index_IQ_Extra_Dates);
       Extra_Dates=reshape(Extra_Dates',1,size(Extra_Dates,1)*size(Extra_Dates,2));
       Extra_Dates=strrep(Extra_Dates,'2017','2017 & ');
       Extra_Dates=strrep(Extra_Dates,'2016','2016 & ');
       Extra_Dates=Extra_Dates(1:end-3);
   uiwait(msgbox(sprintf('%s IQ Feed data has These EXTRA Dates: \n %s \n that are the weekdays: %s',Asset_Name,Extra_Dates,num2str(Extra_Dates_Days))))   
   Index_IQ(ismember(Index_IQ{:,'Date'},Index_IQ_Extra_Dates),:)=[];
end
  % Missing Dates:
Index_IQ_Missing_Dates=Index_BBG{(~ismember(Index_BBG{:,'Date'},Index_IQ{:,'Date'})),'Date'};
if ~isempty(Index_IQ_Missing_Dates)
       Missing_Dates_Days=weekday(Index_IQ_Missing_Dates)';
       Missing_Dates=datestr(Index_IQ_Missing_Dates);
       Missing_Dates=reshape(Missing_Dates',1,size(Missing_Dates,1)*size(Missing_Dates,2));
       Missing_Dates=strrep(Missing_Dates,'2017','2017 & ');
       Missing_Dates=strrep(Missing_Dates,'2016','2016 & ');
       Missing_Dates=Missing_Dates(1:end-3);
   uiwait(msgbox(sprintf('%s IQ Feed data has These MISSING Dates: \n %s \n that are the weekdays: %s',Asset_Name,Missing_Dates,num2str(Missing_Dates_Days))))
   Index_BBG(ismember(Index_BBG{:,'Date'},Index_IQ_Missing_Dates),:)=[];
end


% Changes/differences Table:
Diff_Table=Index_BBG;
%Index_IQ{:,2:end-1}=Index_IQ{:,2:end-1}./100;
Diff_Table{:,2:end}=Index_IQ{:,2:end}./Index_BBG{:,2:end}-1;

Tol_Vol=0.1; %Tolerence just for volume:
Max_Abs_Diff_Vol=max(abs(Diff_Table{:,'Volume'}));
if Max_Abs_Diff_Vol>Tol_Vol
   uiwait(msgbox(sprintf('Max_Abs_Diff_Vol = %d',Max_Abs_Diff_Vol))) 
end

Tol_OHLC=0.001;% 0.1 % %Tolerence for Open, High, Low, Close Prices: 
Max_Abs_Diff_OHLC=max(max(abs(Diff_Table{:,{'Open','High','Low','Close'}})));
if Max_Abs_Diff_OHLC>Tol_OHLC
   uiwait(msgbox(sprintf('Max_Abs_Diff_Vol = %d Percent',Max_Abs_Diff_OHLC.*100)))
else
   uiwait(msgbox(sprintf('All is fine \n Max_Abs_Diff_Vol = %d Percent',Max_Abs_Diff_OHLC.*100)))
end

