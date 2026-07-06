# Average Daily Range

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63112  
> Forum: 17 · Topic 63112 · 37 post(s)


---

## Average Daily Range

**Apprentice** · Fri Feb 05, 2016 6:24 am

![EURUSD H1 (02-05-2016 1149).png](images/104627/EURUSD%20H1%20%2802-05-2016%201149%29.png)



Based on request.
[viewtopic.php?f=27&t=63109](https://fxcodebase.com/code/viewtopic.php?f=27&t=63109)
Range= High-Low
ADR = Avg or Last N Ranges
Top Line= Open + ADR*Multiplier
Bottom Line = Open - ADR*Multiplier

 [Average Daily Range.lua](files/104627/Average%20Daily%20Range.lua)

 [Average Daily Range on Chart.lua](files/104627/Average%20Daily%20Range%20on%20Chart.lua)

 [Average Daily Range Dashboard.lua](files/104627/Average%20Daily%20Range%20Dashboard.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=67213](https://fxcodebase.com/code/viewtopic.php?f=38&t=67213)


---

## Re: Average Daily Range

**Myotone** · Fri Feb 05, 2016 8:52 am

Thank You for directing my attention to this ADR. This is just what I have been looking for and couldn't find. Thank you.


---

## Re: Average Daily Range

**Myotone** · Fri Feb 05, 2016 9:31 am

After a short period of running the indicator with the Alligator and the AO the ADR indicator loads itself in to the AO as well as on the chart. Is there any way of stopping this double loading?
Thank you


---

## Re: Average Daily Range

**Apprentice** · Sat Feb 06, 2016 10:45 am

This looks like TS bug.


---

## Re: Average Daily Range

**Myotone** · Sat Feb 06, 2016 11:13 am

Thank you. What should I do about the TS Bug?


---

## Re: Average Daily Range

**Myotone** · Tue Feb 09, 2016 12:03 pm

Still looking for a reliable simple ADR. The one above gives different readings to the MFT ADR Projection and all the ADR indicators here give different readings to each other when set to the same settings.. Would it please be possible to program an accurate reliable 14 day ADR. The double loading is now confirmed as a FXCM issue in hand.
Thank you for your help so far.


---

## Re: Average Daily Range

**Apprentice** · Wed Apr 04, 2018 5:47 am

Average Daily Range on Chart.lua added.


---

## Re: Average Daily Range

**logicgate** · Wed Dec 26, 2018 10:21 pm

Dear friend apprentice, can you please compile a MT4 version of this indi? Perhaps it is already here on the forum and I didn't find it.

I also would like to ask a little add on. Is it possible to display near the ADR value a countdown of the ADR? For example, if the ADR is 150, then, if the price moved 110 pips on the day, next to it could have another reading like "Remaining: 40". I remember I had an ATR indicator in my old computer that would show the ATR for the day, then the distance to high and low and the ATR remaining for the day, so you wold know the chances for the price reaching a level.

Cheers


---

## Re: Average Daily Range

**Apprentice** · Thu Dec 27, 2018 5:24 am

Your request is added to the development list under Id Number 4389


---

## Re: Average Daily Range

**logicgate** · Thu Dec 27, 2018 8:21 am

Dear friend apprentice, I was thinking about this and now I remembered that the countdown was based on the average intraday pip movement, not the daily range. Because the daily range is smaller than the up and down movements, like in this image attached. So the other average I am talking about is the Average Daily Pip Movement, this is the one that makes sense watching counting down to see if it is reached or not, or surpassed. So, if you can, combine those two into one, please!

Cheers


---

## Re: Average Daily Range

**logicgate** · Thu Dec 27, 2018 8:26 am

Sorry, just wanted to complement the previous post:

So, those statistics are worth seeing on the ADR indi:

-The ADR Value and the projection (you could put next to the projection the distance in pips for them to be reached like "20 to go"
-The Current day range
-The Average Daily Up and Down movement in pips and the pips remaining in the current day for the average to be reached or surpassed.


---

## Re: Average Daily Range

**Apprentice** · Fri Dec 28, 2018 6:33 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=67213](https://fxcodebase.com/code/viewtopic.php?f=38&t=67213)


---

## Re: Average Daily Range

**Reymondpolanco** · Tue Apr 16, 2019 2:40 pm

can you add the option to show how many pips left to complete the daily range ?


---

## Re: Average Daily Range

**Apprentice** · Thu Apr 18, 2019 5:16 am

Your request is added to the development list under Id Number 4599


---

## Re: Average Daily Range

**Apprentice** · Fri Apr 19, 2019 4:57 am

Try this version.

 [Average Daily Range.lua](files/125848/Average%20Daily%20Range.lua)


---

## Re: Average Daily Range

**Reymondpolanco** · Fri Apr 26, 2019 10:35 am

> **Apprentice wrote:**
> Try this version.
>
>
> Average Daily Range.lua

The remaing pips till the daily range is wrong, please check it


---

## Re: Average Daily Range

**Apprentice** · Mon Apr 29, 2019 3:37 pm

I see no issues with it. Can you provide an example of the wrong value and what correct value should be?


---

## Re: Average Daily Range

**RVK2211** · Sat Jun 01, 2019 9:18 am

> **Apprentice wrote:**
> I see no issues with it. Can you provide an example of the wrong value and what correct value should be?

Hi,

I have tried to apply the ADR to my charts and it shows nothing at all... I tired a few different symbols and settings, but nada....

Any suggestions?

RVK


---

## Re: Average Daily Range

**Apprentice** · Sat Jun 01, 2019 9:53 am

![EURUSD H8 (06-01-2019 1456).png](images/126655/EURUSD%20H8%20%2806-01-2019%201456%29.png)



You probably use the sub-hour time frame.
ADR will use D1 as default.
Try to use a higher chart time frame.


---

## Re: Average Daily Range

**RVK2211** · Sat Jun 01, 2019 9:29 pm

> **Apprentice wrote:**
>
>
> EURUSD H8 (06-01-2019 1456).png
>
>
> You probably use the sub-hour time frame.
> ADR will use D1 as default.
> Try to use a higher chart time frame.

I think you are right as it works on a 4 hour chart...
How do I get an ADR range on my 15m chart?

RVK


---

## Re: Average Daily Range

**Apprentice** · Mon Jun 03, 2019 6:35 am

Compress your chart, to include more price points.
If you change "Bar Size to display High/Low" to lower time frame,
this will not be Average Daily Range


---

## Re: Average Daily Range

**RVK2211** · Tue Jun 04, 2019 2:06 am

> **Apprentice wrote:**
> Compress your chart, to include more price points.
> If you change "Bar Size to display High/Low" to lower time frame,
> this will not be Average Daily Range

OK understood.

I have a request for a modification, as I would like to display the the Average Session Range (ASR?) for X number of sessions, either through adding a start/end time to the ADR indicator or add an ASR option to the Trade Session indicator to show the average session range over the last x sessions.

Is that possible?

RVK


---

## Re: Average Daily Range

**Apprentice** · Tue Jun 04, 2019 6:12 am

Your request is added to the development list under Id Number 4695


---

## Re: Average Daily Range

**Apprentice** · Wed Jun 05, 2019 2:57 am

Try this version.
[viewtopic.php?f=17&t=68537](https://fxcodebase.com/code/viewtopic.php?f=17&t=68537)

 [TRADESESSIONS Range Overlay.lua](files/126724/TRADESESSIONS%20Range%20Overlay.lua)


---

## Re: Average Daily Range

**RVK2211** · Wed Jun 12, 2019 8:40 am

> **Apprentice wrote:**
> Try this version.
> [viewtopic.php?f=17&t=68537](https://fxcodebase.com/code/viewtopic.php?f=17&t=68537)
>
>
>
> TRADESESSIONS Range Overlay.lua

Brilliant!!!


---

## Re: Average Daily Range

**Mohamed85** · Fri Jul 19, 2019 8:53 am

HI Apprentice, when I apply the indicator to the H TF it measures the daily range from the hourly candle not from the daily one as intended, in order to fix this I've changed the data source to D1 in the indicator properties panel, it works well in that case but it is shifted to the right side by 11 hrs, and near the end of the UK session it shifts to the next day, is there a way to fix this please, to make it shows at the start of the day to the end of the day based on he right measurements,

one more thing, if possible as well to make it measure the upper level from the low of the day and the lower level from the high of the day (not from the open price) as I believe this is the proper way.

thanks for the spport
Regards.


---

## Re: Average Daily Range

**Apprentice** · Mon Jul 22, 2019 4:08 am

See no issues with time. It works as expected (start of the day at
17:00 of NY). Changed high/low calculation as requested. 20 min

 [Average Daily Range.Mohamed85.lua](files/127454/Average%20Daily%20Range.Mohamed85.lua)


---

## Re: Average Daily Range

**chai88888** · Mon Jun 22, 2020 12:34 am

hi there can i make request about this indicator

can you make all symbols appear on one chart

thanks


---

## Re: Average Daily Range

**Apprentice** · Mon Jun 22, 2020 3:10 am

As the lines?
X pips from current chat open, based on other currency data.
or as a dashboard?

Your request is added to the development list.
Development reference 1532.


---

## Re: Average Daily Range

**chai88888** · Tue Jun 23, 2020 4:28 am

as a dashboard

where i can see all selected symbols on one chart

example
period 5
eur/usd 106.78
gbp /usd 250.76
usd/jpy 80.45

so on ...

but the period is adjustable

thanks


---

## Re: Average Daily Range

**Apprentice** · Wed Jun 24, 2020 4:12 am

Your request is added to the development list.
Development reference 1540.


---

## Re: Average Daily Range

**Apprentice** · Wed Jun 24, 2020 5:38 am

Average Daily Range Dashboard.lua added to the top/first post of the topic.


---

## Re: Average Daily Range

**chai88888** · Thu Jun 25, 2020 11:07 pm

HERE A PICTURE OF THE AVERAGE DAILY RANGE IM TALKING ABOUT AND THE DASHBOARD LOOKS LIKE

THANKS


---

## Re: Average Daily Range

**Apprentice** · Sun Jun 28, 2020 4:27 am

Your request is added to the development list.
Development reference 1567.


---

## Re: Average Daily Range

**Apprentice** · Mon Jun 29, 2020 8:45 am

[Average Daily Range Multi Dashboard.lua](files/135411/Average%20Daily%20Range%20Multi%20Dashboard.lua)

Average Daily Range Oscillator.lua
[viewtopic.php?f=31&t=65006](https://fxcodebase.com/code/viewtopic.php?f=31&t=65006)


---

## Re: Average Daily Range

**chai88888** · Mon Jun 29, 2020 9:52 am

where can i find the AVERAGE DAILY RANGE OSCILLATOR?


---

## Re: Average Daily Range

**Apprentice** · Tue Jun 30, 2020 3:34 am

Average Daily Range Oscillator.lua
[viewtopic.php?f=31&t=65006](https://fxcodebase.com/code/viewtopic.php?f=31&t=65006)
