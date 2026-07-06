# Exponential Smoothing with Trend Adjustment

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=68216  
> Forum: 48 · Topic 68216 · 1 post(s)


---

## Exponential Smoothing with Trend Adjustment

**Alexander.Gettinger** · Sat Mar 30, 2019 11:45 am

Formulas:
EMATA[i] = Alpha*Price[i-1]+(1-Alpha)*(EMATA[i-1]+Trend[i-1]),
Trend[i] = Beta*(EMATA[i]-EMATA[i-1])+(1-Beta)*Trend[i-1].

 

![EMA with Trend Adjustment.PNG](images/125435/EMA%20with%20Trend%20Adjustment.PNG)



Download:

 [EMA with Trend Adjustment_JS.jsl](files/125435/EMA%20with%20Trend%20Adjustment_JS.jsl)
