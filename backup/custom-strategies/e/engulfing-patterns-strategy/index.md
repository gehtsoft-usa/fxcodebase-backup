# Engulfing Patterns Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=24466  
> Forum: 31 · Topic 24466 · 12 post(s)


---

## Engulfing Patterns Strategy

**Apprentice** · Mon Oct 15, 2012 5:12 am

![Engulfing Patterns Strategy.png](images/42096/Engulfing%20Patterns%20Strategy.png)



Bullish Engulfing patterns
Open Long Trade
Bearish Engulfing patterns
Open Short Trade

 [Engulfing Patterns Strategy.lua](files/42096/Engulfing%20Patterns%20Strategy.lua)

The signals are based on a bearish / Bullish engulfing patterns Indficator
[viewtopic.php?f=17&t=1613](https://fxcodebase.com/code/viewtopic.php?f=17&t=1613)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Engulfing Patterns Strategy

**MrDavide79** · Tue Oct 16, 2012 5:21 am

Hello
what tipe of value i can use this strategy ?
thanks


---

## Re: Engulfing Patterns Strategy

**speakinmymind** · Wed Apr 03, 2013 1:36 pm

Can you add the size of the previous candle, and the size of the current candle as optimize-able parameters?


---

## Re: Engulfing Patterns Strategy

**Apprentice** · Thu Apr 04, 2013 5:00 am

Please explain.
Size of the candle, minimum size, ratio between the two ...


---

## Re: Engulfing Patterns Strategy

**speakinmymind** · Thu Apr 04, 2013 9:22 am

> **Apprentice wrote:**
> Please explain.
> Size of the candle, minimum size, ratio between the two ...

Well the Engulfing Patterns looks at the previous candle to generate signals. A possible filter that would effect results would be restricting signals based on the size of the previous candle. If the previous candle is too small (rather in pips or in relation the the current candle) the signal will not be generated.

Setting acceptable size range of the looked at candle and the size of the current candle will allow you an additional option in which to optimize this strategy.

The idea is that this strategy should be as optimize able as the Hanging Mans Strategy.

[viewtopic.php?f=31&t=24509](https://fxcodebase.com/code/viewtopic.php?f=31&t=24509)

Regards.


---

## Re: Engulfing Patterns Strategy

**sqrrl99** · Tue Mar 25, 2014 12:39 pm

Could a moving average filter be added so that it will only take patterns going in certain directions? Also, is it possible to stop it from closing trades on an engulfing pattern going in the opposite direction?

Thanks,

Jason


---

## Re: Engulfing Patterns Strategy

**Stance** · Thu Jul 23, 2015 3:43 am

Can "live" (executed as soon condition is met) be added to this strategy?


---

## Re: Engulfing Patterns Strategy

**Stance** · Sun Aug 09, 2015 8:10 pm

Hi, could you add tickbase / live to this strategy?

Thankyou


---

## Re: Engulfing Patterns Strategy

**Apprentice** · Sun Aug 16, 2015 4:56 am

Please specify trading conditions.


---

## Re: Engulfing Patterns Strategy

**Coondawg71** · Sat Oct 17, 2015 2:04 pm

Is it possible to make Engulfing Patterns Strategy compatible with Line Break View charts?

I tried it on one minute time frame and it does not report an alert.

Thanks!

sjc


---

## Re: Engulfing Patterns Strategy

**Apprentice** · Mon Oct 19, 2015 5:21 am

Your request is added to the development list.


---

## Re: Engulfing Patterns Strategy

**Apprentice** · Wed Dec 14, 2016 4:05 am

Strategy was revised and updated.
