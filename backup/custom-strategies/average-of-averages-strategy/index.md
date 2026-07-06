# Average of Averages Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=2776  
> Forum: 31 · Topic 2776 · 13 post(s)


---

## Average of Averages Strategy

**Apprentice** · Tue Nov 23, 2010 7:18 am

![Averages of Averages Strategy.png](images/6316/Averages%20of%20Averages%20Strategy.png)



The strategy shows, when Average of Averages change slope.

 [Average of Averages Strategy.lua](files/6316/Average%20of%20Averages%20Strategy.lua)

To work, install both indicator.
Average Of Averages
[viewtopic.php?f=17&t=2698&p=6154&hilit=averages#p6154](https://fxcodebase.com/code/viewtopic.php?f=17&t=2698&p=6154&hilit=averages#p6154)
and Averages
[viewtopic.php?f=17&t=2430&p=5705&hilit=averages#p5705](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430&p=5705&hilit=averages#p5705)


---

## Re: Average of Averages Strategy

**Ancient** · Tue Nov 23, 2010 8:00 am

Some Insight will be appreciated!

In Strategy Properties Window, what do the Settings listed below refer too:

Set Limit Orders: Yes / No
Set Stop Orders: Yes /No

And what is the approach if one decides to use these options?

Thanks
Ancient


---

## Re: Average of Averages Strategy

**Ancient** · Tue Nov 23, 2010 8:09 am

Why does the Strategy interfere with Positions previously Placed Manually? Is it not Possible for the Strategy to Monitor its own positions?

I had an Open Position which I manually placed myself. When the Strategy got a signal to enter the market, it closed my position as it decided I was in the wrong direction and then placed a new position in the opposite direction. Only to close this position 30 seconds later and re-enter in the direction the manual position was originally placed.

Is it not Possible for the Strategy to Monitor its own positions only? i.e. NOT TO INTERFERE WITH POSITIONS EITHER PLACED BY OTHER STRATEGIES OR MANUALLY


---

## Re: Average of Averages Strategy

**Ancient** · Tue Nov 23, 2010 8:45 am

Suggestion / Request: Is it possible to add the options Listed below:

Trade Direction.........................: Long Only
...........................................:Short Only
...........................................: Long & Short
Close Position on Opposite Signal....: Yes / No
If either Long Only or Short Only is Selected


---

## Re: Average of Averages Strategy

**Fortunelost** · Tue Nov 23, 2010 9:07 am

Dear Apprentice,
Thank you for all the postings.
One suggestion please, your team is being asked to make many changes to indictors that your followers request, I now have a collection of these indicators which I test when time permits, but there is a problem; how do i know what is the most current version as you make small and fine adjustments on users comments, but still have the same indicator name.
May i suggest you write the version number after the indicator name so that we know we are up to date.
Best regards, nadir


---

## Re: Average of Averages Strategy

**macogi37** · Mon Jan 10, 2011 3:13 pm

Hi, I tried to test this strategy but does not work, get this error: [string 'Average of Averages Strategy.lua']: 128: Unsupported
I use MarketScope 2.0 with the latest update of TS, can anyone help me?
 Thanks


---

## Re: Average of Averages Strategy

**Apprentice** · Mon Jan 10, 2011 5:20 pm

I tested this strategy and everything works as expected.
I contacted the development team to find the cause of this.


---

## Re: Average of Averages Strategy

**macogi37** · Mon Jan 10, 2011 5:49 pm

Thanks, I will wait the news about this strategy and about my problem, I think it is a good strategie...


---

## Re: Average of Averages Strategy

**macogi37** · Tue Jan 11, 2011 3:49 am

Hello, is not to believe, but today I tried again and the test worked!
 I can not believe it!
 However, the test did not work yesterday so I did not put the strategy, first wanted to test, but today everything magically works perfectly, strange that! With these machines there is always surprising.
 Anyway thank you for your interest...


---

## Re: Average of Averages Strategy

**sergiomier** · Fri Jan 14, 2011 5:20 pm

Hi Nikolay, I just downloaded the latest revision of Trading Station and I started experiencing the same issue as above when trying to test several strategies included "Average of Averages Strategy". The error description is: [string 'Average of Averages Strategy.lua']: 128: Unsupported.

I'm sending you some more details:

1) Check whether the version of the trading station is 1.10.010311?
YES it's that exact version.

2) Is this version installed or updated from a previous version?
Installed. I uninstall the whole program and installed it again to include the latest updates.

3) Do you "test strategy" or "add a strategy"?
Adding the strategy is doable. I can even see the signals in the price chart. The problem shows up when testing the strategy.

4) Is Trading Station logged in?
Yes

5) If so - what is the name of the server you are connected to (it is shown in the TS status bar, next to lock icon and before the user name).
Demo: U100D5

6) What is the instrument and time frame you choose?
I tried several instruments and frames. Specifically USDJPY in m15 and EURUSD in m15.

Thanks.


---

## Re: Average of Averages Strategy

**sergiomier** · Sat Jan 15, 2011 12:19 pm

I logged in the day after I submitted the issue and now all the issues of Unsupported for all my strategies are gone. I think there's some features in the software that take effect with 1 day time.


---

## Re: Average of Averages Strategy

**knightflyer** · Thu Jan 20, 2011 4:06 am

Hi, I have found that is the error I get if I don't restart TradingStation after every new strategy is loaded. In other words, load your strategy, shut down TS and restart it, everything works fine. (well it does for me )


---

## Re: Average of Averages Strategy

**Apprentice** · Mon Jan 29, 2018 7:52 am

The strategy was revised and updated.
