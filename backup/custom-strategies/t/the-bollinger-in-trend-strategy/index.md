# The Bollinger in Trend strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=73164  
> Forum: 31 · Topic 73164 · 1 post(s)


---

## The Bollinger in Trend strategy

**Apprentice** · Tue Jan 10, 2023 8:19 am

![EURUSD m1 (01-10-2023 1418).png](images/149008/EURUSD%20m1%20%2801-10-2023%201418%29.png)



Based on source
[https://www.prorealcode.com/prorealtime ... -strategy/](https://www.prorealcode.com/prorealtime-trading-strategies/bollinger-trend-strategy/)

In a bull market, we go to purchase if :
close > MA100
MA20 > MA200
% Bollinger < 0.2 and % Bollinger < 0.2 on previous candle (consolidation)

We close the trade if :
% Bollinger > 1

 [The Bollinger in Trend strategy.lua](files/149008/The%20Bollinger%20in%20Trend%20strategy.lua)
