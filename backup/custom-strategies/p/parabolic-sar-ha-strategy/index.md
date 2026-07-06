# Parabolic SAR HA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=15116  
> Forum: 31 · Topic 15116 · 5 post(s)


---

## Parabolic SAR HA Strategy

**Apprentice** · Sat Mar 24, 2012 1:42 pm

![Parabolic SAR HA Strategy.png](images/28619/Parabolic%20SAR%20HA%20Strategy.png)



Long
SAR Uptrend

short
SAR Dowtrend

HA was used for confirmation.

Additional filter.
You can specify the minimum change in closing prices in a given period.
If the change is less than defined, the trade will not be executed.

I have the optional Exit conditions.
Trade can be closed if any of the components is contradictory.
(SAR or HA)

 [Parabolic SAR HA Strategy.lua](files/28619/Parabolic%20SAR%20HA%20Strategy.lua)

The Strategy was revised and updated on December 10, 2018.


---

## Re: Parabolic SAR HA Strategy

**briansummy** · Sat Mar 24, 2012 8:38 pm

Very nice Apprentice!


---

## Re: Parabolic SAR HA Strategy

**arnault0** · Fri Aug 16, 2013 5:23 am

Hello Apprentice,

Thank you for this strategy.
Could it be possible to modify a bit the strategy to have MVA indicator instead of HA. The strategy would be:
-if SAR up and as soon as price close>MVA then LONG
 Exit : as soon as price close crosses down MVA or SAR changes + maybe add a trailing stop that starts after price reaches a certain level
-if SAR down and as soon as price close<MVA then SHORT
 Exit : as soon as price close crosses up MVA or SAR changes + maybe add a trailing stop that starts after price reaches a certain level

Do you think this is possible?


---

## Re: Parabolic SAR HA Strategy

**Apprentice** · Mon Aug 19, 2013 1:51 am

This is possible.
Your request is added to the development list.


---

## Re: Parabolic SAR HA Strategy

**Apprentice** · Fri Dec 09, 2016 7:14 am

Strategy was revised and updated.
