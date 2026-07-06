# Corelation Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64609  
> Forum: 17 · Topic 64609 · 9 post(s)


---

## Corelation Indicator

**Apprentice** · Wed Apr 19, 2017 4:16 pm

![EURUSD m30 (04-19-2017 2124).png](images/112067/EURUSD%20m30%20%2804-19-2017%202124%29.png)



Based on request.
[viewtopic.php?f=27&t=64606&p=112068#p112068](https://fxcodebase.com/code/viewtopic.php?f=27&t=64606&p=112068#p112068)
Corelation= Multiplier*"EUR/CHF" -("EUR/USD" * "USD/CHF"))

 [Corelation Indicator.lua](files/112067/Corelation%20Indicator.lua)

The indicator was revised and updated


---

## Re: Corelation Indicator

**sebgautier49** · Wed Apr 26, 2017 6:12 am

Is it possible to have the same indicator with a 1 minute timeframe ?

Thanks a lot

Sébastien


---

## Re: Corelation Indicator

**Apprentice** · Wed Apr 26, 2017 7:31 am

Only if you chart time frame is "m1"
If you want a lower time frame,
Presentation as this is needed.
[viewtopic.php?f=17&t=64620](https://fxcodebase.com/code/viewtopic.php?f=17&t=64620)


---

## Re: Corelation Indicator

**sebgautier49** · Wed Apr 26, 2017 7:39 am

I just need the same indicator with timeframe 1 minutes . I don't need lower

Thanks a lot

sébastien


---

## Re: Corelation Indicator

**Apprentice** · Wed Apr 26, 2017 10:11 am

You can have "m1" time frame only if you chart time frame is "m1"
If you chart time frame is "m5" or Higher, this is not possible.

Can write indicator like this
[viewtopic.php?f=17&t=19743&p=107509&hilit=lower+time+frame#p107509](https://fxcodebase.com/code/viewtopic.php?f=17&t=19743&p=107509&hilit=lower+time+frame#p107509)
or
[viewtopic.php?f=17&t=64620](https://fxcodebase.com/code/viewtopic.php?f=17&t=64620)


---

## Re: Corelation Indicator

**sebgautier49** · Wed Apr 26, 2017 11:48 am

Thanks for your explanation. Now I know how tu use it.

I have a new question. What must I do if I want to automize the trading ?
Can I put the algorithm here ?

Thanks for your help.

Sébastien


---

## Re: Corelation Indicator

**Apprentice** · Thu Apr 27, 2017 3:23 am

Yes, Describe your strategy logic here.
Or post it here.
[viewforum.php?f=27](https://fxcodebase.com/code/viewforum.php?f=27)


---

## Re: Corelation Indicator

**sebgautier49** · Thu Apr 27, 2017 1:59 pm

Ok I will try to explain the strategy :

IF "corelation indicator" >= "15" AND Open position <=12
 BUY EUR USD and BUY USD CHF and SELL EUR CHF (at the same time)
 When "correlation indicator <="-0.5"
 CLOSE all positions
OR

IF "corelation indicator" <= "-15" AND Open position <=12
 SELL EUR USD and SELL USD CHF and BUY EUR CHF (at the same time)
 When "correlation indicator >="0.5"
 CLOSE all positions

I hope it is clear

Thanks

Sébastien


---

## Re: Corelation Indicator

**Apprentice** · Thu Apr 27, 2017 5:12 pm

Try this version.
[viewtopic.php?f=31&t=64623](https://fxcodebase.com/code/viewtopic.php?f=31&t=64623)
