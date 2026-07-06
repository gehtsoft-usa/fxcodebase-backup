# Tick DMI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=23859  
> Forum: 31 · Topic 23859 · 6 post(s)


---

## Tick DMI Strategy

**Apprentice** · Thu Sep 27, 2012 2:54 am

![Tick DMIADX.png](images/41012/Tick%20DMIADX.png)



Long
DI+/DI- CrossOver
Short
DI+/DI- CrossUnder

For signal filtering as a option you can use Tick ADX.
Then, DMI signal is respected, only id ADX is greater than a specified level.

 [Tick DMI Strategy.lua](files/41012/Tick%20DMI%20Strategy.lua)

For this strategy, you need to install, TickDmiAdx Indicator.
[viewtopic.php?f=17&t=16809&p=31015#p31015](https://fxcodebase.com/code/viewtopic.php?f=17&t=16809&p=31015#p31015)


---

## Re: Tick DMI Strategy

**Apprentice** · Fri Jan 05, 2018 8:14 am

The strategy was revised and updated.


---

## Re: Tick DMI Strategy

**Gilles** · Wed Nov 28, 2018 4:45 pm

Hi Apprentice,
I just downloaded the strategy and the indicator.
There is a serious problem with the indicator.

If we specify 1 period it sticks visually to the DMI of the trading station. But if we increase the number of periods it becomes imprecise.

Could you remedy that so that our assumptions are feasible.

Regards,
thanks


---

## Re: Tick DMI Strategy

**Apprentice** · Thu Nov 29, 2018 12:39 pm

Will try to optimize.
As you know, two versions of the indicator use different formulas.
Therefore, the results will never be the same.


---

## Re: Tick DMI Strategy

**Gilles** · Thu Dec 06, 2018 8:18 am

So the DMI signal is not respected. I do not understand the approach that led to this result so far from the real.

The whole concept is great but if the DMI is not respected, it ruins everything. Impossible to make a correct observation and correct this.

Dear Apprentice, Why create a different formula than the one that determines the DMI. If that is your goal, you should not call it DMI but otherwise.

What do you think dear Apprentice?


---

## Re: Tick DMI Strategy

**Apprentice** · Fri Dec 07, 2018 6:20 am

To calculate regular DMI you need bar source.
As I use Tick as the source was named Tick DMI.
Two can not have the same result, different data points are used as input.
