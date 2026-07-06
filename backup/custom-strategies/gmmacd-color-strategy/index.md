# GMMACD Color Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=59829  
> Forum: 31 · Topic 59829 · 9 post(s)


---

## GMMACD Color Strategy

**Apprentice** · Sun Nov 10, 2013 3:10 pm

![GMMACD Color Strategy.png](images/90705/GMMACD%20Color%20Strategy.png)



Based on GMMACD Color Indicator.
[viewtopic.php?f=17&t=412&start=40](https://fxcodebase.com/code/viewtopic.php?f=17&t=412&start=40)

Open Long on Green Bar
Open Short on Red Bar
Close position if contradictory signal occurs.

 [GMMACD Color Strategy.lua](files/90705/GMMACD%20Color%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: GMMACD Color Strategy

**Aboxofdonuts** · Mon Nov 11, 2013 4:38 pm

Thank you very much for this!


---

## Re: GMMACD Color Strategy

**toxxum** · Wed Dec 25, 2013 11:44 am

Has anyone tried to backtest this strategy? I visually checked some two dozens entry and exit points and they seem to be totally off. Please see attached, some of the entries are marked with a vertical yellow line.

Is that a bug?


---

## Re: GMMACD Color Strategy

**Xandra** · Mon Jan 12, 2015 4:20 am

Can you add the size of the previous candle, and the size of the current candle as optimize-able parameters?


---

## Re: GMMACD Color Strategy

**Apprentice** · Tue Jan 13, 2015 10:01 am

Candle Size is not changeable.


---

## Re: GMMACD Color Strategy

**cpc_cs** · Fri Apr 01, 2016 1:38 pm

Dear Apprentice,

Is it possible to use this strategy with GMMACD in a different time frame i.e. with 4 hr GMMACD on a 5 min Chart?

Or is it possible to develop such a strategy? If possible, please let me know, I will explain a strategy.

Thanks and Regards

S. Joseph


---

## Re: GMMACD Color Strategy

**cpc_cs** · Sun Apr 03, 2016 8:47 am

Dear Apprentice,

I received an email saying there was reply for my earlier post - but I cannot see anything. Anyway, I will describe my strategy below. Please let me know if this can be programmed:

Short Time Frame: 15 Minutes
Long Time Frame: 4 Hour
Indicators: GMMACD COLOR (H4, Close, 9) my 4hr candles close at 1, 5, 9, 13, 17 and 21 (UTC-4.00)

**Long Entry**:
1) GMMACD Changes from -ve to +ve AND Signal Line < GMMACD (see picture 1 below)
2) GMMACD Crosses Signal Line from Below (see picture 2 below)

**Short Entry**:
1) GMMACD Changes from +ve to -ve AND Signal Line > GMMACD (see picture 3 below)
2) GMMACD Crosses Signal Line from Below (on the Short Side) (see picture 4 below)

**Long Exit**:
1) GMMACD Changes from +ve to -ve (no picture - opposite of Short Exit No. 1)
2) Signal Line Crosses GMMACD from Below (see picture 6 below)

**Short Exit**:
1) GMMACD Changes from -ve to +ve (see picture 7 below)
2) Signal Line Crosses GMMACD from Below (on the Short Side) (see picture 8 below)

**Position Size**:
1) For Long Entry No. 1 and Short Entry No. 1 - 2% of Equity
2) For Long Entry No. 2 and Short Entry No. 2 - 5% of Equity; SL; 30 pips; TP: 90 pips

**Pictures**:

 

![Picture 1.jpg](images/105630/Picture%201.jpg)

*Picture 1*



 

![Picture 2.jpg](images/105630/Picture%202.jpg)

*Picture 2*



 

![Picture 3.jpg](images/105630/Picture%203.jpg)

*Picture 3*



 

![Picture 4.jpg](images/105630/Picture%204.jpg)

*Picture 4*



 

![Picture 6.jpg](images/105630/Picture%206.jpg)

*Picture 6*



 

![Picture 7.jpg](images/105630/Picture%207.jpg)

*Picture 7*



 

![Picture 8.jpg](images/105630/Picture%208.jpg)

*Picture 8*


---

## Re: GMMACD Color Strategy

**Apprentice** · Wed Apr 06, 2016 1:10 pm

Requested can be found here.
[viewtopic.php?f=31&t=63349](https://fxcodebase.com/code/viewtopic.php?f=31&t=63349)


---

## Re: GMMACD Color Strategy

**Apprentice** · Fri Dec 16, 2016 6:15 am

Strategy was revised and updated.
