# Tick Count

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62296  
> Forum: 17 · Topic 62296 · 10 post(s)


---

## Tick Count

**Apprentice** · Mon Jun 08, 2015 7:24 am

![Tick Count.png](images/100818/Tick%20Count.png)



Based on request.
[viewtopic.php?f=27&t=62282](https://fxcodebase.com/code/viewtopic.php?f=27&t=62282)

While you can use them on higher time frames.
Will give you the number of bars for the selected time period.

The native time frame for this indicator is the Tick Time Frame.
Will give you number of Ticks in the last N seconds.

 [Tick Count.lua](files/100818/Tick%20Count.lua)

 [Tick Count Label.lua](files/100818/Tick%20Count%20Label.lua)


---

## Re: Tick Count

**Hope66** · Wed May 11, 2016 6:26 pm

Hi, i am really interested in one tool. For me, it is not an indicator, it is just a tool that lets me analyze better the market. All i want to know is, if inside a 1 minute candle there are more up ticks or down ticks. The output is simple: one blue dot over the candle high if uptick>downtick inside the candle, else, one red dot in the same position.
On the other hand, i would to like take the information of upticks and downticks from the "alive"candle, not from the history, if it is possible. I mean, while the candle is alive, if we have an uptick, countupTick=countupTick+1, if we have an downtick, countdnTick=countdnTick+1.
Now, if a new bar start, if countupTick>countdnTick -> print a blue dot on the closed bar(that was the one we was analyzing) or if countupTick<countdnTick -> print a red dot on the closed bar(that was the one we was analyzing).
I think, this is one of the best tools a trader can have. If you can help me , I will appreciate it very much.
 Thanks forehand.


---

## Re: Tick Count

**Apprentice** · Fri May 13, 2016 1:37 pm

I'm not sure if this will be possible for the higher time frame candles.
Required number of ticks is enormous.


---

## Re: Tick Count

**Hope66** · Fri May 13, 2016 5:11 pm

Thanks for your response... I am not interested in higher time frames. I am interested in 1 minute bar., because every single move in the market start on 1 second bar... Of course, we do not have 1 second bar, but I am fine with 1 minute bar. So, you could set the indicator to 1 minute bar without any other alternative.
 I know you can do it, because you have done more complicate indicators.
Sorry for my English, it is not my first language.
Thanks you very much.


---

## Re: Tick Count

**Hope66** · Fri May 13, 2016 5:34 pm

Sorry, I already made a replay, but even when I am logging In, I can not see my post. I will try againt.
In short. That’s what I need. Set the indicator to 1 minute bar without any other alternative. In my first post , I specified the 1 minute bar or candle.
Thank you very much.


---

## Re: Tick Count

**Apprentice** · Sun May 15, 2016 6:21 am

Your request is added to the development list.


---

## Re: Tick Count

**Hope66** · Mon May 16, 2016 8:55 am

Thanks Apprentice, I Hope you can help me with this tool.
Thank you very much.


---

## Re: Tick Count

**Apprentice** · Tue May 17, 2016 6:56 am

Try this version.
[viewtopic.php?f=17&t=63490&p=106308#p106308](https://fxcodebase.com/code/viewtopic.php?f=17&t=63490&p=106308#p106308)

Two remarks.
1) available tick data is limited
2) in most cases, candle colors will be identical to Up / Down tick difference.


---

## Re: Tick Count

**Apprentice** · Mon Aug 28, 2017 10:01 am

The indicator was revised and updated.


---

## Re: Tick Count

**Apprentice** · Fri Sep 14, 2018 5:36 am

The indicator was revised and updated.
