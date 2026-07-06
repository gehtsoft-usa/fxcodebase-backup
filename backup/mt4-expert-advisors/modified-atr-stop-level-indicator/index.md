# Modified ATR Stop Level indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=59638  
> Forum: 38 · Topic 59638 · 1 post(s)


---

## Modified ATR Stop Level indicator

**Alexander.Gettinger** · Wed Oct 09, 2013 5:56 pm

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

 

![Modified_ATR_Trailing_Stop_MQL.PNG](images/89930/Modified_ATR_Trailing_Stop_MQL.PNG)



Download:

 [Mod_ATR_Trailing_Stop.mq4](files/89930/Mod_ATR_Trailing_Stop.mq4)
