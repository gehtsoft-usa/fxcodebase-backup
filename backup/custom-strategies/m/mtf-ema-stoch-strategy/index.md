# MTF EMA & Stoch Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7953  
> Forum: 31 · Topic 7953 · 3 post(s)


---

## MTF EMA & Stoch Strategy

**Apprentice** · Wed Nov 09, 2011 6:05 am

![MTF EMA & Stoch Strategy.png](images/17610/MTF%20EMA%20Stoch%20Strategy.png)



Long Trade

On the daily chart:
EMAs: The 5 must be above the 10 and the 10 above the 50.
Stoch (10,3,3): The fast line must be above the slow,
 (in other words, bullish), and must not be in overbought.

On the hourly chart:
EMAs: Buy whenever the 10 crosses the 20 (bullish)
as long as:
Stoch (10,3,3): have bullish indication and it is not is overbought.

Short trades the opposite of above.

The strategy is written, will work properly only correct in the current in development version (Beta).

 [MTF EMA & Stoch Strategy.lua](files/17610/MTF%20EMA%20Stoch%20Strategy.lua)


---

## Re: MTF EMA & Stoch Strategy

**Gerrit.van.Zyl** · Mon Nov 28, 2011 3:42 pm

Thanks very much Apprentice.

Upon backtesting of the strategy I realized that the use of stochastics on the daily chart is too much of a limiting factor. Could you possibly remove it? (While stochastics on the hourly chart remains as it was, buy when bullish indication and not overbought, vice versa for sells)

My gratitude


---

## Re: MTF EMA & Stoch Strategy

**Apprentice** · Wed Jan 31, 2018 10:24 am

The strategy was revised and updated.
