# Simplified supertrend

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=73572  
> Forum: 17 · Topic 73572 · 1 post(s)


---

## Simplified supertrend

**Apprentice** · Fri Apr 07, 2023 9:42 am

![EURUSD H1 (04-07-2023 1641).png](images/150319/EURUSD%20H1%20%2804-07-2023%201641%29.png)



Based on source
[https://www.prorealcode.com/prorealtime ... onent-atr/](https://www.prorealcode.com/prorealtime-indicators/simplified-supertrend-without-volatility-component-atr/)

This simplified supertrend can give better results in certain cases, for example in long-term charts, when prices show highly different values falling in a very broad range.

The indicator behaves more like a traditional trailing stop, because volatility is not considered. The risk of curve-fitting and over-optimization is reduced, because only one adaptable parameter (“factor”) is used.

 [Simplified supertrend.lua](files/150319/Simplified%20supertrend.lua)
