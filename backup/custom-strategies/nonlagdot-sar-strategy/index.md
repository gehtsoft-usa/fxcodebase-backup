# NonLagDot SAR Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=15659  
> Forum: 31 · Topic 15659 · 8 post(s)


---

## NonLagDot SAR Strategy

**Apprentice** · Fri Apr 06, 2012 1:02 pm

![NonLagDot SAR Strategy.png](images/29487/NonLagDot%20SAR%20Strategy.png)



First, this is a wild one.
Due to repaint functionality, my advice is to set ColorBarBack to zero.
In any other case, the results can not be guaranteed.

Enty
There are three algorithms.
First
NLD generates trade signals and SAR is confirmation.
Second
SAR generates trade signals and NLD is confirmation.
Third
When both indicators confirm each other, the trade is placed.

Optional Exit.
If both indicators do not match, the position is closed.

 [NonLagDot SAR Strategy.lua](files/29487/NonLagDot%20SAR%20Strategy.lua)

For this to work, you need to install NLD.lua
[viewtopic.php?f=17&t=1721](https://fxcodebase.com/code/viewtopic.php?f=17&t=1721)


---

## Re: NonLagDot SAR Strategy

**briansummy** · Wed Apr 18, 2012 8:36 pm

Quick question, how does the Bars Back affect repainting or rather, what does it mean for the indicator?


---

## Re: NonLagDot SAR Strategy

**Apprentice** · Thu Apr 19, 2012 1:28 am

Should still would not affect the backtest.
However, the indicator will be different from the results obtained at the time of testing.
The reason, the indicator changes its indication, Bars back period back.


---

## Re: NonLagDot SAR Strategy

**virgilio** · Wed Jun 20, 2012 3:53 pm

Is it possible to integrate the strategy with a Trailing Stop feature that goes alive ONLY after a certain number of pips have been reached?
For example, if the trade goes in my favor for 25 pips, I'd like a Trailing Stop feature that automatically kicks in with a 15 pips stop.

Any help is greatly appreciated.


---

## Re: NonLagDot SAR Strategy

**Apprentice** · Fri Jun 22, 2012 2:20 am

Your request is added to the development list.


---

## Re: NonLagDot SAR Strategy

**virgilio** · Tue Jul 03, 2012 5:47 am

Any updates? Thanks.


---

## Re: NonLagDot SAR Strategy

**virgilio** · Wed Jul 11, 2012 5:31 pm

Any hope that this will get tackled anytime soon? What do I have to do to have it escalated?


---

## Re: NonLagDot SAR Strategy

**Apprentice** · Fri Jan 26, 2018 12:35 pm

The strategy was revised and updated.
