# MA Delta Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=24271  
> Forum: 31 · Topic 24271 · 7 post(s)


---

## MA Delta Strategy

**Apprentice** · Wed Oct 10, 2012 5:15 am

![MA Delta Strategy.png](images/41755/MA%20Delta%20Strategy.png)



Long
Delta/ OS Line Crossover
Short
Delta/ OB Line Crossover

 [MA Delta Strategy.lua](files/41755/MA%20Delta%20Strategy.lua)

For this strategy, you must install the MA Delta indicator.
[viewtopic.php?f=17&t=24270](https://fxcodebase.com/code/viewtopic.php?f=17&t=24270)

The Strategy was revised and updated on December 10, 2018.


---

## Re: MA Delta Strategy

**Patrick Sweet** · Mon Oct 07, 2013 4:37 pm

For many indicators, we can choose 'DATA SOURCE' from indicators running in a given MarketScope Chart.

Would it be possible to add a DATA SOURCE TAB on the MA Delta Strategy like we have on the MA DELTA indicator?

Or do we need to specify specific data sources themselves in the strategy as the strategy runs independent of any MarketScope Chart/session which I am 99% certain is the case.

If I am correct, how do I proceed to be able to add a few prespecified data sources to this MA DELTA strategy?

Thanks for you help.


---

## Re: MA Delta Strategy

**Apprentice** · Tue Oct 08, 2013 2:28 am

Data sources must be encoded within strategy.
Can you make the list.


---

## Re: MA Delta Strategy

**Patrick Sweet** · Tue Oct 08, 2013 9:41 am

VWAP
VAMA
Let us leave it at that for now so I can see if the extra work requested is of enough value to pursue in strategy further.
THanks!


---

## Re: MA Delta Strategy

**Patrick Sweet** · Wed Oct 09, 2013 1:34 am

Hello Apprentice!

I realise this.

VWAP as a source is ok. It is a 'standard' data stream. It requires no extra specifications. It uses the timeframe of the Strategy.

VAMA however requires that #periods and price type be set.

Data Source: VAMA; Price Type: open, close, weighted, high, low; # Periods; 1-500.

On this note could we add a fuller range of AVERAGES to the MA DELTA indicator itself?...to include VAMA and VAMA Double SMOOTHED? Perhaps the full range of MA types in the AVERAGES.lua (adding VAMA and perhaps even VWAP to the MA DELTA indicator itself)?

Hope this helps. Thank


---

## Re: MA Delta Strategy

**Apprentice** · Wed Oct 09, 2013 1:16 pm

Your request is added to the development list.


---

## Re: MA Delta Strategy

**Apprentice** · Fri Dec 09, 2016 6:50 am

Strategy was revised and updated.
