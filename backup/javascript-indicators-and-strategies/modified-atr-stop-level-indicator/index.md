# Modified ATR Stop Level indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=66443  
> Forum: 48 · Topic 66443 · 1 post(s)


---

## Modified ATR Stop Level indicator

**Alexander.Gettinger** · Mon Aug 06, 2018 2:10 pm

The indicator can be used to calculate the stop levels for trading.

Formulas:
TS[i] = Max(TS[i-1], Close[i]-loss), if Close[i]>TS[i-1] and Close[i-1]>TS[i-1],
TS[i] = Min(TS[i-1], Close[i]+loss), if Close[i]<TS[i-1] and Close[i-1]<TS[i-1],
TS[i] = Close[i]-loss, if Close[i]>TS[i-1],
TS[i] = Close[i]+loss, if Close[i]<TS[i-1], where
loss = Coeff*WMA(Diff, Period),
WMA - Wilder Exponential Moving Average,
Diff[i] = Max(HiLo, Href, Lref),
HiLo[i] = Min(High[i]-Low[i], MVA(High-Low, Period)),
Href[i] = High[i]-Close[i-1], if Low[i]<=High[i-1],
Href[i] = (High[i]+High[i-1]-Low[i]-Close[i-1])/2, if Low[i]>High[i-1],
Lref[i] = Close[i-1]-Low[i], if High[i]>=Low[i-1],
Lref[i] = (Close[i-1]+High[i]-Low[i-1]-Low[i])/2, if High[i]<Low[i-1].

 

![Mod_ATR_Trailing_Stop.PNG](images/120375/Mod_ATR_Trailing_Stop.PNG)



Download:

 [Mod_ATR_Trailing_Stop_JS.jsl](files/120375/Mod_ATR_Trailing_Stop_JS.jsl)
