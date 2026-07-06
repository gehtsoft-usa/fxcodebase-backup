# Moving Average, Moving Average Envelope Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=60897  
> Forum: 31 · Topic 60897 · 13 post(s)


---

## Moving Average, Moving Average Envelope Strategy

**Apprentice** · Mon Jul 14, 2014 3:46 am

![Moving Average, Moving Average Envelope Strateg.png](images/94877/Moving%20Average%20Moving%20Average%20Envelope%20Strateg.png)



Based on request.
[viewtopic.php?f=27&t=60890](https://fxcodebase.com/code/viewtopic.php?f=27&t=60890)

Open Long
On Averages / MAE Top Line CrossOver
Open Short
On Averages / MAE Bottom Line CrossUnder

 [MA MAE Strategy.lua](files/94877/MA%20MAE%20Strategy.lua)

Averages Indicator is required.
[viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)
MAE AVERAGES.lua is Optional.
[viewtopic.php?f=17&t=658&hilit=MAE+Averages](https://fxcodebase.com/code/viewtopic.php?f=17&t=658&hilit=MAE+Averages)

The Strategy was revised and updated on December 11, 2018.


---

## Re: Moving Average, Moving Average Envelope Strateg

**volnmar** · Mon Jul 14, 2014 2:31 pm

Thank you very much, you are the best!


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Thu Jul 17, 2014 4:37 am

Can you please add option to open position in opposite direction, let rules be the same, only direction changed (buy signal = open short).

And option to open opposite direction when SL is hit. New position has same or greater TP as SL of previous trade.


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Fri Aug 01, 2014 2:46 am

Can somebody help me with this please?


---

## Re: Moving Average, Moving Average Envelope Strategy

**TonnyPaka** · Tue Aug 05, 2014 2:45 am

I want to try that new setting too...


---

## Re: Moving Average, Moving Average Envelope Strategy

**Apprentice** · Tue Aug 05, 2014 3:56 am

Please Re-Download


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Tue Aug 05, 2014 8:15 am

Thank you very much


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Sun Aug 10, 2014 1:49 am

new edit needed: do not open new trade when SL or TP is hit.. (now it opens new trades in oposite directions).... wait for new signal


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Tue Aug 12, 2014 3:36 am

Second edit needed: Please add VIDIA, MAMA, EHLERS FILTER,MEDIAN FILTER, FRAMA, NONLINEAR LAGUERRE FILTER to make channel with it.


---

## Re: Moving Average, Moving Average Envelope Strategy

**Apprentice** · Wed Aug 13, 2014 6:19 am

Unfortunately Averages indicator does not support the specified indicator.
We need to re-write it from from scratch.


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Thu Aug 14, 2014 12:46 am

Thank you

And how about that opening positions after SL ad TP? It makes me big problems when backtesting. I don´t know if it is possible to set something up in options.
Easiest is to open after signal, and close after opposite signal, or get out on SL or TP (fixed pips) if it comes sooner. Then it is necessary to wait for next new signal, do not open opposite position immediately.

In second edit i forgot :Three Filtered MA.lua - there is Three-Pole Super Smoother filter inside this indi and it looks most interesting for new backtest.

**FRAMA as short moving average, (not channel) looks great for system, can you please add it?**


---

## Re: Moving Average, Moving Average Envelope Strategy

**volnmar** · Fri Aug 29, 2014 2:35 pm

Anything new please?


---

## Re: Moving Average, Moving Average Envelope Strategy

**Apprentice** · Sun Dec 11, 2016 7:22 am

Strategy was revised and updated.
