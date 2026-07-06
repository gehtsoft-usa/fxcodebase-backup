# Smoothed Heikin-Ashi trailing stop Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=69696  
> Forum: 31 · Topic 69696 · 7 post(s)


---

## Smoothed Heikin-Ashi trailing stop Strategy

**Apprentice** · Mon Apr 20, 2020 7:40 am

Based on request.
[viewtopic.php?f=27&t=69694](https://fxcodebase.com/code/viewtopic.php?f=27&t=69694)

 [Smoothed Heikin-Ashi trailing stop Strategy.lua](files/132978/Smoothed%20Heikin-Ashi%20trailing%20stop%20Strategy.lua)


---

## Re: Smoothed Heikin-Ashi trailing stop Strategy

**foxbat** · Sat Apr 25, 2020 9:41 pm

I tried back-testing this strategy but it doesn't place any trades.
Could you help please?


---

## Re: Smoothed Heikin-Ashi trailing stop Strategy

**Apprentice** · Sun Apr 26, 2020 5:57 am

The strategy will all/move stop level for selected or all active trades, based on HA indicator.

This is requested and expected.


---

## Re: Smoothed Heikin-Ashi trailing stop Strategy

**Sheera123** · Mon May 04, 2020 8:04 am

Hi Apprentice,

I've tested the strategy in End-of-Turn mode and it works as intended, but when the stop moves, it moves to the previous HA candle. My original idea is to move the stop to the current HA candle, is it possible to do that, if so, can you please add an option to select between previous and current HA candles.

In LIVE mode the stop moves once immediately after a trade is entered and never moves again. Also when the stop moves it never moves exactly on the open of the HA candle, it's always about 1pip below the open. Can you please have a look at that as well.

Thank you so much,

Shawn H


---

## Re: Smoothed Heikin-Ashi trailing stop Strategy

**Apprentice** · Tue May 05, 2020 4:49 am

Your request is added to the development list.
Development reference 1226.


---

## Re: Smoothed Heikin-Ashi trailing stop Strategy

**Apprentice** · Tue May 05, 2020 5:57 am

[Smoothed Heikin-Ashi trailing stop Strategy.lua](files/133568/Smoothed%20Heikin-Ashi%20trailing%20stop%20Strategy.lua)

Try this version.


---

## Re: Smoothed Heikin-Ashi trailing stop Strategy

**Sheera123** · Tue May 05, 2020 7:05 am

It works perfectly now.

Thank you very much,

Shawn H
