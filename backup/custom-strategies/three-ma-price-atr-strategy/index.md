# Three MA/Price/ATR Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=12889  
> Forum: 31 · Topic 12889 · 2 post(s)


---

## Three MA/Price/ATR Strategy

**Apprentice** · Mon Feb 06, 2012 3:57 am

![Three MA_Price_ATR Strategy.png](images/25271/Three%20MA_Price_ATR%20Strategy.png)



indicators:

1. ma1 (34)
2.ma2(70)
3.ma3(100)
4.atr (period 14, multiplier 2)

buy:

1. ma1 >ma2>ma3
2. ma1-ma2>atr(period 14, multiplier 2)
3.price cross over ma1

sell:

1. ma1<ma2< ma3
2.ma2-ma1> atr{period 14, multiplier 2}
3. price cross under ma1

exit buy:

price cross under ma2

exit sell:

price cross over ma2

 [Three MA_Price_ATR Strategy.lua](files/25271/Three%20MA_Price_ATR%20Strategy.lua)

The Strategy was revised and updated on November 22, 2018.


---

## Re: Three MA/Price/ATR Strategy

**Apprentice** · Sun Dec 04, 2016 8:53 am

Bump up.
