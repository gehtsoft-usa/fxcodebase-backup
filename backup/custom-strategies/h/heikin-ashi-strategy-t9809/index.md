# Heikin Ashi Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=9809  
> Forum: 31 · Topic 9809 · 12 post(s)


---

## Heikin Ashi Strategy

**Apprentice** · Fri Dec 16, 2011 6:45 am

![HA Strategy.png](images/20858/HA%20Strategy.png)



Allows you to open positions depending on the color of the candles.

Bob Short.
Green Long.

Upon request, has the option to turn on the closure of all previous positions at the beginning of each period.

Because the algorithm constructions, the signals have big lagging time.

 [HA Strategy.lua](files/20858/HA%20Strategy.lua)

I have added the option to filtering, delay signal until appearance of the first candle without a wick.
Fewer false signals.

The Strategy was revised and updated on January 21, 2019.


---

## Re: Heikin Ashi Strategy

**ronald3rg** · Mon Dec 19, 2011 3:01 pm

From the looks of your back-test a reverse entry option might do some good as well.

At the place at the right time

3RG


---

## Re: Heikin Ashi Strategy

**muneebkhan** · Thu Mar 29, 2012 5:38 pm

Is it possible to modify this strategy to send an alert when a HA candle is closed that either has a flat bottom (for going long) or flat top (for going short)


---

## Re: Heikin Ashi Strategy

**Apprentice** · Sat Mar 31, 2012 3:57 am

Can you describe in more detail, I'm not sure I understand your request.
With Chart drawing if possible.


---

## Re: Heikin Ashi Strategy

**flores_joseg** · Mon Apr 02, 2012 4:22 am

Hi Apprentice,

I am trying this strategy in a demo account right now and it is closing open positions even if I set these parameters (see screenshots):

Close Previous Order --> NO
Allow Multiple --> YES

Do you have an idea why am I getting the error in the screenshot and it is closing the opened positions anyway? c

Can you please check if there is some extra condition in the strategy which is still closing open positions even if the setting are telling it to not do it?

Thanks man a lot for your developments … You are doing such a great job!!!

Best Regards...


---

## Re: Heikin Ashi Strategy

**flores_joseg** · Fri Apr 13, 2012 3:31 am

Hi Apprentice,

I am still testing this strategy. I activated it “only once per pair” and “only for 1H timeframe”.
I realised that if the limit is not hit in within 3 hours, the orders are automatically closed and this should not happen.

I would really appreciate if you can please give it a look and set the strategy to “ONLY” close orders “if the Limit or Stop is hit”.

Thanks in advance !!!

Best Regards!


---

## Re: Heikin Ashi Strategy

**msemryck** · Sat Jul 09, 2016 3:41 pm

Hi Apprentice,

Could you please add the following to this strategy

1) Buy if (close on blue bar ) & (between a high and low price point) ( must meet both criteria). For a stop loss can there be an option for an exact price.

2) same for red for a sell

Thanks you

Matt


---

## Re: Heikin Ashi Strategy

**Apprentice** · Mon Aug 08, 2016 6:55 am

can you explain

> Buy if (close on blue bar ) & (between a high and low price point)

buy if we have down HA bar within range or previous bar ?


---

## Re: Heikin Ashi Strategy

**Apprentice** · Sat Dec 17, 2016 7:53 am

Strategy was revised and updated.


---

## Re: Heikin Ashi Strategy

**xpertizetrading** · Mon Jan 09, 2017 7:02 am

Is it possible to translate this strategy for mt4?
Thanks and Regards,
XpertizeTrading


---

## Re: Heikin Ashi Strategy

**Apprentice** · Thu Jan 12, 2017 4:48 am

Your request is added to the development list, Under Id Number 3712
 If someone is interested to do this task, please contact me.


---

## Re: Heikin Ashi Strategy

**Alexander.Gettinger** · Fri Sep 29, 2017 1:51 pm

> **xpertizetrading wrote:**
> Is it possible to translate this strategy for mt4?
> Thanks and Regards,
> XpertizeTrading

MT4 version of this strategy: [viewtopic.php?f=38&t=65134](https://fxcodebase.com/code/viewtopic.php?f=38&t=65134)
