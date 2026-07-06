# Shadow trailing stop

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2793  
> Forum: 31 · Topic 2793 · 8 post(s)


---

## Shadow trailing stop

**Alexander.Gettinger** · Thu Nov 25, 2010 1:12 am

The strategy sets stop value for the chosen trade using several next candles.
Strategy parameters:
BarsNumber - Number of analysed candles,
Indent - Indent from selected shadow, if =0 then stop put directly on high or low,
MoveBack - if false then for BUY stop moves up only and for SELL stop moves down only.

For example:
BarsNumber=4, BUY order. Stop will be put on maximum of [BarsNumber] last low prices.
For SELL order stop will be put on minimum of [BarsNumber] last high prices.

Download:

 [ShadowStop.lua](files/6363/ShadowStop.lua)

The Strategy was revised and updated on December 10, 2018.


---

## Re: Shadow trailing stop

**STEIGO** · Fri Aug 12, 2011 2:30 pm

Hello Alexander
I think this is an interesting stop strategy. I've been watching it over short timeframes to see how it behaves. Unfortunately, I don't have much evidence it is working reliably. Perhaps I need to understand how it tries to move the stop.
I get that if I apply it to a LONG postion it moves the stop to the highest low of the last n candles (where n=barsnumber).

The indent variable, does this mean it does not in consider the last 1,2, 3 etc most recently closed candles (on the specified time frame)?

Also, would it be possible to modify this strategy to accept a manually entered stop - ie. in a long postion, opening at say, 1.5290, if ask=1.6310, set stop to 1.6300, then adjust stop according this strategy (ie. only adjust upwards according to barnumber/indent/timeframe)

Thanks


---

## Re: Shadow trailing stop

**trendwatch** · Tue Dec 06, 2011 10:24 am

Hello Alexander,

I respect your commitment and coding skills. You really make trading life a lot easier for me. Thank you for that.

I have a request regarding this strategy. I will try to explain accorindg the example given by you.

Now, your example:
BarsNumber=4, BUY order. Stop will be put on maximum of [BarsNumber] last low prices.
For SELL order stop will be put on minimum of [BarsNumber] last high prices.

My request:
BarsNumber=4, BUY order. Stop will be put on MINIMUM of [BarsNumber] last low prices.
For SELL order stop will be put on MAXIMUM of [BarsNumber] last high prices.

I hope you'll find some time to ad this option.

Thanks again


---

## Re: Shadow trailing stop

**Apprentice** · Wed Dec 07, 2011 3:38 am

Your request is added to the developmental cue.


---

## Re: Shadow trailing stop

**napitt** · Tue Oct 09, 2012 10:33 pm

I searched the error I got "failed to create stop command disabled" and see it is common with strategies. Is it that none of these stop strategies is going to work on a FIFO account?

I wanted to use this one on a US account using a heikin-ashi chart.
Thanks


---

## Re: Shadow trailing stop

**Apprentice** · Wed Oct 10, 2012 3:47 am

Thank you for reporting a problem, I have send a message to Alex.


---

## Re: Shadow trailing stop

**arstechnica** · Wed Nov 07, 2012 6:13 am

I tested this strategy on 5 m and h4 periods, but the stop doesn't move.

I wait also for new candle open, but it is the same.

Could you please help in understanding what's happen?

Salvatore


---

## Re: Shadow trailing stop

**Apprentice** · Wed Dec 07, 2016 3:22 pm

Strategy has been revised and updated.
