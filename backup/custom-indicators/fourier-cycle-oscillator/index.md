# Fourier Cycle Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75867  
> Forum: 17 · Topic 75867 · 2 post(s)


---

## Fourier Cycle Oscillator

**Apprentice** · Sat Apr 26, 2025 3:40 pm

![EURUSD D1 (04-26-2025 2236).png](images/159059/EURUSD%20D1%20%2804-26-2025%202236%29.png)



Fourier Cycle Oscillator
Description:
The Fourier Cycle Oscillator is a custom technical indicator that uses a simplified Fourier Transform to detect the dominant cycle strength within a selected number of historical periods.

Instead of analyzing price movements directly, the indicator breaks down recent price behavior into its cyclical (frequency) components, allowing traders to visualize whether the market is dominated by a periodic movement (trend/cycle) or random noise.

The oscillator plots the magnitude of the fundamental frequency extracted from the price data. This makes it easier to identify whether the market is currently cycling upwards or downwards and how strong the detected cycle is.

Practical Application:
Cycle Detection: Helps detect dominant market cycles by highlighting periods when cyclical behavior is strong versus when it is weak.

Trend Confirmation: Rising oscillator values suggest an active, strong upward or downward cycle. Falling oscillator values imply weakening trends or an increasingly random market.

Trading Signals:

If the oscillator rises above its average or crosses above a predefined threshold, it may indicate the beginning of a trending phase.

A fall below a threshold could signal cycle exhaustion and a potential reversal or consolidation.

Noise Filtering: Fourier analysis removes a lot of market "noise" and focuses on cleaner, more meaningful patterns.

Fourier Cycle Oscillator + Moving Average Strategy
Concept:
Combine the Fourier Cycle Oscillator with a Moving Average (MA) to trade only when both:

The trend (via MA) and

The cycle strength (via Fourier analysis) agree.

This filters out bad trades during random/choppy markets and focuses on moments when the market is trending and cyclically strong.

Example Usage:
Trend Traders can use it to confirm whether a breakout or momentum move is supported by strong underlying cycles.

Swing Traders may use it to detect the start of new cycle phases.

Counter-trend Traders might identify weakening cycles for timing reversals.

Market Condition Filters: The oscillator can act as a filter — for example, only trade when cycles are strong, avoid trading when cycles are weak.

 [Fourier Cycle Oscillator.lua](files/159059/Fourier%20Cycle%20Oscillator.lua)


---

## Fourier Oscillating Moving Average (FOMA)

**Apprentice** · Sat Apr 26, 2025 4:02 pm

![EURUSD D1 (04-26-2025 2300).png](images/159061/EURUSD%20D1%20%2804-26-2025%202300%29.png)



Fourier Oscillating Moving Average (FOMA)
Description:
The Fourier Oscillating Moving Average (FOMA) is an advanced moving average that uses Fourier Transform principles to enhance cycle detection and smooth price movement analysis.

Unlike traditional moving averages that simply average historical prices, FOMA captures the dominant cyclical behavior of the market by extracting the real part (cosine component) of the Fourier Transform over a selected period.

This real part (oscillation) is then added to a standard Simple Moving Average (SMA), creating a line that oscillates naturally above and below the SMA baseline, reflecting true market cycles more accurately than conventional smoothing techniques.

Key Features:
Cyclic Behavior Detection: Captures hidden cyclical movements that traditional moving averages cannot see.

Oscillation Around SMA: Instead of simply shifting the moving average upwards, FOMA oscillates above and below the SMA based on market dynamics.

Noise Reduction: Reduces random price noise while enhancing meaningful cycles and trends.

Adaptive: The FOMA adapts its movement according to the underlying cyclical strength detected in the data.

Practical Application:
Trend Enhancement: Traders can spot strengthening or weakening cycles within trends more easily.

Early Reversals: FOMA can indicate subtle changes before regular moving averages react.

Cycle Trading: Ideal for identifying high-probability entries during market expansions and contractions.

Filter for Strategies: FOMA can act as a condition filter, ensuring that trading systems trigger only during strong cyclic conditions.

Visual Behavior:
When the market has strong upward cycles, FOMA will rise above the SMA.

When the market experiences downward cycles, FOMA will dip below the SMA.

In low cycle environments (no clear rhythm), FOMA stays closer to the SMA.

Quick Example:
If price action becomes rhythmically bullish, FOMA will cross above SMA — giving traders early confirmation of trend strength. Conversely, rhythmic bearishness will push FOMA below the SMA ahead of simple moving average crossings.

Summary:
FOMA is a powerful upgrade over traditional moving averages, combining cycle theory (Fourier analysis) with price smoothing to better detect the underlying forces of the market.

 [Fourier Oscillating Moving Average (FOMA).lua](files/159061/Fourier%20Oscillating%20Moving%20Average%20%28FOMA%29.lua)
