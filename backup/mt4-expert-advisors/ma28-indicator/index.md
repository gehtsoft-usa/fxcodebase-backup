# MA28 indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=60369  
> Forum: 38 · Topic 60369 · 1 post(s)


---

## MA28 indicator

**Alexander.Gettinger** · Thu Feb 27, 2014 11:37 am

The indicator represents the average of 28 variants moving average.

Formulas:
MA28 = (Sum_MVA+Sum_EMA+Sum_SMMA+Sum_LWMA)/28, where
Sum_MVA = MVA(Open)+MVA(Close)+MVA(High)+MVA(Low)+MVA(Median)+MVA(Typical)+MVA(Weighted),
Sum_EMA = EMA(Open)+EMA(Close)+EMA(High)+EMA(Low)+EMA(Median)+EMA(Typical)+EMA(Weighted),
Sum_SMMA = SMMA(Open)+SMMA(Close)+SMMA(High)+SMMA(Low)+SMMA(Median)+SMMA(Typical)+SMMA(Weighted),
Sum_LWMA = LWMA(Open)+LWMA(Close)+LWMA(High)+LWMA(Low)+LWMA(Median)+LWMA(Typical)+LWMA(Weighted).

 

![MA28_MQL.PNG](images/92930/MA28_MQL.PNG)



Download:

 [MA28.mq4](files/92930/MA28.mq4)
