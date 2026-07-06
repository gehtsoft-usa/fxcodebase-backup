# TWO MA WITH MOMENTUM STRATEGY

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=62771  
> Forum: 31 · Topic 62771 · 4 post(s)


---

## TWO MA WITH MOMENTUM STRATEGY

**Apprentice** · Mon Oct 12, 2015 4:26 am

![TWO MA WITH MOMENTUM STRATEGY.png](images/102778/TWO%20MA%20WITH%20MOMENTUM%20STRATEGY.png)



INDICATORS

1.MA1: PREFERABLY MVA OR EMA PERIOD 10
2.MA2: PREFERABLY MVA OR EMA PERIOD 20
3.MOMENTUM :
period:12
smoothening method:mva or ema
smoothening period:20
BUY LEVEL 100
SELL LEVEL 100

BUY;
1. MOMENTUM > BUY LEVEL AND MOMUNTUM (PERIOD)>MOMENTUM(PERIOD-1)
2.MA1.>MA2
3.PRICE CROSS OVER MA1

SELL;

1. MOMENTUM < SELL LEVEL AND MOMUNTUM (PERIOD)<MOMENTUM(PERIOD-1)
2.MA1<MA2
3.PRICE CROSS UNDER MA1

 [TWO MA WITH MOMENTUM STRATEGY.lua](files/102778/TWO%20MA%20WITH%20MOMENTUM%20STRATEGY.lua)

Smoothed Momentum Indicator can be found here.
[viewtopic.php?f=17&t=62770](https://fxcodebase.com/code/viewtopic.php?f=17&t=62770)

The Strategy was revised and updated on January 22, 2019.


---

## Re: TWO MA WITH MOMENTUM STRATEGY

**rogueking** · Tue Jul 12, 2016 6:42 am

Hello Apprentice,

I've been testing this strategy for a while now, but I realized something odd:

It only opens buy trades. I've tested on multiple accounts and multiple time-frames.

Do you know what the problem could be?


---

## Re: TWO MA WITH MOMENTUM STRATEGY

**Apprentice** · Mon Aug 08, 2016 6:50 am

![EURUSD H1 (08-08-2016 1301).png](images/107530/EURUSD%20H1%20%2808-08-2016%201301%29.png)



This test shows both positions, long & short were opened.


---

## Re: TWO MA WITH MOMENTUM STRATEGY

**Apprentice** · Sat Jan 06, 2018 8:25 am

The strategy was revised and updated.
