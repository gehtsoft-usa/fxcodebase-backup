# Recursive Moving Average (RMA)

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72670  
> Forum: 17 · Topic 72670 · 1 post(s)


---

## Recursive Moving Average (RMA)

**Apprentice** · Mon Aug 29, 2022 9:24 am

![AUDUSD H2 (08-29-2022 1622).png](images/147263/AUDUSD%20H2%20%2808-29-2022%201622%29.png)



This indicator was developed by Dennis Meyers and introduced in his article “The Japanese Yen, Recursed”, published in the December 1998 issue of Technical Analysis of Stocks and Commodities magazine. According to Meyers, this method requires a small number of historical data of the estimated price and the price at present (today) in order to forecast the price in the future (tomorrow).

A=close[N]
B=(close[N]+close[N-1])/2
C=(close[N]+close[N-1]+close[N-2])/3
D=(close[N]+close[N-1]+close[N-2]+close[N-3])/4
E=(close[N]+close[N-1]+close[N-2]+close[N-3]+close[N-4])/5
F=(close[N]+close[N-1]+close[N-2]+close[N-3]+close[N-4]+close[N-5])/6
G=(close[N]+close[N-1]+close[N-2]+close[N-3]+close[N-4]+close[N-5]+close[N-6])/7
H=(close[N]+close[N-1]+close[N-2]+close[N-3]+close[N-4]+close[N-5]+close[N-6]+close[N-7])/8
I=(close[N]+close[N-1]+close[N-2]+close[N-3]+close[N-4]+close[N-5]+close[N-6]+close[N-7]+close[N-8])/9
J=(close[N]+close[N-1]+close[N-2]+close[N-3]+close[N-4]+close[N-5]+close[N-6]+close[N-7]+close[N-8]+close)/10

X=(A+B+C+D+E+F+G+H+I+J)/10
Y=average[P](X)

 [Recursive Moving Average.lua](files/147263/Recursive%20Moving%20Average.lua)

Indicator based strategy
[https://fxcodebase.com/code/viewtopic.php?f=31&t=72676](https://fxcodebase.com/code/viewtopic.php?f=31&t=72676)
