function H = speechproc1(rv,rt,df)
%speechproc1(rv,rt,df)
%输入:
%   <double>rv: 调速比
%   <double>rt: 调(tiao)调(diao)比, ratio_tone
%   <double>df: 共振峰频率改变量
%输出文件

    % 定义常数
    FL = 80;                % 帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech('voice.pcm',100000);             % 载入语音s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    zi_pre = zeros(P,1);    % 预测滤波器的状态
    zi_syn = zeros(P,1);
    % 合成滤波器
    exc_syn = zeros(ceil(L/rv),1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(ceil(L/rv),1);     % 合成语音
    
    hw = hamming(WL);       % 汉明窗
    
    % 依次处理每帧语音
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
        [A E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                        % A是预测系数，E会被用来计算合成激励的能量
        
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % (4) 在此位置写程序，用filter函数s_f计算激励，注意保持滤波器状态
        [Y,zi_pre] = filter(A,[1,zeros(1,P)],s_f,zi_pre);   % keep state
        exc((n-1)*FL+1:n*FL) = Y;
        % exc((n-1)*FL+1:n*FL) = ... 将你计算得到的激励写在这里

        % 注意下面只有在得到exc后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）

        
        % 变速变调
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

    % 保存所有文件
    writespeech('exc_syn_c.pcm',exc_syn);     % _c means Combine both velocity and tone change
    writespeech('syn_c.pcm',s_syn);
    
    % normalization
    s = normalize(s);
    s_syn = normalize(s_syn);
    
    sound(s_syn,8000);
    H = plot(s_syn);title('"电灯比油灯进步多了"');
    
return

% 从PCM文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到PCM文件中
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
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

