# ADXVMA

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65817  
> Forum: 17 · Topic 65817 · 7 post(s)


---

## ADXVMA

**Apprentice** · Fri Mar 09, 2018 7:38 am

![EURNZD D1 (03-09-2018 1137).png](images/118100/EURNZD%20D1%20%2803-09-2018%201137%29.png)



Based on the request.
[viewtopic.php?f=27&t=65813](https://fxcodebase.com/code/viewtopic.php?f=27&t=65813)

The ADXVMA is a volatility based moving average with the volatility being determined by the value of the ADX. The ADXVMA provides levels of support during uptrends and resistance during downtrends.

 [ADXVMA.lua](files/118100/ADXVMA.lua)

ADXVMA.lua based strategy.
[viewtopic.php?f=31&t=65824](https://fxcodebase.com/code/viewtopic.php?f=31&t=65824)


---

## Re: ADXVMA

**Paul W** · Sat Mar 10, 2018 1:52 pm

interesting

would like to test - and if possible, could it be configured to support tick-charts ?

btw - not sure if the link is correct - this is what downloaded

thx


---

## Re: ADXVMA

**Apprentice** · Sun Mar 11, 2018 4:59 am

Line 24
indicator:requiredSource(core.Tick);
Tick is supported.

Line 22
indicator:name("ADXVMA");
Indicator name is ADXVMA


---

## Re: ADXVMA

**Paul W** · Mon Mar 12, 2018 10:05 am

installed and runs on 1 minute and higher charts

however, a spastic error appears on tick-charts, and ADXVMA indicator will not load ?


---

## Re: ADXVMA

**Apprentice** · Tue Mar 13, 2018 6:36 am

Fixed.


---

## Re: ADXVMA

**Paul W** · Wed Mar 14, 2018 11:14 am

thanks

could ADXVMA Strategy be updated as well - including tick-chart support

much appreciated


---

## Re: ADXVMA

**Apprentice** · Wed Mar 14, 2018 5:27 pm

Tick ADXVMA Strategy added.
