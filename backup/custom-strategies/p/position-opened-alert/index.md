# Position_Opened_Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=69145  
> Forum: 31 · Topic 69145 · 1 post(s)


---

## Position_Opened_Alert

**Apprentice** · Wed Nov 20, 2019 5:42 am

Based on request.
[viewtopic.php?f=27&t=69140](https://fxcodebase.com/code/viewtopic.php?f=27&t=69140)

A simple alert that sends an email every time a position is opened with the symbol, lot size, open, limit, stop.

 [Position_Opened_Alert.lua](files/129846/Position_Opened_Alert.lua)

There are some catches. FXTS2 order workflow create a trade without stop loss first. So, when the strategy detects a new trade there will be no stop and limit. They will be added one by one as a dedicated event. So, on creating single trade with stop and limit there will be several message. To avoid sending several emails I've added a 3 second delay. All these messages will be send in batches. This is the only working solution I came up with.
