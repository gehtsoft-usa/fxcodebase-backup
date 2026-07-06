# Z-Score Mean Reversion

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75931  
> Forum: 17 · Topic 75931 · 2 post(s)


---

## Z-Score Mean Reversion

**Apprentice** · Tue May 13, 2025 12:56 pm

![USOil D1 (05-13-2025 2004).png](images/159231/USOil%20D1%20%2805-13-2025%202004%29.png)



 **Z-Score Mean Reversion Strategy (FXCM TS2)**

**Concept:**
This strategy uses **Z-score** to detect how far price has deviated from its mean (SMA). Extreme values suggest potential reversion.

**Formula:**
Z = (Price - SMA) / StdDev
High positive Z - price is overbought
High negative Z - price is oversold

**Trade Logic:**
Buy when Z < -EntryZ
Sell when Z > EntryZ
Exit when |Z| < ExitZ

**Indicator: Z-Score Mean Reversion Level.lua**

Adds automatic color-coded oscillator line

Highlights entry/exit levels visually

Parameters: SMA period, Z thresholds, level lines

Green = Buy Zone (Oversold)
Red = Sell Zone (Overbought)
Gray = Neutral (mean proximity)

**Usage Tips:**
Works best in sideways/range markets (e.g. M30/H1 FX pairs)
Avoid strong trends unless combined with filter (e.g. slope of 200 EMA)

 [Z-Score Mean Reversion.lua](files/159231/Z-Score%20Mean%20Reversion.lua)

 [Z-Score Mean Reversion Level.lua](files/159231/Z-Score%20Mean%20Reversion%20Level.lua)


---

## Re: Z-Score Mean Reversion

**Apprentice** · Tue May 13, 2025 2:10 pm

![MTF MCP  Z-SCORE MEAN REVERSION LEVEL VIEW(UNK) (05-13-2025 2107).png](images/159232/MTF%20MCP%20Z-SCORE%20MEAN%20REVERSION%20LEVEL%20VIEW%28UNK%29%20%2805-13-2025%202107%29.png)



[center]**Z-Score Mean Reversion Indicator Set (FXCM TS2)**[/center]

**1. Z-Score Mean Reversion Level**
A classic oscillator showing how far price deviates from its mean (SMA), expressed in standard deviations.
Visual entry/exit zones based on customizable Z-score levels.

**Trading logic:**

- Buy when Z < –EntryZ
- Sell when Z > +EntryZ
- Exit when |Z| < ExitZ

Includes color-coded lines and levels for easy visual tracking.
Useful for mean-reverting markets and price extremes.

**2. MTF MCP Z-Score Mean Reversion View**
A powerful multi-timeframe, multi-currency dashboard that shows Z-score values across pairs and timeframes.

**Key features:**

- Supports up to 20 custom instruments
- 13 selectable timeframes
- Color-coded labels for BUY (green), SELL (red), and NEUTRAL (gray)
- Optional signal-only view to reduce clutter

Perfect for identifying broad market opportunities and reversals in one glance.

[center]**Why Z-Score Mean Reversion View Is Highly Selective**[/center]

**Purposeful Selectivity**

The **MTF MCP Z-Score Mean Reversion View** is designed to show only statistically significant deviations from the mean.

This makes it **highly selective** by filtering out noise and highlighting only strong mean reversion opportunities.

**It only displays signals when:**

1. The **Z-score exceeds the configured EntryZ threshold** (e.g., ±2.00)
2. There is **momentum (Δ Z-score)** in the direction of reversion

Optional: If **SignalOnly = false**, it also shows neutral values, but otherwise hides them

 [MTF MCP Z-SCORE MEAN REVERSION LEVEL View.lua](files/159232/MTF%20MCP%20Z-SCORE%20MEAN%20REVERSION%20LEVEL%20View.lua)
