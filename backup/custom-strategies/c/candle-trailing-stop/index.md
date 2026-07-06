# Candle Trailing Stop

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65802  
> Forum: 31 · Topic 65802 · 2 post(s)


---

## Candle Trailing Stop

**Apprentice** · Mon Mar 05, 2018 12:15 pm

Based on the request.
[viewtopic.php?f=27&t=24012](https://fxcodebase.com/code/viewtopic.php?f=27&t=24012)

Bullish : The strategy checks, if a trade is opened. If yes, a stop loss is set a specified number of pips below the low of the latest bullish candle. Afterwards, the stop is trailed to the next low of the next closed bullish candle etc.. If the next closed candle is not bullish, the stop remains where it was until a bullish candle is created.

Bearish: vice versa

 [Candle Trailing Stop.lua](files/118035/Candle%20Trailing%20Stop.lua)


---

## Re: Candle Trailing Stop

**alienmole** · Sat Mar 10, 2018 1:57 pm

Hi

I've tried this strategy out and it does trail but not as described, any chance you could check it please because this is a really useful trailing stop loss.

Im not sure why there is an option to input what Time frame you want as I thought this wouldn't be needed as it runs based on which order its assigned to, however if this is necessary could you add an option please for custom time frames, eg I use a 2 Minute Chart a lot.

Thanks
