# Alternative OBV

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60338  
> Forum: 17 · Topic 60338 · 6 post(s)


---

## Alternative OBV

**Apprentice** · Sat Feb 22, 2014 6:56 am

![Alternative OBV.png](images/92823/Alternative%20OBV.png)



The classic formula
Close > previousClose
OBV = OBVprevious + VOLUME
 Close < previousClose
OBV = OBVprevious - VOLUME
IF Close = previousClose
OBV = previousOBV

1. Alternative
(Close > Open)
OBV = previousOBV + (Volume* (Close-Open) / (High-Low));
(Close < Open)
OBV = previousOBV - (Volume * (Open-Close) / (High-Low));

2. Alternative
OBV= previousOBV + (Volume * (High-Open) / (High-Low)) - (Volume * (Open-Low) / (High-Low))

 [Alternative OBV.lua](files/92823/Alternative%20OBV.lua)

MT4/MQ4 version
[viewtopic.php?f=38&t=70136](https://fxcodebase.com/code/viewtopic.php?f=38&t=70136)


---

## Re: Alternative OBV

**asedic** · Thu Aug 06, 2015 3:32 pm

Hi Appretince, thanks for this indicator. I really appreciate your work.

Is it possible to make version of this indicator with option of choice of different data source? I would like to use this formula for analysis of some other active indicators?

Thanks.


---

## Re: Alternative OBV

**Apprentice** · Wed Jul 19, 2017 8:23 am

The indicator was revised and updated.


---

## Re: Alternative OBV

**TastyTreats** · Thu Jul 02, 2020 6:42 pm

Hi Apprentice

Is it possible to get this in MT4 flavour?

Thanks


---

## Re: Alternative OBV

**Apprentice** · Fri Jul 03, 2020 4:20 am

Your request is added to the development list.
Development reference 1617.


---

## Re: Alternative OBV

**Apprentice** · Tue Jul 07, 2020 8:28 am

MT4/MQ4 version
[viewtopic.php?f=38&t=70136](https://fxcodebase.com/code/viewtopic.php?f=38&t=70136)
