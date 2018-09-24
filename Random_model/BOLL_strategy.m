%% ��飺ϵͳ���ڲ���ͨ��ԭ����һ������׷��ϵͳ��
%  �볡������
%    ROC����0�Ҽ۸�ͻ�Ʋ��ִ��Ϲ�Ϳ���֣�
%    ROCС��0�Ҽ۸���Ʋ��ִ��¹�Ϳ��ղ֣�
%  �ؼ�������
%	 �����������Slip
%	 ���ִ���������BollLength��
%    ���ִ���׼��ı���Offset;
%    ROC��������ROCLength��
%    ����ֹ���㷨��������ExitLength;


%% --��ȡ����--
% data=csvread('/Users/Steven/Desktop/IF888(1����).csv',1,0,[1 0 1000 7]);
% StockName = '600036.ss';
% StartDate = today-500;
% EndDate = today;
% Freq = 'd';
% [DataYahoo, Date_datenum, Head]=YahooData(StockName, StartDate, EndDate, Freq);

% data=YahooData('600036.ss', today-200, today,'d');
load data.mat
Date=datenum(data(:,1));                %����ʱ��
Open=cell2mat(data(:,2));               %���̼�
High=cell2mat(data(:,3));               %��߼�
Low=cell2mat(data(:,4));                %��ͼ�
Close=cell2mat(data(:,5));              %���̼�
Volume=cell2mat(data(:,6));             %�ɽ���
OpenInterest=cell2mat(data(:,7));       %�ֲ���

% Date=datenum(data(:,1)); 
% Open=data(:,2);               %���̼�
% High=data(:,3);               %��߼�
% Low=data(:,4);                %��ͼ�
% Close=data(:,5);              %���̼�
% Volume=data(:,6);             %�ɽ���
% OpenInterest=data(:,7);       %�ֲ���

%% --���������������--

%���Բ���
Slip=2;                                      %����
BollLength=50;                               %�����߳���
Offset=1.25;                                 %�����߱�׼���
ROCLength=30;                                %ROC��������

%Ʒ�ֲ���
MinMove=0.2;                                    %��Ʒ����С�䶯��
PriceScale=1;                                 %��Ʒ�ļ�����λ
TradingUnits=10;                              %���׵�λ
Lots=1;                                       %��������
MarginRatio=0.07;                             %��֤����
TradingCost=0.0003;                           %���׷�����Ϊ�ɽ��������֮��
RiskLess=0.035;                               %�޷���������(�������ձ���ʱ��Ҫ)

%% --�������--

%���Ա���
UpperLine=zeros(length(data),1);               %�Ϲ�
LowerLine=zeros(length(data),1);               %�¹�
MidLine=zeros(length(data),1);                 %�м���
Std=zeros(length(data),1);                     %��׼������
RocValue=zeros(length(data),1);                %ROCֵ


%���׼�¼����
MyEntryPrice=zeros(length(data),1);            %�����۸�
MarketPosition=0;                              %��λ״̬��-1��ʾ���п�ͷ��0��ʾ�޳ֲ֣�1��ʾ���ж�ͷ
pos=zeros(length(data),1);                     %��¼��λ�����-1��ʾ���п�ͷ��0��ʾ�޳ֲ֣�1��ʾ���ж�ͷ
Type=zeros(length(data),1);                    %�������ͣ�1��ʾ��ͷ��-1��ʾ��ͷ
OpenPosPrice=zeros(length(data),1);            %��¼���ּ۸�
ClosePosPrice=zeros(length(data),1);           %��¼ƽ�ּ۸�
OpenPosNum=0;                                  %���ּ۸����
ClosePosNum=0;                                 %ƽ�ּ۸����
OpenDate=zeros(length(data),1);                %����ʱ��
CloseDate=zeros(length(data),1);               %ƽ��ʱ��
NetMargin=zeros(length(data),1);               %����
CumNetMargin=zeros(length(data),1);            %�ۼƾ���
RateOfReturn=zeros(length(data),1);            %������
CumRateOfReturn=zeros(length(data),1);         %�ۼ�������
CostSeries=zeros(length(data),1);              %��¼���׳ɱ�
BackRatio=zeros(length(data),1);               %��¼�ز����

%��¼�ʲ��仯����
LongMargin=zeros(length(data),1);              %��ͷ��֤��
ShortMargin=zeros(length(data),1);             %��ͷ��֤��
Cash=repmat(1e6,length(data),1);               %�����ʽ�,��ʼ�ʽ�Ϊ10W
DynamicEquity=repmat(1e6,length(data),1);      %��̬Ȩ��,��ʼ�ʽ�Ϊ10W
StaticEquity=repmat(1e6,length(data),1);       %��̬Ȩ��,��ʼ�ʽ�Ϊ10W

%% --���㲼�ִ���ROC--
[UpperLine,MidLine,LowerLine]=BOLL(Close,BollLength,Offset,0);
RocValue=ROC(Close,ROCLength);

%% --���Է���--

for i=BollLength:length(data)

    if MarketPosition==0
        LongMargin(i)=0;                            %��ͷ��֤��
        ShortMargin(i)=0;                           %��ͷ��֤��
        StaticEquity(i)=StaticEquity(i-1);          %��̬Ȩ��
        DynamicEquity(i)=StaticEquity(i);           %��̬Ȩ��
        Cash(i)=DynamicEquity(i);                   %�����ʽ�
    end
    if MarketPosition==1
        LongMargin(i)=Close(i)*Lots*TradingUnits*MarginRatio;
        StaticEquity(i)=StaticEquity(i-1);
        DynamicEquity(i)=StaticEquity(i)+(Close(i)-OpenPosPrice(OpenPosNum))*TradingUnits*Lots;
        Cash(i)=DynamicEquity(i)-LongMargin(i);
    end
    if MarketPosition==-1
        ShortMargin(i)=Close(i)*Lots*TradingUnits*MarginRatio;
        StaticEquity(i)=StaticEquity(i-1);
        DynamicEquity(i)=StaticEquity(i)+(OpenPosPrice(OpenPosNum)-Close(i))*TradingUnits*Lots;
        Cash(i)=DynamicEquity(i)-ShortMargin(i);
    end


    %����ģ��

    %����ͷ
    if MarketPosition~=1 && RocValue(i-1)>0 && High(i)>=UpperLine(i-1)   %��i-1,����δ������
        %ƽ�տ���
        if MarketPosition==-1
            MarketPosition=1;
            ShortMargin(i)=0;   %ƽ�պ��ͷ��֤��Ϊ0��
            MyEntryPrice(i)=UpperLine(i-1);
            if Open(i)>MyEntryPrice(i)    %�����Ƿ�����
                MyEntryPrice(i)=Open(i);
            end
            MyEntryPrice(i)=MyEntryPrice(i)+Slip*MinMove*PriceScale;%���ּ۸�(Ҳ��ƽ�ղֵļ۸�)
            ClosePosNum=ClosePosNum+1;
            ClosePosPrice(ClosePosNum)=MyEntryPrice(i);%��¼ƽ�ּ۸�
            CloseDate(ClosePosNum)=Date(i);%��¼ƽ��ʱ��
            OpenPosNum=OpenPosNum+1;
            OpenPosPrice(OpenPosNum)=MyEntryPrice(i);%��¼���ּ۸�
            OpenDate(OpenPosNum)=Date(i);%��¼����ʱ��
            Type(OpenPosNum)=1;   %����Ϊ��ͷ
            StaticEquity(i)=StaticEquity(i-1)+(OpenPosPrice(OpenPosNum-1)-ClosePosPrice(ClosePosNum))...
                *TradingUnits*Lots-OpenPosPrice(OpenPosNum-1)*TradingUnits*Lots*TradingCost...
                -ClosePosPrice(ClosePosNum)*TradingUnits*Lots*TradingCost;%ƽ�ղ�ʱ�ľ�̬Ȩ��
            DynamicEquity(i)=StaticEquity(i)+(Close(i)-OpenPosPrice(OpenPosNum))*TradingUnits*Lots; %ƽ�ղ�ʱ�Ķ�̬Ȩ��
        end
        %�ղֿ���
        if MarketPosition==0
            MarketPosition=1;
            MyEntryPrice(i)=UpperLine(i-1);
            if Open(i)>MyEntryPrice(i)    %�����Ƿ�����
                MyEntryPrice(i)=Open(i);
            end
            MyEntryPrice(i)=MyEntryPrice(i)+Slip*MinMove*PriceScale;%���ּ۸�
            OpenPosNum=OpenPosNum+1;
            OpenPosPrice(OpenPosNum)=MyEntryPrice(i);%��¼���ּ۸�
            OpenDate(OpenPosNum)=Date(i);%��¼����ʱ��
            Type(OpenPosNum)=1;   %����Ϊ��ͷ
            StaticEquity(i)=StaticEquity(i-1);
            DynamicEquity(i)=StaticEquity(i)+(Close(i)-OpenPosPrice(OpenPosNum))*TradingUnits*Lots;
        end
        LongMargin(i)=Close(i)*Lots*TradingUnits*MarginRatio;               %��ͷ��֤��
        Cash(i)=DynamicEquity(i)-LongMargin(i);
    end

    %����ͷ
    %ƽ�࿪��
    if MarketPosition~=-1 && RocValue(i-1)<0 && Low(i)<=LowerLine(i-1)
        if MarketPosition==1
            MarketPosition=-1;
            LongMargin(i)=0;     %ƽ����ͷ��֤��Ϊ0��
            MyEntryPrice(i)=LowerLine(i-1);
            if Open(i)<MyEntryPrice(i)
                MyEntryPrice(i)=Open(i);
            end
            MyEntryPrice(i)=MyEntryPrice(i)-Slip*MinMove*PriceScale;%���ּ۸�(Ҳ��ƽ��ֵļ۸�)
            ClosePosNum=ClosePosNum+1;
            ClosePosPrice(ClosePosNum)=MyEntryPrice(i);%��¼ƽ�ּ۸�
            CloseDate(ClosePosNum)=Date(i);%��¼ƽ��ʱ��
            OpenPosNum=OpenPosNum+1;
            OpenPosPrice(OpenPosNum)=MyEntryPrice(i);%��¼���ּ۸�
            OpenDate(OpenPosNum)=Date(i);%��¼����ʱ��
            Type(OpenPosNum)=-1;   %����Ϊ��ͷ
            StaticEquity(i)=StaticEquity(i-1)+(ClosePosPrice(ClosePosNum)-OpenPosPrice(OpenPosNum-1))...
                *TradingUnits*Lots-OpenPosPrice(OpenPosNum-1)*TradingUnits*Lots*TradingCost...
                -ClosePosPrice(ClosePosNum)*TradingUnits*Lots*TradingCost;%ƽ���ʱ�ľ�̬Ȩ��
            DynamicEquity(i)=StaticEquity(i)+(OpenPosPrice(OpenPosNum)-Close(i))*TradingUnits*Lots;%ƽ�ղ�ʱ�Ķ�̬Ȩ��
        end
        %�ղֿ���
        if MarketPosition==0
            MarketPosition=-1;
            MyEntryPrice(i)=LowerLine(i-1);
            if Open(i)<MyEntryPrice(i)
                MyEntryPrice(i)=Open(i);
            end
            MyEntryPrice(i)=MyEntryPrice(i)-Slip*MinMove*PriceScale;
            OpenPosNum=OpenPosNum+1;
            OpenPosPrice(OpenPosNum)=MyEntryPrice(i);
            OpenDate(OpenPosNum)=Date(i);%��¼����ʱ��
            Type(OpenPosNum)=-1;   %����Ϊ��ͷ
            StaticEquity(i)=StaticEquity(i-1);
            DynamicEquity(i)=StaticEquity(i)+(OpenPosPrice(OpenPosNum)-Close(i))*TradingUnits*Lots;
        end
        ShortMargin(i)=Close(i)*Lots*TradingUnits*MarginRatio;
        Cash(i)=DynamicEquity(i)-ShortMargin(i);
    end

    %������һ��Bar�гֲ֣��������̼�ƽ��
    if i==length(data)
        %ƽ��
        if MarketPosition==1
            MarketPosition=0;
            LongMargin(i)=0;
            ClosePosNum=ClosePosNum+1;
            ClosePosPrice(ClosePosNum)=Close(i);%��¼ƽ�ּ۸�
            CloseDate(ClosePosNum)=Date(i);%��¼ƽ��ʱ��
            StaticEquity(i)=StaticEquity(i-1)+(ClosePosPrice(ClosePosNum)-OpenPosPrice(OpenPosNum))...
                *TradingUnits*Lots-OpenPosPrice(OpenPosNum)*TradingUnits*Lots*TradingCost...
                -ClosePosPrice(ClosePosNum)*TradingUnits*Lots*TradingCost;%ƽ���ʱ�ľ�̬Ȩ�� 
            DynamicEquity(i)=StaticEquity(i);%�ղ�ʱ��̬Ȩ��;�̬Ȩ�����
            Cash(i)=DynamicEquity(i); %�ղ�ʱ�����ʽ���ڶ�̬Ȩ��
        end
        %ƽ��
        if MarketPosition==-1
            MarketPosition=0;
            ShortMargin(i)=0;
            ClosePosNum=ClosePosNum+1;
            ClosePosPrice(ClosePosNum)=Close(i);
            CloseDate(ClosePosNum)=Date(i);
            StaticEquity(i)=StaticEquity(i-1)+(OpenPosPrice(OpenPosNum)-ClosePosPrice(ClosePosNum))...
                *TradingUnits*Lots-OpenPosPrice(OpenPosNum)*TradingUnits*Lots*TradingCost...
                -ClosePosPrice(ClosePosNum)*TradingUnits*Lots*TradingCost;%ƽ�ղ�ʱ�ľ�̬Ȩ�� 
            DynamicEquity(i)=StaticEquity(i);%�ղ�ʱ��̬Ȩ��;�̬Ȩ�����
            Cash(i)=DynamicEquity(i); %�ղ�ʱ�����ʽ���ڶ�̬Ȩ��
        end
    end
    pos(i)=MarketPosition;
end

%% -��Ч����--

RecLength=ClosePosNum;%��¼���׳���

%�������������
for i=1:RecLength
    %���׳ɱ�(����+ƽ��)
    CostSeries(i)=OpenPosPrice(i)*TradingUnits*Lots*TradingCost+ClosePosPrice(i)*TradingUnits*Lots*TradingCost;

    %������
      %��ͷ����ʱ
    if Type(i)==1
        NetMargin(i)=(ClosePosPrice(i)-OpenPosPrice(i))*TradingUnits*Lots-CostSeries(i);
    end
      %��ͷ����ʱ
    if Type(i)==-1
        NetMargin(i)=(OpenPosPrice(i)-ClosePosPrice(i))*TradingUnits*Lots-CostSeries(i);
    end
    %������
    RateOfReturn(i)=NetMargin(i)/(OpenPosPrice(i)*TradingUnits*Lots*MarginRatio);
end

%�ۼƾ���
CumNetMargin=cumsum(NetMargin);

%�ۼ�������
CumRateOfReturn=cumsum(RateOfReturn);

%�س�����
for i=1:length(data)
    c=max(DynamicEquity(1:i));
    if c==DynamicEquity(i)
        BackRatio(i)=0;
    else
        BackRatio(i)=(DynamicEquity(i)-c)/c;
    end
end

%{
%��������
% Daily=Date(hour(Date)==9 & minute(Date)==0 & second(Date)==0);
% DailyEquity=DynamicEquity(hour(Date)==9 & minute(Date)==0 & second(Date)==0);
% DailyRet=tick2ret(DailyEquity);

DailyRet=tick2ret(DynamicEquity);
DailyRet=[0;DailyRet];

%��������
WeeklyNum=weeknum(Daily);     
Weekly=[Daily((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);Daily(end)];
WeeklyEquity=[DailyEquity((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyEquity(end)];
WeeklyRet=tick2ret(WeeklyEquity);

%��������
MonthNum=month(Daily);
Monthly=[Daily((MonthNum(1:end-1)-MonthNum(2:end))~=0);Daily(end)];
MonthlyEquity=[DailyEquity((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyEquity(end)];
MonthlyRet=tick2ret(MonthlyEquity);

%��������
YearNum=year(Daily);
Yearly=[Daily((YearNum(1:end-1)-YearNum(2:end))~=0);Daily(end)];
YearlyEquity=[DailyEquity((YearNum(1:end-1)-YearNum(2:end))~=0);DailyEquity(end)];
YearlyRet=tick2ret(YearlyEquity);
%}


%{

%% �Զ��������Ա���(�����excel) 
%% ������׻���
xlswrite('���Ա���.xls',{'ͳ��ָ��'},'���׻���','A1');
xlswrite('���Ա���.xls',{'ȫ������'},'���׻���','B1');
xlswrite('���Ա���.xls',{'��ͷ'},'���׻���','C1');
xlswrite('���Ա���.xls',{'��ͷ'},'���׻���','D1');

%������
ProfitTotal=sum(NetMargin);
ProfitLong=sum(NetMargin(Type==1));
ProfitShort=sum(NetMargin(Type==-1));
xlswrite('���Ա���.xls',{'������'},'���׻���','A2');
xlswrite('���Ա���.xls',ProfitTotal,'���׻���','B2');
xlswrite('���Ա���.xls',ProfitLong,'���׻���','C2');
xlswrite('���Ա���.xls',ProfitShort,'���׻���','D2');

%��ӯ��
WinTotal=sum(NetMargin(NetMargin>0));
ans=NetMargin(Type==1);
WinLong=sum(ans(ans>0));
ans=NetMargin(Type==-1);
WinShort=sum(ans(ans>0));
xlswrite('���Ա���.xls',{'��ӯ��'},'���׻���','A3');
xlswrite('���Ա���.xls',WinTotal,'���׻���','B3');
xlswrite('���Ա���.xls',WinLong,'���׻���','C3');
xlswrite('���Ա���.xls',WinShort,'���׻���','D3');

%�ܿ���
LoseTotal=sum(NetMargin(NetMargin<0));
ans=NetMargin(Type==1);
LoseLong=sum(ans(ans<0));
ans=NetMargin(Type==-1);
LoseShort=sum(ans(ans<0));
xlswrite('���Ա���.xls',{'�ܿ���'},'���׻���','A4');
xlswrite('���Ա���.xls',LoseTotal,'���׻���','B4');
xlswrite('���Ա���.xls',LoseLong,'���׻���','C4');
xlswrite('���Ա���.xls',LoseShort,'���׻���','D4');

%��ӯ��/�ܿ���
WinTotalDLoseTotal=abs(WinTotal/LoseTotal);
WinLongDLoseLong=abs(WinLong/LoseLong);
WinShortDLoseShort=abs(WinShort/LoseShort);
xlswrite('���Ա���.xls',{'��ӯ��/�ܿ���'},'���׻���','A5');
xlswrite('���Ա���.xls',WinTotalDLoseTotal,'���׻���','B5');
xlswrite('���Ա���.xls',WinLongDLoseLong,'���׻���','C5');
xlswrite('���Ա���.xls',WinShortDLoseShort,'���׻���','D5');

%��������
LotsTotal=length(Type(Type~=0))*Lots;
LotsLong=length(Type(Type==1))*Lots;
LotsShort=length(Type(Type==-1))*Lots;
xlswrite('���Ա���.xls',{'��������'},'���׻���','A7');
xlswrite('���Ա���.xls',LotsTotal,'���׻���','B7');
xlswrite('���Ա���.xls',LotsLong,'���׻���','C7');
xlswrite('���Ա���.xls',LotsShort,'���׻���','D7');

%ӯ������
LotsWinTotal=length(NetMargin(NetMargin>0))*Lots;
ans=NetMargin(Type==1);
LotsWinLong=length(ans(ans>0))*Lots;
ans=NetMargin(Type==-1);
LotsWinShort=length(ans(ans>0))*Lots;
xlswrite('���Ա���.xls',{'ӯ������'},'���׻���','A8');
xlswrite('���Ա���.xls',LotsWinTotal,'���׻���','B8');
xlswrite('���Ա���.xls',LotsWinLong,'���׻���','C8');
xlswrite('���Ա���.xls',LotsWinShort,'���׻���','D8');

%��������
LotsLoseTotal=length(NetMargin(NetMargin<0))*Lots;
ans=NetMargin(Type==1);
LotsLoseLong=length(ans(ans<0))*Lots;
ans=NetMargin(Type==-1);
LotsLoseShort=length(ans(ans<0))*Lots;
xlswrite('���Ա���.xls',{'��������'},'���׻���','A9');
xlswrite('���Ա���.xls',LotsLoseTotal,'���׻���','B9');
xlswrite('���Ա���.xls',LotsLoseLong,'���׻���','C9');
xlswrite('���Ա���.xls',LotsLoseShort,'���׻���','D9');

%��ƽ����
ans=NetMargin(Type==1);
LotsDrawLong=length(ans(ans==0))*Lots;
ans=NetMargin(Type==-1);
LotsDrawShort=length(ans(ans==0))*Lots;
LotsDrawTotal=LotsDrawLong+LotsDrawShort;
xlswrite('���Ա���.xls',{'��ƽ����'},'���׻���','A10');
xlswrite('���Ա���.xls',LotsDrawTotal,'���׻���','B10');
xlswrite('���Ա���.xls',LotsDrawLong,'���׻���','C10');
xlswrite('���Ա���.xls',LotsDrawShort,'���׻���','D10');

%ӯ������
LotsWinTotalDLotsTotal=LotsWinTotal/LotsTotal;
LotsWinLongDLotsLong=LotsWinLong/LotsLong;
LotsWinShortDLotsShort=LotsWinShort/LotsShort;
xlswrite('���Ա���.xls',{'ӯ������'},'���׻���','A11');
xlswrite('���Ա���.xls',LotsWinTotalDLotsTotal,'���׻���','B11');
xlswrite('���Ա���.xls',LotsWinLongDLotsLong,'���׻���','C11');
xlswrite('���Ա���.xls',LotsWinShortDLotsShort,'���׻���','D11');

%ƽ������
xlswrite('���Ա���.xls',{'ƽ������(������/��������)'},'���׻���','A13');
xlswrite('���Ա���.xls',ProfitTotal/LotsTotal,'���׻���','B13');
xlswrite('���Ա���.xls',ProfitLong/LotsLong,'���׻���','C13');
xlswrite('���Ա���.xls',ProfitShort/LotsShort,'���׻���','D13');

%ƽ��ӯ��
xlswrite('���Ա���.xls',{'ƽ��ӯ��(��ӯ�����/ӯ����������)'},'���׻���','A14');
xlswrite('���Ա���.xls',WinTotal/LotsWinTotal,'���׻���','B14');
xlswrite('���Ա���.xls',WinLong/LotsWinLong,'���׻���','C14');
xlswrite('���Ա���.xls',WinShort/LotsWinShort,'���׻���','D14');

%ƽ������
xlswrite('���Ա���.xls',{'ƽ������(�ܿ�����/����������)'},'���׻���','A15');
xlswrite('���Ա���.xls',LoseTotal/LotsLoseTotal,'���׻���','B15');
xlswrite('���Ա���.xls',LoseLong/LotsLoseLong,'���׻���','C15');
xlswrite('���Ա���.xls',LoseShort/LotsLoseShort,'���׻���','D15');

%ƽ��ӯ��/ƽ������
xlswrite('���Ա���.xls',{'ƽ��ӯ��/ƽ������'},'���׻���','A16');
xlswrite('���Ա���.xls',abs((WinTotal/LotsWinTotal)/(LoseTotal/LotsLoseTotal)),'���׻���','B16');
xlswrite('���Ա���.xls',abs((WinLong/LotsWinLong)/(LoseLong/LotsLoseLong)),'���׻���','C16');
xlswrite('���Ա���.xls',abs((WinShort/LotsWinShort)/(LoseShort/LotsLoseShort)),'���׻���','D16');

%���ӯ��
MaxWinTotal=max(NetMargin(NetMargin>0));
ans=NetMargin(Type==1);
MaxWinLong=max(ans(ans>0));
ans=NetMargin(Type==-1);
MaxWinShort=max(ans(ans>0));
xlswrite('���Ա���.xls',{'���ӯ��'},'���׻���','A18');
xlswrite('���Ա���.xls',MaxWinTotal,'���׻���','B18');
xlswrite('���Ա���.xls',MaxWinLong,'���׻���','C18');
xlswrite('���Ա���.xls',MaxWinShort,'���׻���','D18');

%������
MaxLoseTotal=min(NetMargin(NetMargin<0));
ans=NetMargin(Type==1);
MaxLoseLong=min(ans(ans<0));
ans=NetMargin(Type==-1);
MaxLoseShort=min(ans(ans<0));
xlswrite('���Ա���.xls',{'������'},'���׻���','A19');
xlswrite('���Ա���.xls',MaxLoseTotal,'���׻���','B19');
xlswrite('���Ա���.xls',MaxLoseLong,'���׻���','C19');
xlswrite('���Ա���.xls',MaxLoseShort,'���׻���','D19');

%���ӯ��/��ӯ��
xlswrite('���Ա���.xls',{'���ӯ��/��ӯ��'},'���׻���','A20');
xlswrite('���Ա���.xls',MaxWinTotal/WinTotal,'���׻���','B20');
xlswrite('���Ա���.xls',MaxWinLong/WinLong,'���׻���','C20');
xlswrite('���Ա���.xls',MaxWinShort/WinShort,'���׻���','D20');

%������/�ܿ���
xlswrite('���Ա���.xls',{'������/�ܿ���'},'���׻���','A21');
xlswrite('���Ա���.xls',MaxLoseTotal/LoseTotal,'���׻���','B21');
xlswrite('���Ա���.xls',MaxLoseLong/LoseLong,'���׻���','C21');
xlswrite('���Ա���.xls',MaxLoseShort/LoseShort,'���׻���','D21');

%������/������
xlswrite('���Ա���.xls',{'������/������'},'���׻���','A22');
xlswrite('���Ա���.xls',ProfitTotal/MaxLoseTotal,'���׻���','B22');
xlswrite('���Ա���.xls',ProfitLong/MaxLoseLong,'���׻���','C22');
xlswrite('���Ա���.xls',ProfitShort/MaxLoseShort,'���׻���','D22');

%���ʹ���ʽ�
xlswrite('���Ա���.xls',{'���ʹ���ʽ�'},'���׻���','A24');
xlswrite('���Ա���.xls',max(max(LongMargin),max(ShortMargin)),'���׻���','B24');
xlswrite('���Ա���.xls',max(LongMargin),'���׻���','C24');
xlswrite('���Ա���.xls',max(ShortMargin),'���׻���','D24');

%���׳ɱ��ϼ�
CostTotal=sum(CostSeries);
ans=CostSeries(Type==1);
CostLong=sum(ans);
ans=CostSeries(Type==-1);
CostShort=sum(ans);
xlswrite('���Ա���.xls',{'���׳ɱ��ϼ�'},'���׻���','A25');
xlswrite('���Ա���.xls',CostTotal,'���׻���','B25');
xlswrite('���Ա���.xls',CostLong,'���׻���','C25');
xlswrite('���Ա���.xls',CostShort,'���׻���','D25');

%����ʱ�䷶Χ
xlswrite('���Ա���.xls',{'����ʱ�䷶Χ'},'���׻���','F2');
xlswrite('���Ա���.xls',cellstr(strcat(datestr(Date(1),'yyyy-mm-dd HH:MM:SS'),'-',datestr(Date(end),'yyyy-mm-dd HH:MM:SS'))),'���׻���','G2');

%�ܽ���ʱ��
xlswrite('���Ա���.xls',{'��������'},'���׻���','F3');
xlswrite('���Ա���.xls',round(Date(end)-Date(1)),'���׻���','G3');

%�ֲ�ʱ�����
xlswrite('���Ա���.xls',{'�ֲ�ʱ�����'},'���׻���','F4');
xlswrite('���Ա���.xls',length(pos(pos~=0))/length(data),'���׻���','G4');

%�ֲ�ʱ��
xlswrite('���Ա���.xls',{'�ֲ�ʱ��(��)'},'���׻���','F5');
HoldingDays=round(round(Date(end)-Date(1))*(length(pos(pos~=0))/length(data)));%�ֲ�ʱ��
xlswrite('���Ա���.xls',HoldingDays,'���׻���','G5');

%������
xlswrite('���Ա���.xls',{'������(%)'},'���׻���','F7');
xlswrite('���Ա���.xls',(DynamicEquity(end)-DynamicEquity(1))/DynamicEquity(1)*100,'���׻���','G7');

%��Ч������
xlswrite('���Ա���.xls',{'��Ч������(%)'},'���׻���','F8');
TrueRatOfRet=(DynamicEquity(end)-DynamicEquity(1))/max(max(LongMargin),max(ShortMargin));
xlswrite('���Ա���.xls',TrueRatOfRet*100,'���׻���','G8');

%���������(��365����)
xlswrite('���Ա���.xls',{'�껯������(��365����,%)'},'���׻���','F9');
xlswrite('���Ա���.xls',(1+TrueRatOfRet)^(1/(HoldingDays/365))*100,'���׻���','G9');

%���������(��240����)
xlswrite('���Ա���.xls',{'���������(��240����,%)'},'���׻���','F10');
xlswrite('���Ա���.xls',(1+TrueRatOfRet)^(1/(HoldingDays/240))*100,'���׻���','G10');

% ���������(������)
xlswrite('���Ա���.xls',{'���������(������,%)'},'���׻���','F11');
xlswrite('���Ա���.xls',mean(DailyRet)*365*100,'���׻���','G11');

%���������(������)
xlswrite('���Ա���.xls',{'���������(������,%)'},'���׻���','F12');
xlswrite('���Ա���.xls',mean(WeeklyRet)*52*100,'���׻���','G12');

%���������(������)
xlswrite('���Ա���.xls',{'���������(������,%)'},'���׻���','F13');
xlswrite('���Ա���.xls',mean(MonthlyRet)*12*100,'���׻���','G13');

%���ձ���(������)
xlswrite('���Ա���.xls',{'���ձ���(������,%)'},'���׻���','F14');
xlswrite('���Ա���.xls',(mean(DailyRet)*365-RiskLess)/(std(DailyRet)*sqrt(365)),'���׻���','G14');

%���ձ���(������)
xlswrite('���Ա���.xls',{'���ձ���(������,%)'},'���׻���','F15');
xlswrite('���Ա���.xls',(mean(WeeklyRet)*52-RiskLess)/(std(WeeklyRet)*sqrt(52)),'���׻���','G15');

%���ձ���(������)
xlswrite('���Ա���.xls',{'���ձ���(������,%)'},'���׻���','F16');
xlswrite('���Ա���.xls',(mean(MonthlyRet)*12-RiskLess)/(std(MonthlyRet)*sqrt(12)),'���׻���','G16');

%���س�����
xlswrite('���Ա���.xls',{'���س�����(%)'},'���׻���','F17');
xlswrite('���Ա���.xls',abs(min(BackRatio))*100,'���׻���','G17');

%% ������׼�¼
xlswrite('���Ա���.xls',{'#'},'���׼�¼','A1');
xlswrite('���Ա���.xls',(1:RecLength)','���׼�¼','A2');
xlswrite('���Ա���.xls',{'����'},'���׼�¼','B1');
xlswrite('���Ա���.xls',Type(1:RecLength),'���׼�¼','B2');
xlswrite('���Ա���.xls',{'��Ʒ'},'���׼�¼','C1');
xlswrite('���Ա���.xls',cellstr(repmat(commodity,RecLength,1)),'���׼�¼','C2');
xlswrite('���Ա���.xls',{'����'},'���׼�¼','D1');
xlswrite('���Ա���.xls',cellstr(repmat(Freq,RecLength,1)),'���׼�¼','D2');
xlswrite('���Ա���.xls',{'����ʱ��'},'���׼�¼','E1');
xlswrite('���Ա���.xls',cellstr(datestr(OpenDate(1:RecLength),'yyyy-mm-dd HH:MM:SS')),'���׼�¼','E2');
xlswrite('���Ա���.xls',{'���ּ۸�'},'���׼�¼','F1');
xlswrite('���Ա���.xls',OpenPosPrice(1:RecLength),'���׼�¼','F2');
xlswrite('���Ա���.xls',{'ƽ��ʱ��'},'���׼�¼','G1');
xlswrite('���Ա���.xls',cellstr(datestr(CloseDate(1:RecLength),'yyyy-mm-dd HH:MM:SS')),'���׼�¼','G2');
xlswrite('���Ա���.xls',{'ƽ�ּ۸�'},'���׼�¼','H1');
xlswrite('���Ա���.xls',ClosePosPrice(1:RecLength),'���׼�¼','H2');
xlswrite('���Ա���.xls',{'����'},'���׼�¼','I1');
xlswrite('���Ա���.xls',repmat(Lots,RecLength,1),'���׼�¼','I2');
xlswrite('���Ա���.xls',{'���׳ɱ�'},'���׼�¼','J1');
xlswrite('���Ա���.xls',CostSeries(1:RecLength),'���׼�¼','J2');
xlswrite('���Ա���.xls',{'����'},'���׼�¼','K1');
xlswrite('���Ա���.xls',NetMargin(1:RecLength),'���׼�¼','K2');
xlswrite('���Ա���.xls',{'�ۼƾ���'},'���׼�¼','L1');
xlswrite('���Ա���.xls',CumNetMargin(1:RecLength),'���׼�¼','L2');
xlswrite('���Ա���.xls',{'������'},'���׼�¼','M1');
xlswrite('���Ա���.xls',RateOfReturn(1:RecLength),'���׼�¼','M2');
xlswrite('���Ա���.xls',{'�ۼ�������'},'���׼�¼','N1');
xlswrite('���Ա���.xls',CumRateOfReturn(1:RecLength),'���׼�¼','N2');

%% ����ʲ��仯
xlswrite('���Ա���.xls',{'�ʲ���Ҫ'},'�ʲ��仯','A1');
xlswrite('���Ա���.xls',{'����ʲ�'},'�ʲ��仯','A2');
xlswrite('���Ա���.xls',StaticEquity(1),'�ʲ��仯','A3');
xlswrite('���Ա���.xls',{'��ĩ�ʲ�'},'�ʲ��仯','B2');
xlswrite('���Ա���.xls',StaticEquity(end),'�ʲ��仯','B3');
xlswrite('���Ա���.xls',{'����ӯ��'},'�ʲ��仯','C2');
xlswrite('���Ա���.xls',sum(NetMargin),'�ʲ��仯','C3');
xlswrite('���Ա���.xls',{'����ʲ�'},'�ʲ��仯','D2');
xlswrite('���Ա���.xls',max(DynamicEquity),'�ʲ��仯','D3'); %����TB
xlswrite('���Ա���.xls',{'��С�ʲ�'},'�ʲ��仯','E2');
xlswrite('���Ա���.xls',min(DynamicEquity),'�ʲ��仯','E3');
xlswrite('���Ա���.xls',{'���׳ɱ��ϼ�'},'�ʲ��仯','F2');
xlswrite('���Ա���.xls',sum(CostSeries),'�ʲ��仯','F3');
xlswrite('���Ա���.xls',{'�ʲ��仯��ϸ'},'�ʲ��仯','A5');
xlswrite('���Ա���.xls',{'Bar#'},'�ʲ��仯','A6');
xlswrite('���Ա���.xls',(1:length(data))','�ʲ��仯','A7');
xlswrite('���Ա���.xls',{'ʱ��'},'�ʲ��仯','B6');
xlswrite('���Ա���.xls',cellstr(datestr(Date,'yyyy-mm-dd HH:MM:SS')),'�ʲ��仯','B7');
xlswrite('���Ա���.xls',{'��ͷ��֤��'},'�ʲ��仯','C6');
xlswrite('���Ա���.xls',LongMargin,'�ʲ��仯','C7');
xlswrite('���Ա���.xls',{'��ͷ��֤��'},'�ʲ��仯','D6');
xlswrite('���Ա���.xls',ShortMargin,'�ʲ��仯','D7');
xlswrite('���Ա���.xls',{'�����ʽ�'},'�ʲ��仯','E6');
xlswrite('���Ա���.xls',Cash,'�ʲ��仯','E7');
xlswrite('���Ա���.xls',{'��̬Ȩ��'},'�ʲ��仯','F6');
xlswrite('���Ա���.xls',DynamicEquity,'�ʲ��仯','F7');
xlswrite('���Ա���.xls',{'��̬Ȩ��'},'�ʲ��仯','G6');
xlswrite('���Ա���.xls',StaticEquity,'�ʲ��仯','G7');

%}

%% --ͼ�����--
%�������ִ�(����)
figure(1);
candle(High(end-150:end),Low(end-150:end),Open(end-150:end),Close(end-150:end),'r');
hold on;
plot([MidLine(end-150:end)],'k');
plot([UpperLine(end-150:end)],'g');
plot([LowerLine(end-150:end)],'g');
title('���ִ�(������)');
saveas(gcf,'1.���ִ�(������).png');
close all;

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
candle(High,Low,Close,Open,'r');
hold on;
plot([MidLine(end-50:end)],'k');
plot([UpperLine(end-50:end)],'g');
plot([LowerLine(end-50:end)],'g');
xlim( [0 length(Open)+1] );
title(StockName);

%����ӯ�����߼��ۼƳɱ�
figure(2);
subplot(2,1,1);
area(1:RecLength,CumNetMargin(1:RecLength),'FaceColor','g');
axis([1 RecLength min(CumNetMargin(1:RecLength)) max(CumNetMargin(1:RecLength))]);
xlabel('���״���');
ylabel('����ӯ��(Ԫ)');
title('����ӯ������');

subplot(2,1,2);
plot(CumNetMargin(1:RecLength),'r','LineWidth',2);
hold on;
plot(cumsum(CostSeries(1:RecLength)),'b','LineWidth',2);
axis([1 RecLength min(CumNetMargin(1:RecLength)) max(CumNetMargin(1:RecLength))]);
xlabel('���״���');
ylabel('����ӯ�����ɱ�(Ԫ)');
legend('����ӯ��','�ۼƳɱ�','Location','NorthWest');
hold off;
saveas(gcf,'2.����ӯ������.png');

%����ӯ���ֲ�ͼ
figure(3)
subplot(2,1,1);
ans=NetMargin(1:RecLength);%������͸������ò�ͬ����ɫ��ʾ
ans(ans<0)=0;
plot(ans,'r.');
hold on;
ans=NetMargin(1:RecLength);
ans(ans>0)=0;
plot(ans,'b.');
xlabel('ӯ��(Ԫ)');
ylabel('���״���');
title('����ӯ���ֲ�ͼ');

subplot(2,1,2);
hist(NetMargin(1:RecLength),50);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
xlabel('Ƶ��');
ylabel('ӯ������');
saveas(gcf,'3.����ӯ���ֲ�ͼ.png');


%Ȩ������
figure(4)
plot(Date,DynamicEquity,'r','LineWidth',2);
hold on;
area(Date,DynamicEquity,'FaceColor','g');
datetick('x',29);
axis([Date(1) Date(end) min(DynamicEquity) max(DynamicEquity)]);
xlabel('ʱ��');
ylabel('��̬Ȩ��(Ԫ)');
title('Ȩ������ͼ');
hold off;
saveas(gcf,'4.Ȩ������ͼ.png');


%��λ���ز����
figure(5);
subplot(2,1,1);
plot(Date,pos,'g');
datetick('x',29);
axis([Date(1) Date(end) min(pos) max(pos)]);
xlabel('ʱ��');
ylabel('��λ');
title('��λ״̬(1-��ͷ 0-���ֲ� -1-��ͷ)');

subplot(2,1,2);
plot(Date,BackRatio,'b');
datetick('x',29);
axis([Date(1) Date(end) min(BackRatio) max(BackRatio)]);
xlabel('ʱ��');
ylabel('�س�����');
title(strcat('�س���������ʼ�ʽ�Ϊ��',num2str(DynamicEquity(1)),'�����ֱ�����',num2str(max(max(LongMargin),max(ShortMargin))/DynamicEquity(1)*100),'%',...
    '����֤�������',num2str(MarginRatio*100),'%��'));
saveas(gcf,'5.��λ���ز����.png');


%��նԱ�
figure(6)
subplot(2,2,1);
pie3([LotsWinLong LotsLoseLong],[1 0],{strcat('��ͷӯ������:',num2str(LotsWinLong),'�֣�','ռ��:',num2str(LotsWinLong/(LotsWinLong+LotsLoseLong)*100),'%')...
    ,strcat('��ͷ��������:',num2str(LotsLoseLong),'�֣�','ռ��:',num2str(LotsLoseLong/(LotsWinLong+LotsLoseLong)*100),'%')});

subplot(2,2,2);
pie3([WinLong abs(LoseLong)],[1 0],{strcat('��ͷ��ӯ��:',num2str(WinLong),'Ԫ��','ռ��:',num2str(WinLong/(WinLong+abs(LoseLong))*100),'%')...
    ,strcat('��ͷ�ܿ���:',num2str(abs(LoseLong)),'Ԫ��','ռ��:',num2str(abs(LoseLong)/(WinLong+abs(LoseLong))*100),'%')});

subplot(2,2,3);
pie3([LotsWinShort LotsLoseShort],[1 0],{strcat('��ͷӯ������:',num2str(LotsWinShort),'�֣�','ռ��:',num2str(LotsWinShort/(LotsWinShort+LotsLoseShort)*100),'%')...
,strcat('��ͷ��������:',num2str(LotsLoseShort),'�֣�','ռ��:',num2str(LotsLoseShort/(LotsWinShort+LotsLoseShort)*100),'%')});

subplot(2,2,4);
pie3([WinShort abs(LoseShort)],[1 0],{strcat('��ͷ��ӯ��:',num2str(WinShort),'Ԫ��','ռ��:',num2str(WinShort/(WinShort+abs(LoseShort))*100),'%')...
    ,strcat('��ͷ�ܿ���:',num2str(abs(LoseShort)),'Ԫ��','ռ��:',num2str(abs(LoseShort)/(WinShort+abs(LoseShort))*100),'%')});
saveas(gcf,'6.��նԱȱ�ͼ.png');
%}


%% ���������ͳ��
figure(7);
subplot(2,2,1);
% bar(Daily(2:end),DailyRet,'r','EdgeColor','r');
bar(1:length(DailyRet),DailyRet,'r','EdgeColor','r');
datetick('x',29);
axis([min(Daily(2:end)) max(Daily(2:end)) min(DailyRet) max(DailyRet)]);
xlabel('ʱ��');
ylabel('��������');

subplot(2,2,2);
bar(Weekly(2:end),WeeklyRet,'r','EdgeColor','r');
datetick('x',29);
axis([min(Weekly(2:end)) max(Weekly(2:end)) min(WeeklyRet) max(WeeklyRet)]);
xlabel('ʱ��');
ylabel('��������');

subplot(2,2,3);
bar(Monthly(2:end),MonthlyRet,'r','EdgeColor','r');
datetick('x',28);
axis([min(Monthly(2:end)) max(Monthly(2:end)) min(MonthlyRet) max(MonthlyRet)]);
xlabel('ʱ��');
ylabel('��������');

subplot(2,2,4);
bar(Yearly(2:end),YearlyRet,'r','EdgeColor','r');
datetick('x',10);
axis([min(Yearly(2:end)) max(Yearly(2:end)) min(YearlyRet) max(YearlyRet)]);
xlabel('ʱ��');
ylabel('��������');
saveas(gcf,'7.���������ͳ��.png');
close all;
%}