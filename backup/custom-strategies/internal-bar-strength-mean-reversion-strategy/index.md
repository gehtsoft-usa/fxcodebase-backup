# Internal Bar Strength Mean reversion strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=74776  
> Forum: 31 · Topic 74776 · 1 post(s)


---

## Internal Bar Strength Mean reversion strategy

**Apprentice** · Fri Apr 12, 2024 6:34 pm

![EURUSD H1 (04-13-2024 0147).png](images/154994/EURUSD%20H1%20%2804-13-2024%200147%29.png)



Open Long
If today’s IBS is lower than 0.1, then long at the close.
Exit at the close when the IBS is 0.75 or higher.

Open Short
If today’s IBS is higher than 0.9, then short at the close.
Exit at the close when the IBS is 0.25 or lower.

Internal Bar Strength.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=74775](https://fxcodebase.com/code/viewtopic.php?f=17&t=74775)

 [Internal Bar Strength Mean reversion strategy.lua](files/154994/Internal%20Bar%20Strength%20Mean%20reversion%20strategy.lua)
