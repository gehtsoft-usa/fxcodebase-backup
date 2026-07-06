# Volatility Ratio

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=60789  
> Forum: 38 · Topic 60789 · 1 post(s)


---

## Volatility Ratio

**Alexander.Gettinger** · Thu Jun 05, 2014 4:28 pm

Original LUA oscillator: [viewtopic.php?f=17&t=60293](https://fxcodebase.com/code/viewtopic.php?f=17&t=60293).

Formulas:
VR[i] = tr[i]/pr[i], where
tr[i] = Max(hl[i], hc[i], lc[i]),
hl[i] = High[i]-Low[i],
hc[i] = Abs(High[i]-Close[i-1]),
lc[i] = Abs(Low[i]-Close[i-1]),
pr[i] = Max(MH, Open[i-Length+1])-Min(ML, Open[i-Length+1]),
MH, ML - maximum and minimum prices at range from (i-Length+1) to (i).

 

![Volatility_Ratio_MQL.PNG](images/94354/Volatility_Ratio_MQL.PNG)



Download:

 [Volatility_Ratio.mq4](files/94354/Volatility_Ratio.mq4)
