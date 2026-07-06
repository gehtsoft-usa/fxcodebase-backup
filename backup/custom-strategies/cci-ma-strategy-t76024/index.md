# CCI MA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=76024  
> Forum: 31 · Topic 76024 · 1 post(s)


---

## CCI MA Strategy

**Apprentice** · Tue Jun 10, 2025 5:48 am

![EURUSD D1 (06-10-2025 1245).png](images/159564/EURUSD%20D1%20%2806-10-2025%201245%29.png)



Based on the post.
[https://x.com/joinfingrad/status/1932057368495530468](https://x.com/joinfingrad/status/1932057368495530468)

Trading Logic
The user can choose one of three "Cross Methods" via the parameter CrossMethod:
CCI: Trade signals are based only on the CCI crossing a predefined level.
MA: Trade signals are based only on price crossing the Moving Average.
Any: Trade signals are triggered when either the CCI or the MA condition is met.

Buy Entry:
CCI crosses above the user-defined cciLevel (default: 100).
Or Close price crosses above the MA.
Or either of these if CrossMethod = "Any".

Sell Entry:
CCI crosses below -cciLevel.
Or Close price crosses below the MA.
Or either of these if CrossMethod = "Any".

Exit Logic – Price Above MA
If CloseOnOpposite = true, the strategy will close the current position when the opposite signal is triggered. This includes the case when:

For a Sell Position:
The price was below the MA, and now crosses above the MA → the sell position is closed.

For a Buy Position:
The price was above the MA, and now crosses below the MA → the buy position is closed.

This allows the strategy to dynamically exit trades based on MA crossovers, depending on trend reversals.

 [CCI MA Strategy.lua](files/159564/CCI%20MA%20Strategy.lua)
