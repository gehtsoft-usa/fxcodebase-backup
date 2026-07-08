# Period Extreme Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=5091  
> Forum: 31 · Topic 5091 · 38 post(s)

---

## Period Extreme Strategy

**Apprentice** · Thu Jul 07, 2011 12:07 pm

![Period Extreme Strategy.png](images/12462/Period%20Extreme%20Strategy.png)

Buy
 Signals and/or Trade are given when the value of the current candle exceeds the high of the past two candles
Sell
Signals and/or Trade are given when the value of the current candle drops below the low of the past two candles

 [Period Extreme Strategy.lua](files/12462/Period%20Extreme%20Strategy.lua)

Based on indicator.
[viewtopic.php?f=17&t=8688&p=113849#p113849](https://fxcodebase.com/code/viewtopic.php?f=17&t=8688&p=113849#p113849)

The Strategy was revised and updated on December 10, 2018.

---

## Re: Period Extreme Strategy

**t1982t** · Thu Jul 07, 2011 7:38 pm

wow! brilliant! like mini breakout

---

## Re: Period Extreme Strategy

**Apprentice** · Wed Nov 30, 2011 4:57 am

The strategy is adaptable.
You can set any number of periods.

---

## Re: Period Extreme Strategy

**ronald3rg** · Thu Dec 01, 2011 9:30 am

Apprentice,

when i set any number of periods higher than zero it gives me an error message
"index is out of range"
Please advise

---

## Re: Period Extreme Strategy

**Apprentice** · Thu Dec 01, 2011 9:46 am

Your request is added to the developmental cue.

Can you re-download strategy.
I have test it, and I can not repeat this bug.
It is possible that you have some of the older version.

---

## Re: Period Extreme Strategy

**irbica** · Sun Dec 04, 2011 11:12 pm

If the number of periods is 1, does it mean that it will check only on the last period (candle) to determinate the high or the low break?

---

## Re: Period Extreme Strategy

**Apprentice** · Wed Dec 07, 2011 3:43 am

1
Previous candles extremes.
2
Previous Two candles extremes.

---

## Re: Period Extreme Strategy

**ronald3rg** · Wed Dec 14, 2011 12:26 pm

Very happy with this strategy giving me outstanding results both on the back-test and live

I appreciate your work.

right place at the right time

3RG

---

## Re: Period Extreme Strategy

**ronald3rg** · Tue Jan 31, 2012 10:53 am

Apprentice,

I really like this strategy but I would like to understand what makes it work. What is the entry based on. I get amazing results for this strategy on a 4H chart. Maybe adding a little more control would eliminate the number of bad trades may confirmation by ADX, DMI, MAcd Or SAR. I trade this strategy live it does really good but i would like to cut down a bit more on the bad trades. This strategy works great with a 5% risk meaning 1 micro lot for every $500 because at worst even although rare because the strategy tends to take bad trades out before they hit the stop, the stop is set at 250 so at worst case you will loose 5% of your capital but you wont loose on everything you bought into the move.

Also a small improvement right away would be that when the option to allow multiple positions is yes that the limit is above first position entered usually the second and or third entries tend to be below the first and you end up loosing because the entries are closed in order thus for adding to the loses even though it was a good trade in the right direction.

over all strategy works well for the long term kinda like a mutual fund. Overall long term always positive never dips below capital. So a little more control would probably benefit it.

Thanks

here is my 3 year back-test.

---

## Re: Period Extreme Strategy

**Apprentice** · Wed Feb 01, 2012 3:09 am

Thank you.
I'll try to do something.
I thought that the description I gave is clear and sufficient.
Which part need clarification.

---

## Re: Period Extreme Strategy

**Hug Coder** · Wed Feb 01, 2012 8:11 am

The strategy does seem to perform nicely on H4 over time. But I think it sometimes triggers to often, but I guess you can change periods for that. I also wish it was some alternative to confirm the trend with another indicator.

One thing I don't understand is this:

```lua
strategy.parameters:addBoolean("Backtrack", "Use completed candles only", "", true);
...
if Backtrack then
 period = period-1;
end
...
```

How does that make it act on non-completed candles? All I see is that it looks at previous period/bar, if you set Backtrack = true. It will still wait for the close be for it acts anyway, if it's false.

---

## Re: Period Extreme Strategy

**ronald3rg** · Wed Feb 01, 2012 9:33 am

Apprentice,

my apologies you're right it just had been a while since i downloaded your explanation makes perfect sense. After reading it makes sense and i can see what affects it most which is why and confirmation indicator would do this strategy great. Actually i have a couple of the strategies on this site that work wonderfully but at the end the spread its the strategies worst enemy. By far this one seems to be the most steady for me or for what I'm looking for. I run the optimizer for days on end till I find the right combinations that produce next to no bad trades for the longest period of time I can back-test but the trades a very few and far apart. Which is not a Bad thing if you have a ton of capital and can setup a couple of accounts trading large lots.

So far this strategy produces a lot of winners with few losses so I'm trying to battle certain setups in the candle pattern that work against the strategy. Another great feature for future development would be adding stage stop to the strategy. I usually turn the strategy on by itself but for some reason it doesn't always activate.

In any case i really appreciate what you do. I'm trying to learn scripting so i can someday create a strategy of my own. I can read the code understand I have been unable to start from scratch.

---

## Re: Period Extreme Strategy

**ronald3rg** · Wed Feb 01, 2012 4:42 pm

Apprentice,

Ok I went over to the strategy to make sure i understood it correctly and that it was functioning as it should but i think i found some problems maybe you can explain take a look at image below. Looks like false triggers. Let me know if I'm posting to much lol. an SAR confirmation might be better than ADX i previously requested

---

## Re: Period Extreme Strategy

**Apprentice** · Thu Feb 02, 2012 2:00 am

Your request was added to our database.

---

## Re: Period Extreme Strategy

**TheEdge** · Sun Apr 01, 2012 4:12 pm

I am also getting the "Index out of Range message, just downloaded and installed. Any idea what might be the problem?

---

## Re: Period Extreme Strategy

**Apprentice** · Mon Apr 02, 2012 4:48 am

What are the parameters you are using.

---

## Re: Period Extreme Strategy

**TheEdge** · Mon Apr 02, 2012 10:31 am

Hey Apprentice,

If I set the period to any number higher than 2 in Back testing or Optimization I receive the error. All other settings are default.

If running the strategy on live data it appears to be working normally.

---

## Re: Period Extreme Strategy

**irbica** · Fri Jun 22, 2012 2:23 pm

Hello Aprentice, can you make this a single previous candle lookback only for HL reference to Buy or Sell? Also would like to have an option to Liquidate at end of current candle if I am not Limited or Stopped. Thanks.

---

## Re: Period Extreme Strategy

**Apprentice** · Mon Jun 25, 2012 1:36 am

Your request is added to the development list.

---

## Re: Period Extreme Strategy

**irbica** · Mon Jun 25, 2012 5:24 am

Hi Apprentice, I notice that the strategy does not open a position when the breakout actually happen. Is there any reason? I would like for the position to open when the previous candle low or high are broke in the current candle. My setting is for 1 candle, valid interval is 3 seconds and I am using 15m TF. Also I set NO to use completed candles only. Thanks.

---

## Re: Period Extreme Strategy

**morngrym** · Sat Jun 30, 2012 11:46 am

i keep trying to use this in back tests but i get [string "c:\program files (x86)\candleworks\fxts2\st..."]:173: index is out of range.

i have tried re downloading serveral times i have tried many values and have only 3 that worked 0, 1 and 2 in the periods and also tried in different time frames as well, any suggestions?

i got it to pass into the progam but i would put "" around my number in the periods section but does not seem to be fuctioning like it should it puts shorts and longs in but the balance falls to 0 shortly into the test

---

## Re: Period Extreme Strategy

**arindam89** · Thu Aug 30, 2012 12:13 am

> **Apprentice wrote:**
>
>
> Period Extreme Strategy.png
>
>
>
> Buy
> Signals and/or Trade are given when the value of the current candle exceeds the high of the past two candles
> Sell
> Signals and/or Trade are given when the value of the current candle drops below the low of the past two candles
>
>
>
> Period Extreme Strategy.lua

HI GREAT CODE
I HAVE A QUESTION
WHAT TIME ARE YOU USING LOCAL TIME OR EST OR GMT OR FINANCIAL WHAT........?
CAN YOU USE LOCAL TIME PLEASE
THANKS
BY

---

## Re: Period Extreme Strategy

**Apprentice** · Thu Aug 30, 2012 5:14 pm

The date and time is always in NY time zone.

---

## Re: Period Extreme Strategy

**Jeffreyvnlk** · Wed Oct 24, 2012 12:36 pm

This is great. Any feedback ?

---

## Re: Period Extreme Strategy

**arstechnica** · Sat Nov 10, 2012 4:23 am

I'm trying to test this strategy, but it always stop with error: "index is out of range"

Can someone advice how to fix it?

Regards

Salvatore

---

## Re: Period Extreme Strategy

**Apprentice** · Wed Jan 02, 2013 12:55 pm

I just removed reported bug.

---

## Re: Period Extreme Strategy

**arstechnica** · Sun Jan 06, 2013 12:42 pm

Period 1 is last candle.

What does it mean period 0?

And complete candles? Are candles ar close?

---

## Re: Period Extreme Strategy

**Apprentice** · Mon Jan 07, 2013 7:04 am

No, if you use 0, u will have last candle

Last-1 - PERIOD+1 -1, period-1

0 or Break of Prev. Bar. High/Low
Last-1 - 0+1 -1, Last-1
Last-1, Last-1

1 or Break of Prev. Two Bars extreme.
Last-1 - 1+1 -1, Last-1
Last -2 , Last-1

If you are using complete candle filter.
Strategy is not calculated for last, activ candle, in order to avoid false signals.

---

## Re: Period Extreme Strategy

**arstechnica** · Mon Jan 07, 2013 11:47 am

I have set Period 0 on Ger 30 last night on daily chart, but today it has not opened a short trade

Completed candle: no
Why?

---

## Re: Period Extreme Strategy

**Apprentice** · Fri Dec 09, 2016 5:09 am

Strategy was revised and updated.

---

## Re: Period Extreme Strategy

**ying2299** · Wed Jan 12, 2022 11:44 pm

Hello,
the following error message appears:
An error occurred during the calculation of the indicator 'GSI(USDOLLAR, 5 pips)'. The error details: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Standard/GSI.bin:1424: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Standard/GSI.bin:1379: attempt to call method 'onDecodeError' (a nil value).

---

## Re: Period Extreme Strategy

**Apprentice** · Fri Jan 14, 2022 7:03 am

Your request is added to the development list.
Development reference 29.

---

## Re: Period Extreme Strategy

**ying343434** · Fri Jun 17, 2022 1:44 am

Hello, I have been looking fora way to limit the orders on this strategy. What I mean is the following:
I would like to be able to tell the strategy:
Keep a maximum of 1 or 2 or 3 positions open and each one of a maximum of 1 or 2 or 3 lots.

I would like the strategy to have 1 open short of 1 lot and until that trade is not closed, the strategy should not try to short again.

Is that possible? Any help will be welcome, by the way this strategy is so far the one who has had the best results for me.

---

## Re: Period Extreme Strategy

**Apprentice** · Mon Jun 20, 2022 11:39 am

We have added your request to the development list.
Development reference 371.

---

## Re: Period Extreme Strategy

**Apprentice** · Wed Jul 06, 2022 2:29 am

GSI doesn't have a source code available. There is little we can do with it.

---

## Re: Period Extreme Strategy

**mangonel** · Wed Jul 06, 2022 12:53 pm

Apprentice can you modify the"Period Extreme Strategy.lua" to buy and sell at different periods ? For example buy with 200 periods and sell with 50 periods.

---

## Re: Period Extreme Strategy

**Apprentice** · Fri Jul 08, 2022 3:31 am

We have added your request to the development list.
Development reference 409.

---

## Re: Period Extreme Strategy

**Apprentice** · Fri Jul 08, 2022 10:55 am

[Period Extreme Strategy.lua](files/146656/Period%20Extreme%20Strategy.lua)

Try this version.
