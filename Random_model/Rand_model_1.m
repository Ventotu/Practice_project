clear
clc
%% --��ȡ����--
commodity = 'IF888';
Freq = 'M1';
load sign.mat
data=csvread('IF888_1����.csv');
date=data(:,1);
date1=unique(date);
for i=1:length(date)
    for j=1:length(date1)
        if date(i)==date1(j)
            date(i)=j;
            break;
        end
    end
end
data(:,1)=date;


Date=data(:,1);               %��������
Time=data(:,2);               %ʱ������
Open=data(:,3);
Close=data(:,6);

%% --���������������--

%���Բ���
Slip=2;                                      %����
Daymin=270;

%Ʒ�ֲ���
MinMove=0.2;                                  %��Ʒ����С�䶯��
PriceScale=10;                                 %��Ʒ�ļ�����λ
TradingUnits=1;                              %���׵�λ
Lots=1;                                       %��������
MarginRatio=0.07;                             %��֤����
TradingCost=0.0003;                           %���׷�����Ϊ�ɽ��������֮��
RiskLess=0.035;                               %�޷���������(�������ձ���ʱ��Ҫ)
a=30;
b=10;
c=10;

%% --�������--

%���Ա���

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
Cash=repmat(1e6,length(data),1);               %�����ʽ�,��ʼ�ʽ�Ϊ100W
DynamicEquity=repmat(1e6,length(data),1);      %��̬Ȩ��,��ʼ�ʽ�Ϊ100W
StaticEquity=repmat(1e6,length(data),1);       %��̬Ȩ��,��ʼ�ʽ�Ϊ100W

%% --���Է���--
barry=inf;
for i=1:lenth(sign)
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
  
  if i<barry
    continue;
  end
  
  if MarketPosition==0 && rand>=0.5
    MarketPosition=1;
    MyEntryPrice(i)=Close(i);
    MyEntryPrice(i)=MyEntryPrice(i)+Slip*MinMove*PriceScale;%���ּ۸�
    OpenPosNum=OpenPosNum+1;
    OpenPosPrice(OpenPosNum)=MyEntryPrice(i);%��¼���ּ۸�
    OpenDate(OpenPosNum)=Date(i);%��¼����ʱ��
    Type(OpenPosNum)=1;   %����Ϊ��ͷ
    StaticEquity(i)=StaticEquity(i-1);
    DynamicEquity(i)=StaticEquity(i)+(Close(i)-OpenPosPrice(OpenPosNum))*TradingUnits*Lots;
    LongMargin(i)=Close(i)*Lots*TradingUnits*MarginRatio;               %��ͷ��֤��
    Cash(i)=DynamicEquity(i)-LongMargin(i);
  elseif MarketPosition==0 && rand<0.5
    MarketPosition=-1;
    MyEntryPrice(i)=Close(i);
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
    ShortMargin(i)=Close(i)*Lots*TradingUnits*MarginRatio;
    Cash(i)=DynamicEquity(i)-ShortMargin(i);
  end

  if MarketPosition~=0 
    MarketPosition=0;
    ShortMargin(i)=0;   %ƽ�պ��ͷ��֤��Ϊ0��
    LongMargin(i)=0; 
    MyEntryPrice(i+a)=Close(i+a);
    MyEntryPrice(i+a)=MyEntryPrice(i+a)+Slip*MinMove*PriceScale;%���ּ۸�(Ҳ��ƽ�ղֵļ۸�)
    ClosePosNum=ClosePosNum+1;
    ClosePosPrice(ClosePosNum)=MyEntryPrice(i+a);%��¼ƽ�ּ۸�
    CloseDate(ClosePosNum)=Date(i+a);%��¼ƽ��ʱ��
    barry=i+a;
  end
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

%��������
LotsTotal=length(Type(Type~=0))*Lots;
LotsLong=length(Type(Type==1))*Lots;
LotsShort=length(Type(Type==-1))*Lots;

%��ӯ��
WinTotal=sum(NetMargin(NetMargin>0));
ans=NetMargin(Type==1);
WinLong=sum(ans(ans>0));
ans=NetMargin(Type==-1);
WinShort=sum(ans(ans>0));

%�ܿ���
LoseTotal=sum(NetMargin(NetMargin<0));
ans=NetMargin(Type==1);
LoseLong=sum(ans(ans<0));
ans=NetMargin(Type==-1);
LoseShort=sum(ans(ans<0));

%��ӯ��/�ܿ���
WinTotalDLoseTotal=abs(WinTotal/LoseTotal);
WinLongDLoseLong=abs(WinLong/LoseLong);
WinShortDLoseShort=abs(WinShort/LoseShort);

%ӯ������
LotsWinTotal=length(NetMargin(NetMargin>0))*Lots;
ans=NetMargin(Type==1);
LotsWinLong=length(ans(ans>0))*Lots;
ans=NetMargin(Type==-1);
LotsWinShort=length(ans(ans>0))*Lots;

%��������
LotsLoseTotal=length(NetMargin(NetMargin<0))*Lots;
ans=NetMargin(Type==1);
LotsLoseLong=length(ans(ans<0))*Lots;
ans=NetMargin(Type==-1);
LotsLoseShort=length(ans(ans<0))*Lots;

%��ƽ����
ans=NetMargin(Type==1);
LotsDrawLong=length(ans(ans==0))*Lots;
ans=NetMargin(Type==-1);
LotsDrawShort=length(ans(ans==0))*Lots;
LotsDrawTotal=LotsDrawLong+LotsDrawShort;

%ӯ������
LotsWinTotalDLotsTotal=LotsWinTotal/LotsTotal;
LotsWinLongDLotsLong=LotsWinLong/LotsLong;
LotsWinShortDLotsShort=LotsWinShort/LotsShort;


%% --ͼ�����--

%Ȩ������
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
plot(Date,DynamicEquity,'r','LineWidth',2);
hold on;
axis([Date(1) Date(end) min(DynamicEquity) max(DynamicEquity)]);
xlabel('ʱ��');
ylabel('��̬Ȩ��(Ԫ)');
title('Ȩ������ͼ');



%��նԱ�
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
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
