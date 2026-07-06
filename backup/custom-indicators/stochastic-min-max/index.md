# Stochastic Min Max

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64558  
> Forum: 17 · Topic 64558 · 37 post(s)


---

## Stochastic Min Max

**Apprentice** · Fri Mar 31, 2017 3:43 pm

![EURUSD m1 (03-31-2017 2049).png](images/111752/EURUSD%20m1%20%2803-31-2017%202049%29.png)



Shows the location of the high/low price achieved between two K/D line Stochastic crosses.

 [Stochastic Min Max.lua](files/111752/Stochastic%20Min%20Max.lua)

 [Stochastic Min Max with Alert.lua](files/111752/Stochastic%20Min%20Max%20with%20Alert.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=68493](https://fxcodebase.com/code/viewtopic.php?f=38&t=68493)

 

![EURUSD m1 (01-24-2023 1321).png](images/111752/EURUSD%20m1%20%2801-24-2023%201321%29.png)



 [Stochastic Min Max Signal Oscillator.lua](files/111752/Stochastic%20Min%20Max%20Signal%20Oscillator.lua)


---

## Re: Stochastic Min Max

**colajam1979** · Fri Apr 07, 2017 11:37 am

Perfect. Can you add 'end of turn' and 'Live' Options please.


---

## Re: Stochastic Min Max

**colajam1979** · Sat Apr 08, 2017 4:32 pm

I have just worked out what you have done here. You have programmed it to show the highest and lowest point in the K/D cross over.

Can you re do it to show only the
highest candle when k>D
Lowest candle when D<K

Thanks again


---

## Re: Stochastic Min Max

**Apprentice** · Mon Apr 10, 2017 7:21 am

Trend Filter added.


---

## Re: Stochastic Min Max

**colajam1979** · Mon Apr 10, 2017 8:28 am

That is perfect thanks Mario


---

## Re: Stochastic Min Max

**colajam1979** · Mon Jul 10, 2017 9:54 am

Hello Mario
Hope you are well.

Can you add an alert function to this indicator please.
make sound
pop up box
email

Thanks

Also do you know where i can make custom Lua sound files for my alerts?


---

## Re: Stochastic Min Max

**Apprentice** · Mon Jul 10, 2017 3:38 pm

Stochastic Min Max with Alert.lua added.


---

## Re: Stochastic Min Max

**colajam1979** · Tue Jul 11, 2017 6:53 am

Thank you for this update Mario.
One last thing perhaps you could add to this indicator?

**Alert if Higher high not made Yes/No
Alert if lower low not made Yes/No**

The way I would like the check to be made is as follows.
If trending in a long trade = K>D with higher highs made during each K>D cycle.

‘**Alert if Higher high not made**’ is made when the most recent (current) K/D cycle does not make a higher high (when the cycle ends) than the previous K/D cycle.


---

## Re: Stochastic Min Max

**colajam1979** · Tue Jul 11, 2017 7:00 am

I am getting an error with the alert update.

set to 15/5/5 ema ema 15m but running in a 5m chart


---

## Re: Stochastic Min Max

**Apprentice** · Tue Jul 11, 2017 1:03 pm

I failed to reproduce the mentioned bug,
Can you please specify error messages.
However, re-download due to a completely unrelated bug.


---

## Re: Stochastic Min Max

**colajam1979** · Tue Jul 11, 2017 3:52 pm

Hello Apprentice
I have attached a screen shot. If you look in the top right hand corner you will see the error message that i am getting.


---

## Re: Stochastic Min Max

**Apprentice** · Wed Jul 12, 2017 1:16 pm

Can you please copy/past error message?


---

## Re: Stochastic Min Max

**colajam1979** · Wed Jul 12, 2017 3:56 pm

I do not get an error message. just the information in the Legend, top left corner, that finishes (error)


---

## Re: Stochastic Min Max

**Apprentice** · Mon Aug 14, 2017 4:52 am

I have not been able to reproduce any of this issues.


---

## Re: Stochastic Min Max

**Apprentice** · Sat Oct 27, 2018 8:48 am

The Indicator was revised and updated.


---

## Re: Stochastic Min Max

**TheGMan** · Sat May 18, 2019 12:06 pm

Hi Apprentice

The Stochastic Min Max Indicator is a great indicator!

Can you please code the same in MQL4 for use in MT4?

This would be greatly appreciated.

Thank you!

G


---

## Re: Stochastic Min Max

**Apprentice** · Sun May 19, 2019 4:07 am

Your request is added to the development list under Id Number 4664


---

## Re: Stochastic Min Max

**Apprentice** · Wed May 22, 2019 5:29 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=68493](https://fxcodebase.com/code/viewtopic.php?f=38&t=68493)


---

## Re: Stochastic Min Max

**TheGMan** · Wed May 22, 2019 6:21 am

Thank you, Apprentice!

G


---

## Re: Stochastic Min Max

**Reymondpolanco** · Wed May 22, 2019 11:22 am

Can you make an strategy for this ?


---

## Re: Stochastic Min Max

**Apprentice** · Thu May 23, 2019 3:13 am

Sure. I'm not sure, this will be beneficial, the signal is quite lagging.
The indicator is analytical, not trading help.


---

## Re: Stochastic Min Max

**lavolpe** · Thu Jan 30, 2020 3:29 pm

Hi! Can you transform this in an oscillator? i would like to use it in a strategy.

I tryed to trasform it in oscillator but result seems to be not congruent!

i need two continuous line with price scale to know in any period the last maximum and minimum value (support and resistence).
Then i need two stream (Up and Down) for any periods.

I attach my indicator.

thanks in advance.


---

## Re: Stochastic Min Max

**Apprentice** · Thu Jan 30, 2020 4:39 pm

![GBPUSD D1 (01-30-2020 2047).png](images/130989/GBPUSD%20D1%20%2801-30-2020%202047%29.png)



 [Stochastic Min Max Oscillator.lua](files/130989/Stochastic%20Min%20Max%20Oscillator.lua)

Try this version.


---

## Re: Stochastic Min Max

**Gilles** · Mon Sep 26, 2022 2:30 pm

Hi Apprentice,
Would it be possible to replace the K and D of the standard STOCHASTIC with the K and D of the SMI indicator ?
Thank you very much :) !


---

## Re: Stochastic Min Max

**Apprentice** · Wed Sep 28, 2022 11:08 am

We have added your request to the development list.
Development reference 596.


---

## Re: Stochastic Min Max

**Apprentice** · Mon Oct 03, 2022 3:05 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=72795](https://fxcodebase.com/code/viewtopic.php?f=17&t=72795)

I hope I used the correct SMI


---

## Re: Stochastic Min Max

**Gilles** · Thu Jan 19, 2023 3:25 am

Hi Apprentice,

For the Stochastic_Min_Max.LUA indicator, could you provide a flux for the green arrows and another flux for the red arrows?

Thanck you very much.


---

## Re: Stochastic Min Max

**Apprentice** · Fri Jan 20, 2023 11:33 am

What is flux?


---

## Re: Stochastic Min Max

**Gilles** · Fri Jan 20, 2023 2:36 pm

Hi Apprentice,
Hi Apprentice, I apologize. I wanted to talk about Stream. The ideal for me would be to get the position of the arrows in a dedicated stream as you usually do with:

 indicator.parameters:addColor("upaclr", "Up arrow Color", "Up arrow Color", core.colors().Chartreuse);
 indicator.parameters:addColor("dnaclr", "Dn arrow Color", "Dn arrow Color", core.colors().Tomato);
 indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 5, 1, 5);

local dnArrow, upArrow;

 dnArrow = instance:addStream("dnArrow", core.Dot, name .. ".dnArrow", "dnArrow", instance.parameters.dnaclr, first);
 upArrow = instance:addStream("upArrow", core.Dot, name .. ".upArrow", "upArrow", instance.parameters.upaclr, first);
 dnArrow:setWidth(instance.parameters.DotSize);
 upArrow:setWidth(instance.parameters.DotSize);

Thank you very much !


---

## Re: Stochastic Min Max

**Apprentice** · Tue Jan 24, 2023 7:23 am

Stochastic Min Max Signal Oscillator.lua added.


---

## Re: Stochastic Min Max

**Apprentice** · Tue Jan 24, 2023 7:26 am

To be honest, I still don't understand you.

Something like Stochastic Min Max with Alert.lua or Stochastic Min Max Signal Oscillator.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=64558](https://fxcodebase.com/code/viewtopic.php?f=17&t=64558)


---

## Re: Stochastic Min Max

**Gilles** · Tue Jan 24, 2023 7:54 am

Hi Apprentice,
Currently in Stochastic Min Max.LUA you are searching for and indicating the min max of the price between two stochastic crosses. You indicate the min and max by arrows that you draw on the graph. However, we cannot retrieve this information through dedicated streams. I would like the position of the min and max to be indicated in a dedicated stream for the MAX arrows (upArrow) and another dedicated stream for the MIN arrows (dnArrow). This way, we can query these two streams to retrieve the information we want.
Is this possible?

Thanck you :) !


---

## Re: Stochastic Min Max

**Apprentice** · Tue Jan 24, 2023 8:19 am

Sure.
Stochastic Min Max Signal Oscillator has separate min and max streams.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=64558](https://fxcodebase.com/code/viewtopic.php?f=17&t=64558)


---

## Re: Stochastic Min Max

**Gilles** · Tue Jan 24, 2023 9:29 am

Apprentice,
The STOCHASTIC MIN MAX SIGNAL OSCILLATOR.LUA indicator does not match what I am trying to achieve.
There are indeed two separate streams:
stream 1 for minmax,
stream 2 for cross.

However, I would like to simply have 2 streams as follows:
stream 1 for max,
stream 2 for min.
This would allow me to locate where the arrows are and at what price.

Thanck you :) !


---

## Re: Stochastic Min Max

**Apprentice** · Thu Jan 26, 2023 6:02 am

Try it now.


---

## Re: Stochastic Min Max

**Gilles** · Thu Jan 26, 2023 6:05 am

Hi Apprentice,
I've reached my goal and I can now retrieve the coordinates of the arrows and their position in their dedicated stream. I've made 2 versions, one Indicator version and one Oscillator version (Display possible in Bar or Dot). Each of these versions includes 2 separate streams:

1. upArrow stream
2. dnArrow stream

In this image you can see in the upper frame GER30_m15:
STOCHASTIC MIN MAX.LUA that you propose.

And just below, in the lower frame GER30_m15:
An indicator that I called SMMSI (Stochastic Min Max Stream Indicator)
Which allows to retrieve the data that corresponds to the dots (Dot).
See IMG_table

And another indicator that I called SMMSO (Stochastic Min Max Stream Oscillator)
Which displays the following indications:

1. a GREEN bar with the value -1 to place a BUY
2. a RED bar with the value +1 to place a SELL
And below I placed the same oscillator by selecting the Dot to show you. Everything coincides.

To check and extract this information, simply click on the "Table" graphic mode instead of "Candlestick", right-click to copy everything and paste it into a simple Excel sheet or other.
Have a good day everyone :)!


---

## Re: Stochastic Min Max

**Gilles** · Thu Jan 26, 2023 8:34 am

Apprentice,
I sent you my two files with images and explanations this morning (in France).
The version you propose does not take into account the TrendFilter, which generates false signals.
However, we can recover and use the flow even if it is still incorrect.
The next version will be correct, I am sure, knowing the quality of the work done here every day.
Courage... :)
