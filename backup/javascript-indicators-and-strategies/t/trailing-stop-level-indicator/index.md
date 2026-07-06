# Trailing Stop level indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=68280  
> Forum: 48 · Topic 68280 · 1 post(s)


---

## Trailing Stop level indicator

**Alexander.Gettinger** · Sat Mar 30, 2019 4:38 pm

The indicator can be used to calculate the stop levels for trading.

Formulas:
TSL[i] = Max(TSL[i-1], Close[i]-loss), if Close[i]>TSL[i-1] and Close[i-1]>TSL[i-1],
TSL[i] = Min(TSL[i-1], Close[i]+loss), if Close[i]<TSL[i-1] and Close[i-1]<TSL[i-1],
TSL[i] = Close[i]-loss, if Close[i]>TSL[i-1],
TSL[i] = Close[i]+loss, if Close[i]<TSL[i-1], where
loss = Close[i]*Percent/100.

 

![Trailing_Stop_Level.PNG](images/125502/Trailing_Stop_Level.PNG)



Download:

 [Trailing_Stop_Level_JS.jsl](files/125502/Trailing_Stop_Level_JS.jsl)
