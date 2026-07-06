# Power Measure

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61379  
> Forum: 17 · Topic 61379 · 7 post(s)


---

## Power Measure

**Apprentice** · Sat Oct 25, 2014 1:54 pm

![Power Measure.png](images/96734/Power%20Measure.png)



Based on the request.
[viewtopic.php?f=27&t=61378](https://fxcodebase.com/code/viewtopic.php?f=27&t=61378)
1. Stream is calculates as percentage difference between the close and previous close price.
2. Stream is calculates as percentage difference between the High and Low price.
Based on request.

Power Measure is calculates as correlation coefficient between this two streams

 [Power Measure.lua](files/96734/Power%20Measure.lua)

The indicator was revised and updated


---

## Re: Power Measure

**Jeffreyvnlk** · Sun Oct 26, 2014 12:12 pm

Can you adjust Stream 2 as following : (High-Low)/Low
Thanks


---

## Re: Power Measure

**Apprentice** · Sun Oct 26, 2014 1:49 pm

You are aware, that this modification will not be in the spirit of the original article.


---

## Re: Power Measure

**Jeffreyvnlk** · Mon Oct 27, 2014 8:45 am

> **Apprentice wrote:**
> You are aware, that this modification will not be in the spirit of the original article.

Please, could you just modify a bit more. Actually, from beginning I kindly request about the volatility as following:

> **Jeffreyvnlk wrote:**
> This concept from Brett Steenbarger as following:
> [http://traderfeed.blogspot.com/2009/03/ ... asure.html](https://traderfeed.blogspot.com/2009/03/calculating-power-measure.html)
>
> Frist, calculate the difference btw close of current bar and close of the previous one. Do that for 20 previous bars
> Then, calculate the volatility of the current bar **(High minus Low then divided by the Low**). The same for 20 previous bars
> Finally, running 20-bar correlation between the series of step 1 and step 2. **That correlation is power measure.** Post this line on the chart as overlay. This will express both price change and its volatility on a single indicator. It will be neat and convenient
>
> Thanks

I express thanks for your work on the first one. Appreciated if you can adjust back a bit. I really need it


---

## Re: Power Measure

**Apprentice** · Mon Oct 27, 2014 9:41 am

[Power MeasureNew.lua](files/96754/Power%20MeasureNew.lua)

Again, this modification has no basis in the description provided by the author.
Will give results that differ from the original.


---

## Re: Power Measure

**Alexander.Gettinger** · Wed Apr 08, 2015 11:29 am

MQL4 version of Power Measure oscillator: [viewtopic.php?f=38&t=62088](https://fxcodebase.com/code/viewtopic.php?f=38&t=62088).


---

## Re: Power Measure

**Apprentice** · Tue Aug 08, 2017 5:31 am

The indicator was revised and updated.
