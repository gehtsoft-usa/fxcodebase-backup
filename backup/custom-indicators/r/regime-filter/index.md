# Regime Filter

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75868  
> Forum: 17 · Topic 75868 · 2 post(s)


---

## Regime Filter

**Steve_W** · Sun Apr 27, 2025 1:27 pm

Developed from original source here:
[https://www.tradingview.com/script/ia5ozyMF-MLExtensions/](https://www.tradingview.com/script/ia5ozyMF-MLExtensions/)
by [https://www.tradingview.com/u/jdehorty/](https://www.tradingview.com/u/jdehorty/)

This indicator aims to detect trending or ranging markets.
There is no exact explanation of the mechanics, but comments are added in the code below by interpretation.
First, an adaptive smoothing constant is generated based on average price slope and volatility
The constant looks like a solution of a quadratic equation and scaled to be between 0 and 1 for use in EMA KAMA filter or price.
The output KAMA slope is compared to averaged KAMA slope to select regime
Defaults are based on original authors values and code corrected for a minor error and numerical protections added for edge cases.

The indicator is aimed at algorithmic trading, and was specifically used on Lorentzian kNN Classification algorithm as an optional trade filter. ADX indicator could be an alternative.
Options are available to show raw signal, or a threshold toggled indication - see screenshot.

The code has also been optimised and improved using Grok3 - this is worthwhile if new to LUA programming, and generally improves coding standard.

 

![EURUSD D1 (04-27-2025 1855).png](images/159062/EURUSD%20D1%20%2804-27-2025%201855%29.png)

*EURUSD D1*



 [regime.lua](files/159062/regime.lua)


---

## Re: Regime Filter

**Avignon** · Thu May 01, 2025 7:18 am

> **Steve_W wrote:**
>
> The code has also been optimised and improved using Grok3 - this is worthwhile if new to LUA programming, and generally improves coding standard.

You're shooting yourself in the foot by saying that!
