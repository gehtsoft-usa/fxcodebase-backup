# Bar Based Stochastic oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=67075  
> Forum: 48 · Topic 67075 · 1 post(s)


---

## Bar Based Stochastic oscillator

**Alexander.Gettinger** · Fri Dec 07, 2018 1:28 pm

Formulas:
K = MA(FastK) with [D_Slowing] number of periods and [K_Smoothing_Method] type,
D = MA(K) with [D_Length] number of periods and [D_Smoothing_Method] type, where
FastK[i] = 100*mins[i]/maxes[i],
mins[i] = Close[i]-minLow,
maxes[i] = maxHigh-minLow,
minLow, maxHigh - minimum and maximum prices at range from (i-K_Length+1) to (i).

 

![Bar Based Stochastic with Histogram.PNG](images/122584/Bar%20Based%20Stochastic%20with%20Histogram.PNG)



Download:

 [Bar Based Stochastic with Histogram_JS.jsl](files/122584/Bar%20Based%20Stochastic%20with%20Histogram_JS.jsl)
