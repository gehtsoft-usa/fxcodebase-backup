# MA Cross CCI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=75919  
> Forum: 31 · Topic 75919 · 1 post(s)


---

## MA Cross CCI Strategy

**Apprentice** · Thu May 08, 2025 5:05 am

![EURUSD H1 (05-08-2025 1205).png](images/159183/EURUSD%20H1%20%2805-08-2025%201205%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.p ... 78#p159178](https://fxcodebase.com/code/viewtopic.php?f=27&p=159178#p159178)

 [MA Cross CCI Strategy.lua](files/159183/MA%20Cross%20CCI%20Strategy.lua)

The MA Cross CCI Strategy combines Moving Average (MA) crossovers and the Commodity Channel Index (CCI) to generate trade signals.

Trading Logic (Summary):
MA Cross:

When the first MA (faster) crosses above the second MA (slower) → Buy Signal.

When the first MA crosses below the second MA → Sell Signal.

MA signals can be disabled via the MA_Off parameter.

CCI (Commodity Channel Index):

If the CCI crosses above a defined Overbought level (e.g., +100) → Buy Signal.

If the CCI crosses below a defined Oversold level (e.g., -100) → Sell Signal.

CCI signals can be disabled via the CCI_Off parameter.

Combined Signal Logic:

If both MA and CCI are enabled, both conditions must be true simultaneously for a trade to be triggered.

If only one is enabled, only that condition is used.

 

![EURUSD H1 (05-08-2025 1210).png](images/159183/EURUSD%20H1%20%2805-08-2025%201210%29.png)



With CCI cross disabled.
Only Checks CCI position.
