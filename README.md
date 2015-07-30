# voice-synthesizer
Homework No.2 for summer course: MATLAB

## 语音预测模型

1. 给定 $e(n)=s(n)-a_1s(n-1)-a_2s(n-2)$

    1. 假设$e(n)$是输入信号, $s(n)$是输出信号, 则上述滤波器的传递函数为 $$H(s)=\frac{1}{1-a_1s-a_2s^2}$$

    2. 如果$a_1=1.3789, a_2=-0.9506$, 则利用`[Z,P,K]=tf2zp(b,a)`或`roots(poly)`等函数可求出系统极点为 $$p_{1,2}=0.7253\pm 0.7252j=1.0257e^{\pm j0.7854}$$

        根据共振峰频率的定义 $$f=\frac{\omega}{2\pi}=\frac{\Omega}{2\pi T}=\frac{\Omega f_s}{2\pi}=\frac{Arg(p)}{2\pi}f_s$$

        取$f_s=8000$Hz, 求得**共振峰频率**(Formant Frequency) $f_f=999.94$Hz

    3. 绘制**零极点图**, `zplane(Z,P)`

        ![零极点图](pic/zplane.png)

    4. 绘制**频率响应**, `freqz(1,[-a2,-a1,1],512,fs)`

        ![频率响应](pic/freqz.png)

    5. 绘制**单位样值响应**

        * `impz(1,[-a2,-a1,1],512,fs)`

            ![impz](pic/impz.png)

        * `filter`

            ```matlab
            x = zeros(1,512);
            x(1) = 1;
            y = filter(1,[-a2,-a1,1],x);
            stem(0:1/fs:511/fs,y);
            ```

            ![filter](pic/filter.png)

            **与impz画出的结果相同**


