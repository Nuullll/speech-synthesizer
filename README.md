# speech-synthesizer
Homework No.2 for summer course: MATLAB

## 语音预测模型

1. 给定 $$e(n)=s(n)-a_1s(n-1)-a_2s(n-2)$$

    1. 假设$e(n)$是输入信号, $s(n)$是输出信号, 则上述滤波器的传递函数为 $$H(z)=\frac{z^2}{z^2-a_1z-a_2}$$

    2. 如果$a_1=1.3789, a_2=-0.9506$, 则利用`[Z,P,K]=tf2zp(b,a)`或`roots(poly)`等函数可求出系统极点为 $$p_{1,2}=0.6895\pm 0.6894j=0.9750e^{\pm j0.7854}$$

        根据共振峰频率的定义 $$f=\frac{\omega}{2\pi}=\frac{\Omega}{2\pi T}=\frac{\Omega f_s}{2\pi}=\frac{Arg(p)}{2\pi}f_s$$

        取$f_s=8000$Hz, 求得**共振峰频率**(Formant Frequency) $f_f=999.94$Hz

    3. 绘制**零极点图**, `zplane(Z,P)`

        ![零极点图](pic/zplane.png)

    4. 绘制**频率响应**, `freqz(b,a,512,fs)`

        ![频率响应](pic/freqz.png)

        从频率响应图中也可直观地看出**共振峰频率**在1000Hz附近

    5. 绘制**单位样值响应**

        * `impz(b,a,512,fs)`

            ![impz](pic/impz.png)

        * `filter`

            ```matlab
            x = zeros(1,512);
            x(1) = 1;
            y = filter(b,a,x);
            stem(0:1/fs:511/fs,y);
            ```

            ![filter](pic/filter.png)

            **与impz画出的结果相同**

2. 阅读`speechproc.m`

    ```matlab
    function speechproc()

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
        s_rec = zeros(L,1);     % 重建语音
        zi_rec = zeros(P,1);
        % 合成滤波器
        exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
        s_syn = zeros(L,1);     % 合成语音
        % 变调不变速滤波器
        exc_syn_t = zeros(L,1);   % 合成的激励信号（脉冲串）
        s_syn_t = zeros(L,1);     % 合成语音
        % 变速不变调滤波器（假设速度减慢一倍）
        exc_syn_v = zeros(2*L,1);   % 合成的激励信号（脉冲串）
        s_syn_v = zeros(2*L,1);     % 合成语音

        hw = hamming(WL);       % 汉明窗
        
        % 依次处理每帧语音
        for n = 3:FN

            % 计算预测系数（不需要掌握）
            s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
            [A E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                            % A是预测系数，E会被用来计算合成激励的能量

            if n == 27
            % (3) 在此位置写程序，观察预测系统的零极点图
                
            end
            
            s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

            % (4) 在此位置写程序，用filter函数s_f计算激励，注意保持滤波器状态

            
            % exc((n-1)*FL+1:n*FL) = ... 将你计算得到的激励写在这里

            % (5) 在此位置写程序，用filter函数和exc重建语音，注意保持滤波器状态

            
            % s_rec((n-1)*FL+1:n*FL) = ... 将你计算得到的重建语音写在这里

            % 注意下面只有在得到exc后才会计算正确
            s_Pitch = exc(n*FL-222:n*FL);
            PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
            G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）

            
            % (10) 在此位置写程序，生成合成激励，并用激励和filter函数产生合成语音

            
            % exc_syn((n-1)*FL+1:n*FL) = ... 将你计算得到的合成激励写在这里
            % s_syn((n-1)*FL+1:n*FL) = ...   将你计算得到的合成语音写在这里

            % (11) 不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为filter
            % 的输入得到新的合成语音，听一听是不是速度变慢了，但音调没有变。

            
            % exc_syn_v((n-1)*FL_v+1:n*FL_v) = ... 将你计算得到的加长合成激励写在这里
            % s_syn_v((n-1)*FL_v+1:n*FL_v) = ...   将你计算得到的加长合成语音写在这里
            
            % (13) 将基音周期减小一半，将共振峰频率增加150Hz，重新合成语音，听听是啥感受～

            
            % exc_syn_t((n-1)*FL+1:n*FL) = ... 将你计算得到的变调合成激励写在这里
            % s_syn_t((n-1)*FL+1:n*FL) = ...   将你计算得到的变调合成语音写在这里
            
        end

        % (6) 在此位置写程序，听一听 s ，exc 和 s_rec 有何区别，解释这种区别
        % 后面听语音的题目也都可以在这里写，不再做特别注明
        

        % 保存所有文件
        writespeech('exc.pcm',exc);
        writespeech('rec.pcm',s_rec);
        writespeech('exc_syn.pcm',exc_syn);
        writespeech('syn.pcm',s_syn);
        writespeech('exc_syn_t.pcm',exc_syn_t);
        writespeech('syn_t.pcm',s_syn_t);
        writespeech('exc_syn_v.pcm',exc_syn_v);
        writespeech('syn_v.pcm',s_syn_v);
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
    ```

3. 在`speechproc`运行至第27帧时观察预测系统的**零极点图**

    **预测系统** $$e(n)=s(n)-\sum_{k=1}^{N}a_k s(n-k)$$

    其中$s(n)$为输入, $e(n)$为输出, 则系统函数 $$H_{pre}(z)=\frac{z^N}{z^N-\sum_{k=1}^{N}a_k z^{N-k}}$$

    取**预测系数个数** $N=P=10$

    在`speechproc`中相应位置插入代码:

    ```matlab
    if n == 27
    % (3) 在此位置写程序，观察预测系统的零极点图
        [z,p,~] = tf2zp([1,zeros(1,P)],A);
        zplane(z,p);
        title('预测系统零极点图(第27帧)');
    end
    ```

    ![预测系统第27帧零极点图](pic/zplane-pre27.png)


