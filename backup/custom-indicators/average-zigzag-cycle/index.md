# Average ZigZag Cycle

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60681  
> Forum: 17 · Topic 60681 · 12 post(s)


---

## Average ZigZag Cycle

**Apprentice** · Sun May 11, 2014 1:57 pm

![Average ZigZag Cycle.png](images/93957/Average%20ZigZag%20Cycle.png)



This version of Zigzag Indicator,
will show the Average Value of Last N Zig / Zag Swings.

Indicator will show how many candle have passed between the peaks.
Actual price shift is not of our interest.

 [Average ZigZag Cycle.lua](files/93957/Average%20ZigZag%20Cycle.lua)


---

## Re: Average ZigZag Cycle

**Taskryr** · Mon May 12, 2014 1:47 pm

Apprentice,

Is it possible to limit the Av to 1 decimal. I'm getting AVs of 13 decimals long.

Thanks,


---

## Re: Average ZigZag Cycle

**Apprentice** · Tue May 13, 2014 1:26 am

Done.


---

## Re: Average ZigZag Cycle

**Apprentice** · Mon Nov 03, 2014 3:33 am

Minor Update.


---

## Re: Average ZigZag Cycle

**7510109079** · Wed Nov 12, 2014 3:52 am

I am finding the Ac. values are not correctly calculated. If i measure them with ruler the no. pips is always incorrect by random factor.
Also if I overlay the integer ZigZag version with same params, integer version paints correct pip values:

yellow line and pips are integer and are correct

Correct integer -vs- Ac values e.g.
25 vs 52
19 vs 8
22 vs 20
21 vs 16


---

## Re: Average ZigZag Cycle

**Apprentice** · Wed Nov 12, 2014 4:40 am

Indicator will show how many candle have passed between the peaks.
Actual price shift is not of our interest.


---

## Re: Average ZigZag Cycle

**7510109079** · Fri Nov 28, 2014 5:40 am

sry, didnt read above properly


---

## Re: Average ZigZag Cycle

**cnikitopoulos94** · Sat Oct 10, 2015 1:11 pm

anyway we can have this adjusted so that the swings are defined by the amount of pips?

I.E. Each swing is justified by the amount of pips. So if EurUsd for example is at 1.1250 (source Low) then euro goes to 1.1270 then it adjusts itself based on "N" number of pips so in this example it would be 20 pips.. If eurusd does NOT go down 20 pips after the 20 up pip move then the zig zag keeps extending until it does.


---

## Re: Average ZigZag Cycle

**Apprentice** · Mon Oct 12, 2015 5:30 am

It's similar to the definition of a Renko.
[http://stockcharts.com/school/doku.php? ... ysis:renko](http://stockcharts.com/school/doku.php?id=chart_school:chart_analysis:renko)
I'm not sure we can call such a indicator, ZigZag.


---

## Re: Average ZigZag Cycle

**7510109079** · Fri Aug 19, 2016 6:40 am

> **Apprentice wrote:**
> Indicator will show how many candle have passed between the peaks.
> Actual price shift is not of our interest.

Is it possible to add an option to display the average price shift/swing (pips) of the zigzag based on the user set Period?

thx


---

## Re: Average ZigZag Cycle

**Apprentice** · Sun Aug 21, 2016 6:01 am

Your request is added to the development list, Under Id Number 3605
 If someone is interested to do this task, please contact me.


---

## Re: Average ZigZag Cycle

**Apprentice** · Mon Aug 27, 2018 5:04 am

The indicator was revised and updated.
