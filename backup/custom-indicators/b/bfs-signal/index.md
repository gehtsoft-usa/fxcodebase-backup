# BFS Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64002  
> Forum: 17 · Topic 64002 · 6 post(s)


---

## BFS Signal

**Apprentice** · Fri Oct 21, 2016 3:13 am

![EURUSD H8 (10-21-2016 0925).png](images/108719/EURUSD%20H8%20%2810-21-2016%200925%29.png)



Based on request.
[viewtopic.php?f=27&t=63999](https://fxcodebase.com/code/viewtopic.php?f=27&t=63999)

 [BFS Signal.lua](files/108719/BFS%20Signal.lua)

The indicator was revised and updated


---

## Re: BFS Signal

**jupiter ange** · Fri Oct 21, 2016 4:06 am

> **Apprentice wrote:**
>
>
> EURUSD H8 (10-21-2016 0925).png
>
>
> Based on request.
> [viewtopic.php?f=27&t=63999](https://fxcodebase.com/code/viewtopic.php?f=27&t=63999)
>
>
> BFS Signal.lua

hello mario
almost there, when I compare his looks good but I have a difference of 20 pips from my original one of the input and output are slightly offset.
I'm not Programmer but just now I saw that there was a difference in this part of the code:

 ArrayInitialize(g_ibuf_108, 0);
 ArrayInitialize(g_ibuf_112, 0);
 if (CalculatedBars > Bars || CalculatedBars == 0) CalculatedBars = Bars;
 for (int li_4 = CalculatedBars - 1; li_4 >= 0; li_4--) {
 ld_52 = 0;
 for (int li_0 = PeriodWATR - 1; li_0 >= 0; li_0--) {
 ld_60 = 1.0 * (PeriodWATR - li_0) / PeriodWATR + 1.0;
 ld_52 += ld_60 * MathAbs(High[li_0 + li_4] - (Low[li_0 + li_4]));
 }
 ld_68 = ld_52 / PeriodWATR;
 ld_76 = MathMax(ld_68, ld_76);
 if (li_4 == CalculatedBars - 1 - PeriodWATR) ld_84 = ld_68;
may be that the problem comes from there?
thank you


---

## Re: BFS Signal

**newton** · Sat Oct 22, 2016 11:24 am

hi

can you create a strategy based on bfs indicator

**indicator:**
bfs indicator with default parameters

buy level :0.5
buy exit: 0.8
sell level: 0.5
sell exit: 0.2

BUY: LINE 2> BUY LEVEL AND LINE 1< BUY EXIT LEVEL AND LINE 1 CROSS OVER LINE 2

SELL: LINE 2< SELL LEVEL AND LINE1> BUY EXIT LEVEL AND LINE 1 CROSS UNDER LINE 2


---

## Re: BFS Signal

**Apprentice** · Mon Oct 24, 2016 3:59 am

Try this version.
[viewtopic.php?f=31&t=64022](https://fxcodebase.com/code/viewtopic.php?f=31&t=64022)

> LINE1> BUY EXIT LEVEL

This is typo?


---

## Re: BFS Signal

**jupiter ange** · Mon Nov 14, 2016 6:03 am

i programmer
 cmake me a simple strategy with BFS signal and this corrected average [download/file.php?id=16866](https://fxcodebase.com/code/download/file.php?id=16866)

like this please
buy ask
bfs line 1 > bfs line 2
close > corrected averages

sell bid
bfs line 1 < bfs line 2
close < corrected averages
stop
limit
that it no more options please
many thanks


---

## Re: BFS Signal

**Apprentice** · Tue Nov 15, 2016 3:18 am

Try this version.
[viewtopic.php?f=31&t=64097](https://fxcodebase.com/code/viewtopic.php?f=31&t=64097)
