# SI oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59974  
> Forum: 17 · Topic 59974 · 3 post(s)


---

## SI oscillator

**Alexander.Gettinger** · Mon Nov 25, 2013 5:13 pm

SI indicator ([http://www.mql5.com/en/code/1883](http://www.mql5.com/en/code/1883)) has been the basis of this indicator.

Formulas:
SI = MA(D), where
D = 50*X*K/R,
X[i] = 0.25*Open[i]-1.5*Close[i-1]+0.75*Close[i]+0.5*Open[i-1],
R = R1-R2/2+R4/4, if R1>=Max(R2, R3),
R = R2-R1/2+R4/4, if R2>=Max(R1, R3),
R = R3+R4/4, in other cases,
K = Max(R1, R2),
R1[i] = Abs(High[i]-Close[i-1]),
R2[i] = Abs(Low[i]-Close[i-1]),
R3[i] = Abs(High[i]-Low[i]),
R4[i] = Abs(Close[i-1]-Open[i-1]).

 

![SI.PNG](images/91111/SI.PNG)



Download:

 [SI.lua](files/91111/SI.lua)

For this indicator must be installed Averages indicator ([viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)).


---

## Re: SI oscillator

**Alexander.Gettinger** · Mon Nov 25, 2013 5:17 pm

MQL4 version of SI oscillator: [viewtopic.php?f=38&t=59975](https://fxcodebase.com/code/viewtopic.php?f=38&t=59975).


---

## Re: SI oscillator

**Apprentice** · Sun Oct 07, 2018 9:09 am

The indicator was revised and updated.
