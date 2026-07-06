# Tick Volume Percentage Change

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62242  
> Forum: 17 · Topic 62242 · 4 post(s)


---

## Tick Volume Percentage Change

**Apprentice** · Thu May 21, 2015 8:32 am

![Tick Volume Percentage Change.png](images/100582/Tick%20Volume%20Percentage%20Change.png)



Based on request.
[viewtopic.php?f=27&t=62236](https://fxcodebase.com/code/viewtopic.php?f=27&t=62236)
Is calculated as.
Volume / (Previous Volume / 100)
If normalized
Volume / (Previous Volume / 100) -100

 [Tick Volume Percentage Change.lua](files/100582/Tick%20Volume%20Percentage%20Change.lua)


---

## Re: Tick Volume Percentage Change

**nookie** · Tue May 26, 2015 8:57 am

Can we tweak the formula a bit ?

Formula:
 PerChg = 100 * (Price - Price[n]) / Price[n]
where
 n = calculation time period
 Price[n] = the price n periods ago

This indicator is a fast and simple method of watching price fluctuations on a bar-by-bar basis depicting price inconstancy.

No smoothing or MVA added is needed, only this formula please


---

## Re: Tick Volume Percentage Change

**Apprentice** · Thu May 28, 2015 4:48 am

Try percent change.
[viewtopic.php?f=17&t=6522&p=100645&hilit=Change#p100645](https://fxcodebase.com/code/viewtopic.php?f=17&t=6522&p=100645&hilit=Change#p100645)


---

## Re: Tick Volume Percentage Change

**Apprentice** · Fri Jul 06, 2018 6:38 am

The indicator was revised and updated.
