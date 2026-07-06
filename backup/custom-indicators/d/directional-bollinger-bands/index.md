# Directional Bollinger Bands

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75786  
> Forum: 17 · Topic 75786 · 1 post(s)


---

## Directional Bollinger Bands

**Apprentice** · Tue Apr 01, 2025 12:03 pm

![EURUSD D1 (04-01-2025 1900).png](images/158852/EURUSD%20D1%20%2804-01-2025%201900%29.png)



What are Directional Bollinger Bands?
Directional Bollinger Bands are a variation of the standard Bollinger Bands indicator. While classic Bollinger Bands consist of a moving average (central line) with bands placed a certain number of standard deviations above and below this moving average, the Directional Bollinger Bands adapt dynamically according to the current price direction.
How Directional Bollinger Bands Work:
Calculation Basis:

Uses a moving average (default 20 periods).

Bands are placed at a distance determined by a certain number of standard deviations from this moving average (default is 2 deviations).

Directional Adjustment:
The bands dynamically adjust based on the price’s direction:

Bullish Direction (price is above moving average):
The top line (TL) is calculated as the moving average plus 2 standard deviations.
The bottom line (BL) adjusts upward following price movement (trailing).

Bearish Direction (price is below moving average):
The bottom line (BL) is calculated as the moving average minus 2 standard deviations.
The top line (TL) adjusts downward following price movement (trailing).

Line Breaks (Gaps):
When the price crosses above or below the moving average, the bands briefly reset, creating breaks or gaps in the lines.

 [Directional Bollinger Bands.lua](files/158852/Directional%20Bollinger%20Bands.lua)
