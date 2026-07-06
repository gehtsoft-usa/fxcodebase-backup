# WILDERS VOLATILITY STRATEGY

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=62829  
> Forum: 31 · Topic 62829 · 5 post(s)


---

## WILDERS VOLATILITY STRATEGY

**Apprentice** · Tue Oct 27, 2015 5:24 am

![WILDERS VOLATILITY STRATEGY.png](images/103060/WILDERS%20VOLATILITY%20STRATEGY.png)



Based on request.
[viewtopic.php?f=27&t=62826](https://fxcodebase.com/code/viewtopic.php?f=27&t=62826)
BUY: CrossOver (C,Ref(LLV(Close,Period),-1)+(Ref(ATR(Period),-1)*3))
SELL: CrossUnder(Ref(HHV(Close,Period),-1)-(Ref(ATR(Period),-1)*3),C)

 [WILDERS VOLATILITY STRATEGY.lua](files/103060/WILDERS%20VOLATILITY%20STRATEGY.lua)

The Strategy was revised and updated on January 21, 2019.


---

## Re: WILDERS VOLATILITY STRATEGY

**apockfx** · Tue Oct 27, 2015 11:32 am

Backtesting from 10-23-2012


---

## Re: WILDERS VOLATILITY STRATEGY

**Stance** · Wed Oct 28, 2015 12:48 am

I think you have a typo in the sell code.

I think it should be:

Code: [Select all](https://fxcodebase.com/code/)
`Source.close[period-1] >= Value4`

Instead of:

Code: [Select all](https://fxcodebase.com/code/)
`Source.close[period] >= Value4`


---

## Re: WILDERS VOLATILITY STRATEGY

**Apprentice** · Thu Oct 29, 2015 5:45 am

Fixed.


---

## Re: WILDERS VOLATILITY STRATEGY

**Apprentice** · Thu Dec 21, 2017 10:51 am

The strategy was revised and updated.
