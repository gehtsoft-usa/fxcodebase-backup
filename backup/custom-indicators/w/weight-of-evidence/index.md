# Weight of Evidence

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62054  
> Forum: 17 · Topic 62054 · 11 post(s)


---

## Weight of Evidence

**Apprentice** · Sun Mar 29, 2015 7:12 am

![Weight of Evidence.png](images/99516/Weight%20of%20Evidence.png)



Based on request.
[viewtopic.php?f=27&t=62052&p=99514#p99514](https://fxcodebase.com/code/viewtopic.php?f=27&t=62052&p=99514#p99514)

 [Weight of Evidence.lua](files/99516/Weight%20of%20Evidence.lua)

 [Weight of Evidence Signal Indicator.lua](files/99516/Weight%20of%20Evidence%20Signal%20Indicator.lua)

Williams Accumulation/Distribution (WAD) Can be found here.
[viewtopic.php?f=17&t=901&p=95765&hilit=accumulation%2Fdistribution#p95765](https://fxcodebase.com/code/viewtopic.php?f=17&t=901&p=95765&hilit=accumulation%2Fdistribution#p95765)

 

![MTF MCP Weight of Evidence DASHBOARD.png](images/99516/MTF%20MCP%20Weight%20of%20Evidence%20DASHBOARD.png)



 [MTF MCP Weight of Evidence DASHBOARD.lua](files/99516/MTF%20MCP%20Weight%20of%20Evidence%20DASHBOARD.lua)


---

## Re: Weight of Evidence

**Coondawg71** · Sun Mar 29, 2015 9:26 am

Thanks for the quick turn around, you are the man!

You know what comes next....

I see this being a very useful indicator.

Can we please request two elements to complement the basic:

1.) May we please request Alert functionality, similar to Stochastic: user sets parameters of OB and OS such as 90 and 10, cross of 50 center line.

2.) May we please request MTF MCP Weight of Evidence List with Alert functions like MTF MCP SSD Dashboard.

Thank You!!!

sjc


---

## Re: Weight of Evidence

**mulligan** · Tue Mar 31, 2015 8:08 am

This looks like a really good indicator. A standard alert for signal line and WOE line cross with pop up show alert and sound would be great. Show alert on chart with arrows would be icing on the cake.

Thanks for all you do


---

## Re: Weight of Evidence

**Apprentice** · Wed Apr 01, 2015 4:03 am

Weight of Evidence Signal Indicator Added.


---

## Re: Weight of Evidence

**panos59** · Wed Apr 01, 2015 5:37 am

Does anybody has any suggestions for best settings ?


---

## Re: Weight of Evidence

**Apprentice** · Thu Apr 02, 2015 12:07 pm

MTF MCP Weight of Evidence DASHBOARD.lua Added.
Please re-download / re-install Weight of Evidence.
Old version has a bug, which may affect the MTF MCP Weight of Evidence DASHBOARD.lua


---

## Re: Weight of Evidence

**muz1979** · Thu Apr 02, 2015 11:29 pm

how to use weight of evidence? what is this indicator? i never heard of it.


---

## Re: Weight of Evidence

**Apprentice** · Fri Apr 03, 2015 1:34 am

This script gives a score out of 100 in increments of 2.5,
Based on the 5 periods entered and the following eight indicator tests:
1.Close>=EMA(x)
2. RSI(x)>=50
3. OBV>=OBV[x periods ago]
4. PVT>=PVT[x periods ago]
5.Percentrank(x)>=50
6.Lower donchian channel(x period) is rising
7. Accumulation/distribution>=A/D[x periods ago]
8. Volatility stop : Close>=Highest(L3 periods)-n.ATR where n =1,2,3,4,5
where x equals to L1,L2,L3,L4 and L5


---

## Re: Weight of Evidence

**Alexander.Gettinger** · Fri May 22, 2015 10:11 am

MQL4 version of Weight of Evidence oscillator: [viewtopic.php?f=38&t=62248](https://fxcodebase.com/code/viewtopic.php?f=38&t=62248).


---

## Re: Weight of Evidence

**Apprentice** · Mon Dec 14, 2015 6:00 am

Dec 14, 2015: Compatibility issue Fixed. _Alert helper is not longer needed.

If you want to use updated version of this indicator,
please make sure to use TS Version 01.14.101415. or higher.


---

## Re: Weight of Evidence

**Apprentice** · Mon Aug 06, 2018 1:28 pm

The indicator was revised and updated.
