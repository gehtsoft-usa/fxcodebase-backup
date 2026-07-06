# Previous day Bounce with MA Confirmation

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=76085  
> Forum: 17 · Topic 76085 · 1 post(s)


---

## Previous day Bounce with MA Confirmation

**Apprentice** · Wed Jun 25, 2025 3:10 pm

![USDJPY H8 (06-25-2025 2209).png](images/159742/USDJPY%20H8%20%2806-25-2025%202209%29.png)



 **Filter Description – Previous Day Bounce with MA Confirmation**

This indicator uses a **three-stage filtering system** to identify high-probability trade setups aligned with recent breakouts and moving average structure.

**1. Break of Previous Day High/Low (Close > PDH Close < PDL)**
Detects whether the current candle has breached key levels from the previous session:

- For a **buy**: must be above the previous day’s high.
- For a **sell**: must be below the previous day’s low.
This ensures that the market is breaking out of the prior day's range before considering a trade.

**2. Bounce From MA Confirmation (PDHL Filter)**
Ensures price is pulling back into value and rejecting it, validating a bounce from the MA:

- For a **buy**: candle must dip below the MA + PD range * Multiplier
- For a **sell**: candle must spike above the MA + PD range * Multiplier

**3. MA Based trend filter (Close > MA Close < MA)**

- For a **buy**: Price > MA
- For a **sell**: Price < MA

 

![SPX500 H8 (06-25-2025 2236).png](images/159742/SPX500%20H8%20%2806-25-2025%202236%29.png)



This helps time entries after a healthy retracement, avoiding overextended entries.

All three conditions must be met for a valid signal. The filter system is designed to reduce noise, confirm direction, and time-precise pullback entries.

 [Previous day Bounce with MA Confirmation.lua](files/159742/Previous%20day%20Bounce%20with%20MA%20Confirmation.lua)

Indicator-based strategy.
[https://fxcodebase.com/code/viewtopic.p ... 52#p159752](https://fxcodebase.com/code/viewtopic.php?f=31&t=76089&p=159752#p159752)
