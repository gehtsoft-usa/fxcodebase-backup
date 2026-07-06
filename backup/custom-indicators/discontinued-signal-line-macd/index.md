# Discontinued signal line MACD

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72874  
> Forum: 17 · Topic 72874 · 2 post(s)


---

## Discontinued signal line MACD

**Apprentice** · Thu Oct 27, 2022 3:07 am

![TSLA.us D1 (10-27-2022 1007).png](images/148056/TSLA.us%20D1%20%2810-27-2022%201007%29.png)



Based on the code
[https://www.prorealcode.com/prorealtime ... line-macd/](https://www.prorealcode.com/prorealtime-indicators/discontinued-signal-line-macd/)
Instead of having one signal line, the Top and Bottom lines depend on the current value of the indicator.

The “Signal” line is calculated the following way :
When some level is crossed in the desired direction,
ema of that value is calculated for the desired signal line
When that level is crossed in the opposite direction,
previous “signal” line value is simple “inherited” and it becomes a kind of a level

 [Discontinued signal line MACD.lua](files/148056/Discontinued%20signal%20line%20MACD.lua)


---

## Discontinued signal line RSI

**Apprentice** · Thu Oct 27, 2022 3:28 am

![TSLA.us D1 (10-27-2022 1027).png](images/148058/TSLA.us%20D1%20%2810-27-2022%201027%29.png)



 [Discontinued signal line RSI.lua](files/148058/Discontinued%20signal%20line%20RSI.lua)
