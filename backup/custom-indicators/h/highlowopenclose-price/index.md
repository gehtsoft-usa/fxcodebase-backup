# HighLowOpenClose Price

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72159  
> Forum: 17 · Topic 72159 · 2 post(s)


---

## HighLowOpenClose Price

**Apprentice** · Mon May 09, 2022 4:00 am

![USDJPY H8 (05-09-2022 1059).png](images/145933/USDJPY%20H8%20%2805-09-2022%201059%29.png)



Calculate the price as ((High+Low)/2 + (Open+Close)/2)/2

 [HighLowOpenClose Price.lua](files/145933/HighLowOpenClose%20Price.lua)


---

## Re: HighLowOpenClose Price

**Gilles** · Mon May 09, 2022 12:35 pm

Hello Apprentice,
it's a real shame that this indicator has a result identical to the one we get by applying a simple moving average to the chart in Heikin-Ashi, over 1 period.

Exactly the same result as: MVA(HA(instrument).close, 1)

See you soon :) !
