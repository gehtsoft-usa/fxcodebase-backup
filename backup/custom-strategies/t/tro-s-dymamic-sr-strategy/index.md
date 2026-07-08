# TRO's Dymamic SR Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=59633  
> Forum: 31 · Topic 59633 · 9 post(s)

---

## TRO's Dymamic SR Strategy

**Apprentice** · Wed Oct 09, 2013 2:12 pm

![TRO's Dymamic SR.png](images/89921/TROs%20Dymamic%20SR.png)

**Still in development, will not work within Backtester.**

 [TRO's Dymamic SR Strategy.lua](files/89921/TROs%20Dymamic%20SR%20Strategy.lua)

Please install TheRumpledOne's (TRO's) Dynamic Support/Resistance.

[viewtopic.php?f=17&t=882](https://fxcodebase.com/code/viewtopic.php?f=17&t=882)

The Strategy was revised and updated on December 11, 2018.

---

## Re: TRO's Dymamic SR Strategy

**guangho** · Thu Oct 10, 2013 9:41 am

Sorry, because I can't send a new post, so only the questions here.
Excuse me, does not affect the strategy of running condition can be used in calculating the parameter "MVA" is how much? I want to try to quote "MVA" ---1000 average, can? I tried, failed. Why? Is there any way to solve this BUG? Thank you!!

---

## Re: TRO's Dymamic SR Strategy

**guangho** · Fri Oct 11, 2013 4:53 am

> **Apprentice wrote:**
>
>
> TRO's Dymamic SR.png
>
>
>
> **Still in development, will not work within Backtester.**
>
>
> TRO's Dymamic SR Strategy.lua
>
>
> Please install TheRumpledOne's (TRO's) Dynamic Support/Resistance.
>
> [viewtopic.php?f=17&t=882](https://fxcodebase.com/code/viewtopic.php?f=17&t=882)

HI! Apprentice
I know it is not a bug.Initially a strategy has 300 bars to work at. But my strategy has to use 1000 bars. As to Backtester No problem, but A problem in practical use.
 Whether through the establishment of "temporary data flow" to achieve policy reference beyond 300 K data outside the function?
Indicators and strategies similar to consider for me?

Thank you very much!

---

## Re: TRO's Dymamic SR Strategy

**Valeria** · Tue Oct 15, 2013 2:35 am

Hi guangho,

I have forwarded your requests to the developers, it should be discussed. But, unfortunately, currently there is no way to solve it.

---

## Re: TRO's Dymamic SR Strategy

**guangho** · Tue Oct 15, 2013 10:21 am

> **Valeria wrote:**
> Hi guangho,
>
> I have forwarded your requests to the developers, it should be discussed. But, unfortunately, currently there are no way to solve it.

Really appreciate your help and answer. Good luck!

---

## Re: TRO's Dymamic SR Strategy

**Valeria** · Fri Oct 18, 2013 1:23 am

Hi guangho,

Unfortunately the ExtSubscribe which you use request the default amount of bars (which is 300 in most cases). To get more data you should write your own implementation of ExtSubscribe function. You can do it the following way:
Instead of including helper.lua, open it and copy all code of the helper.lua file into your strategy.
In this code you can find the following strings:

```lua
sub.stream = core.host:execute("getHistory", id, instance.bid:instrument(), period, 0, 0, bid);
...
sub.stream = core.host:execute("getHistory", id, instrument, period, 0, 0, bid);
```

Two zeros here are dates. To get more than 300 bars you should send range of dates which your strategy need.
local s, e = core.getcandle("m5", 0, 0, 0);
local from_date = core.now() - 1000 * (e - s);
-- this will request about 1000 bars, but it isn't guaranteed because of weekends (so it may return less bars than you need)
-- it's quite difficult to calculate the date which will guarantee specified number of bars
sub.stream = core.host:execute("getHistory", id, instance.bid:instrument(), period, from_date, 0, bid);
sub.stream = core.host:execute("getHistory", id, instrument, period, from_date, 0, bid);
But it will not work for tick timeframe.
Please note, we have not tested this code, it is just example.

---

## Re: TRO's Dymamic SR Strategy

**guangho** · Fri Oct 18, 2013 3:40 am

> **Valeria wrote:**
> Hi guangho,
> ...
> Please note, we have not tested this code, it is just example.

Hi Valeria:

Methods according to what you said to try. Results the success!! It can index more than 300 bar data.
You were great.

Thank you very much for your help！

---

## Re: TRO's Dymamic SR Strategy

**guangho** · Fri Oct 18, 2013 4:13 am

> **Valeria wrote:**
> Hi guangho,
> ....
> Please note, we have not tested this code, it is just example.

The way of indexing is successful. But do not know why strategy sometimes stop automatically (without any prompting), sometimes very normal operation.

Don't know about whether the connection with the network.

Because of the "M1" cycle strategy will cause automatic stop. This is not problem of the "M5" cycle.
Do you have special monitoring "strategy" running strategy? If there is a similar strategy please recommend to me.

Thank you very much！

---

## Re: TRO's Dymamic SR Strategy

**Apprentice** · Sun Dec 11, 2016 6:11 am

Strategy was revised and updated.
