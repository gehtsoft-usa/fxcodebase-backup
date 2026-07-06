# Mean Reversion Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61144  
> Forum: 31 · Topic 61144 · 9 post(s)


---

## Mean Reversion Strategy

**Apprentice** · Sun Sep 14, 2014 6:10 am

![Mean reversion strategy.png](images/95876/Mean%20reversion%20strategy.png)



Based on request.
[viewtopic.php?f=27&t=61143#p95867](https://fxcodebase.com/code/viewtopic.php?f=27&t=61143#p95867)

Price Below Lower Bollinger band
Stochastic K <30
And for following period.
RSI is Up
Stochastic K is Up.

Exit Long Price > Bollinger Mid band.

Opposite for a Short....

 [Mean reversion strategy.lua](files/95876/Mean%20reversion%20strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Mean Reversion Strategy

**CHECEZAR** · Fri Oct 03, 2014 11:41 am

Hi all, I need a very big help. Could someone please add to this strategy the option to reverse the signal? For example if the strategy indicates purchase I can tell that you sell, not buy. Thanks for the help, I'll be waiting.


---

## Re: Mean Reversion Strategy

**Apprentice** · Sat Oct 04, 2014 2:21 am

Added to development list.


---

## Re: Mean Reversion Strategy

**CHECEZAR** · Mon Oct 06, 2014 6:08 pm

Here is a strategy that can help understand incorporate what I am requesting.

With this strategy, you have two options one of which is possible to obtain signals contrary to what is stated strategy and adding to that instead of going to operate directly, what it does is place orders either few pips above the price given or few pips less.


---

## Re: Mean Reversion Strategy

**moomoofx** · Mon Nov 17, 2014 1:34 am

As requested, the option to reverse the signals (for both entry and exit) has been added to the strategy. Please redownload to get the updated version.

Cheers,
MooMooForex


---

## Re: Mean Reversion Strategy

**Sviet531** · Thu Mar 24, 2016 10:50 am

Hello,

can you change the strategy ?

I would like just work with the BB. I would like desactivate RSI and stochastic.

If the price touch on live the bb with deviation 3.0 take a position buy/sell at against trend.

Thank you for your attention.


---

## Re: Mean Reversion Strategy

**Sviet531** · Thu Mar 24, 2016 10:58 am

And, can you too put the strategie in m2 ?


---

## Re: Mean Reversion Strategy

**Apprentice** · Fri Mar 25, 2016 4:49 am

Try this version.

 [Mean reversion strategy.lua](files/105466/Mean%20reversion%20strategy.lua)

Will allow you to input any time frame supported by TS.


---

## Re: Mean Reversion Strategy

**Apprentice** · Fri Dec 16, 2016 6:28 am

Strategy was revised and updated.
