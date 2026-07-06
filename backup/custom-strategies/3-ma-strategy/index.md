# 3 MA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70532  
> Forum: 31 · Topic 70532 · 6 post(s)


---

## 3 MA Strategy

**Apprentice** · Mon Oct 12, 2020 3:24 am

![EURUSD H1 (10-12-2020 1022).png](images/138222/EURUSD%20H1%20%2810-12-2020%201022%29.png)



Based on request.
[viewtopic.php?f=27&t=70518](https://fxcodebase.com/code/viewtopic.php?f=27&t=70518)

 [3 MA Strategy.lua](files/138222/3%20MA%20Strategy.lua)


---

## Re: 3 MA Strategy

**ami9192** · Mon Oct 12, 2020 8:20 am

Hi Mr Apprentice,

Thank you for turning this around in such a timely manner, and I really appreciate all you do for this community and for us traders. However upon backtesting, I've found some faults in the current strategy you've sent, as trades aren't opening or closing at the right times.

The first screenshot illustrates some issues I've found. For reference, the 5/Fast EMA is yellow, 20/medium is green and 50/slow is the red line.

Issue 1 is where the strategy entered a Long trade even though both the fast and medium are underneath the slow. It then closed for a loss when the fast recrossed the medium it seems. That crossing point should actually be a sell trigger.

Issue 2 is when a buy trade was entered despite the medium EMA not having crossed the Slow yet. Where the strategy seemed to work, is the trade to the right of that. It opened when the fast crossed the Medium, when both the fast and medium were above the slow.

The second screenshot is from right after that trade closed, and no further trades were entered despite there being triggers to do so. I've highlighted the buy triggers with green circles, and the close points in pink circles. These trades weren't entered whilst the strategy was being tested, but should have as all the criteria was met. T4, the circle highlighted in red is when a sell trade should've occurred too. The Fast EMA had crossed the Slow, and the Medium EMA crossed the slow within the allowed 5 hour window, meaning all criteria was met for a trade.

I hope this all makes sense, and is fixable. We really appreciate all you do here, and look forward to your further help!

All hail The Apprentice!


---

## Re: 3 MA Strategy

**Apprentice** · Tue Oct 13, 2020 7:59 am

> place a buy as long as the the medium has crossed the slow within 5 hours of the fast crossing the slow. (Hope that makes sense)

medium and slow are red and green lines on your chart.
And indeed we have a cross within a set period.


---

## Re: 3 MA Strategy

**ami9192** · Tue Oct 13, 2020 8:31 am

Yes so the medium is the green line and the slow is the red line.

For example for that "Issue 2", the fast has crossed the slow, however the medium hasn't, yet there's a buy trade put on. Additionally, had that trade not been put on, when the medium then crosses the slow 15 hours later, under the rules we wouldn't execute a trade as it's not in the 5 hour crossing window (it took 15 hours to cross after the fast).

In the second screenshot, all of those highlighted trades should've been triggered at the highlighted points but weren't.

Again hope this makes sense !


---

## Re: 3 MA Strategy

**fortesan9** · Wed Nov 04, 2020 10:08 pm

This strategy looks very good on the optimizer,

Very cool colaboration

Apprentice we salute you !


---

## Re: 3 MA Strategy

**tannos** · Mon Nov 23, 2020 10:04 am

Hi M. Apprentice

Which other indicator (stochastic, rsi...) is better to use to avoid false signal. I ask because in lower timeframe M5/M15 I have a lot of false signal
