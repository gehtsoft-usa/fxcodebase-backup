# Better Volume

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=2161  
> Forum: 17 · Topic 2161 · 11 post(s)


---

## Better Volume

**Apprentice** · Mon Sep 13, 2010 6:03 pm

![Better VOLUME.png](images/4464/Better%20VOLUME.png)



Logarithmic Scaling have three modes.
Linear
Logarithmic (Base 10)
1, 10, 100, 1000 steps, the same spacing between steps.
Semi Logarithmic (Base 2).
1, 2, 4, 8, 16, the same spacing between steps, each step, it has twice the weight of the previous one.

 [Better Volume.lua](files/4464/Better%20Volume.lua)


---

## Re: Better Volume

**DS0167** · Mon Sep 13, 2010 6:25 pm

Hello,

Could you please tell us how the volume is calculated with this tool? which data are considered?

Thank you.

Kind regards,
DS0167


---

## Re: Better Volume

**Apprentice** · Tue Sep 14, 2010 10:51 am

This indicator presents Volume Data (Tick Volume).
Which is available via the platform.

However, because user requirements, Style option was added,
 it have the moving average and different ways of the bar coloring.


---

## Re: Better Volume

**Apprentice** · Thu Sep 30, 2010 12:46 pm

As you know, there is no real forex volume, we are talking about Tick volume, its value can vary because of different sources of liquidity for an individual broker, applied algorithms to calculate the Tick Volume, Number of decimal places.

Are comparable only to the same data source.
I read somewhere that the Tick Volume has 85 percent correlation with the right stuff.

As regards the second problem, I'll tell when I learn more.


---

## Re: Better Volume

**patick** · Tue Oct 05, 2010 1:44 am

I'm not sure if this patch is responsible, fxcodebase.com/code/viewtopic.php?f=31&t=2337, but the volumes bars are now updating/refreshing themselves correctly.


---

## Re: Better Volume

**miocker** · Tue Oct 05, 2010 5:15 am

Hello, patrick

Yes, you are correct. The patch includes the fix for the incorrect volume.


---

## Re: Better Volume

**patick** · Tue Oct 05, 2010 6:24 am

Excellent! Thank you very much!

I just made a small trade using the volume... it was a winner


---

## Re: Better Volume

**Nikolay.Gekht** · Tue Oct 05, 2010 8:05 am

There is a problem in 082610 release with volume.

Please download and re-install offical 091010 release (just go to the "download software" section on your broker site and download and install Trading Station) or use [Marketscope 2.0 Autotrading Patch](https://fxcodebase.com/code/viewtopic.php?f=31&t=2337) which incorporates all changes made in 091010 release plus a lot of additional changes which will be released officially later but will let you use these many new indicator, signals and strategies right now.


---

## Re: Better Volume

**yangzj** · Tue Oct 05, 2010 12:56 pm

It's a very helpful indicator,Thank you.


---

## Re: Better Volume

**Apprentice** · Tue Oct 26, 2010 6:36 am

Update.

Logarithmic Scaling added.
Grid Added.
Cursor Added.
Resolved problems with the Tick and Monthly time frame.


---

## Re: Better Volume

**Apprentice** · Mon Feb 05, 2018 9:08 am

The Indicator was revised and updated.
