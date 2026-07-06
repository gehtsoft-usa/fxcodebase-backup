# ATR exponential

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=64682  
> Forum: 48 · Topic 64682 · 1 post(s)


---

## ATR exponential

**Alexander.Gettinger** · Fri May 26, 2017 2:09 pm

Formula:
ATRex[i]=T*pr+ATRex[i-1]*(1-pr), where
pr=2/(Period+1),
T[i]=Max(High[i], Close[i-1])-Min(Low[i], Close[i-1]),
Period - number of periods.

 

![ATR_Exponential_JS.PNG](images/112561/ATR_Exponential_JS.PNG)



Download:

 [ATR_Exponential_JS.jsl](files/112561/ATR_Exponential_JS.jsl)
