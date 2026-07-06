# Kaufman efficiency ratio indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=64724  
> Forum: 48 · Topic 64724 · 1 post(s)


---

## Kaufman efficiency ratio indicator

**Alexander.Gettinger** · Fri Jun 02, 2017 2:08 pm

The indicator is written according to Perry Kaufman books "Smarter Trading" and "Trading Systems & Methods".

Formula:
Ratio[i]=Abs(close[i]-close[i-Period])/Volatility(i), where
Volatility[i]=(DiffPrice[i]+DiffPrice[i-1]+...+DiffPrice[i-Period])/Period,
DiffPrice[i]=Abs(close[i]-close[i-1]).

 

![Kaufman_Efficiency_Ratio_JS.PNG](images/112713/Kaufman_Efficiency_Ratio_JS.PNG)



Download:

 [Kaufman_Efficiency_Ratio_JS.jsl](files/112713/Kaufman_Efficiency_Ratio_JS.jsl)
