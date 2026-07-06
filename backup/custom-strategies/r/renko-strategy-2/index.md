# Renko Strategy 2

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=66896  
> Forum: 31 · Topic 66896 · 4 post(s)


---

## Renko Strategy 2

**Apprentice** · Wed Nov 07, 2018 11:14 am

Based on request.
[viewtopic.php?f=27&t=66894](https://fxcodebase.com/code/viewtopic.php?f=27&t=66894)

 [Renko_candles_New.lua](files/121998/Renko_candles_New.lua)

 [Renko Strategy 2.lua](files/121998/Renko%20Strategy%202.lua)

NOTE Renko Strategy 2.lua can NOT be backtested.
You can find Renko_candles_New.lua here.
[viewtopic.php?f=17&t=60748](https://fxcodebase.com/code/viewtopic.php?f=17&t=60748)


---

## Re: Renko Strategy 2

**SmithGasset** · Wed Nov 07, 2018 8:13 pm

Hi, I've noticed a bug, the strategy does not open any new positions after new bricks are formed.


---

## Re: Renko Strategy 2

**SmithGasset** · Thu Nov 08, 2018 11:41 am

the strategy doesn't close previous positions when a contrary brick is formed. And the strategy does not buy in the direction of the trend, rather, it always buys into the type of price that it's configured with.


---

## Re: Renko Strategy 2

**Apprentice** · Mon Nov 12, 2018 4:32 pm

Yep, it was a typo. The wrong brick size was used.
Also, I applied some optimizations to the view. It still can't be optimized (not sure why yet). But it works in the simulator.
