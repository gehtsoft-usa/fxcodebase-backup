# Standard Deviation MT4 formula

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=6299  
> Forum: 17 · Topic 6299 · 2 post(s)


---

## Standard Deviation MT4 formula

**Nikolay.Gekht** · Mon Sep 05, 2011 10:27 am

The indicator has no practical meaning itself, but is useful for whose who wants to make their indicators to calculate the same values as MT4 indicators based on the standard deviation do.

The problem is that MT4's [`iStdDev`](http://docs.mql4.com/indicators/iStdDev) function differs from [classic standard deviation formula](https://en.wikipedia.org/wiki/Standard_deviation) used in Excel, Marketscope and hundreds of other applications.

The problem was discussed on [mql4.com](http://forum.mql4.com/10604):

> **mt4 support wrote:**
>
>
> > **user wrote:**
> > If I calculate the standard deviation for a set of prices held in an array in MT4 I get a completely different result compared to calculating the STD in Excel using the STDEVPA function and the same data held in the array.
>
>
> Standard Deviation formula is different calculated in different platforms (groups, individuals), mostly is based on change on smoothed price (ex.: get iStdDev from Moving Average indicator), but you can do the same but with actual Close prices ( or OHLC ) and by percent changes with same data (periods or ticks) and compare in MT4 and excel.

So, here is a port of MT4's [iStdDev](http://codebase.mql4.com/301) indicator to Lua.

Download:

 [MT4_STDDEV.lua](files/14535/MT4_STDDEV.lua)

The indicator was revised and updated


---

## Re: Standard Deviation MT4 formula

**Apprentice** · Thu Mar 16, 2017 5:47 am

Indicator was revised and updated.
