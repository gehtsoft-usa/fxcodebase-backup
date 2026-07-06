# Directional Movement Index (DMI) Positive Negative Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63024  
> Forum: 31 · Topic 63024 · 8 post(s)


---

## Directional Movement Index (DMI) Positive Negative Strategy

**Apprentice** · Sun Jan 10, 2016 7:50 am

![EURUSD H1 (01-10-2016 1315).png](images/104208/EURUSD%20H1%20%2801-10-2016%201315%29.png)



Based on request.
[viewtopic.php?f=27&t=63022](https://fxcodebase.com/code/viewtopic.php?f=27&t=63022)

Open Long
DIP > EntryLevel
DIM < ConfirmationLevel

Open Short
DIM > EntryLevel
DIP < ConfirmationLevel

 [Directional Movement Index (DMI) Positive Negative Strategy.lua](files/104208/Directional%20Movement%20Index%20%28DMI%29%20Positive%20Negative%20Strategy.lua)

The Strategy was revised and updated on January 19, 2019.


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**Apprentice** · Fri Mar 25, 2016 4:20 am

![EURUSD H1 (03-25-2016 0946).png](images/105460/EURUSD%20H1%20%2803-25-2016%200946%29.png)



Open Long
DIP > EntryLevel
DIM < ConfirmationLevel
ADX > Entry Level

Open Short
DIM > EntryLevel
DIP < ConfirmationLevel
ADX > Entry Level

Exit
If ADX CrossUnder Exit Level

 [DMI Strategy with ADX Filter.lua](files/105460/DMI%20Strategy%20with%20ADX%20Filter.lua)


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**PrinceJ58** · Mon Mar 28, 2016 8:46 pm

Hey people this strategy is awesome, I got it to work on my virtual/demo account quite perfectly, however when i placed it on my real/live account, I got a error, something like "compary numbers..."nill. And it paused all the pairs I activated it on. What could be some of the likely causes of this, it is such a great strategy. Next thing how far does the trailing stop keep from the price, is it based on the stop loss?


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**Apprentice** · Tue Mar 29, 2016 3:09 am

Fixed.


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**IQFX36** · Sun Sep 25, 2016 9:32 am

I cant download:

DMI Strategy with ADX Filter.lua

Help please!!!


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**Avignon** · Sun Sep 25, 2016 4:52 pm

This is sad, especially with me it works.

A little more precision/explanation ?


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**Apprentice** · Sat Dec 17, 2016 10:46 am

Strategy was revised and updated.


---

## Re: Directional Movement Index (DMI) Positive Negative Strat

**thebestsmoothjazz** · Sun Jan 29, 2017 8:04 pm

Hello, is it possible to get multiple entry and exit options? I usually have between 5 or 10 of these strategies running at a time. Very profitable but would like to condense the multiple entry and exit points into one strategy.

Something like this

**DMI Calculation**

Period
EntryLevel1
EntryLevel 2
ExtryLevel 3
EntryLevel 4
EntryLevel 5
ConfirmationLevel 1
ConfirmationLevel 2
ConfirmationLevel 3
ConfirmationLevel 4
ConfirmationLevel 5

**ADX Calculation**

Period
EntryLevel 1
EntryLevel 2
EntryLevel 3
EntryLevel 4
EntryLevel 5
ExitLevel 1
ExitLevel 2
ExitLevel 3
ExitLevel 4
ExitLevel 5

Thanks,
Bryan
