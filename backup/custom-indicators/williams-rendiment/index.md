# Williams Rendiment

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63611  
> Forum: 17 · Topic 63611 · 2 post(s)


---

## Williams Rendiment

**Apprentice** · Mon Jun 20, 2016 8:48 am

![EURUSD m1 (06-20-2016 1514).png](images/106836/EURUSD%20m1%20%2806-20-2016%201514%29.png)



Based on request.
[viewtopic.php?f=27&t=63610&p=106835#p106835](https://fxcodebase.com/code/viewtopic.php?f=27&t=63610&p=106835#p106835)

Formula:
 %RR= ( (%R Williams) + ( Rendiment) ) / 2

1) %R williams is the indicator of Larry Williams
%R = (Highest High - Close)/(Highest High - Lowest Low) * -100

2) Rendiment= X * natural logarithm (Close1/Close2)

close1= close of previous candelstick
close2= close of candelstick N periods ago

Normalization will shift, normalize Quantitative Return Oscillator to Williams% R indicator range.

 [Williams Rendiment.lua](files/106836/Williams%20Rendiment.lua)


---

## Re: Williams Rendiment

**Apprentice** · Sat Jun 30, 2018 3:55 am

The indicator was revised and updated.
