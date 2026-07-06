# Dominant Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75417  
> Forum: 17 · Topic 75417 · 1 post(s)


---

## Dominant Moving Average

**Apprentice** · Tue Dec 10, 2024 8:33 am

![SPX500 m5 (12-10-2024 1425).png](images/157516/SPX500%20m5%20%2812-10-2024%201425%29.png)



Calculates the dominant moving average period by identifying the period that best tracks price movements.

Dynamic Period Calculation:For each bar, it calculates multiple moving averages (from Min_Period to Max_Period) and determines which period fits the price the best.

Best-Fit Period Selection:The period that produces the moving average with the lowest variance relative to price is chosen as the dominant period.

The output is an oscillator showing the dominant period at each point in time.

 [Dominant Moving Average.lua](files/157516/Dominant%20Moving%20Average.lua)

 [Dominant Moving Average Period Oscillator.lua](files/157516/Dominant%20Moving%20Average%20Period%20Oscillator.lua)

Patreon article
[https://www.patreon.com/posts/dominant-moving-117688490](https://www.patreon.com/posts/dominant-moving-117688490)
