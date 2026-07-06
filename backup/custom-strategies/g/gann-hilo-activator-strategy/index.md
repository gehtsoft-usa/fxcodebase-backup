# Gann HiLo Activator Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3562  
> Forum: 31 · Topic 3562 · 12 post(s)


---

## Gann HiLo Activator Strategy

**Apprentice** · Tue Mar 01, 2011 6:01 am

![Gann HiLo Activator strategy.png](images/8543/Gann%20HiLo%20Activator%20strategy.png)



This is a simple Gann HiLo Activator strategy.
Signals / Trades are generates by crossover of closing price and GHLA indicator.

This is a good base, but further development of strategies is needed.

 [Gann HiLo Activator Strategy.lua](files/8543/Gann%20HiLo%20Activator%20Strategy.lua)

Gann HiLo Activator Indicator is Required.
[viewtopic.php?f=17&t=227](https://fxcodebase.com/code/viewtopic.php?f=17&t=227)

The Strategy was revised and updated on December 09, 2018.


---

## Re: Gann HiLo Activator Strategy

**bluepip** · Wed May 18, 2011 12:06 am

Hello,
my Parameter are set: Allow Short/Long/Both Positions on Long.
Parameter are set to open only Long Positions.
When will be closed this Long-Position?
I thought Positions are close automatically when the indicator change the direction

Kind regards from Germany
bluepip


---

## Re: Gann HiLo Activator Strategy

**Apprentice** · Wed May 18, 2011 3:49 am

The old version does not work well in these conditions.
This version solves this problem.


---

## Re: Gann HiLo Activator Strategy

**efoxlau** · Tue Nov 08, 2011 7:29 pm

When the indicator change, it " close all position" , but it cannot open the new position, please help!


---

## Re: Gann HiLo Activator Strategy

**Apprentice** · Wed Nov 09, 2011 3:57 am

I'm not sure I understand you.
What are the parameters you are using.


---

## Re: Gann HiLo Activator Strategy

**efoxlau** · Wed Nov 09, 2011 7:32 am

For example:
If my account have a long position,
the indicator change to short,
Normally, it will close all the long position then open short position.
But, after it close all long position, it will not open short position.

If my account haven't any position, it will open short position normally.


---

## Re: Gann HiLo Activator Strategy

**Apprentice** · Wed Nov 09, 2011 6:07 pm

Are you using Allowed side Buy not Both.


---

## Re: Gann HiLo Activator Strategy

**efoxlau** · Thu Nov 10, 2011 1:48 am

Yesterday I try it at a real account.
I set short only. At strategy alert window, it show up "Close long" then "Open short". It closed my long position but don't open any short position.

At the Events log, It show Close All positions for Symbol xxxx successful. But not seen any market order!

Thanks


---

## Re: Gann HiLo Activator Strategy

**trader-muc** · Tue Sep 11, 2012 4:35 pm

this is a great indicator. as always you should trade with the higher trend:

therefore a signal like the following would be of great value:

LONG

close M5 crosses above Gann HiLo
AND
close M5 is above Gann HiLO (H1)

**SHORT**

close M5 crosses below Gann HiLo
AND
close M5 is below Gann HiLO (H1)

Could anyone update the gann hilo strategy with the second timeframe as trend-filter ?? thank you

(btw: as an additional confirmation of momentum i use the trendstop overlay)


---

## Re: Gann HiLo Activator Strategy

**Apprentice** · Wed Sep 12, 2012 11:36 am

Your request is added to the development list.


---

## Re: Gann HiLo Activator Strategy

**Apprentice** · Wed Sep 12, 2012 1:37 pm

Requested can be found here.
[viewtopic.php?f=31&t=23334](https://fxcodebase.com/code/viewtopic.php?f=31&t=23334)


---

## Re: Gann HiLo Activator Strategy

**Apprentice** · Wed Dec 07, 2016 5:36 am

Strategy has been revised and updated.
