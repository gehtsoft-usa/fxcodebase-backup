# Trend force oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=59986  
> Forum: 38 · Topic 59986 · 1 post(s)


---

## Trend force oscillator

**Alexander.Gettinger** · Tue Nov 26, 2013 3:54 pm

Formulas:
Trend Force[i] = Up[i]-Dn[i], where
Up[i] = maximum (MaxPrice-ATR_Coeff*ATR) at range from (i-Period+1) to i,
Dn[i] = minimum (MinPrice+ATR_Coeff*ATR) at range from (i-Period+1) to i,
MaxPrice, MinPrice - maximum and minimum prices at range from (i-ATR_Period+1) to i,
ATR - Average True Range with ATR_Period.

 

![Trend_Force_MQL.PNG](images/91140/Trend_Force_MQL.PNG)



Download:

 [Trend_Force.mq4](files/91140/Trend_Force.mq4)
