# Random Walk Index

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=1166  
> Forum: 17 · Topic 1166 · 9 post(s)


---

## Random Walk Index

**Apprentice** · Thu May 27, 2010 5:46 am

![Random Walk Index.png](images/2217/Random%20Walk%20Index.png)

*Random Walk Index.png*



Random Walk Index (RWI) determines if a security is is trending (uptrend or downtrend) or is in a random trading range..

The random walk index (RWI) is a technical indicator that attempts to determine if a stock's price movement is random or nature or a result of a statistically significant trend.

RANDOM WALK INDEX FORMULA
High = MAX((High - Low(n)) / (ATR(n) * SQRT(n)))
Low = MAX((High(n) - Low) / (ATR(n) * SQRT(n)))

The random walk index (RWI) by E. Michael Poulos is a measure of how much price ranges over N days differ from what would be expected by a random walk (randomly going up and down).
A bigger than expected range suggests a trend.

 [RWI.lua](files/2217/RWI.lua)

The indicator was revised and updated


---

## Re: Random Walk Index

**boursicoton** · Thu May 27, 2010 6:33 am

thanks for your velocity !


---

## Re: Random Walk Index

**Apprentice** · Thu May 27, 2010 6:44 am

I found 4 different versions of this indicator.
So i need to do a little research,
before i decide wich will be the final version.


---

## Re: Random Walk Index

**Alexander.Gettinger** · Thu Jul 05, 2012 4:53 pm

MQL4 version of Random Walk Index: [viewtopic.php?f=38&t=20875](https://fxcodebase.com/code/viewtopic.php?f=38&t=20875)


---

## Re: Random Walk Index

**Surasit** · Thu Jul 26, 2012 9:19 am

Dear Sir,
May I requested the strategy for RWI? Please.
I would like to set the alert whenever the line cross.
Thanks
Best regards


---

## Re: Random Walk Index

**jackfx09** · Mon Jul 30, 2012 5:41 am

Great Indicator!

Can we please request a MTF, MCP Random Walk Index HEATMAP with the same cooling based on signal crosses. Red over green, green over red after price CLOSE.

thanks!

sjc


---

## Re: Random Walk Index

**Apprentice** · Wed Oct 03, 2012 5:17 pm

Updated.
Will write MTF, MCP Random Walk Index HEATMAP + RWI Strategy Tomorrow or earlier.


---

## Re: Random Walk Index

**Apprentice** · Thu Oct 04, 2012 1:18 am

MTF, MCP Random Walk Index HEATMAP Can be found here.
[viewtopic.php?f=17&t=24056](https://fxcodebase.com/code/viewtopic.php?f=17&t=24056)

RWI Strategy Can be found here.
[viewtopic.php?f=31&t=24057&p=41390#p41390](https://fxcodebase.com/code/viewtopic.php?f=31&t=24057&p=41390#p41390)


---

## Re: Random Walk Index

**Apprentice** · Thu Apr 13, 2017 7:54 am

Indicator was revised and updated.
