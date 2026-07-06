# Donchian Channel of RSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=67387  
> Forum: 17 · Topic 67387 · 19 post(s)


---

## Donchian Channel of RSI

**Apprentice** · Tue Feb 26, 2019 6:28 am

![EURUSD D1 (02-26-2019 1032).png](images/124118/EURUSD%20D1%20%2802-26-2019%201032%29.png)



Based on request.
[viewtopic.php?f=27&t=67376](https://fxcodebase.com/code/viewtopic.php?f=27&t=67376)

 [Donchian Channel of RSI.lua](files/124118/Donchian%20Channel%20of%20RSI.lua)


---

## Re: Donchian Channel of RSI

**SpLiFT** · Tue Feb 26, 2019 9:44 am

Hi Apprentice,

I've tried this one already, but it's not what I'm after. The channel lines to show the High and Low values that the RSI has printed for the Current candle, not an average number of RSI values.

For example (settings are default RSI, 14, Close) the following happens:

- the RSI (current candle) opens with value 50
- the candle goes up and so does the RSI. RSI reaches 70 value
- the candle then goes down and so does the RSI. RSI reaches 30 value
- the candle finally closes bearish and the RSI prints main line the 40 value

Based on the above, what the indicator should print is:
- High channel line: 70
- Low channel line: 30
- Main RSI line: 40

I hope this makes it clear, but let me know if further explanation is needed.


---

## Re: Donchian Channel of RSI

**Apprentice** · Wed Feb 27, 2019 6:39 am

Something like RSI Candle?
 [viewtopic.php?f=17&t=1927](https://fxcodebase.com/code/viewtopic.php?f=17&t=1927)


---

## Re: Donchian Channel of RSI

**SpLiFT** · Wed Feb 27, 2019 7:02 am

Yes, however as a channel:

- RSI candle High = Channel High line
- RSI candle Low = Channel Low line
- RSI candle Close = RSI Main line

Would it be possible to adapt it, please?


---

## Re: Donchian Channel of RSI

**Apprentice** · Thu Feb 28, 2019 5:30 am

Try Donchian Channel on RSI Candle
[viewtopic.php?f=17&t=1927](https://fxcodebase.com/code/viewtopic.php?f=17&t=1927)


---

## Re: Donchian Channel of RSI

**SpLiFT** · Thu Feb 28, 2019 9:12 am

Hi Apprentice,

Thanks!

This one would work perfectly, if:

1 The period setting for the Donchian Channel can be set to value of "1" (currently "2" is the minimum)
2 (Optional) - The RSI Candle Close could be a line, although I found a workaround by applying an MVA to it and getting the result I need

Would at least Option 1 be a possibility and is there an MT4 version of this indi too (also Optional)?


---

## Re: Donchian Channel of RSI

**Apprentice** · Thu Feb 28, 2019 10:14 am

Fixed.


---

## Re: Donchian Channel of RSI

**SpLiFT** · Thu Feb 28, 2019 11:00 am

Hi again and thanks,

I removed the old indi and installed the new Donchian Channel on RSI Candle.lua, but the problem persists.

In the image below, when I try to set the Donchian number of periods to "1" (red box on the left) I receive a warning/error message (red box on the right).

 

![DC on RSI Candle.png](images/124177/DC%20on%20RSI%20Candle.png)


---

## Re: Donchian Channel of RSI

**Apprentice** · Fri Mar 01, 2019 2:46 am

Try Donchian Channel on RSI Candle.lua
[viewtopic.php?f=17&t=1927](https://fxcodebase.com/code/viewtopic.php?f=17&t=1927)


---

## Re: Donchian Channel of RSI

**SpLiFT** · Fri Mar 01, 2019 5:08 am

That's the one I've been trying out (see image in my previous post), but the error remains.


---

## Re: Donchian Channel of RSI

**Apprentice** · Fri Mar 01, 2019 5:30 am

Try to open it on some other computer, browser...


---

## Re: Donchian Channel of RSI

**SpLiFT** · Mon Mar 04, 2019 4:01 am

Hi Apprentice,

It worked on another computer, thank you!

Is there a way to disable the candles and leave only the channel on?

Finally, would it be possible to do this for MT4 as well, please?

Thanks for all the help!


---

## Re: Donchian Channel of RSI

**Apprentice** · Mon Mar 04, 2019 6:04 am

Your request is added to the development list under Id Number 4500

"Nothing" option added for RSI Type


---

## Re: Donchian Channel of RSI

**SpLiFT** · Mon Mar 04, 2019 9:03 am

Thanks! You and the team are the best


---

## Re: Donchian Channel of RSI

**Alexander.Gettinger** · Tue Mar 05, 2019 6:49 pm

> **SpLiFT wrote:**
> Finally, would it be possible to do this for MT4 as well, please?

Please try this indicator:

 [Donchian_Channel_of_RSI.mq4](files/124261/Donchian_Channel_of_RSI.mq4)


---

## Re: Donchian Channel of RSI

**SpLiFT** · Thu Mar 07, 2019 5:44 am

Hi Alex,

Thanks for posting this indi, but I was hoping you could make the attached one for MT4 with the option of having the DC period set to 1 (on the High and Low of the RSI candle alone).

Would you be able to do this, please?


---

## Re: Donchian Channel of RSI

**Alexander.Gettinger** · Mon Mar 11, 2019 1:17 pm

> **SpLiFT wrote:**
> Hi Alex,
>
> Thanks for posting this indi, but I was hoping you could make the attached one for MT4 with the option of having the DC period set to 1 (on the High and Low of the RSI candle alone).
>
> Would you be able to do this, please?

Please try this indicator:

 [Donchian_Channel_of_RSI_Candle.mq4](files/124363/Donchian_Channel_of_RSI_Candle.mq4)


---

## Re: Donchian Channel of RSI

**SpLiFT** · Mon Mar 18, 2019 5:31 am

Hi Alex,

I'm afraid this is not the same as the .lua indicator shared by Apprentice.

What the MT4 version does is that it plots a High and Low channels on two different RSIs: one with RSI period set to High and another RSI with the same period set to Low.

What we need is to have only one RSI value with a period (for example 14) set to Close. Then, the High and Low channels (basically, a Donchian Channel set to period 1) should be drawn based on the Highest and Lowest values that the RSI 14 Close has reached during each single candle before closing (once it closes the usual RSI line is drawn).

Would you be able to code that? I hope I made it clear but let me know if it's not and I'll show you a comparison between the Marketscope and MT4 indicators.


---

## Re: Donchian Channel of RSI

**Apprentice** · Sat Mar 23, 2019 3:15 am

I've compared the output, is the same.
