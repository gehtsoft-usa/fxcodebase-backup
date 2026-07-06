# FX Trend

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=66545  
> Forum: 48 · Topic 66545 · 1 post(s)


---

## FX Trend

**Alexander.Gettinger** · Sat Aug 18, 2018 9:20 pm

Formulas:
FXT = K*((Close-L1)/(D1*Short_Length)+(Close-L2)/(D2*Mid_Length)+(Close-L3)/(D3*Long_Length)), where
D1 = H1-L1,
D2 = H2-L2,
D3 = H3-L3,
L1, H1 - lowest and highest prices at range from (i-Short_Length+1) to (i),
L2, H2 - lowest and highest prices at range from (i-Mid_Length+1) to (i),
L3, H3 - lowest and highest prices at range from (i-Long_Length+1) to (i),
K = 100/(1/Short_Length+1/Mid_Length+1/Long_Length).

 

![FX Trend.PNG](images/120648/FX%20Trend.PNG)



Download:

 [FX Trend_JS.jsl](files/120648/FX%20Trend_JS.jsl)
