# Equilibrium Cross

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61357  
> Forum: 17 · Topic 61357 · 11 post(s)


---

## Equilibrium Cross

**Apprentice** · Wed Oct 22, 2014 4:39 am

![Equilibrium Cross.png](images/96661/Equilibrium%20Cross.png)



Based on request.
[viewtopic.php?f=27&t=61351](https://fxcodebase.com/code/viewtopic.php?f=27&t=61351)
Will present the arrow for each DMI DI + / DI Cross

 [Equilibrium Cross.lua](files/96661/Equilibrium%20Cross.lua)

This indicator provides Audio / Email Alerts on DMI Indicator component cross.

 [Equilibrium Cross with Alarm.lua](files/96661/Equilibrium%20Cross%20with%20Alarm.lua)

The indicator was revised and updated


---

## Re: Equilibrium Cross

**paololuigi** · Wed Oct 22, 2014 11:06 am

over all many thanks for your work

i write cause i want to know if is possible add a sound and an alert message each time the indicator draw an arrow up or down

thank you in advance


---

## Re: Equilibrium Cross

**Apprentice** · Thu Oct 23, 2014 3:00 am

Your request is added to the development list.


---

## Re: Equilibrium Cross

**Apprentice** · Fri Oct 24, 2014 5:09 am

Equilibrium Cross with Alarm.lua Cross.

One exciting news.
Alert even trade functionality should get native support within Indicator,
In the coming TS update. Releasing date is still Tentative.
Use of _Alert helper and external libraries then will not be necessary.


---

## Re: Equilibrium Cross

**copperwasher7** · Thu Feb 05, 2015 11:14 am

> **Apprentice wrote:**
>
>
> Equilibrium Cross.png
>
>
> Based on request.
> [viewtopic.php?f=27&t=61351](https://fxcodebase.com/code/viewtopic.php?f=27&t=61351)
> Will present the arrow for each DMI DI + / DI Cross
>
>
> Equilibrium Cross.lua
>
>
> This indicator provides Audio / Email Alerts on DMI Indicator component cross.
>
>
> Equilibrium Cross with Alarm.lua
>
>
> In order to Audio/Email alerts could work, install and activate Alert Signal.
>
>
> _Alert.lua

Hi Apprentice

This is a very useful indicator - thank you

Can you please consider and hopefully add the following functions...
* The ability to select specific 'charts' for the alert: Example: selection of the chart 60min and 1 day for instance, or selection of the 30min, 60min, 4 hours ??

* The pop-up alert to 'pop up' across other working apps programs like word, excel, outlook ??

* The alert to display with chart time it relates to i.e. 60min chart??

* Specify the actual DI+ cross above DI- or DI+ cross below DI- (Rising signal or falling signal)??

*DI+ value, DI- value, ADX value

* That the pop up displays the Date and time of the latest alert also??

Example:
*****************************************
* DMI CROSSOVER ALERT
* 4 Feb 2015
* 13.41
* EUR/USD
*
* DI + crossed above DI- (RISING)
* DI+ 45.36 DI- 11.128 ADX 55.897
* 60Min Chart
*
* [OK]
*****************************************

With many thanks always

Copperwasher7


---

## Re: Equilibrium Cross

**Apprentice** · Sun Feb 08, 2015 2:05 am

Your request is added to the development list.


---

## Re: Equilibrium Cross

**nookie** · Sat Aug 22, 2015 10:20 am

Please Apprentice add if possible a custom level that can be set to a value from 5 to 30, with the following rule:

If DMI+ < Level then no alarm
If DMI- < Level then no alarm
if the cross happens from high to low no alarm

and if the cross has happened below this level, alarm trigger when DMI +- reach the level, is this possible ?


---

## Re: Equilibrium Cross

**Apprentice** · Wed Aug 26, 2015 9:29 am

So you're not interested in DMI + / DMI- cross.
Rather in DMI + / Level & DMI- / Level Cross?


---

## Re: Equilibrium Cross

**nookie** · Thu Aug 27, 2015 10:31 am

Yes


---

## Re: Equilibrium Cross

**Apprentice** · Mon Dec 14, 2015 6:34 am

Dec 14, 2015: Compatibility issue Fixed. _Alert helper is not longer needed.

If you want to use updated version of this indicator,
please make sure to use TS Version 01.14.101415. or higher.


---

## Re: Equilibrium Cross

**Apprentice** · Wed Aug 02, 2017 7:22 am

The indicator was revised and updated.
