# MTF StochRSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=14949  
> Forum: 31 · Topic 14949 · 6 post(s)


---

## MTF StochRSI Strategy

**Apprentice** · Tue Mar 20, 2012 8:53 am

![MTF StochRSI Strategy.png](images/28326/MTF%20StochRSI%20Strategy.png)



For Long Trade

Short Time Frame
K / D line Crossover
K line < OS

Long Time Frame
K line is in OS or Bullishand not above 75

Extra exit is added.
Exit on K / D line Crossounder (Short time Frame)

For short, we use inverse algorithm.

 [MTF StochRSI Strategy.lua](files/28326/MTF%20StochRSI%20Strategy.lua)

StochRSI indicator is required for this strategy.
[viewtopic.php?f=17&t=451&p=10039&hilit=StochRSI#p10039](https://fxcodebase.com/code/viewtopic.php?f=17&t=451&p=10039&hilit=StochRSI#p10039)


---

## Re: MTF StochRSI Strategy

**ThemBonez** · Wed Jun 13, 2012 5:33 pm

Hello,
Could you post the same strategy without the Extra Exit. I am doing some backtesting.
Thank You
ThemBonez


---

## Re: MTF StochRSI Strategy

**Apprentice** · Thu Jun 14, 2012 1:51 am

Your request is added to the development list.


---

## Re: MTF StochRSI Strategy

**ThemBonez** · Thu Aug 29, 2013 6:57 am

Hello,
Could you add a 3rd time frame and change the triggers of the trades are as follows:
Long Trade
D1
K <75 and K>D

H1
K <75 and K>d

5 min
Long Trade Trigger = k<25 and K crosses over D

Short Trade
D1
K >25 and K<D

H1
K >25 and K<D

5 min
Short Trade Trigger = k>75 and K crosses under D

Thank You


---

## Re: MTF StochRSI Strategy

**emanmirza** · Mon Sep 02, 2013 1:17 am

nice post


---

## Re: MTF StochRSI Strategy

**Apprentice** · Mon Jan 29, 2018 8:49 am

The strategy was revised and updated.
