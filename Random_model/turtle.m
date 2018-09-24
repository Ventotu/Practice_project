%% Turtle.M
% ���꽻�׷���
% ��Ҫ������
%     ? �г�----����ʲô������SVRǿ��������������˳��
% ����? ͷ���ģ----�������٣�����ATR�Լ����Գ�����Է��վ�����д���չ���
% ����? ����----��ʱ����������ͻ���źű�𷽷����������źţ������˻��ʽ�ˮƽ������ͷ�磬����û�п��ǵ����ٱ仯����Ļ��㡣
% ����? ֹ��----��ʱ�˳������ͷ�磬����ATR�͹̶���ʧˮƽ�趨������û�п��ǵ����ٱ仯����Ļ��㡣
% ����? ����----��ʱ�˳�Ӯ����ͷ�磬�����ض������ع顣
% ����? ����----����������˴�ֻ������4�ֲ��ԣ�����θ�ϸ�µ�ִ�иĲ�������û�п��ǵ����磺�����������ָ�긨��������Ż�����ʲ����õȡ�

% ˵���� 
% Ϊ��������˼·��һЩѭ����������ɸ���ѭ����Ӱ�����ٶȣ�������������ѧϰ�ͷ�����
% Ϊ�˸�Ϊ��ȷ�ķ����Ƶ���ݣ������趨��������Ϊ1�������ݡ����ԣ������ر�Ҫע����ǣ�����Ŀǰֻ�ܴ���ͬ������ʱ����г�Ʒ�֡�
% ��ô��֣�ݺʹ���(9:00-10:15 10:30-11:30 1:30-3:00)���Ϻ�(9:00-10��15 10��30-11��30 1��30-2��10  2��20-3��00)��֤ȯ�г�(9:30-11:30 1:00-3:00)�ͱ����ѿ����ˡ�
% ��Ϊ�޷����ƷǶԳ�ʱ�䴰���ڵķ��գ����Ժͳ�����ʱ�������չ���޸ġ�����������������ݣ��򲻴����κ������ˡ�

% ���ۣ�
% ������û��д��ǿ�����۳�����Ϊ�Ҿ����ҵ�˼·������ȫ�������ҵĳ����뷨�ǣ����������ˮƽ��������������ˮƽ�������£�
% ������ǻ���ѹ���ߣ���������ǿ��SVR�����������ģ����۸�����journal of Finance 2002, Andrew , and

%%  Controls %
clear  
clc
global EMA;
global Repeat
global Margin;
global Size;
global Account;
global Str1
global Str2
global CorrLev
global PosLim
global Freq
Freq= 1;           % �г����׳��ȣ����ӣ���������֣��=225 ���Ϻ�=215�� ֤ȯ=240
STRATEGY=1;          % ѡ��Ľ��ײ���,1 ����1��2 ����2�� 3 ǿ�������� d
EMA=20;              % ����ָ��ƽ���������� d
Repeat=1;            % ���ʱ��������һ��ATR D
Margin=ones(1,12);           % ������Ʒ�ֵı�֤���� 1��i , i �ʲ���������ƱΪ1
Size=100*ones(1,12);            % ������Ʒ�ֵĺ�Լ��ģ 1��i, ��ƱΪ100,ͭΪ5��etc��
Account=[100000000];          % ��ʼ�˻��ʽ� D
Str1_in=20;          % ����һ�������ڲ��� d
Str2_in=55;          % ���Զ��������ڲ��� d
Str1_out=10;         % ����һ�������ڲ��� d
Str2_out=20;         % ���Զ��������ڲ��� d

P_RSV= 50*Freq;      % ���ǿ��ָ��
CorrAdj=50*Freq;     % �г�����Ե���ʱ�䴰�ڳ��ȣ����ǵ��г�����ԵĲ��Գ��ԣ����뿼���µ�����ԣ������������������
CorrLev=[0.3 0.7];   % �����ˮƽʶ�𣬸�����Ϊ�߶�������г���������Ϊ�Ͷ�����г��� 1��2
PosLim=[4 6 8 10 12];  % �ֱ�Ϊ���г����߶���ء�һ����ء��Ͷ���ء������׳ֲ����� 1��5
HoldingPosition=[];  % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩 4����5��i)
LastPL=[];           % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
Balance=[];          % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��

%% ���ݳ�ʼ�����������

data=csvread('IF888_1����.csv');

[m n]=size(data);
Q=1;
Days=fix(m/Freq);

%{
N����TR��True Range��ʵ�ʷ�Χ����20��ָ���ƶ�ƽ�������ڸ��ձ�س�֮ΪATR��
N��ʾ����������ĳ���ض��г�����ɵļ۸񲨶���ƽ����Χ��
Nͬ���ù��ɺ�Լ�����ĵ㣨points�����ж�����
����ÿ��ʵ�ʷ�Χ�ļ��㣺
����TR��ʵ�ʷ�Χ��=max(H-L,H-PDC,PDC-L)
����ʽ�У�
����H-������߼�
����L-������ͼ�
����PDC-ǰ�������յ����̼�
����������Ĺ�ʽ����N��
����N=(19��PDN+TR)/20
����ʽ�У�
����PDN-ǰ�������յ�Nֵ
����TR-���յ�ʵ�ʷ�Χ
������Ϊ�����ʽҪ�õ�ǰ�������յ�Nֵ�����ԣ�������ʵ�ʷ�Χ��20�ռ�ƽ����ʼ�����ʼֵ��
%}

% ��Ҫ��ü���һ��Nֵ�͵�λ��С��һ��Ϊһ������һ�Σ���������ÿ�졣

NMatrix=zeros(Days,Q);
    
    O=data(1:Freq:Days*Freq,3);
    H=data(1:Freq:Days*Freq,4);
    L=data(1:Freq:Days*Freq,5);
    C=data(1:Freq:Days*Freq,6);
    V=data(1:Freq:Days*Freq,7);
    PDC=[C(1);C(1:end-1,:)];

    for j=1:Repeat:Days
        if j==1
            TR=max([H(j)-L(j) ,H(j)-PDC(j),PDC(j)-L(j)]);
            NMatrix(j,1)=TR;
        elseif j<EMA && j>1
            TR=max([H(j)-L(j) ,H(j)-PDC(j),PDC(j)-L(j)]);
            NMatrix(j,1)=((j-1)*NMatrix(j-1,1)+TR)/j;
        else
            TR=max([H(j)-L(j) ,H(j)-PDC(j),PDC(j)-L(j)]);
            NMatrix(j,1)=((EMA-1)*NMatrix(j-1,1)+TR)/EMA;
        end
    end


% save ATR NMatrix
DailyData=data(1:Freq:Days*Freq,:);

%{
 ��ֵ��������=N��ÿ���ֵ��
�����������Ƶĵ�λ��Units������ͷ�硣��λ���¼��㣬ʹ1N�����ʻ���ֵ��1%��
��Ϊ����ѵ�λ����ͷ���ģ�����Ȼ���������Ϊ��Щ��λ�Ѿ��������Է��յ��������ԣ���λ����ͷ����յ����ȱ�׼������ͷ������Ͷ����ϵ����ȱ�׼��
��λ=�ʻ���1%/(N��ÿ���ֵ��)
%}

HoldingPosition=zeros(4,5*Q);  % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,����ʱ�䣩 4����5��i)
LastPL=[0, 0, 0, 0, 0];        % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
Balance=repmat([Account ,0],m,1);          % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��

%% ���ײ�����ʽ��ʼ���ԣ�
% �������������ָ�ꡪ��RSV
RSV=50*ones(m,Q);
for i=1:Q
    O=data(:,i*5-4);H=data(:,i*5-3);L=data(:,i*5-2);C=data(:,i*5-1);
    RSV(:,i)=rsv(H,L,C,P_RSV);
end

PLI=zeros(3,Q);% ��һ�ο��ּ�λ�������Լ�ӯ�����ʾ��ָ�꣬ȷ�϶��ڿ����ź�Ҫ�õ���

    for j=max([Str1_in,Str2_in,Str1_out,Str2_out,P_RSV/Freq,CorrAdj/Freq])*Freq+1:Days*Freq
        Today=ceil(j/Freq); % ���������Ľ����գ�����ȡ��

        % ϵͳһ----��20��ͻ��Ϊ������ƫ����ϵͳ

        %{
        1,�����ֹ��
��������ֹ�𲢲���ζ�ź��������þ���������ʵ�ʵ�ֹ��ָ�
������Ϊ���������˴�����ͷ�磬���ԣ����ǲ�����Ϊ�þ���������ֹ��ָ���й¶���ǵ�ͷ������ǵĽ��ײ��ԡ�
    �෴�����Ǳ������趨ĳ����λ��һ���ﵽ�ü�λ�����Ǿͻ�ʹ���޼�ָ����м�ָ���˳�ͷ�硣
        2,�뿪�г�
    ϵͳһ���ж��ڶ�ͷͷ��Ϊ10����ͼۣ����ڿ�ͷͷ��Ϊ10����߼ۡ�����۸񲨶���ͷ�米����10��ͻ�ƣ�ͷ���е����е�λ�����˳���
        %}
        newlip=[0, 0, 0, inf,0]; % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿
        MarketValue=0; % ��ֵˮƽ��

        for i=1:Q
            O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);C=data(j,i*5-1);
            QuitL=min(DailyData(Today-Str1_out:Today-1,i*5-2));
            QuitH=max(DailyData(Today-Str1_out:Today-1,i*5-3));
            %             HoldingPosition=zeros(4,5*Q);  % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,����ʱ�䣩 4����5��i)
            if any(HoldingPosition(:,i*5-4)) % ��ʾ�е�λ�ĳֲַǿ�
                ii=find(HoldingPosition(:,i*5-3)~=0);
                for k=1:ii
                    if HoldingPosition(k,i*5-2)==1  % ��ͷ
                        if L<=HoldingPosition(k,i*5-1) % ֹ�𴥷�
                            %                             LastPL=[0, 0, 0, 0, 1];        % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
                            %                             Balance=[Account ,0];          % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��

                            newlip(1,1)=newlip(1,1)+(HoldingPosition(k,i*5-1)-HoldingPosition(k,i*5-4))*HoldingPosition(k,i*5-3); % ӯ��
                            newlip(1,2)=newlip(1,2)-HoldingPosition(k,i*5-3); % ��ͷ������
                            newlip(1,3)=newlip(1,3)+0;
                            newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                            newlip(1,5)=max([newlip(1,5),j]);
                            

                            HoldingPosition(k,i*5-4:i*5)=zeros(1,5);  % ��ԭ��λ
                            PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                            PLI(2,i)=1;  % ����
                            PLI(3,i)=-1; % �������
                        elseif L<=QuitL                % �˳�����
                            newlip(1,1)=newlip(1,1)+(HoldingPosition(k,i*5-1)-QuitL)*HoldingPosition(k,i*5-3); % ӯ��
                            newlip(1,2)=newlip(1,2)-HoldingPosition(k,i*5-3); % ��ͷ������
                            newlip(1,3)=newlip(1,3)+0;
                            newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                            newlip(1,5)=max([newlip(1,5),j]);

                            HoldingPosition(k,i*5-4:i*5)=zeros(1,5);  % ��ԭ��λ

                            PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                            PLI(2,i)=1;  % ����
                            if (HoldingPosition(k,i*5-1)-QuitL)*HoldingPosition(k,i*5-3)<0
                                PLI(3,i)=-1; % ����
                            else
                                PLI(3,i)=1;  % ӯ��
                            end

                        else
                        end

                    elseif  HoldingPosition(k,i*5-2)==-1     %��ͷ
                        if H>=HoldingPosition(k,i*5-1) % ֹ�𴥷�
                            %                             LastPL=[0, 0, 0, 0, 1];        % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
                            %                             Balance=[Account ,0];          % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��

                            newlip(1,1)=newlip(1,1) -(HoldingPosition(k,i*5-1)-HoldingPosition(k,i*5-4))*HoldingPosition(k,i*5-3); % ӯ��
                            newlip(1,2)=newlip(1,2)+0;
                            newlip(1,3)=newlip(1,3)-HoldingPosition(k,i*5-3);% ��ͷ������
                            newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                            newlip(1,5)=max([newlip(1,5),j]);

                            HoldingPosition(k,i*5-4:i*5)=zeros(1,5);  % ��ԭ��λ
                            PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                            PLI(2,i)=-1;  % ����
                            PLI(3,i)=-1;  % �������
                        elseif H>=QuitH                % �˳�����
                            newlip(1,1)=newlip(1,1) -(HoldingPosition(k,i*5-1)-QuitH)*HoldingPosition(k,i*5-3); % ӯ��
                            newlip(1,2)=newlip(1,2)+0;
                            newlip(1,3)=newlip(1,3)-HoldingPosition(k,i*5-3);% ��ͷ������
                            newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                            newlip(1,5)=max([newlip(1,5),j]);

                            HoldingPosition(k,i*5-4:i*5)=zeros(1,5);  % ��ԭ��λ

                            PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                            PLI(2,i)=-1;  % ����
                            if -(HoldingPosition(k,i*5-1)-QuitH)*HoldingPosition(k,i*5-3)<0
                                PLI(3,i)=-1; % ����
                            else
                                PLI(3,i)=1;  % ӯ��
                            end
                        else
                        end
                    else
                    end
                end
            end
        end

        % ����ƽ����ʷ��¼
        if newlip(1,1)~=0
            LastPL=[LastPL;newlip];
        end

        for i=1:Q
            O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);C=data(j,i*5-1);
            MarketValue=MarketValue+sum(HoldingPosition(:,i*5-3)*C);
        end

        % �����˻�������Ϣ
        Balance(j,:)=[Balance(j-1,1)+newlip(1,1), MarketValue];
        %%
        % �����źŲ�����ȷ���Լ��Ӳ��źŵ�ȷ��
        %{
      ����ϴ�ͻ���ѵ���Ӯ���Ľ��ף�ϵͳһ��ͻ�������źžͻᱻ���ӡ�ע�⣺Ϊ�˼���������⣬�ϴ�ͻ�Ʊ���Ϊĳ����Ʒ�����һ�ε�ͻ�ƣ�
      �����ܶ��Ǵ�ͻ���Ƿ�ʵ�ʱ����ܣ������������������ԡ������Ӯ����10������֮ǰ��ͻ����֮��ļ۸���ͷ�緽���෴������2N��
      ��ô����һͻ�ƾͻᱻ��Ϊʧ�ܵ�ͻ�ơ�
����  �ϴ�ͻ�Ƶķ�����������޹ء���ˣ�����Ķ�ͷͻ�ƻ����Ŀ�ͷͻ�ƽ�ʹ����µ�ͻ�Ʊ���Ϊ��Ч��ͻ�ƣ����������ķ�����Σ�����ͷ���ͷ����

      Ȼ�������ϵͳһ������ͻ��������ǰ�Ľ����Ѿ�ȡ��Ӯ���������ԣ���������55��ͻ��ʱ���У��Ա�������Ҫ�Ĳ�����
      ����55��ͻ�Ʊ���Ϊ�Զ�����ͻ�Ƶ㣨Failsafe Breakout point����

      ��Ʒ�����ʱ������˳�������ǿ��ָ��������жԱȡ�����ʱ����ǿ������ʱ��������
        %}

        RSV_j=RSV(j,:);
        [s sr]= sort(RSV_j,'descend'); % ��ôӴ�С����
        [s2 sr2]= sort(RSV_j);           % ��ô�С��������

        % ���ȶԲ�λ�ͷ���ˮƽ��һ�����㡣
        % ����ˮƽ�����������ˮƽ�����Ǹ����㡣
        % ����Ҫ�Ѽ۸�����ת���������ʡ�
        MCorr=[]; % ����غ� �����
        
        % Ϊ���ܹ�����һ��Ʒ�֣�����������Ҫ����һ���ж���������������ؾ�����������
        if Q>1
            for i=1:Q-1
                for k=i+1
                    Ci=data(j-CorrAdj:j,i*5-1); Ck=data(j-CorrAdj:j,k*5-1);
                    ri=diff(log(Ci)); rk=diff(log(Ck));
                    [corrxy] = exceedence_corr(ri,rk,0,0); % ��ֵ���ҵ������<0 ;>0
                    MCorr=[MCorr,corrxy];
                end
            end
            MCorr=mean(MCorr,2);
            
            
            % ������տ��ƣ��۲��µ�����Է���
            if MCorr(1,1)<= CorrLev(1,1)
                CB=PosLim(1,4);
            elseif MCorr(1,1)>= CorrLev(1,2)
                CB=PosLim(1,2);
            else
                CB=PosLim(1,3);
            end
            
            
            % ���շ��տ��ƣ��۲���������Է���
            if MCorr(2,1)<= CorrLev(1,1)
                CS=PosLim(1,4);
            elseif MCorr(2,1)>= CorrLev(1,2)
                CS=PosLim(1,2);
            else
                CS=PosLim(1,3);
            end
        else
            CB=PosLim(1,1);
            CS=PosLim(1,1);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ��ͳ������ʣ����̿���
        %{
���ͷ������Ϊ��
��������        ����            ���λ
����1        ��һ�г�           4����λ
����2      �߶�����г�         6����λ
    3      һ����ض��г�       8����λ
����4      �Ͷ�����г�         10����λ
����5   �����ס���ͷ���ͷ    12����λ
���ֹ������ݶ�Ϊ2N���Ե����׶��ԣ�һ����ϵͳ�е���������Ϊ-24%
        %}
        BQ=0; % ��λ�� buy quantity
        SQ=0; % ����λ��
        for i=1:Q
            for k=1:4
                if HoldingPosition(k,i*5-3)~=0 && HoldingPosition(k,i*5-2)==1
                    BQ=BQ+1;
                end
                if HoldingPosition(k,i*5-3)~=0 && HoldingPosition(k,i*5-2)==-1
                    SQ=SQ+1;
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ���ݷ��տ��Ƹ�����ڻ�������������յĵ�λ���ֱ�Ϊ��
        PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;  % permit buy,����Է����¿��������ٲ��ֶԳ壬���ܵ���ֲֲ����ҹ�һ���޶ȡ�
        PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;  % permit sell

        for ll=1:Q
            if PB>0 % ��ʣ��ͷ��
                i=sr(ll); % ���ȴ�RSV���Ŀ�ʼ
                O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);
                EnterL=min(DailyData(Today-Str1_in:Today-1,i*5-2));
                EnterH=max(DailyData(Today-Str1_in:Today-1,i*5-3));
                N= NMatrix(Today-1,i);
                ValuePerPoint=N*Size(i)/Margin(i); % һ�ֲ���ȫ����ʧ��ֵ��ֵ
                VN= fix(0.01*sum(Balance(j-1,:))/ValuePerPoint); % ÿ����׼���յ�λ
                PriceVN_B=VN*H*Margin(i)*Size(i); % ����ÿ�������ʽ�
                if H>=EnterH
                    if PLI(2,i)==-1 || PLI(3,i)==-1 || PLI(2,i)==1 && PLI(1,i)-EnterL>=2*N || H>= max(DailyData(Today-Str2_in:Today-1,i*5-3))
                        % �ϴν���Ϊ���� ���ϴν��׿��� �� �ϴν���Ҳ�����࣬��������λ������һ����͵�û�г���2N
                        if HoldingPosition(1,i*5-3)==0
                            % ��λ�Դ���
                            if Balance(j-1,1)>PriceVN_B
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(1,i*5-4)=(EnterH);
                                HoldingPosition(1,i*5-3)=(VN);
                                HoldingPosition(1,i*5-2)=(1);
                                HoldingPosition(1,i*5-1)=(EnterH-2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(1,i*5)=(j);

                                HoldingPosition(2:4,i*5-4:i*5)=zeros;

                                Balance(j,1)=Balance(j-1,1)-PriceVN_B; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_B;

                                BQ=BQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end

                            %{
                        Ϊ�˱�֤ȫ��ͷ��ķ�����С������������ӵ�λ��ǰ�浥λ��ֹ������1/2N��
                        ��һ����ζ��ȫ��ͷ���ֹ�𽫱������ھ�������ӵĵ�λ��2N����

                        Ȼ�����ں��浥λ���г�����̫����ɡ��򻬣�skid���������������ն��Խϴ�ļ�����õ�����£�ֹ���������ͬ��
                            %}
                        elseif  HoldingPosition(1,i*5-3)~=0 && HoldingPosition(2,i*5-3)==0 && H>=HoldingPosition(1,i*5-4)+0.5*N
                            if Balance(j-1,1)>PriceVN_B
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(2,i*5-4)=(HoldingPosition(1,i*5-4)+0.5*N);
                                HoldingPosition(2,i*5-3)=(VN);
                                HoldingPosition(2,i*5-2)=(1);
                                HoldingPosition(2,i*5-1)=(HoldingPosition(2,i*5-4)-2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(2,i*5)=(j);

                                HoldingPosition(1,i*5-1)=(HoldingPosition(1,i*5-4)-2*N+0.5*N); %% ֹ��ˮƽ���
                                HoldingPosition(3:4,i*5-4:i*5)=zeros;

                                Balance(j,1)=Balance(j-1,1)-PriceVN_B; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_B;

                                BQ=BQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end
                        elseif  HoldingPosition(2,i*5-3)~=0 && HoldingPosition(3,i*5-3)==0 && H>=HoldingPosition(2,i*5-4)+0.5*N
                            if Balance(j-1,1)>PriceVN_B
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(3,i*5-4)=(HoldingPosition(2,i*5-4)+0.5*N);
                                HoldingPosition(3,i*5-3)=(VN);
                                HoldingPosition(3,i*5-2)=(1);
                                HoldingPosition(3,i*5-1)=(HoldingPosition(3,i*5-4)-2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(3,i*5)=(j);

                                HoldingPosition(1,i*5-1)=(HoldingPosition(1,i*5-4)-2*N+N); %% ֹ��ˮƽ���
                                HoldingPosition(2,i*5-1)=(HoldingPosition(2,i*5-4)-2*N+0.5*N); %% ֹ��ˮƽ���
                                HoldingPosition(4,i*5-4:i*5)=zeros;

                                Balance(j,1)=Balance(j-1,1)-PriceVN_B; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_B;

                                BQ=BQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end
                        elseif  HoldingPosition(3,i*5-3)~=0 && HoldingPosition(4,i*5-3)==0 && H>=HoldingPosition(3,i*5-4)+0.5*N
                            if Balance(j-1,1)>PriceVN_B
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(4,i*5-4)=(HoldingPosition(3,i*5-4)+0.5*N);
                                HoldingPosition(4,i*5-3)=(VN);
                                HoldingPosition(4,i*5-2)=(1);
                                HoldingPosition(4,i*5-1)=(HoldingPosition(4,i*5-4)-2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(4,i*5)=(j);

                                HoldingPosition(1,i*5-1)=(HoldingPosition(1,i*5-4)-2*N+1.5*N); %% ֹ��ˮƽ���
                                HoldingPosition(2,i*5-1)=(HoldingPosition(2,i*5-4)-2*N+1*N); %% ֹ��ˮƽ���
                                HoldingPosition(3,i*5-1)=(HoldingPosition(3,i*5-4)-2*N+0.5*N); %% ֹ��ˮƽ���

                                Balance(j,1)=Balance(j-1,1)-PriceVN_B; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_B;

                                BQ=BQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end
                        else
                        end
                    end
                else
                end
            end

            if  PS>0
                i=sr2(ll); % ���ȴ�RSV��С�Ŀ�ʼ
                O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);C=data(j,i*5-1);
                EnterL=min(DailyData(Today-Str1_in:Today-1,i*5-2));
                EnterH=max(DailyData(Today-Str1_in:Today-1,i*5-3));
                N= NMatrix(Today-1,i);
                ValuePerPoint=N*Size(i)/Margin(i); % һ�ֲ���ȫ����ʧ��ֵ��ֵ
                VN= fix(0.01*sum(Balance(j-1,:))/ValuePerPoint); % ÿ����׼���յ�λ
                PriceVN_S=VN*L*Margin(i)*Size(i); % ����ÿ�������ʽ�
                if L<=EnterL
                    if PLI(2,i)==1 || PLI(3,i)==-1 || PLI(2,i)==-1 && EnterH -PLI(1,i)>=2*N || L<=min(DailyData(Today-Str2_in:Today-1,i*5-2));
                        % �ϴν���Ϊ���� ���ϴν��׿��� �� �ϴν���Ҳ�����գ���������λ������һ����ߵ�û�г���2N
                        if HoldingPosition(1,i*5-3)==0
                            % ��λ�Դ���
                            if Balance(j-1,1)>PriceVN_S
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(1,i*5-4)=(EnterL);
                                HoldingPosition(1,i*5-3)=(VN);
                                HoldingPosition(1,i*5-2)=(-1);
                                HoldingPosition(1,i*5-1)=(EnterL+2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(1,i*5)=(j);

                                HoldingPosition(2:4,i*5-4:i*5)=zeros;

                                Balance(j,1)=Balance(j-1,1)-PriceVN_S; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_S;

                                SQ=SQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end

                            %{
                        Ϊ�˱�֤ȫ��ͷ��ķ�����С������������ӵ�λ��ǰ�浥λ��ֹ������1/2N��
                        ��һ����ζ��ȫ��ͷ���ֹ�𽫱������ھ�������ӵĵ�λ��2N����
                        Ȼ�����ں��浥λ���г�����̫����ɡ��򻬣�skid���������������ն��Խϴ�ļ�����õ�����£�ֹ���������ͬ��
                            %}
                        elseif  HoldingPosition(1,i*5-3)~=0 && HoldingPosition(2,i*5-3)==0 && L<=HoldingPosition(1,i*5-4)-0.5*N
                            if Balance(j-1,1)>PriceVN_S
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(2,i*5-4)=(HoldingPosition(1,i*5-4)-0.5*N);
                                HoldingPosition(2,i*5-3)=(VN);
                                HoldingPosition(2,i*5-2)=(-1);
                                HoldingPosition(2,i*5-1)=(HoldingPosition(2,i*5-4)+2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(2,i*5)=(j);

                                HoldingPosition(1,i*5-1)=(HoldingPosition(1,i*5-4)+2*N-0.5*N); %% ֹ��ˮƽ���
                                HoldingPosition(3:4,i*5-4:i*5)=zeros;

                                Balance(j,1)=Balance(j-1,1)-PriceVN_S; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_S;

                                SQ=SQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end
                        elseif  HoldingPosition(2,i*5-3)~=0 && HoldingPosition(3,i*5-3)==0 && L<=HoldingPosition(2,i*5-4)-0.5*N
                            if Balance(j-1,1)>PriceVN_S
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(3,i*5-4)=(HoldingPosition(2,i*5-4)-0.5*N);
                                HoldingPosition(3,i*5-3)=(VN);
                                HoldingPosition(3,i*5-2)=(-1);
                                HoldingPosition(3,i*5-1)=(HoldingPosition(3,i*5-4)+2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(3,i*5)=(j);

                                HoldingPosition(1,i*5-1)=(HoldingPosition(1,i*5-4)+2*N-N); %% ֹ��ˮƽ���
                                HoldingPosition(2,i*5-1)=(HoldingPosition(2,i*5-4)+2*N-0.5*N); %% ֹ��ˮƽ���
                                HoldingPosition(4,i*5-4:i*5)=zeros;

                                Balance(j,1)=Balance(j-1,1)-PriceVN_S; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_S;

                                SQ=SQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end
                        elseif  HoldingPosition(3,i*5-3)~=0 && HoldingPosition(4,i*5-3)==0 && L<=HoldingPosition(3,i*5-4)-0.5*N
                            if Balance(j-1,1)>PriceVN_S
                                % % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩
                                % 4����5��i)
                                HoldingPosition(4,i*5-4)=(HoldingPosition(3,i*5-4)-0.5*N);
                                HoldingPosition(4,i*5-3)=(VN);
                                HoldingPosition(4,i*5-2)=(-1);
                                HoldingPosition(4,i*5-1)=(HoldingPosition(4,i*5-4)-2*N); %% ע��Ԥ��2��ֹ��
                                HoldingPosition(4,i*5)=(j);

                                HoldingPosition(1,i*5-1)=(HoldingPosition(1,i*5-4)+2*N-1.5*N); %% ֹ��ˮƽ���
                                HoldingPosition(2,i*5-1)=(HoldingPosition(2,i*5-4)+2*N-1*N); %% ֹ��ˮƽ���
                                HoldingPosition(3,i*5-1)=(HoldingPosition(3,i*5-4)+2*N-0.5*N); %% ֹ��ˮƽ���

                                Balance(j,1)=Balance(j-1,1)-PriceVN_S; % �ʽ��˻���ת
                                Balance(j,2)=Balance(j-1,2)+PriceVN_S;

                                SQ=SQ+1; % ��������λ����
                                PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ;
                                PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ;
                            end
                        else
                        end
                    end
                else
                end
            end
        end
    end
    sign=unique(LastPL(2:end,4:5));
    save sign.mat sign
    
    

    
    
