# Breakdown Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=68255  
> Forum: 48 · Topic 68255 · 1 post(s)


---

## Breakdown Oscillator

**Alexander.Gettinger** · Sat Mar 30, 2019 3:20 pm

Formula:
Breakdown = 100*EMA/Bottom, where
EMA = EMA(Difference) with [Short_Length] number of periods,
Difference[i] = Price[i]-Bottom[i]+Slope_Factor*(SMA[i]-SMA[i-1]),
Bottom[i] = SMA[i]-Deviation*StdDev,
StdDev - Standard Deviation(Price) with [Band_Length] number of periods,
SMA = MVA(Price) with [Short_Length] number of periods.

 

![Breakdown Oscillator.PNG](images/125475/Breakdown%20Oscillator.PNG)



Download:

 [Breakdown Oscillator_JS.jsl](files/125475/Breakdown%20Oscillator_JS.jsl)
