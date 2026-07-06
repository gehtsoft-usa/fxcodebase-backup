# Acceleration Bands (AB)

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=1051  
> Forum: 17 · Topic 1051 · 13 post(s)


---

## Acceleration Bands (AB)

**Apprentice** · Tue May 18, 2010 5:03 am

![AUDCAD H1 (09-18-2017 1141).png](images/1983/AUDCAD%20H1%20%2809-18-2017%201141%29.png)



Developed by Price Headley, the Acceleration bands are based on the average trading range for each day. The values are plotted equidistant from an n-day simple moving average which serves as the center or middle band. The author indicates that successive days exceeding one of the bands tends to indicate an entry point.
Because the bands use the daily trading range (high-low) they will also expand and contract based on the volatility of the price.

The formula for Acceleration Bands
Upperband = ( High * ( 1 + 2 * (((( High - Low )/(( High + Low ) / 2 )) * 1000 ) * Factor )));
Lowerband = ( Low * ( 1 - 2 * (((( High - Low )/(( High + Low ) / 2 )) * 1000 ) * Factor )));

 [AB.lua](files/1983/AB.lua)

 [MTF MCP Acceleration Bands Heat Map.lua](files/1983/MTF%20MCP%20Acceleration%20Bands%20Heat%20Map.lua)


---

## Re: Acceleration Bands (AB)

**CMTrader** · Sun Aug 14, 2011 12:16 pm

Could you develop an alert that indicates when the price goes outside of the Acceleration Bands?


---

## Re: Acceleration Bands (AB)

**Apprentice** · Sun Aug 21, 2011 12:21 pm

Give me a few days.


---

## Re: Acceleration Bands (AB)

**Apprentice** · Mon Aug 22, 2011 4:33 am

Requested can be found here.
[viewtopic.php?f=29&t=5998&p=14031#p14031](https://fxcodebase.com/code/viewtopic.php?f=29&t=5998&p=14031#p14031)


---

## Re: Acceleration Bands (AB)

**Alexander.Gettinger** · Fri Nov 21, 2014 4:46 pm

MQL4 version of AB indicator: [viewtopic.php?f=38&t=61511](https://fxcodebase.com/code/viewtopic.php?f=38&t=61511).


---

## Re: Acceleration Bands (AB)

**Apprentice** · Sun Mar 08, 2015 2:55 am

Updated.


---

## Re: Acceleration Bands (AB)

**money0101** · Wed Aug 24, 2016 10:00 am

Hi there, I love your acceleration bands and I was wondering whether I could do some backtesting with them. Unfortunately, I get a FXCM Trading Station error in the Strategy Backtester.

"The input value is incorrect. The value must be in the range from 0.01 to 0.0001."

The value referenced is the "FACTOR" under parameters. Even if I type 0.01 or 0.001 (or xx2) it doesn't work. Would you mind having a look?

Thanks a lot and thanks also for sharing this great CI!


---

## Re: Acceleration Bands (AB)

**Apprentice** · Wed Aug 24, 2016 10:48 am

Can you provide strategy download link?


---

## Re: Acceleration Bands (AB)

**money0101** · Wed Aug 24, 2016 10:55 am

There is no link, I just used your custom indicator to do a back-test strategy. Would that not usually work "out of the box"?


---

## Re: Acceleration Bands (AB)

**Apprentice** · Thu Aug 25, 2016 4:17 am

Try AB Signal now.

You can not use indicator with in a back-test.
Signal will provide signals only.
Only Strategy will actually trade.


---

## Re: Acceleration Bands (AB)

**Apprentice** · Mon Sep 04, 2017 9:07 am

The indicator was revised and updated.


---

## Re: Acceleration Bands (AB)

**Apprentice** · Mon Sep 18, 2017 6:33 am

MTF MCP Acceleration Bands Heat Map.lua added.


---

## Re: Acceleration Bands (AB)

**Apprentice** · Mon Aug 06, 2018 1:35 pm

The indicator was revised and updated.
