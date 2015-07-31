function speechproc()

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
    s_rec = zeros(L,1);     % �ؽ�����
    zi_rec = zeros(P,1);
    % �ϳ��˲���
    exc_syn = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn = zeros(L,1);     % �ϳ�����
    % ����������˲���
    exc_syn_t = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn_t = zeros(L,1);     % �ϳ�����
    % ���ٲ�����˲����������ٶȼ���һ����
    exc_syn_v = zeros(2*L,1);   % �ϳɵļ����źţ����崮��
    s_syn_v = zeros(2*L,1);     % �ϳ�����

    hw = hamming(WL);       % ������
    
    % ���δ���ÿ֡����
    for n = 3:FN

        % ����Ԥ��ϵ��������Ҫ���գ�
        s_w = s(n*FL-WL+1:n*FL).*hw;    %��������Ȩ�������
        [A E] = lpc(s_w, P);            %������Ԥ�ⷨ����P��Ԥ��ϵ��
                                        % A��Ԥ��ϵ����E�ᱻ��������ϳɼ���������

        if n == 27
        % (3) �ڴ�λ��д���򣬹۲�Ԥ��ϵͳ���㼫��ͼ
            [z,p,~] = tf2zp(A,[1,zeros(1,P)]);
            figure(1);zplane(z,p);
            title('Ԥ��ϵͳ�㼫��ͼ(��27֡)');
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % ��֡�����������Ҫ����������

        % (4) �ڴ�λ��д������filter����s_f���㼤����ע�Ᵽ���˲���״̬
        [Y,zi_pre] = filter(A,[1,zeros(1,P)],s_f,zi_pre);   % keep state
        exc((n-1)*FL+1:n*FL) = Y;
        % exc((n-1)*FL+1:n*FL) = ... �������õ��ļ���д������

        % (5) �ڴ�λ��д������filter������exc�ؽ�������ע�Ᵽ���˲���״̬
        [Y,zi_rec] = filter([1,zeros(1,P)],A,Y,zi_rec);
        s_rec((n-1)*FL+1:n*FL) = Y;
        % s_rec((n-1)*FL+1:n*FL) = ... �������õ����ؽ�����д������

        % ע������ֻ���ڵõ�exc��Ż������ȷ
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % �����������PT����Ҫ�����գ�
        G = sqrt(E*PT);           % ����ϳɼ���������G����Ҫ�����գ�

        
        % (10) �ڴ�λ��д�������ɺϳɼ��������ü�����filter���������ϳ�����
        if n == 3                   % first loop
            cursor = (n-1)*FL+1;    % initialize cursor
            m = n;                  % initialize m
        end
        
        while m == n                % cursor still point into current frame
            exc_syn(cursor) = 1;
            cursor = cursor + PT;   % next cursor
            m = ceil(cursor/FL);    % locate next cursor
        end
        
        s_syn((n-1)*FL+1:n*FL) = filter([1,zeros(1,P)],A,...
            G*exc_syn((n-1)*FL+1:n*FL));
        % exc_syn((n-1)*FL+1:n*FL) = ... �������õ��ĺϳɼ���д������
        % s_syn((n-1)*FL+1:n*FL) = ...   �������õ��ĺϳ�����д������

        % (11) ���ı�������ں�Ԥ��ϵ�������ϳɼ����ĳ�������һ��������Ϊfilter
        % ������õ��µĺϳ���������һ���ǲ����ٶȱ����ˣ�������û�б䡣
        FL_v = 2*FL;
        if n == 3                   % first loop
            cursor_v = (n-1)*FL_v+1;    % initialize cursor
            m_v = n;                  % initialize m
        end
        
        while m_v == n                % cursor still point into current frame
            exc_syn_v(cursor_v) = 1;
            cursor_v = cursor_v + PT;   % next cursor
            m_v = ceil(cursor_v/FL_v);    % locate next cursor
        end
        
        s_syn_v((n-1)*FL_v+1:n*FL_v) = filter([1,zeros(1,P)],A,...
            G*exc_syn_v((n-1)*FL_v+1:n*FL_v));
        % exc_syn_v((n-1)*FL_v+1:n*FL_v) = ... �������õ��ļӳ��ϳɼ���д������
        % s_syn_v((n-1)*FL_v+1:n*FL_v) = ...   �������õ��ļӳ��ϳ�����д������
        
        % (13) ���������ڼ�Сһ�룬�������Ƶ������150Hz�����ºϳ�������������ɶ���ܡ�
        PT_t = round(PT/2);
        if n == 3                   % first loop
            cursor_t = (n-1)*FL+1;    % initialize cursor
            m_t = n;                  % initialize m
        end
        
        while m_t == n                % cursor still point into current frame
            exc_syn_t(cursor_t) = 1;
            cursor_t = cursor_t + PT_t;   % next cursor
            m_t = ceil(cursor_t/FL);    % locate next cursor
        end
        A_t = changetone(A,150,8000);   % ff += 150
        s_syn_t((n-1)*FL+1:n*FL) = filter([1,zeros(1,P)],A_t,...
            G*exc_syn_t((n-1)*FL+1:n*FL));
        % exc_syn_t((n-1)*FL+1:n*FL) = ... �������õ��ı���ϳɼ���д������
        % s_syn_t((n-1)*FL+1:n*FL) = ...   �������õ��ı���ϳ�����д������
        
    end
    
    % ���������ļ�
    writespeech('exc.pcm',exc);
    writespeech('rec.pcm',s_rec);
    writespeech('exc_syn.pcm',exc_syn);
    writespeech('syn.pcm',s_syn);
    writespeech('exc_syn_t.pcm',exc_syn_t);
    writespeech('syn_t.pcm',s_syn_t);
    writespeech('exc_syn_v.pcm',exc_syn_v);
    writespeech('syn_v.pcm',s_syn_v);

    % (6) �ڴ�λ��д������һ�� s ��exc �� s_rec �к����𣬽�����������
    % ��������������ĿҲ������������д���������ر�ע��
    
    % normalization
    s = normalize(s);
    exc = normalize(exc);
    s_rec = normalize(s_rec);
    exc_syn = normalize(exc_syn);
    s_syn = normalize(s_syn);
    exc_syn_v = normalize(exc_syn_v);
    s_syn_v = normalize(s_syn_v);
    exc_syn_t = normalize(exc_syn_t);
    s_syn_t = normalize(s_syn_t);
    
    sound([s;exc;s_rec;s_syn;s_syn_v;s_syn_t],8000);
    figure(2);
    subplot(3,1,1);plot(s);title('ԭ��');
    subplot(3,1,2);plot(exc);title('�����ź�');
    subplot(3,1,3);plot(s_rec);title('�ؽ��ź�');
    
    figure(3);
    plot(s,'k');axis([6400 6500 -1 1]);hold on;
    plot(exc,'r');
    plot(s_rec);hold off;
    legend('ԭ��','�����ź�','�ؽ��ź�');title('Ƭ�ζԱ�');
    
    figure(4);
    subplot(2,1,1);plot(s);title('ԭ��');
    subplot(2,1,2);plot(s_syn);title('�ϳ��ź�');
    
    figure(5);
    subplot(2,1,1);plot(s_syn);title('�ϳ��ź�(ԭ��ԭ��)');axis([0 3e4 -1 1]);
    subplot(2,1,2);plot(s_syn_v);title('�ϳ��ź�(����ԭ��)');
    
    figure(6);
    subplot(3,1,1);plot(s_syn);title('�ϳ��ź�(ԭ��ԭ��)');
    subplot(3,1,2);plot(s_syn_v);title('�ϳ��ź�(����ԭ��)');
    subplot(3,1,3);plot(s_syn_t);title('�ϳ��ź�(ԭ������)');

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