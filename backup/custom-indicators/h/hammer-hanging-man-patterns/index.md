# Hammer Hanging Man Patterns

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=24469  
> Forum: 17 · Topic 24469 · 19 post(s)


---

## Hammer Hanging Man Patterns

**Apprentice** · Mon Oct 15, 2012 6:16 am

![Hammer Hanging Man Patterns.png](images/42100/Hammer%20Hanging%20Man%20Patterns.png)



 [Hammer Hanging Man Patterns.lua](files/42100/Hammer%20Hanging%20Man%20Patterns.lua)

Theory.

Hanging Man
Hanging Man candlestick formation, is a bearish reversal candlestick pattern that occurs mainly at the top of uptrends and is a warning of a potential reversal.

Hammer
Hammer candlestick formation is a bullish reversal candlestick pattern that occurs at the bottom of downtrends and is a warning of a potential reversal.

Conditions
1. Long lower shadow should be at least twice the length as the real body.
2. Upper shadow is small or non-existent.
3. Direction of candles is not crucial.
It is Preferred that we have Down Candle for Hanging Man,
and Up Candle for Hammer Pattern.
4. Pattern occurs after a period of trend, and is indication of a potential reversal.
On Top for Hanging Man and on Bottom for Hammer.

The indicator was revised and updated


---

## Re: Hammer Hanging Man Patterns

**MrDavide79** · Tue Oct 16, 2012 5:28 am

Hello,
is it possible to have an strategy for this?

Thanks


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Tue Oct 16, 2012 6:49 am

Your request has been added to the development list.


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Tue Oct 16, 2012 1:03 pm

Requested can be found here.
[viewtopic.php?f=31&t=24509](https://fxcodebase.com/code/viewtopic.php?f=31&t=24509)


---

## Re: Hammer Hanging Man Patterns

**ev8383** · Sat Mar 09, 2013 12:43 pm

Thanks for the great indicator Apprentice.

Can you make signal that would detect hammer and handing man pattern?

Thanks


---

## Re: Hammer Hanging Man Patterns

**speakinmymind** · Sun Mar 10, 2013 1:54 pm

Could you please allow the on/off option for “allow strategy to trade” to be automated based on the output of the TWO AVERAGES OSCILLATOR? This would eliminate most false signals.
For example, using the TWO AVERAGES OSCILLATOR, the output must be below -.00050 to allow trading with the long strategy and must be above .00050 to allow trading with the short strategy.
Also, if an order is open in one strategy, the other strategy should not interfere. If strategy Long has an open position, strategy Short should be restricted from trading until all long positions for that symbol have been closed. (This should at least be optional.)

Pairs Tested: USD/JPY; EUR/GBP; (still backtesting other pairs for hammer/hanging man settings)

Indicators used AND auto trading settings:
1.	(FOR LONG) Hammer hanging Man Patterens (2.8, 28.0, 4) TP 55 SL 22 (Yes, Yes, Yes, No) (ALSO STRATEGY)
2.	(FOR SHORT) Hammer hanging Man Patterens (2.1, 28.3, 4) TP 55 SL 22 (Yes, Yes, No, Yes) (ALSO STRATEGY)
3.	MVA 880; MVA 165 and/or TWO AVERAGES OSCILLATOR (165, 880)
4.	Tick Donchian 2000

For manual trading:
Long Scenario:
1.	Hammer hanging Man Patterens man signals buy
2.	165MVA is below 880MVA and is closing about to cross ABOVE 880MVA
3.	Enter long,
4.	limit at 55 pips
5.	stop at Donchian channel bottom, and adjust as needed manually
6.	Manual exit when Hanging man signals sell AND 165MVA crosses BELOW 880MVA

Short Scenario:
1.	Hanging man signals sell
2.	165MVA is above 880MVA and is closing about to cross BELOW 880MVA
3.	Enter short,
4.	limit at 55 pips
5.	stop at Donchian channel top, and adjust as needed manually
6.	Manual exit when Hanging man signals buy AND 165MVA crosses ABOVE 880MVA


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Tue Mar 12, 2013 5:19 am

Requests were added to the development list.


---

## Re: Hammer Hanging Man Patterns

**speakinmymind** · Wed Apr 10, 2013 12:15 pm

could you please create a modified version of this that will restrict signals to only when the next candle does not touch the wick of the hanging man's candle?


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Fri Apr 12, 2013 4:12 am

Next candle body,
or Next candle should not have wicks all together.
You're aware that this will delayed the signal by one period.


---

## Re: Hammer Hanging Man Patterns

**speakinmymind** · Fri Apr 12, 2013 5:39 am

The next candle can have a wick or not. Either way, if price has not touched back into the hanging man's wick that should generate a signal.

I understand that this will delay the signal.

When price has completed its action away from the hanging man and reverses.

I will use the signal as the initial target of the reversal.


---

## Re: Hammer Hanging Man Patterns

**HappyFox8** · Sun Nov 01, 2015 2:28 pm

Thank you so much for this indicator & the matching strategy. It is great that you have included a trend filter & the ability to customise the upper & lower shadows. I would like to make a request that I think would be a valuable further improvement. It would be great if we could also customise the size (i.e. entire length including shadows) of the candle. Ideally this would be linked to average true range. In this way the indicator length can be customised according to the surrounding price activity rather than a randomly-selected number of pips.

To explain further, I would like to be able to specify that the indicator selects hammers/hanging men that are greater than x*average-true-range of the past y bars, where x & y are user specified. For example a user might wish to only capture bars where the entire length of the candle (low to high) is at least 3 x the average-true-range of the past 100 bars. Or perhaps the user may refine this to, say, 2.3 times the ATR.

If you have the time to add this refinement it would be greatly appreciated (& please also update the matching strategy).
Many thanks in advance.


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Tue Nov 03, 2015 5:05 am

Requested can be found here.
[viewtopic.php?f=17&t=62850](https://fxcodebase.com/code/viewtopic.php?f=17&t=62850)


---

## Re: Hammer Hanging Man Patterns

**HappyFox8** · Tue Nov 03, 2015 3:09 pm

Awesome! Thank you so much. The indicator is much more effective now.

Dare I make another request? How about flipping it over so that we can also identify Shooting Stars (i.e. the bearish equivalent of a Hammer).


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Wed Nov 04, 2015 8:09 am

Your request is added to the development list.


---

## Re: Hammer Hanging Man Patterns

**HappyFox8** · Thu Nov 05, 2015 4:13 pm

Great, thanks. I look forward to it.


---

## Re: Hammer Hanging Man Patterns

**HappyFox8** · Thu Dec 10, 2015 10:17 pm

Hi,
Wondering if you've had any time to look at creating the Shooting Star.


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Fri Dec 11, 2015 4:42 am

Your request is added to the development list.


---

## Re: Hammer Hanging Man Patterns

**Apprentice** · Fri Jul 21, 2017 8:28 am

The indicator was revised and updated.


---

## Re: Hammer Hanging Man Patterns

**HappyFox8** · Fri Jul 28, 2017 8:44 am

Hi Apprentice,
Thanks for revising the indicator. It is improved, however a major limitation is that whilst it identifies candles with the relative proportions selected, there is no ability to assign the size of the candle. Which means that it picks out the tiniest candles that have no meaning. When you have time, I would like the ability to assign a minimum range (low to high). Many thanks.
