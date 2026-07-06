# Period Amplitude Price Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75822  
> Forum: 17 · Topic 75822 · 1 post(s)


---

## Period Amplitude Price Oscillator

**Apprentice** · Fri Apr 11, 2025 2:08 pm

![EURUSD D1 (04-11-2025 2107).png](images/158937/EURUSD%20D1%20%2804-11-2025%202107%29.png)



**Period, Amplitude, Price Oscillator with Smoothing Methods**

**Description:**
This custom oscillator for FXCM Trading Station 2 (Marketscope) calculates the current closing price's position within a specific price range over a user-defined number of periods (bars). It helps identify potential overbought and oversold market conditions.

**Key Features:**

- Clearly visualizes price positioning within a defined amplitude (high-low range).
- Oscillator scale from 0 (price at bottom of range) to 100 (price at top of range), 50 indicates neutral.

**Usage Tips:**

 - Values near 100 indicate possible overbought conditions.
 - Values near 0 indicate possible oversold conditions.
 - Smoothing filters noise, offering clearer trade signals.

 [Period Amplitude Price Oscillator.lua](files/158937/Period%20Amplitude%20Price%20Oscillator.lua)
