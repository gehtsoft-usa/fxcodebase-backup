# Mean reversion

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=64337  
> Forum: 38 · Topic 64337 · 1 post(s)


---

## Mean reversion

**Alexander.Gettinger** · Wed Jan 25, 2017 1:22 pm

Formulas:
DN[i] - lowest price at range from (i-Length+1) to (i),
UP[i] - highest price at range from (i-Length+1) to (i),
DM - median value between DN and UP,
MA - Simple moving average from Close price with [MA_Length] number of periods.

 

![Mean_Reversion.png](images/110703/Mean_Reversion.png)



Download:

 [Mean_Reversion.mq4](files/110703/Mean_Reversion.mq4)
