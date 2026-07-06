# Bollinger Bandwith Delta

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=68202  
> Forum: 48 · Topic 68202 · 1 post(s)


---

## Bollinger Bandwith Delta

**Alexander.Gettinger** · Sat Mar 30, 2019 11:13 am

Formulas:
BBD[i] = 100*(Bandwidth[i]-Bandwidth[i-Delta_Length+1])/Bandwidth[i-Delta_Length+1], if Percentage,
BBD[i] = Bandwidth[i]-Bandwidth[i-Delta_Length+1], if not Percentage, where
Bandwidth = 2*Deviation*StdDev/MA,
StdDev - Standard Deviation(Price) with [Length] number of periods,
MA = MVA(Price) with [Length] number of periods.

 

![Bollinger Bandwith Delta.PNG](images/125421/Bollinger%20Bandwith%20Delta.PNG)



Download:

 [Bollinger Bandwith Delta_JS.jsl](files/125421/Bollinger%20Bandwith%20Delta_JS.jsl)
