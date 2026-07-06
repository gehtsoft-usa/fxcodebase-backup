# Opening Candle Range Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=75978  
> Forum: 31 · Topic 75978 · 1 post(s)


---

## Opening Candle Range Strategy

**Apprentice** · Tue May 27, 2025 1:31 pm

![EURUSD m5 (05-27-2025 2031).png](images/159393/EURUSD%20m5%20%2805-27-2025%202031%29.png)



Based on the indicator.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=75958](https://fxcodebase.com/code/viewtopic.php?f=17&t=75958)

**Entry Rules**
- Entry is triggered when the price **crosses outside** the predefined range from the opening candle (set by time and timeframe parameters).
- For long trades: the price must break above the range high.
- For short trades: the price must break below the range low.
- Optional filters:
 - **BigCandle**: Entry only if the current candle is larger than a multiple of the previous candle.
 - **Second Cross Only**: Entry only on the second breakout attempt.

**Exit Rules**
- Exits occur when price returns inside the range:
 - For long trades: exit if the price closes below the range low.
 - For short trades: exit if the price closes above the range high.
- The range used for exit depends on the **ExitType** parameter: "Initial Range" or "Shifted Range".

 [Opening Candle Range Strategy.lua](files/159393/Opening%20Candle%20Range%20Strategy.lua)
