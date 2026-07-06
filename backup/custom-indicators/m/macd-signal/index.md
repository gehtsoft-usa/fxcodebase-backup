# MACD Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61667  
> Forum: 17 · Topic 61667 · 10 post(s)


---

## MACD Signal

**Apprentice** · Tue Jan 06, 2015 3:47 am

![macd Signal.png](images/98004/macd%20Signal.png)



Based on request.
[viewtopic.php?f=27&t=61650#p97948](https://fxcodebase.com/code/viewtopic.php?f=27&t=61650#p97948)
Will indicate the MACD / Signal Line / MACD Zero Line, Histogram / Zero Line Cross.

 [MACD Signal.lua](files/98004/MACD%20Signal.lua)

 [MACD Signal with Alert.lua](files/98004/MACD%20Signal%20with%20Alert.lua)


---

## Re: MACD Signal

**Alexander.Gettinger** · Wed Apr 08, 2015 10:58 am

MQL4 version of MACD Signal indicator: [viewtopic.php?f=38&t=62084](https://fxcodebase.com/code/viewtopic.php?f=38&t=62084).


---

## Re: MACD Signal

**Apprentice** · Tue Oct 11, 2016 5:43 am

MACD Signal with Alert added.


---

## Re: MACD Signal

**Santoine** · Sat Sep 09, 2017 2:22 am

I would like being able to make an automated trading from the MACD signal and the ability to get the Heikin Ashi close as a source I mean xClose = (Open+High+Low+Close)/4 Thanks


---

## Re: MACD Signal

**Apprentice** · Sat Sep 09, 2017 4:00 am

Can you define entry / exit conditions?
Use pseudo code.
If ... and ... cross over ... then ... open long ... open short .. exit ...


---

## Re: MACD Signal

**Santoine** · Sun Sep 10, 2017 5:37 am

It's working exactly as described in Strategy MACD [viewtopic.php?f=31&t=4100&p=10276&hilit=macd+strategy+lua#p10276](https://fxcodebase.com/code/viewtopic.php?f=31&t=4100&p=10276&hilit=macd+strategy+lua#p10276)
The major difference is that the MACD isn't calculated directly on the Source (on the selected TF) but on the average of Open, HIgh, Low and Close of current bar (xClose = (Open+High+Low+Close)/4. or Average price of the current bar). Thanks


---

## Re: MACD Signal

**Apprentice** · Sun Sep 10, 2017 6:10 pm

Your request is added to the development list, Under Id Number 3890
 If someone is interested to do this task, please contact me.


---

## Re: MACD Signal

**Apprentice** · Tue Sep 12, 2017 4:22 am

Try HA Close MACD Strategy.lua
[viewtopic.php?f=31&t=4100&p=10276#p10276](https://fxcodebase.com/code/viewtopic.php?f=31&t=4100&p=10276#p10276)


---

## Re: MACD Signal

**Santoine** · Sun Sep 17, 2017 6:28 am

> **Apprentice wrote:**
> Try HA Close MACD Strategy.lua
> [viewtopic.php?f=31&t=4100&p=10276#p10276](https://fxcodebase.com/code/viewtopic.php?f=31&t=4100&p=10276#p10276)

Thank you very much. I modified a little the MACD condition and results are very encouraging. In fact they depend on the global trend, For instance last week the trend was Bullish for GBP JPY so best results are with a a Buy only side. I think a filter on HA above a specific MA like 100 hours can be the way to manage the global trend
This is for 20K on last week Buy side only
ACCOUNT STATISTICS
Total profit/loss 1,154.31
Total profit of all trades 1,408.19
Total loss of all trades 253.88


---

## Re: MACD Signal

**Apprentice** · Tue Sep 04, 2018 9:34 am

The Indicator was revised and updated.
