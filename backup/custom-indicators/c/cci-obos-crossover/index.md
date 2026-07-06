# CCI OBOS Crossover

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62049  
> Forum: 17 · Topic 62049 · 10 post(s)


---

## CCI OBOS Crossover

**Apprentice** · Fri Mar 27, 2015 7:13 am

![New Chart.png](images/99503/New%20Chart.png)



Based on request.
[viewtopic.php?f=27&t=62033](https://fxcodebase.com/code/viewtopic.php?f=27&t=62033)
OBOS indicator can be found here.
[viewtopic.php?f=17&t=3664&p=8869&hilit=OBOS#p8869](https://fxcodebase.com/code/viewtopic.php?f=17&t=3664&p=8869&hilit=OBOS#p8869)

Green Circle
CCI / OBOS CrossOver
Red Circle
CCI / OBOS CrossUnder

 [CCI OBOS Crossover.lua](files/99503/CCI%20OBOS%20Crossover.lua)

 [CCI OBOS Crossover with Alert.lua](files/99503/CCI%20OBOS%20Crossover%20with%20Alert.lua)

The indicator was revised and updated


---

## Re: CCI OBOS Crossover

**7510109079** · Fri Mar 27, 2015 10:55 am

A big thanks for that Apprentice.

At some values of CCI, all dots disappear. Can you reproduce this anomaly your side? e.g. for me, any CCI values over 18 dont plot any dots at all with (Error) displaying in the legend.

Also is it possible to write a filter in the code to reduce noise:

~ Only show green crossover dots for CCI/OBOS cross values <a (negative value) and red crossunder dots for values >b (positive value) where a & b are set by user

many TIA


---

## Re: CCI OBOS Crossover

**7510109079** · Wed Apr 01, 2015 9:39 am

Is this possible?


---

## Re: CCI OBOS Crossover

**Apprentice** · Fri Apr 03, 2015 5:59 am

The filter was introduced.
Make sure to re-download OBOS.lua indicator,
prior to use of new versions of CCI OBOS Crossover.lua.


---

## Re: CCI OBOS Crossover

**7510109079** · Tue Apr 07, 2015 8:10 am

just seen your new post. Many thx Apprentice.


---

## Re: CCI OBOS Crossover

**7510109079** · Wed Apr 15, 2015 11:54 am

Please may I request 2 more refinements for this great indicator:

i) An option for the marker to plot on the Open or Close of the candle rather than be offset

ii) An alert using the Alert.lua

many TIA


---

## Re: CCI OBOS Crossover

**Apprentice** · Fri Apr 17, 2015 3:53 am

CCI OBOS Crossover with Alert added.


---

## Re: CCI OBOS Crossover

**Alexander.Gettinger** · Fri May 08, 2015 10:20 am

MQL4 version of CCI OBOS Crossover indicator: [viewtopic.php?f=38&t=62200&p=100362#p100362](https://fxcodebase.com/code/viewtopic.php?f=38&t=62200&p=100362#p100362).


---

## Re: CCI OBOS Crossover

**Apprentice** · Mon Dec 14, 2015 5:47 am

Dec 14, 2015: Compatibility issue Fixed. _Alert helper is not longer needed.

If you want to use updated version of this indicator,
please make sure to use TS Version 01.14.101415. or higher.


---

## Re: CCI OBOS Crossover

**Apprentice** · Wed Aug 02, 2017 7:35 am

The indicator was revised and updated.
