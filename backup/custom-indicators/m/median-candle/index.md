# Median Candle

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75783  
> Forum: 17 · Topic 75783 · 1 post(s)


---

## Median Candle

**Apprentice** · Tue Apr 01, 2025 4:17 am

![EURUSD D1 (04-01-2025 1144).png](images/158847/EURUSD%20D1%20%2804-01-2025%201144%29.png)



Calculation (Update function):
Called for each bar/candle (period) to calculate and update indicator values.

Logic varies based on the "Repetitions" parameter:

Calculation Logic:
Repetitions = 0:

Original candle prices are displayed without modification.

Repetitions > 0:

The indicator calculates the median price by averaging the current and previous periods' OHLC values for the first repetition.

For subsequent repetitions, each OHLC value is recalculated as the average of the previously smoothed values from the current and preceding period.

After the set number of repetitions, the final smoothed candle values (open, high, low, close) are plotted.

Practical Use:
The indicator provides clear visualization of price trends, filtering out short-term volatility and noise

 [Median Candle.lua](files/158847/Median%20Candle.lua)
