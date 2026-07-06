# DSS Bressert Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4010  
> Forum: 31 · Topic 4010 · 20 post(s)


---

## DSS Bressert Strategy

**Apprentice** · Sun Apr 24, 2011 5:29 am

DSS Formulas is similar to the that of stochastic indicator.
William Blau and Walter Bressert presented different version of the Double Smoothed Stochastics.

 

![DSS Bressert Strategy.png](images/9975/DSS%20Bressert%20Strategy.png)



In addition to the two signal already present on a standard indicator,
Buy
DSS or Signal Rise above Oversold.
Sell
DSS orSignal Falls below Overbought.

I added two additional features.
Buy
Simple DSS - Signal Crossover
DSS - Signal Crossover in Oversold.
Sell
DSS - Signal Crossover in Overbought.
Simple DSS - Signal Crossover

The signals generated while the market is in Oversold / Overbought From my experience are more reliable.

 [DSS Bressert Strategy.lua](files/9975/DSS%20Bressert%20Strategy.lua)

If you do not already have it installed.
You need to install DSS indicator.

You can find it here.
[viewtopic.php?f=17&t=1855](https://fxcodebase.com/code/viewtopic.php?f=17&t=1855)


---

## Re: DSS Bressert Strategy

**amazon1a** · Wed Oct 05, 2011 11:28 am

Could you add an alert function that generates an alert with a choice to trade or not when the signal crosses a given level (80/20) AFTER having previously crossed (DSS/signal) in either overbought/oversold (80/20) territory. I really like this Strategy, but find that it gives too many false alerts while in overbought/oversold territory.


---

## Re: DSS Bressert Strategy

**Apprentice** · Thu Oct 06, 2011 4:48 pm

Your request is added to the developmental cue.


---

## Re: DSS Bressert Strategy

**Apprentice** · Fri Oct 07, 2011 4:08 am

Requested algorithm added.

 [DSS Bressert Strategy.lua](files/15908/DSS%20Bressert%20Strategy.lua)


---

## Re: DSS Bressert Strategy

**amazon1a** · Fri Oct 07, 2011 10:06 am

Thanks so much for such a speedy reply. Worked perfectly on my first try of EUR/USD 1min chart at 10.56-9 EST; then again with a reversal at 11.08. TOO COOL!!!


---

## Re: DSS Bressert Strategy

**amazon1a** · Mon Feb 06, 2012 1:51 pm

Is it possible to code a variation - Robby DSS Bressert with color and alert? I have this indicator for FXCM MetaTrader 4 if that would help. I like it alot, but would prefer to run it on TS2. Thanks.


---

## Re: DSS Bressert Strategy

**Apprentice** · Tue Feb 07, 2012 5:56 am

Strategy / signal already exists.
There is also an indicator.
I'm not sure what your request.
Can you send me Mq4 version for comparison.
New version of the indicator, with alert.


---

## Re: DSS Bressert Strategy

**amazon1a** · Tue Feb 07, 2012 10:31 am

Thanks for your quick response. I do not know if the new indicator was attached or not. If so, you will see that the display is quite different and uses dots which switch colors at the pivot points. Generally I am working with 1Hr charts, and it is somewhat less ambiguous than the existing indicator.


---

## Re: DSS Bressert Strategy

**raychan** · Thu Oct 04, 2012 9:03 am

It seems that the multiple position function is not working. Could you please fix it?


---

## Re: DSS Bressert Strategy

**briansummy** · Fri Oct 12, 2012 8:43 pm

> **Apprentice wrote:**
> Requested algorithm added.
>
>
> DSS Bressert Strategy.lua

This would be a great strategy if you can condition it to buy or sell only in agreement with 3 Level ZZ Semafor Value of 3 or 2. Thoughts?


---

## Re: DSS Bressert Strategy

**Apprentice** · Sun Oct 14, 2012 6:24 am

Your request is added to the development list.


---

## Re: DSS Bressert Strategy

**amazon1a** · Fri Dec 28, 2012 11:52 am

Hi Apprentice, For some reason this Strategy does not let me add multiple positions in the same direction. Can you check it? I have reloaded and retried several times. The single function works but not the multiple function.


---

## Re: DSS Bressert Strategy

**Apprentice** · Sun Dec 30, 2012 5:09 am

You have to set "Allow Multiple Positions in the same direction" to Yes.


---

## Re: DSS Bressert Strategy

**adnanafzal** · Wed Nov 04, 2015 3:53 am

please add sound alert when cross out over sold and over bought line with pair name


---

## Re: DSS Bressert Strategy

**Apprentice** · Wed Nov 04, 2015 8:32 am

Unfortunately, we can not help you.
Ex4 is encrypted.


---

## Re: DSS Bressert Strategy

**Apprentice** · Wed Dec 14, 2016 3:49 am

Strategy was revised and updated.


---

## Re: DSS Bressert Strategy

**amazon1a** · Tue Feb 13, 2018 12:52 pm

Hi Apprentice, Long time since I worked with this Strategy. Does not seem to be working now. Control panel is set to trade, Yes, but the Strategy bar says No. Can you check it? Thanks, AG


---

## Re: DSS Bressert Strategy

**Apprentice** · Fri Feb 16, 2018 3:28 pm

I failed to confirm.
Works in simulator mode and on the back tester.
Will test on demo next week.


---

## Re: DSS Bressert Strategy

**sathiam** · Wed Jun 09, 2021 7:53 am

Hi,

I get an error when attempting to back test the strategy.

I have downloaded and installed the strategy file. What am i missing?


---

## Re: DSS Bressert Strategy

**Apprentice** · Thu Jun 10, 2021 9:47 am

If you do not already have it installed.
You need to install the DSS indicator.

You can find it here.
[viewtopic.php?f=17&t=1855](https://fxcodebase.com/code/viewtopic.php?f=17&t=1855)
