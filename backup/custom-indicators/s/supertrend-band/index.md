# SuperTrend Band

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=68919  
> Forum: 17 · Topic 68919 · 5 post(s)


---

## SuperTrend Band

**Apprentice** · Mon Sep 16, 2019 4:11 am

![EURUSD m1 (09-16-2019 0918).png](images/128699/EURUSD%20m1%20%2809-16-2019%200918%29.png)



Based on request.
[viewtopic.php?f=27&t=68865](https://fxcodebase.com/code/viewtopic.php?f=27&t=68865)

Up[i]=(H[i] + L[i] ) / 2 - (Factor*atr[i]) ;
Dn[i]=(H[i] + L[i] ) / 2 + (Factor*atr[i]) ;

TrendUp[i] = C[i-1] >TrendUp[i-1] ? Math.Max(Up[i],TrendUp[i-1]) : Up[i] ;
TrendDown[i]= C[i-1]<TrendDown[i-1]? Math.Min(Dn[i],TrendDown[i-1]) : Dn[i] ;

 [SuperTrend Band.lua](files/128699/SuperTrend%20Band.lua)

Indicator based strategy
[viewtopic.php?f=31&t=68931](https://fxcodebase.com/code/viewtopic.php?f=31&t=68931)


---

## Re: SuperTrend Band

**SerifKocdemir** · Mon Sep 16, 2019 4:22 am

It is really amazing.
Thank you so much.
Can ve make this strategy?


---

## Re: SuperTrend Band

**Apprentice** · Mon Sep 16, 2019 5:37 am

Can you please provide strategy rules?


---

## Re: SuperTrend Band

**SerifKocdemir** · Mon Sep 16, 2019 7:11 am

LONG RULES
Price >= DN line : Open Long
UP line is Trailing Stop for Long Position

SHORT RULLES
Price <= UP line : Open Short
DN line is Trailing Stop for Short Position


---

## Re: SuperTrend Band

**Apprentice** · Wed Sep 18, 2019 6:38 am

Indicator based strategy
[viewtopic.php?f=31&t=68931](https://fxcodebase.com/code/viewtopic.php?f=31&t=68931)
