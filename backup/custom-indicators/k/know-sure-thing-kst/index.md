# Know Sure Thing (KST)

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64518  
> Forum: 17 · Topic 64518 · 3 post(s)


---

## Know Sure Thing (KST)

**Apprentice** · Fri Mar 10, 2017 12:03 pm

![EURUSD H1 (08-08-2016 0300).png](images/111397/EURUSD%20H1%20%2808-08-2016%200300%29.png)



The KST indicator was developed by Martin J. Pring. The name KST comes from "Know Sure Thing". The KST is constructed by summing four smoothed rates of change. For more interpretation refer to Martin Pring's article "Summed Rate of Change (KST)" in the September 92 issue of TASC.

The indicator formula is
W = R1 + R2 + R3 + R4;
KST = R1/W * MA(ROC(R1), M1) + R2/W * MA(ROC(R2), M2) + R3/W * MVA(ROC(R3), M3) + R4/W * MVA(ROC(R4), M4);
SIGNAL = MA(KST, S)

Where: R1, R2, R3, R4, M1, M2, M3, M4, S and the moving average method are the indicator's parameters.

The typical usage of the indicator is to long when signal line crosses the kst line down and to short when signal line crosses the kst line up.

Please read more:
about usage: [http://www.trending123.com/patterns/kno](http://www.trending123.com/patterns/kno) ... lator.html
about formula: [http://www.incrediblecharts.com/indicators/kst.php](http://www.incrediblecharts.com/indicators/kst.php)

The default settings (MVA(ROC(9), 6), MVA(ROC(12), 6), MVA(ROC(18), 6), MVA(ROC(24), 6))
works well on long time frames, such as week and month:

 [kst.lua](files/111397/kst.lua)

The indicator was revised and updated


---

## Prings KST

**Apprentice** · Fri Mar 10, 2017 12:20 pm

![EURUSD H1 (08-08-2016 1130).png](images/111398/EURUSD%20H1%20%2808-08-2016%201130%29.png)



This version uses a slightly different formula.
KST = 1* MA(ROC(R1), M1) + 2 * MA(ROC(R2), M2) + 3 * MVA(ROC(R3), M3) + 4 * MVA(ROC(R4), M4);

 [Prings KST.lua](files/111398/Prings%20KST.lua)


---

## Re: Know Sure Thing (KST)

**maryaeva** · Sun Mar 12, 2017 12:30 pm

Thank you Apprentice for this KST with alert -
