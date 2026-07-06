# Deviation Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61365  
> Forum: 17 · Topic 61365 · 6 post(s)


---

## Deviation Oscillator

**Apprentice** · Thu Oct 23, 2014 8:41 am

![Deviation Oscillator.png](images/96697/Deviation%20Oscillator.png)



As volatility oscillator, will present the Price-MA difference
Normalized, within range of last N differences
 pd:=C-Mov(C,x,E);
hpd:=Max(pd,x2);
lpd:=Min(pd,x2);
nf:=200/(hpd-lpd);
Deviation=((pd-lpd)*nf)-100

 [Deviation Oscillator.lua](files/96697/Deviation%20Oscillator.lua)

 [Deviation Oscillator with Alert.lua](files/96697/Deviation%20Oscillator%20with%20Alert.lua)

The indicator was revised and updated


---

## Re: Deviation Oscillator

**Alexander.Gettinger** · Mon Mar 09, 2015 3:49 pm

MQL4 version of Deviation oscillator: [viewtopic.php?f=38&t=61979](https://fxcodebase.com/code/viewtopic.php?f=38&t=61979).


---

## Re: Deviation Oscillator

**Coondawg71** · Tue Apr 21, 2015 5:31 pm

Can we please add Alert functions to the Deviation Oscillator in Lua please.

Alert would be triggered upon extreme values of oscillator reaching +90 and -90.

Thanks!!!

sjc


---

## Re: Deviation Oscillator

**Apprentice** · Thu Apr 23, 2015 4:33 am

Deviation Oscillator with Alert Added


---

## Re: Deviation Oscillator

**Apprentice** · Mon Dec 14, 2015 5:18 am

Dec 14, 2015: Compatibility issue Fixed. _Alert helper is not longer needed.

If you want to use updated version of this indicator,
please make sure to use TS Version 01.14.101415. or higher.


---

## Re: Deviation Oscillator

**Apprentice** · Wed Aug 02, 2017 7:39 am

The indicator was revised and updated.
