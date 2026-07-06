# Hammer Hanging Man Patterns Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=24509  
> Forum: 31 · Topic 24509 · 18 post(s)


---

## Hammer Hanging Man Patterns Strategy

**Apprentice** · Tue Oct 16, 2012 1:02 pm

![Hammer Hanging Man Patterns Strategy.png](images/42177/Hammer%20Hanging%20Man%20Patterns%20Strategy.png)



Hammer Pattern
Open Long Position
Hanging Man
Open Short Position

 [Hammer Hanging Man Patterns Strategy.lua](files/42177/Hammer%20Hanging%20Man%20Patterns%20Strategy.lua)

 [Hammer Hanging Man Patterns with ATR Filter Strategy.lua](files/42177/Hammer%20Hanging%20Man%20Patterns%20with%20ATR%20Filter%20Strategy.lua)

Strategy is based on the Hammer Hanging Man Patterns Indicator.
[viewtopic.php?f=17&t=24469](https://fxcodebase.com/code/viewtopic.php?f=17&t=24469)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Hammer Hanging Man Patterns Strategy

**viggy1** · Wed Nov 07, 2012 6:42 am

Hello Apprentice,

Thank you ever so much for making this strategy, I am having a bit of trouble understanding the parameters, the min body shadow ratio and the min body upper shadow.
Also is the trend reversal filter used to only get trades at the top of a trend?

Thanks again

Vig


---

## Re: Hammer Hanging Man Patterns Strategy

**Apprentice** · Thu Nov 08, 2012 6:41 am

Trend reversal filter, allowing trades, only in the opposite direction, from the trend.

Abs(Open - High) - Body
Abs(High- x )-Upper Shadow
Abs˙(x/ Low)-Lower Shadow

Take only this Trades
Body * LSR > Lower Shadow
(Big Lower Wicks )
Body < USR* Upper Shadow
(Small Upper Wicks)


---

## Re: Hammer Hanging Man Patterns Strategy

**speakinmymind** · Fri Mar 01, 2013 11:17 am

Could you please add margin care to this strategy?


---

## Re: Hammer Hanging Man Patterns Strategy

**Apprentice** · Mon Mar 04, 2013 3:48 am

What algorithm do you have in mind.


---

## Re: Hammer Hanging Man Patterns Strategy

**speakinmymind** · Mon Mar 04, 2013 4:12 pm

I'm not sure how to come up with the algorithm, but I'm refering to the margin care parameters (and the gross profit/loss care parameters) that are available in the default DMACD strategy.


---

## Re: Hammer Hanging Man Patterns Strategy

**speakinmymind** · Sun Mar 10, 2013 11:21 pm

> **Apprentice wrote:**
> What algorithm do you have in mind.

The issue I'm having is that this strategy will continue to open positions without considering how much available margin you will have after execution.


---

## Re: Hammer Hanging Man Patterns Strategy

**ev8383** · Mon Mar 11, 2013 5:00 am

Hello,
Can you please add RSI filter based on the [MT5 signal](http://www.mql5.com/en/code/317)

Thanks


---

## Re: Hammer Hanging Man Patterns Strategy

**maxmil** · Mon May 19, 2014 3:36 pm

Hello Apprentice,
it is possible to operate this strategy between the two prices (a minimum price and a maximum price)?

thanks


---

## Re: Hammer Hanging Man Patterns Strategy

**Apprentice** · Wed May 21, 2014 4:27 am

Can you explain in more detail, I did not understand your question.


---

## Re: Hammer Hanging Man Patterns Strategy

**maxmil** · Fri May 30, 2014 2:40 pm

I think that in order to avoid that this strategy will open a long position when the price is near to an important resistance, or open a short position when the price is near to an important support, it is necessary to specify a maximum price and a minimum price, to 'inside of which this strategy can work.


---

## Re: Hammer Hanging Man Patterns Strategy

**maxmil** · Thu Jun 05, 2014 1:11 pm

Hello Apprentice, what do you think of my request?
Thank's


---

## Re: Hammer Hanging Man Patterns Strategy

**Apprentice** · Sun Jun 08, 2014 5:19 am

How do you define these lines of the support resistance.
As Period Min,Max. User defined period.
Or as user defined Min/Max.


---

## Re: Hammer Hanging Man Patterns Strategy

**maxmil** · Mon Jun 09, 2014 3:24 pm

User defined Min/Max.


---

## Re: Hammer Hanging Man Patterns Strategy

**HappyFox8** · Sun Nov 01, 2015 2:37 pm

Hello Apprentice,

Thank you so much for this strategy & the matching indicator.
I have just made a post on the matching indicator page & thought I would also post here to flag my request. I would love it if you could add the ability to customise the size (i.e. entire length) of the candle according to ATR (average true range). Please see my post on the indicator page for further details.

A great many thanks in advance.


---

## Re: Hammer Hanging Man Patterns Strategy

**HappyFox8** · Sun Nov 01, 2015 6:27 pm

Further to my earlier post, I would like to know if it is possible to set the strategy so that an entry order is created rather than (or as well as) a market order. I ask this because price often pulls back to around the middle of the tail of a hammer (where a more conducive entry can be made) before continuing upwards (well, we all hope it will continue upwards!)

So, my idea is that after the hammer completes, the strategy generates a buy entry order at the middle of the hammer. (Obviously this order may or may not be executed).

Ideally the program creates two orders; one at the anticipated pullback price & one at market (in case the pullback does not happen). Even more ideally, the user can set a percentage pullback (i.e. percentage back into the length of the hammer), so that each trader can decide how much pullback they would like to work with.

What do you think!? It'd be pretty cool. Can it be done?


---

## Re: Hammer Hanging Man Patterns Strategy

**Apprentice** · Wed Nov 04, 2015 8:47 am

Your request is added to the development list.


---

## Re: Hammer Hanging Man Patterns Strategy

**Apprentice** · Wed Dec 14, 2016 3:44 am

Strategy was revised and updated.
