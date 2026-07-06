# Accelerate Volume Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=73605  
> Forum: 31 · Topic 73605 · 1 post(s)


---

## Accelerate Volume Strategy

**Apprentice** · Sat Apr 15, 2023 3:12 am

![EURUSD H1 (04-14-2023 1910).png](images/150429/EURUSD%20H1%20%2804-14-2023%201910%29.png)



Based on the source
[https://www.prorealcode.com/prorealtime ... x-4h-v0-1/](https://www.prorealcode.com/prorealtime-trading-strategies/accelerate-volume-dax-4h-v0-1/)

Long
a = AverageVolumeBuy CROSSES OVER AverageVolumeSell
b = AverageVolumeBuy > AverageVolumeBuy[1]
c = MACDVolume > AverageVolumeSell

Short
d = AverageVolumeSell CROSSES OVER AverageVolumeBuy
e = AverageVolumeSell > AverageVolumeSell[1]
f= MACDVolume > AverageVolumeBuy

Accelerate Volume.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=73604](https://fxcodebase.com/code/viewtopic.php?f=17&t=73604)

 [Accelerate Volume Strategy.lua](files/150429/Accelerate%20Volume%20Strategy.lua)
