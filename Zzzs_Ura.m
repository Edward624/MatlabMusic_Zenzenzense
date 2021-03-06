function Y = Zzzs_Ura(F,tn,A)
%为前前前世调制的处理函数，其功能包括：
%将标准乐谱里的一个音符转化为声波；
%使该声波具有高次谐波以调整音色；
%为声波添加包络线以调整音色；（如果没有音色调整，听起来就像蜂鸣器在演奏）
%F为音符的基频，tn为音符的持续时间（以秒为单位），A是音强


%谐波参数矩阵xie，可以通过频谱分析得到，我这里直接用了现成的；
%当然，乱写其实也是可以的，有时候乱写的效果似乎还不错……

%谐波参数矩阵写成这样是方便理解，也方便修改；第1列是谐波次数，第2列是强度
%实际上，并不需要严格按123456……这样逐个增加的顺序来，如果你想加个100次谐波以
%及其对应的强度，直接在10次谐波的下一行加上就行
xie=[
   1  1.0050;
   2  0.2400;
   3  0.1650;
   4  0.2700;
   5  0.1500;
   6  0.1500;
   7  0.0450;
   8  0.0300;
   9  0.0030;
   10  0.0045;
    ];
%谐波矩阵的行数，用来确定循环处理的次数
[j,~]=size(xie);

%根据输入的音符持续时间，在函数内形成一个音符时间矩阵，步长应与主程序中的对应
fs=44100;
dT=1/fs;%时间步长
t=dT:dT:tn;
%音符时间矩阵的长度
L=length(t);
%全零矩阵先作为输出矩阵，预分配内存
y=zeros(j,L,'double');
%稍微解释一下，输出矩阵的第i行，代表的是谐波矩阵中第i行所对应的谐波次数。有点拗
%口，简单来说如果谐波矩阵的第一列是1 3 7 8 9，那么输出矩阵的第1~5行对应的谐波次
%数就是1 3 7 8 9。每一行都是一个被包络的正弦波。

%将各行的正弦波叠加，就得到了最终的输出矩阵Y

%如果音强为0，那么没必要进行后续的运算了，直接全零。
if A==0
    Y=sum(y);
end
    
%如果音强不为0，进行运算    
if A~=0
    
%频率矩阵
f=F.*xie(:,1);

 %为包络做准备
 n=[0:L-1]/L;%标幺，或者叫归一？
 %包络函数，这里用的包络函数，其实是巴特沃斯低通滤波器减常数1/2（确保音符
 %末尾强度会衰减为0），再和x/e^x这个常见函数组合。技术力有限只能组合出这种，
 %若想改善音色，请主要从包络函数入手，其对音色影响很大。
 env=(1./(1+n.^10)-1/2).*(3*n)./exp(n*2);
 
 %随机相位角，对音色有一定的影响，感兴趣的话可以在循环中去掉angle对比一下效果
 angle=2*pi.*rand(1,j)-pi;
 
 %循环计算生成各次谐波存储在y中
  for i=1:j
      y(i,:)=A*xie(i,2).*sin(2.*pi.*f(i).*t+angle(i));
  end
  
  %各次谐波叠加，并包络，得到最终的输出矩阵Y
  Y=env.*sum(y);
end
end