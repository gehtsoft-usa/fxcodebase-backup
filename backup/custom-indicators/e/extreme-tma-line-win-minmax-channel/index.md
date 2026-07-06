# Extreme_TMA_Line win MinMax Channel

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72154  
> Forum: 17 · Topic 72154 · 4 post(s)


---

## Extreme_TMA_Line win MinMax Channel

**Apprentice** · Fri May 06, 2022 7:32 am

![USDJPY D1 (05-06-2022 1431).png](images/145918/USDJPY%20D1%20%2805-06-2022%201431%29.png)



 [Extreme_TMA_Line win MinMax Channel.lua](files/145918/Extreme_TMA_Line%20win%20MinMax%20Channel.lua)


---

## Re: Extreme_TMA_Line win MinMax Channel

**Gilles** · Fri May 06, 2022 9:35 am

Hello Apprentice,
This is not the expected result.
We have here two distinct elements Min[period] and Max[period] while I proposed to make a MinMax_MA[period] which has as a source of calculation TMA[period].

Another problem encountered the output of the two elements is not aligned or accessible.

How to make a strategy from this version, is it possible ?
The rules are :
if
TMA[period] >= MinMax_MA[period]
then
 BUY();
elseif
TMA[period] < MinMax_MA[period]
then
 SELL();
end

Thank you very much for the work already done.


---

## Re: Extreme_TMA_Line win MinMax Channel

**Apprentice** · Tue May 10, 2022 9:09 am

Something like this?
[https://fxcodebase.com/code/viewtopic.php?f=31&t=72163](https://fxcodebase.com/code/viewtopic.php?f=31&t=72163)


---

## Re: Extreme_TMA_Line win MinMax Channel

**AlexanderS** · Sat Jan 10, 2026 1:18 pm

HI
Can you make alert option?
THANKS
