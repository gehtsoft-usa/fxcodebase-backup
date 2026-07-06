# Opening Candle RangeOpening Candle RangeOpening Candle Range

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75958  
> Forum: 17 · Topic 75958 · 1 post(s)


---

## Opening Candle RangeOpening Candle RangeOpening Candle Range

**Apprentice** · Thu May 22, 2025 4:22 am

![SPX500 m5 (05-22-2025 1121).png](images/159325/SPX500%20m5%20%2805-22-2025%201121%29.png)



[Opening Candle Range]

**Description:**
Displays the high-low range of the user-defined opening candle (e.g., 9:30 AM) on a specified timeframe. The range is color-filled and optionally extended across the chart.

**Features:**

- Select start time (hour/minute) and candle timeframe
- Visual fill with configurable up/down colors and transparency

**How to Use with ICT KISS Strategy:**

Use this indicator to automatically mark the 9:30 AM candle range on the M30 chart.
Switch to M5 and wait for price to break out or reject the range to trade based on Fair Value Gaps (FVGs).

Scenario 1: Breakout
•	If price exits the range, look for a Fair Value Gap (FVG) into the range to enter:
•	FVG is a sequence of one, two or three candles in the same direction
•	Typically, the middle candle is large
•	The third candle can be small or in the opposite direction if it doesn’t invalidate the gap

Scenario 2: Range Rejection
•	Even if price stays inside the range,
•	You can still enter a trade if price rejects from the edge and a valid FVG forms

 [Opening Candle Range.lua](files/159325/Opening%20Candle%20Range.lua)

 

![SPX500 m30 (05-22-2025 1142).png](images/159325/SPX500%20m30%20%2805-22-2025%201142%29.png)



 [Opening Candle Range History.lua](files/159325/Opening%20Candle%20Range%20History.lua)

Indicator-based strategy.
[https://fxcodebase.com/code/viewtopic.p ... 93#p159393](https://fxcodebase.com/code/viewtopic.php?f=31&t=75978&p=159393#p159393)
