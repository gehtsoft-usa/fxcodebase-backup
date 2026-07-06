# Fractal and ATR strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=10442  
> Forum: 31 · Topic 10442 · 10 post(s)


---

## Fractal and ATR strategy

**Alexander.Gettinger** · Mon Dec 26, 2011 6:10 am

This strategy is written on request [viewtopic.php?f=27&t=8287&p=18405#p18405](https://fxcodebase.com/code/viewtopic.php?f=27&t=8287&p=18405#p18405)

BUY condition:
fractal high - fractal low < ATR*Mult and appearance of new lower fractal,

SELL condition:
fractal high- fractal low< ATR*Mult and appearance of new upper fractal.

Stop loss will be opposite fractal, take profit will be open price +/- ATR*[ATR mult].

Download:

 [Fractal_ATR_Strategy.lua](files/21669/Fractal_ATR_Strategy.lua)

The Strategy was revised and updated on December 17, 2018.


---

## Re: Fractal and ATR strategy

**Exolon** · Fri Feb 03, 2012 9:19 pm

With EUR-USD over a 3 month period, I can't find any combination of parameters that produce any trades.
Also, could you explain how the limit and stop loss values are derived, since they're not directly set by the user?


---

## Re: Fractal and ATR strategy

**Exolon** · Fri Feb 03, 2012 9:20 pm

Oops, reading fail for me, the explanation was in your original post!


---

## Re: Fractal and ATR strategy

**cash4u** · Wed Jun 27, 2012 6:15 am

hi,

i have used this strategy by puting stop at 1 ATR limit at 2ATR . this strategy {when the opposite condition fulfills} closes open position before it reaches the limit level

can you add exit options 1. after reaching limit and stop level
 2. as per strategy

thanking you

its cash4u


---

## Re: Fractal and ATR strategy

**Apprentice** · Thu Jun 28, 2012 1:15 am

Your request is added to the development list.


---

## Re: Fractal and ATR strategy

**djbraski** · Mon Sep 28, 2015 7:22 pm

Hello!

After about two or three trades this straregy inevitably get the following error, stopping the strategy.

Fractal_ATR_Strategy.lua:313 The value of the rate is incorrect. It must be a number > 120.108.

The 120.108 figure is the price. This error doesn't show up in backtesting or optimizing. Any advice here? It wouldn't be a huge deal except that the strategy is actively controlling when to close the trade, so when it stops it seems there's no stop/limit for the open trades. Thank you!

djbraski


---

## Re: Fractal and ATR strategy

**djbraski** · Mon Sep 28, 2015 7:27 pm

Hello!

After about two or three trades this straregy inevitably get the following error, stopping the strategy.

Fractal_ATR_Strategy.lua:313 The value of the rate is incorrect. It must be a number > 120.108.

The 120.108 figure is the price. This error doesn't show up in backtesting or optimizing. Any advice here? It wouldn't be a huge deal except that the strategy is actively controlling when to close the trade, so when it stops it seems there's no stop/limit for the open trades. Thank you!

djbraski


---

## Re: Fractal and ATR strategy

**Apprentice** · Tue Dec 13, 2016 4:12 pm

Strategy was revised and updated.


---

## Re: Fractal and ATR strategy

**swingtrader** · Mon Mar 04, 2019 12:59 pm

hi ,

i am getting following error

C:/Program Files/Candleworks/FXTS2/Strategies/Custom/Fractal_ATR_Strategy.lua:-1: nil


---

## Re: Fractal and ATR strategy

**Apprentice** · Mon Apr 01, 2019 10:27 am

I can not reproduce it.
Continues testing on a demo account.

Can you provide an error line number?
