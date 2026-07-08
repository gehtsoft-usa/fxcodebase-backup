# Volume Price Momentum Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61222  
> Forum: 17 · Topic 61222 · 3 post(s)

---

## Volume Price Momentum Oscillator

**Apprentice** · Mon Sep 22, 2014 11:47 am

![Volume Price Momentum Oscillator.png](images/96095/Volume%20Price%20Momentum%20Oscillator.png)

Colby (in his book The Encyclopedia of Technical Market Indicators, 2nd. ed., McGraw-Hill, 2003, pg. 774) notes that “As with simple momentum indicators generally, when the n-period exponential moving average of V*PMO is positive, momentum is bullish, so we buy, entering or initiating a long position.”

```
First, calculate today’s V*PMO input value:

VTODAY * (CPTODAY – CPTODAY-1)

where

VTODAY = today’s volume
CPTODAY = today’s closing price
CPTODAY-1 = yesterday’s closing price

Then smooth the values using a 3-day exponential moving average (EMA):

V*PMO = EMA(3)(VTODAY,VTODAY-1,VTODAY-2)
```

 [Volume Price Momentum Oscillator.lua](files/96095/Volume%20Price%20Momentum%20Oscillator.lua)

The indicator was revised and updated

---

## Re: Volume Price Momentum Oscillator

**Alexander.Gettinger** · Wed Apr 08, 2015 11:33 am

MQL4 version of oscillator: [viewtopic.php?f=38&t=62089](https://fxcodebase.com/code/viewtopic.php?f=38&t=62089).

---

## Re: Volume Price Momentum Oscillator

**Apprentice** · Tue Aug 08, 2017 5:33 am

The indicator was revised and updated.
