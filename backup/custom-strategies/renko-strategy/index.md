# Renko Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=66876  
> Forum: 31 · Topic 66876 · 4 post(s)


---

## Renko Strategy

**Apprentice** · Tue Oct 30, 2018 5:27 pm

[Renko Strategy.lua](files/121880/Renko%20Strategy.lua)

Buy/ sell into the trend direction every time that a new brick is formed.
NOTE: this strategy can't be backtested
You will have to download Renko_candles_New.lua
[viewtopic.php?f=17&t=60748](https://fxcodebase.com/code/viewtopic.php?f=17&t=60748)


---

## Re: Renko Strategy

**SmithGasset** · Fri Nov 02, 2018 2:46 am

Hi, I've noticed a few instances where after a new brick is formed, the strategy doesn't do anything. Is this due to a bug?


---

## Re: Renko Strategy

**Apprentice** · Sun Nov 04, 2018 6:19 am

We removed End of bar option which could case such an issue.


---

## Re: Renko Strategy

**SmithGasset** · Mon Nov 05, 2018 1:25 am

This happens even though I{m using the "live execution type".
