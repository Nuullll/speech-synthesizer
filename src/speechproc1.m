function H = speechproc1(rv,rt,df)
%speechproc1(rv,rt,df)
%����:
%   <double>rv: ���ٱ�
%   <double>rt: ��(tiao)��(diao)��, ratio_tone
%   <double>df: �����Ƶ�ʸı���
%����ļ�

    % ���峣��
    FL = 80;                % ֡��
    WL = 240;               % ����
    P = 10;                 % Ԥ��ϵ������
    s = readspeech('voice.pcm',100000);             % ��������s
    L = length(s);          % ������������
    FN = floor(L/FL)-2;     % ����֡��
    % Ԥ����ؽ��˲���
    exc = zeros(L,1);       % �����źţ�Ԥ����
    zi_pre = zeros(P,1);    % Ԥ���˲�����״̬
    zi_syn = zeros(P,1);
    % �ϳ��˲���
    exc_syn = zeros(ceil(L/rv),1);   % �ϳɵļ����źţ����崮��
    s_syn = zeros(ceil(L/rv),1);     % �ϳ�����
    
    hw = hamming(WL);       % ������
    
    % ���δ���ÿ֡����
    for n = 3:FN

        % ����Ԥ��ϵ��������Ҫ���գ�
        s_w = s(n*FL-WL+1:n*FL).*hw;    %��������Ȩ�������
        [A E] = lpc(s_w, P);            %������Ԥ�ⷨ����P��Ԥ��ϵ��
                                        % A��Ԥ��ϵ����E�ᱻ��������ϳɼ���������
        
        s_f = s((n-1)*FL+1:n*FL);       % ��֡�����������Ҫ����������

        % (4) �ڴ�λ��д������filter����s_f���㼤����ע�Ᵽ���˲���״̬
        [Y,zi_pre] = filter(A,[1,zeros(1,P)],s_f,zi_pre);   % keep state
        exc((n-1)*FL+1:n*FL) = Y;
        % exc((n-1)*FL+1:n*FL) = ... �������õ��ļ���д������

        % ע������ֻ���ڵõ�exc��Ż������ȷ
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % �����������PT����Ҫ�����գ�
        G = sqrt(E*PT);           % ����ϳɼ���������G����Ҫ�����գ�

        
        % ���ٱ��
        FL_v = round(FL/rv);        % change velocity
        PT_t = round(PT/rt);        % change tone
        A_t = changetone(A,df,8000);% change predict sys
        
        if n == 3                   % first loop
            cursor = (n-1)*FL_v+1;    % initialize cursor
            m = n;                  % initialize m
        end
        
        while m == n                % cursor still point into current frame
            exc_syn(cursor) = 1;
            cursor = cursor + PT_t;   % next cursor
            m = ceil(cursor/FL_v);    % locate next cursor
        end
        
        [s_syn((n-1)*FL_v+1:n*FL_v),zi_syn] = filter([1,zeros(1,P)],A_t,...
            G*exc_syn((n-1)*FL_v+1:n*FL_v),zi_syn);
        
    end

    % ���������ļ�
    writespeech('exc_syn_c.pcm',exc_syn);     % _c means Combine both velocity and tone change
    writespeech('syn_c.pcm',s_syn);
    
    % normalization
    s = normalize(s);
    s_syn = normalize(s_syn);
    
    sound(s_syn,8000);
    H = plot(s_syn);title('"��Ʊ��͵ƽ�������"');
    
return

% ��PCM�ļ��ж�������
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% д������PCM�ļ���
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% ����һ�������Ļ������ڣ���Ҫ������
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return

