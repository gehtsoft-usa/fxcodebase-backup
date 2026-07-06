# Timed Tick DNC

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62665  
> Forum: 17 · Topic 62665 · 9 post(s)


---

## Timed Tick DNC

**Apprentice** · Fri Sep 18, 2015 2:50 am

![Timed Tick DNC.png](images/102396/Timed%20Tick%20DNC.png)



Your regular Donchian Channel indicator.
Period is defined in seconds, not periods (candles).

 [Timed Tick DNC.lua](files/102396/Timed%20Tick%20DNC.lua)


---

## Re: Timed Tick DNC

**fxcyberman** · Fri Sep 18, 2015 1:30 pm

When i choose NO to "Analyze the current period", i got error message as below
An error occurred during the calculation of the indicator 'TIMED TICK DNC 2'. The error details: Timed Tick DNC.lua:109: Index is out of range.


---

## Re: Timed Tick DNC

**ekonom29** · Sat Sep 19, 2015 1:55 pm

tq aprentice will try this when market open

btw i already search do u have timed oscilator?

 example

i want to set fast period 5seconds and slow period in 7seconds is it possible?


---

## Re: Timed Tick DNC

**Apprentice** · Sun Sep 20, 2015 5:52 am

Try it now.
ekonom29, can you explain,

> i want to set fast period 5seconds and slow period in 7seconds is it possible?

fast period / 5seconds of what?


---

## Re: Timed Tick DNC

**ekonom29** · Mon Sep 21, 2015 12:01 am

> **Apprentice wrote:**
> Try it now.
> ekonom29, can you explain,
>
>
> > i want to set fast period 5seconds and slow period in 7seconds is it possible?
>
>
> fast period / 5seconds of what?

sorry for not clear,

what i mean is, the scilator calculate the fast mva by 5 seconds and slow mva by 7 seconds

the oscilator using time to calculate the mva instead of bar, is it psiblle to make it in tick chart to?


---

## Re: Timed Tick DNC

**Apprentice** · Mon Sep 21, 2015 2:13 am

I believe Influx is what you're looking for.
[viewtopic.php?f=17&t=62160&hilit=timed](https://fxcodebase.com/code/viewtopic.php?f=17&t=62160&hilit=timed)


---

## Re: Timed Tick DNC

**ekonom29** · Tue Sep 22, 2015 4:18 am

> **Apprentice wrote:**
> I believe Influx is what you're looking for.
> [viewtopic.php?f=17&t=62160&hilit=timed](https://fxcodebase.com/code/viewtopic.php?f=17&t=62160&hilit=timed)

hi apprentice, i tried the influx but somehow it behave diffrently

could u convert basic oscilator from fxcm platform to used time to calculte the period

tq for your reply


---

## Re: Timed Tick DNC

**tmdabc** · Fri Oct 23, 2015 2:56 pm

looks good，thanks


---

## Re: Timed Tick DNC

**Apprentice** · Wed Sep 12, 2018 5:25 am

The indicator was revised and updated.
