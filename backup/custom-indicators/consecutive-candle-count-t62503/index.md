# Consecutive Candle Count

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62503  
> Forum: 17 · Topic 62503 · 9 post(s)


---

## Consecutive Candle Count

**Apprentice** · Wed Aug 05, 2015 4:15 am

![Consecutive Candle Count.png](images/101665/Consecutive%20Candle%20Count.png)



Indicator will provide
longest consecutive number of up candles
longest consecutive number of down candles
If Period is set to Zero All available data is checked.
otherwise only last N bender is taken into account.

 [Consecutive Candle Count.lua](files/101665/Consecutive%20Candle%20Count.lua)

Of which Conditional Consecutive Candle Count will only count those with given minimum

 [Conditional Consecutive Candle Count.lua](files/101665/Conditional%20Consecutive%20Candle%20Count.lua)


---

## Re: Consecutive Candle Count

**Alexander.Gettinger** · Mon Aug 31, 2015 11:39 am

MQL4 version of Consecutive Candle Count indicator: [viewtopic.php?f=38&t=62613](https://fxcodebase.com/code/viewtopic.php?f=38&t=62613).


---

## Re: Consecutive Candle Count

**gnarlyarbitrage** · Tue Feb 09, 2016 4:38 am

what if you did something like out of X time-range find the mean of trends at least Y long
or the mean of candles per trend at least X long in Y time-frame
thanks


---

## Re: Consecutive Candle Count

**Apprentice** · Tue Feb 09, 2016 6:47 am

Can you explain your idea further.


---

## Re: Consecutive Candle Count

**gnarlyarbitrage** · Thu Feb 11, 2016 1:36 am

time frame = 100 (x)
y = 5
z = ? (how many trends were 5 candles long at least)

in a text format

or

the average number of candles per trend out of x candles


---

## Re: Consecutive Candle Count

**Apprentice** · Sun Feb 14, 2016 4:13 am

Conditional Consecutive Candle Count Added.


---

## Re: Consecutive Candle Count

**AlphaBagel** · Sat Apr 02, 2016 4:51 pm

Does anyone know if there is a consecutive candle alert out there? One where you can define if the alert is for a bear or bull run?

Example
Consecutive candles : 6
Direction : Bull

After 6 consecutive Bull closes Alert is triggered.

Thanks!


---

## Re: Consecutive Candle Count

**Apprentice** · Tue Apr 05, 2016 6:47 am

Something like this?
[viewtopic.php?f=31&t=3655&p=11995&hilit=Consecutive#p11995](https://fxcodebase.com/code/viewtopic.php?f=31&t=3655&p=11995&hilit=Consecutive#p11995)


---

## Re: Consecutive Candle Count

**Apprentice** · Fri Jul 13, 2018 4:22 am

The indicator was revised and updated.
