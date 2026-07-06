# Stochastic RSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=8169  
> Forum: 17 · Topic 8169 · 3 post(s)


---

## Stochastic RSI

**Apprentice** · Thu Nov 17, 2011 5:45 am

![StochRSI MT.png](images/18049/StochRSI%20MT.png)



These are two versions of this indicator, translated from the MT4 platform.
Algorithm 1

min = Lowest RSI in period
max = Highest RSI in period
FAST = ((RSI - min) / (max - min)) * 100;
SLOW = Averege of Fast

Algorithm 2
Value1 = (RSI - min);
Value2 = (max - min)
Value3 = Value1 / Value2;

FAST= 2 * (MVA of Value3 - 0.5);
SLOW =previous FAST

 [StochRSI MT1.lua](files/18049/StochRSI%20MT1.lua)

 [StochRSI MT2.lua](files/18049/StochRSI%20MT2.lua)

The indicator was revised and updated


---

## Re: Stochastic RSI

**Apprentice** · Thu Nov 17, 2011 6:12 am

Another version can be found here.
[viewtopic.php?f=17&t=451&p=10039&hilit=StochRSI#p10039](https://fxcodebase.com/code/viewtopic.php?f=17&t=451&p=10039&hilit=StochRSI#p10039)


---

## Re: Stochastic RSI

**Apprentice** · Sat Mar 18, 2017 8:07 am

Indicator was revised and updated.
