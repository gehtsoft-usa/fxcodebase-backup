# Pivot based oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63526  
> Forum: 17 · Topic 63526 · 5 post(s)


---

## Pivot based oscillator

**Apprentice** · Wed May 25, 2016 9:15 am

![EURUSD m1 (05-25-2016 1540).png](images/106468/EURUSD%20m1%20%2805-25-2016%201540%29.png)



Based on request.
[viewtopic.php?f=27&t=63524](https://fxcodebase.com/code/viewtopic.php?f=27&t=63524)

Differential 1: Fast_MA-Slow_MA
Differential 2: Medium_MA-Slow_MA
Differential 3 : Fast_MA-Medium_MA
PP : ((Differential 1+Differential 2+Differential 3)/3)

 [Pivot based oscillator.lua](files/106468/Pivot%20based%20oscillator.lua)

 [AhrensMovingAverage Pivot based oscillator.lua](files/106468/AhrensMovingAverage%20Pivot%20based%20oscillator.lua)

Ahrens Moving Average.lua is available here.
[viewtopic.php?f=17&t=62629&p=106064&hilit=Ahrens#p106064](https://fxcodebase.com/code/viewtopic.php?f=17&t=62629&p=106064&hilit=Ahrens#p106064)


---

## Re: Pivot based oscillator

**chipsoft** · Fri Jan 20, 2017 12:58 pm

Hi Apprentice,

Could you please make a change in Pivot based oscillator. The original calculation method was:
Differential 1: Fast_MA-Slow_MA
Differential 2: Medium_MA-Slow_MA
Differential 3 : Fast_MA-Medium_MA
PP : ((Differential 1+Differential 2+Differential 3)/3)

But I want to change PP in the the above formula and also Overall calculation. So Kindly note down new calculations as:

PivotOsc = ((Diff1 + Diff2 + Diff3) / PP)

Differential 1: Fast_MA-Slow_MA
Differential 2: Medium_MA-Slow_MA
Differential 3 : Fast_MA-Medium_MA
PP: ((H + L + C) / 3)
Also all MA (Fast, Medium and Slow) are calculated (H + L + C) / 3 instead of (H+L)/2.

Kindly call it PivotOsc and convert this into MT4 also.

Thanks


---

## Re: Pivot based oscillator

**Apprentice** · Sat Jan 21, 2017 4:29 am

Indicator was revised and updated.


---

## Re: Pivot based oscillator

**Apprentice** · Sat Jan 21, 2017 4:42 am

![EURUSD m1 (07-17-2016 2300).png](images/110637/EURUSD%20m1%20%2807-17-2016%202300%29.png)



Differential 1: Fast_MA of Typical Price-Slow_MA of Typical Price
Differential 2: Medium_MA of Typical Price -Slow_MA of Typical Price
Differential 3 : Fast_MA of Typical Price -Medium_MA of Typical Price
Pivot oscillator = ((Diff1 + Diff2 + Diff3) / Typical Price)

 [Pivot Oscillator.lua](files/110637/Pivot%20Oscillator.lua)

MT4/Mq4 version
[viewtopic.php?f=38&t=64319](https://fxcodebase.com/code/viewtopic.php?f=38&t=64319)


---

## Re: Pivot based oscillator

**Apprentice** · Mon Feb 05, 2018 8:28 am

The Indicator was revised and updated.
