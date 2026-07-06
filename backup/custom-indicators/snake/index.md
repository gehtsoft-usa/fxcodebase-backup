# Snake

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63027  
> Forum: 17 · Topic 63027 · 10 post(s)


---

## Snake

**Apprentice** · Mon Jan 11, 2016 7:54 am

![EURUSD m1 (01-11-2016 1317).png](images/104230/EURUSD%20m1%20%2801-11-2016%201317%29.png)



Based on request.
[viewtopic.php?f=27&t=63025](https://fxcodebase.com/code/viewtopic.php?f=27&t=63025)

 [Snake.lua](files/104230/Snake.lua)


---

## Re: Snake

**Apprentice** · Sun Jan 17, 2016 5:11 am

Style option added.


---

## Re: Snake

**Apprentice** · Sat Aug 26, 2017 5:11 am

The indicator was revised and updated.


---

## Re: Snake

**robertm1907** · Mon Sep 04, 2017 7:54 pm

Am trying to understand the point of this snake indicator. Is there any formulae or algorithm on an external link. There is a lot of talk about it on the net, but no details on what it is actually calculating. Just looks like a heavily weighted moving average. Could almost just draw a line though the medians of the periods candle and get the same result.


---

## Re: Snake

**Apprentice** · Tue Sep 05, 2017 4:29 am

The only information I have is the code provided.


---

## Re: Snake

**bartwas1** · Tue Sep 05, 2017 7:55 am

Hello Apprentice,

Is it possible to add to this indicator an option to change data source's prices - close, high, low, open etc. At current state it looks like I could use it as a filter. It works nicely. Thank you.


---

## Re: Snake

**Apprentice** · Tue Sep 05, 2017 11:44 am

As it is, Unfortunately no, the indicator uses the close, high and low component of the candle.
Maybe some derivative is possible, but the values will be different.


---

## Re: Snake

**Apprentice** · Sun Jul 08, 2018 6:07 am

The indicator was revised and updated.


---

## Re: Snake

**easytrading** · Thu Dec 13, 2018 4:05 pm

Hello Apprentice,

Is the Snake indicator redraw ? because i notice that it change his slope when i refresh the chart .
If Yes, is it possible to develop another version that doesn't redraw please ? with my highly appreciation .


---

## Re: Snake

**Apprentice** · Fri Dec 14, 2018 1:35 pm

Yes, in this version yes.
Will redraw last Snake_HalfCycle candles.
