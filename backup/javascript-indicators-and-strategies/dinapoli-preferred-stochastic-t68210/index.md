# Dinapoli Preferred Stochastic

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=68210  
> Forum: 48 · Topic 68210 · 1 post(s)


---

## Dinapoli Preferred Stochastic

**Alexander.Gettinger** · Sat Mar 30, 2019 11:27 am

Formulas:
K[i] = K[i-1]+(FastK[i]-K[i-1])/D_Slowing,
D[i] = D[i-1]+(K[i]-D[i-1])/D_Length, where
FastK[i] = 100*(Close[i]-Min)/(Max-Min),
Max, Min - Maximum and minimum prices at range from (i-K_Length+1) to (i).

 

![Dinapoli Preferred Stochastic Bar.PNG](images/125429/Dinapoli%20Preferred%20Stochastic%20Bar.PNG)



Download:

 [Dinapoli Preferred Stochastic_Bar_JS.jsl](files/125429/Dinapoli%20Preferred%20Stochastic_Bar_JS.jsl)
