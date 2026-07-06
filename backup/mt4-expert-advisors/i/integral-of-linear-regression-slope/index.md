# Integral of Linear Regression Slope

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=59963  
> Forum: 38 · Topic 59963 · 1 post(s)


---

## Integral of Linear Regression Slope

**Alexander.Gettinger** · Mon Nov 25, 2013 2:34 pm

Integral of Linear Regression Slope (ILRS moving average).

Formulas:
ILRS[i]=(N*Sum1-Sum*Sumy)/(Sum*Sum-N*Sum2)+MVA(I,N), where
Sum=N*(N-1)*0.5,
Sum2=N*(N-1)*(2*N-1)/6,
Sum1=1*Price[i-1]+2*Price[i-2]+…+(N-1)*Price[i-N+1],
Sumy=Price[i]+Price[i-1]+…+Price[i-N+1],
MVA(i,N) – Simple Moving Average,
N - Length.

 

![ILRS_MA_MQL.PNG](images/91097/ILRS_MA_MQL.PNG)



Download:

 [ILRS_MA.mq4](files/91097/ILRS_MA.mq4)
