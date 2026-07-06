# RSI cross with MA confirmation Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63197  
> Forum: 31 · Topic 63197 · 5 post(s)


---

## RSI cross with MA confirmation Strategy

**Apprentice** · Tue Mar 01, 2016 3:03 pm

![EURUSD H1 (03-01-2016 2028).png](images/105043/EURUSD%20H1%20%2803-01-2016%202028%29.png)



Based on request.
[viewtopic.php?f=27&t=63189](https://fxcodebase.com/code/viewtopic.php?f=27&t=63189)

Open Long
RSI crosses above 50
13 MA is above 48 MA
Exit Long
RSI crosses above 60
RSI crosses below 50

Open Short
 RSI crosses below 50
13 MA is below 48 MA
Exit Short
RSI crosses below 40
RSI crosses above 50

 [RSI cross with MA confirmation Strategy.lua](files/105043/RSI%20cross%20with%20MA%20confirmation%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: RSI cross with MA confirmation Strategy

**legacyfighter** · Thu Mar 03, 2016 8:23 pm

Thank you very much!

what is the scale for the profit/ equity. It looked to end in profit, but to what percentage?

Also, how difficult would it be to separate the strategy so that you have a long only strategy and a separate strategy for sell/short only strategy?

In order for the above proposition to work, it would be necessary to somehow confirm a trend first and then trade only in the direction of the trend.

I may re-evaluate this strategy and consider adding an additional longer MA for determining the trend


---

## Re: RSI cross with MA confirmation Strategy

**Apprentice** · Fri Mar 04, 2016 2:52 am

Something like this.
For Long

Short MA is above Middle MA
Middle MA is above Long MA


---

## Re: RSI cross with MA confirmation Strategy

**legacyfighter** · Sat Mar 05, 2016 12:06 pm

Yes, something exactly like that.

If you look at the two big losses, there was a short open throughout a HUGE bull phase.

Because both of them had a multi day duration, it should be relatively easy to implement a stop strategy.

If you take out the two biggest losses, you get an awesome equity curve and profit margin. It looks like it could have great potential


---

## Re: RSI cross with MA confirmation Strategy

**Apprentice** · Wed Dec 14, 2016 6:49 am

Strategy was revised and updated.
