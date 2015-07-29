# voice-synthesizer
Homework No.2 for summer course: MATLAB

## 语音预测模型

1. 给定 $e(n)=s(n)-a_1s(n-1)-a_2s(n-2)$

    1. 假设$e(n)$是输入信号, $s(n)$是输出信号, 则上述滤波器的传递函数为 $$H(s)=\frac{1}{1-a_1s-a_2s^2}$$

    2. 如果$a_1=1.3789, a_2=-0.9506$, 则利用`zpkdata`或`roots`等函数可求出系统极点为 $$p_{1,2}=0.7253\pm 0.7252j=1.0257e^{\pm j0.7854}$$

        根据共振峰频率的定义 $$f=\frac{\omega}{2\pi}=\frac{\Omega}{2\pi T}=\frac{\Omega f_s}{2\pi}=\frac{Arg(p)}{2\pi}f_s$$

        取$f_s=8000$Hz, 求得**共振峰频率**(Formant Frequency) $f_f=999.94$Hz

