# Candle Direction Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=60817  
> Forum: 31 · Topic 60817 · 9 post(s)


---

## Candle Direction Strategy

**Apprentice** · Fri Jun 13, 2014 6:53 am

![Candle Direction Strategy.png](images/94483/Candle%20Direction%20Strategy.png)



Based on the request.
[viewtopic.php?f=27&t=60813](https://fxcodebase.com/code/viewtopic.php?f=27&t=60813)

If Sequence is set to NO.
Open Long-If Current candle is Up
Open Short - If Current candle is Down.

If Sequence is set to YES
Open Long
If Current candle is Up
and Previous candle is Down
Open Short - If Current candle is Down.
and Previous candle is Up

Make sure to set appropriate position limit number.

**Strongly recommend that you do not use Live mode.**

 [Candle Direction Strategy.lua](files/94483/Candle%20Direction%20Strategy.lua)


---

## Re: Candle Direction Strategy

**kankatrader** · Tue Oct 14, 2014 12:59 pm

Hi,
i want trade this strategy in 2 minute time frame .
Can you make this possible.

Best Regards


---

## Re: Candle Direction Strategy

**xpertizetrading** · Mon Jul 20, 2015 12:40 am

Hi Apprentice,

I would like to have a little modification to this strategy:

All open positions expire and are closed at the end of each candle. When a new candle forms new position is entered:

If New Candle Turns Green: Buy
If New Candle Turns Red: Sell

Hold till the end of the candle and repeat.

Regards,
Xpertize Trading


---

## Re: Candle Direction Strategy

**ronald3rg** · Wed Jul 27, 2016 8:27 pm

Hello Everyone,

Added some updates to this strategy.

1. Opposite entry option - enter in the opposite direction of signal
2. Hugstop- move stop after set pips gained on avg between all positions
3. Auto Lot size - auto lot sizing based on balance or equity


---

## Re: Candle Direction Strategy

**vaguthun79** · Sun Oct 16, 2016 9:56 am

StopHug: really a great feature , Fxcodebase has really good Robots, if we could add stopHug feature on them they will be very profitable. I trade manually with that system. Great Job


---

## Re: Candle Direction Strategy

**vaguthun79** · Mon Oct 17, 2016 5:04 am

Would it be possible to add anther feature to this strategy?

A MA filter, where it opens with respect to that.
 For eg: If the price is above MA only buy in new candle. and just opposite for sell.


---

## Re: Candle Direction Strategy

**Apprentice** · Tue Oct 18, 2016 9:20 am

MA Filter added.


---

## Re: Candle Direction Strategy

**vaguthun79** · Wed Oct 19, 2016 11:24 am

Thanks, really appreciate it.


---

## Re: Candle Direction Strategy

**Apprentice** · Sun Dec 18, 2016 7:22 am

Strategy was revised and updated.
