# SSD SFK BB Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=75758  
> Forum: 31 · Topic 75758 · 1 post(s)


---

## SSD SFK BB Strategy

**Apprentice** · Wed Mar 26, 2025 9:28 am

![EURUSD m5 (03-26-2025 1527).png](images/158780/EURUSD%20m5%20%2803-26-2025%201527%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.p ... 28#p156828](https://fxcodebase.com/code/viewtopic.php?f=27&p=156828#p156828)

Timeframes:

M5: SSD(20,10)

M15: SFK(5,5), BB(20,0.75)

H1: SFK(5,5)

Buy Conditions
H1 SFK > 50

M15 SFK > 50

M15 Close > Upper BB(20,0.75)

M5 SSD K crosses above 70

M15 Close > previous close
→ Open Long

Sell Conditions
H1 SFK < 50

M15 SFK < 50

M15 Close < Lower BB(20,0.75)

M5 SSD K crosses below 30

M15 Close < previous close
→ Open Short

Exit Conditions
Long: Exit when M5 SSD K < 70

Short: Exit when M5 SSD K > 30

 [SSD SFK BB Strategy.lua](files/158780/SSD%20SFK%20BB%20Strategy.lua)
