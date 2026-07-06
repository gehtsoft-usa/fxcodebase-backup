# Ema Cross with 3 Filter Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7716  
> Forum: 31 · Topic 7716 · 2 post(s)


---

## Ema Cross with 3 Filter Strategy

**Apprentice** · Mon Oct 31, 2011 9:29 am

![ema cross with 3 filers strategy.png](images/17175/ema%20cross%20with%203%20filers%20strategy.png)



Buy when the MA of the Close crosses above the MA of the Open,
and vice versa for reversing the position to Short.

3 filters:

1) 20EMA
Take only long trades when price is above the 20EMA,
short when price below 20EMA.

2) Introduce a Higher High or Lower Low filter
Entering long after a signal is given ONLY after the high of the previous candle is taken out, and vice versa.

3) Introduce an ATR or ADX filter
Taking trades only when these are above a certain level and increasing {adx [period-1]>adx[period-2] } - thus in theory the market is trending.

 [ema cross with 3 filters strategy.lua](files/17175/ema%20cross%20with%203%20filters%20strategy.lua)

The Strategy was revised and updated on January 21, 2019.


---

## Re: Ema Cross with 3 Filter Strategy

**Apprentice** · Tue Dec 19, 2017 8:59 am

The strategy was revised and updated.
