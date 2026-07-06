# Attributable Volume

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72777  
> Forum: 17 · Topic 72777 · 1 post(s)


---

## Attributable Volume

**Apprentice** · Thu Sep 29, 2022 5:40 am

![USDJPY D1 (09-29-2022 1238).png](images/147669/USDJPY%20D1%20%2809-29-2022%201238%29.png)



Based on the source
[https://www.tradingview.com/script/YSSa ... le-Volume/](https://www.tradingview.com/script/YSSahFC2-Attributable-Volume/)

A volume indicator that calculates "Attributable Volume”,
the portion of volume which contributed to the direction in which the candle moved.

Attributable Volume is calculated as Total volume excluding the "counter wick" volume.
Where for a green (up) candle, the "counter wick" volume is the top wick volume.

RVOL = Relative Volume, the current volume divided by the Volume moving average.
RVOL can be used to identify major moves, and potential starts/ends to trends.

 [Attributable Volume.lua](files/147669/Attributable%20Volume.lua)
