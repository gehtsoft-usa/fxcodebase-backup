# Dynamic RS

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72210  
> Forum: 17 · Topic 72210 · 1 post(s)


---

## Dynamic RS

**Apprentice** · Thu May 26, 2022 7:30 am

![EURUSD m15 (05-26-2022 1430).png](images/146089/EURUSD%20m15%20%2805-26-2022%201430%29.png)



The idea is simple: if the High of the current bar is lower than that of the previous, less than the High n bars ago and the indicator value of the previous bar, then the indicator line is equal to the High. The opposite is for the Lows.

The movement nature of the indicator line resembles the MA, but filters the noises better.

 [Dynamic RS.lua](files/146089/Dynamic%20RS.lua)
