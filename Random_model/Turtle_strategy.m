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
Freq= 240; % �г����׳��ȣ����ӣ���������֣��=225 ���Ϻ�=215�� ֤ȯ=240
STRATEGY=2; % ѡ��Ľ��ײ���,1 ����1��2 ����2�� 3 ǿ��������
EMA=20; % ����ָ��ƽ����������
Repeat=1; % ���ʱ��������һ��ATR D
Margin=[0.05 0.05 0.07 1]; % ������Ʒ�ֵı�֤���� 1��i , i �ʲ���������ƱΪ1
Size= [5 5 8 1]; % ������Ʒ�ֵĺ�Լ��ģ 1��i, ��ƱΪ1
Account=[100000000]; % ��ʼ�˻��ʽ� D
Str1_in=20; % ����һ�������ڲ���
Str2_in=55; % ���Զ��������ڲ���
Str1_out=10; % ����һ�������ڲ���
Str2_out=20; % ���Զ��������ڲ���

P_RSV= 30*Freq; % ���ǿ��ָ��
CorrAdj=30*Freq; % �г�����Ե���ʱ�䴰�ڳ��ȣ����ǵ��г�����ԵĲ��Գ��ԣ����뿼���µ�����ԣ������������������
CorrLev=[0.3 0.7]; % �����ˮƽʶ�𣬸�����Ϊ�߶�������г���������Ϊ�Ͷ�����г��� 1��2
PosLim=[4 6 8 10 12]; % �ֱ�Ϊ���г����߶���ء�һ����ء��Ͷ���ء������׳ֲ����� 1��5
HoldingPosition=[]; % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,,����ʱ�䣩 4����5��i)
LastPL=[]; % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
Balance=[]; % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��
% Load your own data? into matrix "dat"

%% ���ݳ�ʼ�����������
load data;
%{
����������ȷ���ܹ����뽻�׵��ڻ�Ʒ�ֵ���Ҫ��׼���ǹ����г������������ԡ�
ÿһ��Ʒ�֣�����Ҫ��������¼���ָ�꣺������ ���͡��ա���
%}

[m n]=size(data);
if round(n/5)~=n/5 || (m/Freq)<=max([Str1 Str2 20]) || length(Margin)~=length(Size) || length(Margin)~=n/5
    error('����������ݸ�ʽ���������ǵ�Ҫ�������º˶���������')
end

Q=n/5;
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
for i=1:Q
    O=data(1:Freq:Days*Freq,i*5-4);H=data(1:Freq:Days*Freq,i*5-3);L=data(1:Freq:Days*Freq,i*5-2);C=data(1:Freq:Days*Freq,i*5-1);
    V=data(1:Freq:Days*Freq,i*5);PDC=[0;C(1:end-1,:)];
    
    % ��������ͼ����
    cndl(O,H,L,C);
    title('Figure ����ͼ ');
    ylabel('�۸�ˮƽ');
    xlabel('�۲�����');
    grid on;
    saveas(gcf,strcat('Candle_',num2str(i),'.eps'),'psc2');
    
    for j=1:Repeat:Days
        if j==1
            TR=max([H(j)-L(j)]);
            NMatrix(i,j)=TR;
        elseif j<EMA && j>1
            TR=max([H(j)-L(j) ,H(j)-PDC(j),PDC(j)-L(j)]);
            NMatrix(i,j)=((j-1)*NMatrix(i,j-1)+TR)/j;
        else
            TR=max([H(j)-L(j) ,H(j)-PDC(j),PDC(j)-L(j)]);
            NMatrix(i,j)=((EMA-1)*NMatrix(i,j-1)+TR)/EMA;
        end
    end
end

DailyData=data(1:Freq:Days*Freq,:);

%{
��ֵ��������=N��ÿ���ֵ��
�����������Ƶĵ�λ��Units������ͷ�硣��λ���¼��㣬ʹ1N�����ʻ���ֵ��1%��
��Ϊ����ѵ�λ����ͷ���ģ�����Ȼ���������Ϊ��Щ��λ�Ѿ��������Է��յ��������ԣ���λ����ͷ����յ����ȱ�׼������ͷ������Ͷ����ϵ����ȱ�׼��
��λ=�ʻ���1%/(N��ÿ���ֵ��)
%}

VN=zeros(Days,Q); %������λ��ֵ��,���䵥λ

% ˵�����˶α�ʡ������Ϊ�ں�������˸�Ϊ��ȷ�ķ����ʽ��㷨
% for i=1:Q
% for j=1:Days
% % �������׹�ģ�����겻ʹ������ʼ��ֵΪ�����ġ���������ı�׼�ʻ����н��ס����Ǽ����˻�ÿ���ȵ���һ�Ρ�ӯ����𣬿������ע�⣬�˴�
% % ����ȷ��û�п���P&L���ʽ��Ӱ�졣
% ValuePerPoint=N(i,j)*Size(i)/Margin(i); % һ�ֲ���ȫ����ʧ��ֵ��ֵ
% VN(i,j)=fix((0.01*Account)/ValuePerPoint); % ���˻���1%�����Ƿ��ղ���ֵ��������������ȡ��
% end
% end


HoldingPosition=zeros(4,5*Q); % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,����ʱ�䣩 4����5��i)
LastPL=[0, 0, 0, 0, 1]; % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
Balance=repmat([Account ,0],m,1); % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��
%% ���ײ�����ʽ��ʼ���ԣ�
% �������������ָ��??RSV
RSV=50*ones(m,Q);
for i=1:Q
    O=data(:,i*5-4);H=data(:,i*5-3);L=data(:,i*5-2);C=data(:,i*5-1);
    RSV(:,i)=rsv(H,L,C,P_RSV);
end

PLI=[ DailyData(1,1:5:end);zeros(2,Q)];% ��һ�ο��ּ�λ�������Լ�ӯ�����ʾ��ָ�꣬ȷ�϶��ڿ����ź�Ҫ�õ���

for j=max([Str1_in,Str2_in,P_RSV/Freq])*Freq+1:Days*Freq
    Today=fix(j/Freq)+1; % ���������Ľ�����
    
    % ϵͳ2----��50��ͻ��Ϊ������ƫ����ϵͳ
    
    newlip=[0, 0, 0, inf,0]; % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿
    MarketValue=0; % ��ֵˮƽ��
    
    for i=1:Q
        O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);C=data(j,i*5-1);
        QuitL=min(DailyData(Today-Str2_out:Today-1,i*5-2));
        QuitH=max(DailyData(Today-Str2_out:Today-1,i*5-3));
        HoldingPosition=zeros(4,5*Q); % �ֲ֣����ÿһ��Ʒ�֣��������䣨���ּ۸񣬳ֲ��������ַ���Ԥ��ֹ��ֵ,����ʱ�䣩 4����5��i)
        if any(HoldingPosition(:,i*5-4)) % ��ʾ�е�λ�ĳֲַǿ�
            ii=find(HoldingPosition(:,i*5-3)~=0);
            for k=1:ii
                if HoldingPosition(k,i*5-2)==1  % ��ͷ
                    if L<=HoldingPosition(k,i*5-1) % ֹ�𴥷�
                        % LastPL=[0, 0, 0, 0, 1]; % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
                        % Balance=[Account ,0]; % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��
                        
                        newlip(1,1)=newlip(1,1)+(HoldingPosition(k,i*5-1)-HoldingPosition(k,i*5-4))*HoldingPosition(k,i*5-3); % ӯ��
                        newlip(1,2)=newlip(1,2)-HoldingPosition(k,i*5-3); % ��ͷ������
                        newlip(1,3)=newlip(1,3)+0;
                        newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                        newlip(1,5)=max([newlip(1,5),j]);
                        
                        HoldingPosition(k,:)=zeros(1,5); % ��ԭ��λ
                        PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                        PLI(2,i)=1; % ����
                        PLI(3,i)=-1; % �������
                    elseif L<=QuitL % �˳�����
                        newlip(1,1)=newlip(1,1)+(HoldingPosition(k,i*5-1)-QuitL)*HoldingPosition(k,i*5-3); % ӯ��
                        newlip(1,2)=newlip(1,2)-HoldingPosition(k,i*5-3); % ��ͷ������
                        newlip(1,3)=newlip(1,3)+0;
                        newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                        newlip(1,5)=max([newlip(1,5),j]);
                        
                        HoldingPosition(k,:)=zeros(1,5); % ��ԭ��λ
                        
                        PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                        PLI(2,i)=1; % ����
                        if (HoldingPosition(k,i*5-1)-QuitL)*HoldingPosition(k,i*5-3)<0
                            PLI(3,i)=-1; % ����
                        else
                            PLI(3,i)=1; % ӯ��
                        end
                    end
                    
                elseif HoldingPosition(k,i*5-2)==-1 %��ͷ
                    if H>=HoldingPosition(k,i*5-1) % ֹ�𴥷�
                        %?LastPL=[0, 0, 0, 0, 1]; % ƽ�ּ�¼����ӯ��״�� ��ͷˮƽ ��ͷˮƽ ����ʱ�� ƽ��ʱ�䡿 K*(5��i),k���״���
                        %?Balance=[Account ,0]; % �˻������ʽ� �˻������ʲ���ֵ m*(2*i)��mʱ�䳤��
                        
                        newlip(1,1)=newlip(1,1) -(HoldingPosition(k,i*5-1)-HoldingPosition(k,i*5-4))*HoldingPosition(k,i*5-3); % ӯ��
                        newlip(1,2)=newlip(1,2)+0;
                        newlip(1,3)=newlip(1,3)-HoldingPosition(k,i*5-3);% ��ͷ������
                        newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                        newlip(1,5)=max([newlip(1,5),j]);
                        
                        HoldingPosition(k,:)=zeros(1,5); % ��ԭ��λ
                        PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                        PLI(2,i)=-1; % ����
                        PLI(3,i)=-1; % �������
                    elseif H>=QuitH % �˳�����
                        newlip(1,1)=newlip(1,1) -(HoldingPosition(k,i*5-1)-QuitH)*HoldingPosition(k,i*5-3); % ӯ��
                        newlip(1,2)=newlip(1,2)+0;
                        newlip(1,3)=newlip(1,3)-HoldingPosition(k,i*5-3);% ��ͷ������
                        newlip(1,4)=min([newlip(1,4),HoldingPosition(k,i*5)]);
                        newlip(1,5)=max([newlip(1,5),j]);
                        
                        HoldingPosition(k,:)=zeros(1,5); % ��ԭ��λ
                        
                        PLI(1,i)=HoldingPosition(k,i*5-4);% ���ּ�λ
                        PLI(2,i)=-1; % ����
                        if -(HoldingPosition(k,i*5-1)-QuitH)*HoldingPosition(k,i*5-3)<0
                            PLI(3,i)=-1; % ����
                        else
                            PLI(3,i)=1; % ӯ��
                        end
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
    
    RSV_j=RSV(j,:);
    [s sr]= sort(RSV_j,'descend'); % ��ôӴ�С����
    [s2 sr2]= sort(RSV_j); % ��ô�С��������
    
    % ���ȶԲ�λ�ͷ���ˮƽ��һ�����㡣
    % ����ˮƽ�����������ˮƽ�����Ǹ����㡣
    % ����Ҫ�Ѽ۸�����ת���������ʡ�
    MCorr=[0;0]; % ����غ� �����
    for i=1:Q
        for k=i+1
            Ci=data(j-CorrAdj:j,i*5-1); Ck=data(j-CorrAdj:j,k*5-1);
            ri=price2ret(Ci); rk=price2ret(Ck);
            [corrxy] = exceedence_corr(ri,rk,0,0); % ��ֵ���ҵ������<0 ;>0
            MCorr=MCorr+corrxy;
        end
    end
    MCorr=MCorr/(i*(i-1)/2);
    
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ��ͳ������ʣ����̿���
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
    PB=min([CB+SQ-BQ PosLim(1,5)-BQ]) ; % permit buy,����Է����¿��������ٲ��ֶԳ壬���ܵ���ֲֲ����ҹ�һ���޶ȡ�
    PS=min([CS+BQ-SQ PosLim(1,5)-SQ]) ; % permit sell
    
    for ll=1:Q
        if PB>0 % ��ʣ��ͷ��
            i=sr(ll); % ���ȴ�RSV���Ŀ�ʼ
            O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);
            EnterL=min(DailyData(Today-Str2_in:Today-1,i*5-2));
            EnterH=max(DailyData(Today-Str2_in:Today-1,i*5-3));
            N= NMatrix(Today-1,i);
            ValuePerPoint=N*Size(i)/Margin(i); % һ�ֲ���ȫ����ʧ��ֵ��ֵ
            VN= fix(0.01*sum(Balance(j-1,:))/ValuePerPoint); % ÿ����׼���յ�λ
            PriceVN_B=VN*H*Margin(i)*Size(i); % ����ÿ�������ʽ�
            if H>=EnterH
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
                elseif HoldingPosition(1,i*5-3)~=0 && HoldingPosition(2,i*5-3)==0 && H>=HoldingPosition(1,i*5-4)+0.5*N
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
                elseif HoldingPosition(2,i*5-3)~=0 && HoldingPosition(3,i*5-3)==0 && H>=HoldingPosition(2,i*5-4)+0.5*N
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
                elseif HoldingPosition(3,i*5-3)~=0 && HoldingPosition(4,i*5-3)==0 && H>=HoldingPosition(3,i*5-4)+0.5*N
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
                end
            end
        end
        
        
        if PS>0
            i=sr2(ll); % ���ȴ�RSV��С�Ŀ�ʼ
            O=data(j,i*5-4);H=data(j,i*5-3);L=data(j,i*5-2);C=data(j,i*5-1);
            EnterL=min(DailyData(Today-Str2_in:Today-1,i*5-2));
            EnterH=max(DailyData(Today-Str2_in:Today-1,i*5-3));
            N= NMatrix(Today-1,i);
            ValuePerPoint=N*Size(i)/Margin(i); % һ�ֲ���ȫ����ʧ��ֵ��ֵ
            VN= fix(0.01*sum(Balance(j-1,:))/ValuePerPoint); % ÿ����׼���յ�λ
            PriceVN_S=VN*L*Margin(i)*Size(i); % ����ÿ�������ʽ�
            if L<=EnterL
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
                elseif HoldingPosition(1,i*5-3)~=0 && HoldingPosition(2,i*5-3)==0 && L<=HoldingPosition(1,i*5-4)-0.5*N
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
                elseif HoldingPosition(2,i*5-3)~=0 && HoldingPosition(3,i*5-3)==0 && L<=HoldingPosition(2,i*5-4)-0.5*N
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
                elseif HoldingPosition(3,i*5-3)~=0 && HoldingPosition(4,i*5-3)==0 && L<=HoldingPosition(3,i*5-4)-0.5*N
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
                end
            end
        end
    end
    end
end







% out=fopen('turtle','at');
%  fprintf(out,'********************���ս��׽��***********************\n');
%  fprintf(out,'���ղ�λ�������? \n');
%  for i=1:Q
%  fprintf(out,'�����ʲ���?? %u\n',i);
%  fprintf(out,'���ּ۸� �ֲ��� ���ַ��� ֹ���λ ����ʱ��\n');
%  for k=1:4
%  fprintf(out,'%u?? %u?? %u %u %u\n',HoldingPosition(k,i*5-4),...
%  HoldingPosition(k,i*5-3),HoldingPosition(k,i*5-2),HoldingPosition(k,i*5-1),HoldingPosition(k,i*5-0));
%  end
%  fprintf(out,'\n');
%  end
%  fprintf(out,'�ڼ乲�ƽ��״���? %u\n', size(LastPL,1)-1);
%  fprintf(out,'�ڼ乲���ܼ�ӯ��? %u\n', sum(LastPL(:,1)));
%  fprintf(out,'��������е��ֽ�? %u\n', Balance(end,1));
%  fprintf(out,'��������е���ֵ? %u\n', Balance(end,2));
%  fclose(out);
%
%  plot(LastPL(:,1))
%  title('Figure ����ӯ��');
%  ylabel('ÿ�ν���ӯ��ˮƽ');
%  xlabel('���״���');
%  grid on;
%  saveas(gcf,strcat('P&L_',num2str(i),'.eps'),'psc2');
%
%  plot(Balance)
%  title('Figure �˻�ƽ���');
%  ylabel('ÿ�ν��׵��µ�����ˮƽ�䶯');
%  xlabel('ÿ�ڹ۲�');
%  grid on;
%  saveas(gcf,strcat('Balance_',num2str(i),'.eps'),'psc2');
%
%  save STRATEGY1 LastPL Balance HoldingPosition
% end
