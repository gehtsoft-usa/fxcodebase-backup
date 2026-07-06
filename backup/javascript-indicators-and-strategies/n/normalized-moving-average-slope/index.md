# Normalized Moving Average Slope

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=67104  
> Forum: 48 · Topic 67104 · 1 post(s)


---

## Normalized Moving Average Slope

**Alexander.Gettinger** · Fri Dec 07, 2018 2:58 pm

Formula:
NMAS[i] = 100*(MA[i]-MA[i-1])/ATR, where
MA - moving average with [MA_Length] number of periods and [MA_Method] type,
ATR - average true range with [ATR_Length] number of periods.

 

![Normilized Moving Average Slope.PNG](images/122615/Normilized%20Moving%20Average%20Slope.PNG)



Download:

 [Normalized Moving Average Slope_JS.jsl](files/122615/Normalized%20Moving%20Average%20Slope_JS.jsl)
