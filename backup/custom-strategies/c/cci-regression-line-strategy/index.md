# CCI Regression Line Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61775  
> Forum: 31 · Topic 61775 · 6 post(s)


---

## CCI Regression Line Strategy

**Apprentice** · Tue Feb 03, 2015 12:19 pm

![CCI Regression Line Strategy.png](images/98455/CCI%20Regression%20Line%20Strategy.png)



Based on request.
[viewtopic.php?f=27&t=61767](https://fxcodebase.com/code/viewtopic.php?f=27&t=61767)
Open Long
CCI / OS CrossOver
Close > Open
Low < Regression Line
High > Regression Line
Open Short
CCI / OB CrossUnder
Close < Open
Low < Regression Line
High > Regression Line

 [CCI Regression Line Strategy.lua](files/98455/CCI%20Regression%20Line%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: CCI Regression Line Strategy

**Loading** · Wed Feb 04, 2015 10:54 am

thx very much.

its nearly perfect. there is only one thing which need to be changed.

long signal:
CCI crosses the -100 from below and a positive candle (close price of the candle) crosses the regression line at the same time.

and a short signal when:
CCI crosses the 100 from above and a negative candle (close price of the candle) touches the regression line at the same time.

I forgot to write that i need the close prize of the candles.
its my fault because my description was a little bit misleading.

now i get also signals when the wick crosses the regression line, which i dont want.

thx very much for your hard work


---

## Re: CCI Regression Line Strategy

**Apprentice** · Wed Feb 04, 2015 12:54 pm

Candle Definition parameter added.


---

## Re: CCI Regression Line Strategy

**Loading** · Wed Feb 04, 2015 3:01 pm

thx alot


---

## Re: CCI Regression Line Strategy

**reggytrades** · Fri Feb 06, 2015 10:56 am

Hi,
Thanks for the work on the CCI Regression Line Strat. Set it up with standard settings on 15m last night for the first time, woke to a very pleasant surprise...3wins, 1loss. ... -4pips, +8pips, +8pips, +91pips. The small loss was due to spike up on the down trending 21 linear regression MA. Is there a way to filter chop zones? Due to my very happy experience with PVAvol / alerts, I believe if PVA can be integrated w/ the CCI Regression Strat, and with the slope of the MA, then the results would be good.
Is this possible for you in the short term? If not, then could you recommend a coder who could do this?


---

## Re: CCI Regression Line Strategy

**Apprentice** · Sun Dec 11, 2016 1:18 pm

Strategy was revised and updated.
