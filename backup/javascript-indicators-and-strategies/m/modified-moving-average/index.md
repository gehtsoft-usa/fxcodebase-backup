# Modified Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=67099  
> Forum: 48 · Topic 67099 · 1 post(s)


---

## Modified Moving Average

**Alexander.Gettinger** · Fri Dec 07, 2018 2:50 pm

This indicator has been described in Stocks&Commodities, January 2000.

Formula:
MMM = MA+6*Slope/K, where
MA - MVA(Price) with [Length] number of periods,
Slope(i) = Sum(Price[i-j+1]*(Length-Factor)/2), Factor = 1+2*(j-1) for j=1..Length,
K = Length*(Length+1).

 

![Modified Moving Average.PNG](images/122610/Modified%20Moving%20Average.PNG)



Download:

 [Modified Moving Average_JS.jsl](files/122610/Modified%20Moving%20Average_JS.jsl)
