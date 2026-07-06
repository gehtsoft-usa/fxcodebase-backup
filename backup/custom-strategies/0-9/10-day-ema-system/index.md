# 10 Day EMA System

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7810  
> Forum: 31 · Topic 7810 · 8 post(s)


---

## 10 Day EMA System

**Apprentice** · Fri Nov 04, 2011 10:51 am

![10 Day EMA System.png](images/17374/10%20Day%20EMA%20System.png)



Long
10 period ema > 20 period ema
20 period ema>50 period ema
50 period ema >200 period ema

If all three conditions are met we have a trend.

If price has been above the 10 day Ema for the last 10 days we have met the second criteria for a trade, otherwise we have no trade.

Point of entry for the trade is when the price re-traces to touch the 10 day ema-i.e price=10 period ema no need to wait for the candle to close.

Trailing stop to exit trade
Value of 10 period ema minus 50% ofATR

Short trade is reverse of strategy for long trade

 [10 Day EMA System.lua](files/17374/10%20Day%20EMA%20System.lua)

The Strategy was revised and updated on November 21, 2018.


---

## Re: 10 Day EMA System

**impraresempre** · Mon Nov 07, 2011 6:50 am

Has anybody back tested the system?-As posted elsewhere Im having trouble accessing LUA files.I would be interested to hear peoples thoughts on back test results and whether people think the system is viable.


---

## Re: 10 Day EMA System

**Josemunguia** · Fri Nov 18, 2011 7:32 pm

Best regards, can this system autotrade,if not can you code to do so?


---

## Re: 10 Day EMA System

**Apprentice** · Sat Nov 19, 2011 3:38 am

This system is a strategy, therefore it can traded.
As you can see by equity curve.
The strategy is written for the new version of TS.
Therefore, if you already have not download the new version of the platform,
download it from your broker web page.


---

## Re: 10 Day EMA System

**Josemunguia** · Fri Nov 25, 2011 7:50 pm

Hi aprendice,TS? Strategy Trader


---

## Re: 10 Day EMA System

**Apprentice** · Sat Nov 26, 2011 2:58 am

I do not understand you.
You need a strategy for Strategy Trader.
Strategy for TS2 is already written.
See the top most post.


---

## Re: 10 Day EMA System

**Exolon** · Fri Dec 02, 2011 7:35 pm

> **Josemunguia wrote:**
> Hi aprendice,TS? Strategy Trader

TS: Trading Station II, the live trading platform.


---

## Re: 10 Day EMA System

**Apprentice** · Sat Dec 03, 2016 7:52 am

Bump up.
