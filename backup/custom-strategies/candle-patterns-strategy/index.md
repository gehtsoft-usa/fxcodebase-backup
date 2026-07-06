# Candle patterns Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4846  
> Forum: 31 · Topic 4846 · 27 post(s)


---

## Candle patterns Strategy

**Apprentice** · Fri Jun 24, 2011 2:24 pm

![Patterns Strategy.png](images/12027/Patterns%20Strategy.png)



This Strategy is based on Patterns3 Indicator and Signal
[viewtopic.php?f=17&t=903&hilit=pattern&start=10](https://fxcodebase.com/code/viewtopic.php?f=17&t=903&hilit=pattern&start=10)

I wrote this strategy to test candle pattern trading.

We have some interesting results.
For example, the attached chart on M1 using engulfing pattern.

 [Patterns Strategy.lua](files/12027/Patterns%20Strategy.lua)

Algorithms should be adjusted in the future.
For example, I adjusted engulfing to the Forex.
The original did not give any signals.

The Strategy was revised and updated on January 21, 2019.


---

## Re: Candle patterns Strategy

**thetruth** · Tue Jul 05, 2011 1:42 pm

i am testing, can you add an "inverse strategy" parameter,
i know that the engulfing bullish pattern is a bullish signal not a bearish, or can you tell me
were can i find the theory to understand this candle pattern strategy?


---

## Re: Candle patterns Strategy

**Apprentice** · Tue Sep 13, 2011 8:50 am

Your request is added to the developmental cue.


---

## Re: Candle patterns Strategy

**Alexander.Gettinger** · Tue Sep 13, 2011 11:54 pm

> **thetruth wrote:**
> i am testing, can you add an "inverse strategy" parameter,
> i know that the engulfing bullish pattern is a bullish signal not a bearish, or can you tell me
> were can i find the theory to understand this candle pattern strategy?

Please, see this strategy. I added a parameter [TypeSignal] in the strategy.

Download:

 [Patterns Strategy2.lua](files/14921/Patterns%20Strategy2.lua)


---

## Re: Candle patterns Strategy

**cmforextrader** · Thu Oct 13, 2011 7:29 am

Hi.

 The Engulfing Bullish Line open only short order and not long order.

Best Regards


---

## Re: Candle patterns Strategy

**sunshine** · Thu Oct 13, 2011 8:17 am

Please check if the parameter "Allow Multiple" is set to "Yes".


---

## Re: Candle patterns Strategy

**Rpleandro** · Tue Oct 18, 2011 12:35 pm

This seems to only open short positions...


---

## Re: Candle patterns Strategy

**sunshine** · Wed Oct 19, 2011 3:09 am

The strategy has the parameter "Allowed side". If it is set to "Sell", the strategy is allowed to open only short positions.


---

## Re: Candle patterns Strategy

**giancarloniro** · Tue Nov 29, 2011 8:56 am

Hi there,

I was wondering if there was a way to get this strategy to trade both ways (long and short) as it only seems to go short?

I know I have set the parameters correctly
Allowed side - Both
Allow Multiple - Yes

Looking at the backtesting I have done, the strategy does not seem to recognise bullish patterns such as morning star and bullish engulfing.

Can anybody help?


---

## Re: Candle patterns Strategy

**Stance** · Wed Jul 22, 2015 9:35 pm

What does "Engulfing Bullish Line" and "Engulfing Bearish Line" mean?

It doesn't seem to pickup Bullish Engulfing and Bearish Engulfing candles? Can this be added?


---

## Re: Candle patterns Strategy

**Apprentice** · Thu Jul 23, 2015 2:59 am

Have only reproduced aforementioned indicator.
It looks like typo.


---

## Re: Candle patterns Strategy

**fwcolbert** · Wed Aug 05, 2015 12:54 am

So will this strategy execute BUY orders for the bullish patterns ? Or is that being developed ?


---

## Re: Candle patterns Strategy

**fwcolbert** · Thu Aug 06, 2015 8:58 am

So far I like it! Is there any fixes to be made as far as the bullish trend trades? and is it possible for the Bullish patterns to only trade on the bullish trends and the Bearish patterns to only trade on the bearish trends.

Once the Bearish patterns are trading in the Bullish trend and reversed can they be canceled once a true trade is executed ?


---

## Re: Candle patterns Strategy

**Apprentice** · Thu Aug 20, 2015 6:42 am

Your request is added to the development list.


---

## Re: Candle patterns Strategy

**Stance** · Mon Aug 24, 2015 12:40 am

Hi,

Could a MA filter be added to this strategy?

Thankyou,


---

## Re: Candle patterns Strategy

**fwcolbert** · Thu Sep 03, 2015 11:59 pm

And also can you make sure all of the candle patterns and alerts function? Thought I should specify that.Thanks!!!!


---

## Re: Candle patterns Strategy

**Apprentice** · Sun Sep 06, 2015 4:14 am

> And also can you make sure all of the candle patterns and alerts function?

Can you to clarify? Alert are not given every time?


---

## Re: Candle patterns Strategy

**fwcolbert** · Sun Sep 06, 2015 12:26 pm

Oh! sorry just the candle patterns I looked back at it and some of the candle patterns aren't triggering trades!


---

## Re: Candle patterns Strategy

**Apprentice** · Tue Dec 13, 2016 4:50 pm

Strategy was revised and updated.


---

## Re: Candle patterns Strategy

**conjure** · Wed Aug 09, 2017 6:30 am

Is it possible to a parameter
if profit of Day is > 0 then don't play again until next day?


---

## Re: Candle patterns Strategy

**Apprentice** · Sun Aug 13, 2017 5:17 am

For Patterns Strategy.lua or Patterns Strategy2.lua?


---

## Re: Candle patterns Strategy

**conjure** · Sun Aug 13, 2017 3:42 pm

For Patterns Strategy2.lua


---

## Re: Candle patterns Strategy

**Apprentice** · Mon Aug 14, 2017 5:07 am

One more thing.
Will this profit filter be limited to positions opened by this strategy?
Or account wide?

Your request is added to the development list, Under Id Number 3855
 If someone is interested to do this task, please contact me.


---

## Re: Candle patterns Strategy

**conjure** · Mon Aug 14, 2017 6:52 am

account wide


---

## Re: Candle patterns Strategy

**Alexander.Gettinger** · Fri Sep 22, 2017 2:42 pm

> **conjure wrote:**
> Is it possible to a parameter
> if profit of Day is > 0 then don't play again until next day?

Please, try this strategy:

 [Patterns Strategy3.lua](files/115059/Patterns%20Strategy3.lua)


---

## Re: Candle patterns Strategy

**conjure** · Sun Sep 24, 2017 8:33 am

> **Alexander.Gettinger wrote:**
>
>
> > **conjure wrote:**
> > Is it possible to a parameter
> > if profit of Day is > 0 then don't play again until next day?
>
>
>
> Please, try this strategy:
>
>
> Patterns Strategy3.lua

There is an error Message	Time
C:/Program Files (x86)/Candleworks/FXTS2/Strategies/Custom/Patterns Strategy3.lua:125: The first parameter must be a number


---

## Re: Candle patterns Strategy

**Apprentice** · Fri Sep 29, 2017 7:33 am

Try it now.
