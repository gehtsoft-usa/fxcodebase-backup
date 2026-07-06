# Trailing Stop level indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59631  
> Forum: 17 · Topic 59631 · 11 post(s)


---

## Trailing Stop level indicator

**Alexander.Gettinger** · Wed Oct 09, 2013 11:29 am

The indicator can be used to calculate the stop levels for trading.

Formulas:
TSL[i] = Max(TSL[i-1], Close[i]-loss), if Close[i]>TSL[i-1] and Close[i-1]>TSL[i-1],
TSL[i] = Min(TSL[i-1], Close[i]+loss), if Close[i]<TSL[i-1] and Close[i-1]<TSL[i-1],
TSL[i] = Close[i]-loss, if Close[i]>TSL[i-1],
TSL[i] = Close[i]+loss, if Close[i]<TSL[i-1], where
loss = Close[i]*Percent/100.

 

![Trailing_Stop_Level.PNG](images/89913/Trailing_Stop_Level.PNG)



Download:

 [Trailing_Stop_Level.lua](files/89913/Trailing_Stop_Level.lua)

 [Trailing_Limit_Level.lua](files/89913/Trailing_Limit_Level.lua)

Trailing_Stop_Level.lua based strategy.
[viewtopic.php?f=31&t=66878](https://fxcodebase.com/code/viewtopic.php?f=31&t=66878)


---

## Re: Trailing Stop level indicator

**tmdabc** · Fri Oct 23, 2015 2:30 pm

looks good，thanks


---

## Re: Trailing Stop level indicator

**Apprentice** · Tue Oct 23, 2018 6:36 am

The indicator was revised and updated.


---

## Re: Trailing Stop level indicator

**Phamilton630** · Fri Oct 26, 2018 7:36 am

Is there any way to incorporate a limit/take profits line into this indicator also?


---

## Re: Trailing Stop level indicator

**Phamilton630** · Fri Oct 26, 2018 11:38 am

If a take profit (TP) line component can be added to this indicator, it would then be possible to add a profit loss counter to the top right corner of the chart.

It would measure the pips accumulated in the chart by the continuous SL and TP events.

This would allow the operator to fine tune TP & SL levels to maximise profits and minimise losses

thank you


---

## Re: Trailing Stop level indicator

**Apprentice** · Sat Oct 27, 2018 5:17 am

How we will calculated limit/take profits line?


---

## Re: Trailing Stop level indicator

**Phamilton630** · Sun Oct 28, 2018 1:52 pm

simplest case would be to make it equal but opposite to SL amount of pips


---

## Re: Trailing Stop level indicator

**Apprentice** · Mon Oct 29, 2018 6:08 am

Trailing_Limit_Level added.


---

## Re: Trailing Stop level indicator

**Phamilton630** · Mon Oct 29, 2018 10:06 am

ah ok TP never gets hit. Silly me.

Could you please turn the SL indicator into a strategy that can open a trade when SL is hit (a trade in the opposite direction).

Three trade modes
> trade longs only
> trade shorts only
> trade longs & shorts (continuous trading, opposite trade entered when previous trade closed)


---

## Re: Trailing Stop level indicator

**Apprentice** · Tue Oct 30, 2018 4:18 pm

Your request is added to the development list under Id Number 4288


---

## Re: Trailing Stop level indicator

**Apprentice** · Wed Oct 31, 2018 5:17 am

Try this version.
[viewtopic.php?f=31&t=66878](https://fxcodebase.com/code/viewtopic.php?f=31&t=66878)
