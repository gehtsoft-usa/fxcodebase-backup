# Deterministic Boltzmann Approximation

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75788  
> Forum: 17 · Topic 75788 · 1 post(s)


---

## Deterministic Boltzmann Approximation

**Apprentice** · Wed Apr 02, 2025 11:03 am

![EURUSD M1 (04-02-2025 1802).png](images/158855/EURUSD%20M1%20%2804-02-2025%201802%29.png)



**Deterministic Boltzmann-like Energy Indicator (No randomness)**

**Description:**
This Lua indicator for FXCM Trading Station 2 calculates a deterministic "Energy" value inspired by Boltzmann Machines. It provides clear signals regarding trend strength and direction based purely on momentum and volatility, without any random or stochastic elements.

**How it works:**
The indicator calculates two main components:

1. **Momentum**: Difference between the current closing price and the closing price from a defined lookback period.
2. **Volatility**: Average absolute price change over the same lookback period.

Using these two components, the indicator calculates the "Energy," which indicates how strongly price is trending:

Code: [Select all](https://fxcodebase.com/code/)
`Energy = Momentum / Volatility`

**Interpretation of Energy Values:**

- **Positive Energy**: Indicates a strong upward market trend.
- **Negative Energy**: Indicates a strong downward market trend.
- **Energy near zero**: Indicates weak or sideways market movements.

**Indicator Parameters:**

- **Lookback Period**: Number of bars used to calculate momentum and volatility (default: 14, recommended range: 5-30).

**Visual Settings:**

- **Positive Energy Color**: Green bars indicate a bullish or upward trend.
- **Negative Energy Color**: Red bars indicate a bearish or downward trend.

 [Deterministic Boltzmann Approximation.lua](files/158855/Deterministic%20Boltzmann%20Approximation.lua)
