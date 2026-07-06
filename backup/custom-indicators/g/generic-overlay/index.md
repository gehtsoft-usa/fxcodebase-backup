# Generic Overlay

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62211  
> Forum: 17 · Topic 62211 · 31 post(s)


---

## Generic Overlay

**Apprentice** · Tue May 12, 2015 3:34 am

![Generic Overlay.png](images/100408/Generic%20Overlay.png)



With this indicator you can create Overlay for most indicator over there.
The available filters are.
1) Slope -based on a relation to previous period value.
2) Position - based on a relation to the signal line
The signal line is the moving average of the indicator selected.
3) Level -based on a relation to user-defined Level
4) Overbought / Oversold - based on a user-defined Overbought / Oversold Levels

 [Generic Overlay.lua](files/100408/Generic%20Overlay.lua)

 [Generic Overlay Bar Histogram.lua](files/100408/Generic%20Overlay%20Bar%20Histogram.lua)

 

![EURUSD H1 (09-01-2016 0218).png](images/100408/EURUSD%20H1%20%2809-01-2016%200218%29.png)



Two Indicator Generic Overlay will show the relationship between the two indicator lines.
In this case, 25 MVA and MVA 50

 [Two Indicator Generic Overlay.lua](files/100408/Two%20Indicator%20Generic%20Overlay.lua)

MT4/MQ4 version is available here.
[viewtopic.php?f=38&t=64503](https://fxcodebase.com/code/viewtopic.php?f=38&t=64503)

The indicator was revised and updated


---

## Re: Generic Overlay

**easytrading** · Thu May 14, 2015 3:28 pm

hello Apprentice,

is it possible to modify another version of Generic Overlay that can use DATA SOURCE of other indicators, please?
thank you so much for your great work.


---

## Re: Generic Overlay

**mulligan** · Thu May 14, 2015 9:21 pm

A Generic Overlay with alert, based on color change, would open up a world of possibilities.

Thanks


---

## Re: Generic Overlay

**Apprentice** · Fri May 15, 2015 1:58 am

easytrading,
It is possible in theory.
The problem is, to have a candle overlay in one indicator,
we have to have the whole bar of data.
Only In theory u can write a signal indicator indicator,
on the basis of which, Overlay will be generated.


---

## Re: Generic Overlay

**easytrading** · Fri May 22, 2015 3:43 pm

kindly, Apprentice a strategy based on color changing for GENERIC OVERLAY will be a great help,

buy on green
sell on red
disregard the gray
close old and open a new position on opposite color.

many thanks and appreciation as always in advance.


---

## Re: Generic Overlay

**Apprentice** · Mon May 25, 2015 5:02 am

Requested can be found here.
[viewtopic.php?f=31&t=62262](https://fxcodebase.com/code/viewtopic.php?f=31&t=62262)


---

## Re: Generic Overlay

**mulligan** · Wed May 27, 2015 11:10 am

I'm using the position relation to signal line and smoothing on the 1 minute chart. I'm sometimes getting a repainting of colors when I refresh the charts. Is this to be expected?


---

## Re: Generic Overlay

**Apprentice** · Thu May 28, 2015 4:11 am

Yes. All depends on the underlying inicator.


---

## Re: Generic Overlay

**easytrading** · Wed Jun 10, 2015 8:32 pm

kindly Apprentice,could you add another filter to GENERIC OVERLAY that support (0 data stream) so we can overlay indicators that uses arrows or dots (NOT lines) like trend_signal indicator,please ?
 with many many thanks....


---

## Re: Generic Overlay

**Apprentice** · Fri Jun 12, 2015 2:18 am

Unfortunately, we can not read all indicator output types.
One example would be the fractal indicator.
At best, some of them require a different logic.
Therefore we can not provide a generic solution for all indicators out there.


---

## Re: Generic Overlay

**BadTunaSalad** · Fri Jun 10, 2016 12:22 am

Instead of a candle overlay, is it possible to create a bar histogram?


---

## Re: Generic Overlay

**Apprentice** · Fri Jun 10, 2016 2:41 am

Generic Overlay Bar Histogram.lua Added.


---

## Re: Generic Overlay

**BadTunaSalad** · Fri Jun 10, 2016 10:50 am

Works great!! Thank you, much appreciated!!


---

## Re: Generic Overlay

**BadTunaSalad** · Wed Feb 22, 2017 7:49 pm

Is it possible to convert the Generic Overlay Bar Histogram into MT4 format? If a general/multi indicator histogram is not possible, I most commonly use the CCI indicator and would be much appreciative to have the histogram back in my arsenal. Thank you.

BTS


---

## Re: Generic Overlay

**Apprentice** · Fri Feb 24, 2017 5:51 am

Your request is added to the development list, Under Id Number 3749
 If someone is interested to do this task, please contact me.


---

## Re: Generic Overlay

**easytrading** · Tue Feb 28, 2017 6:52 pm

why are both indicators are giving only BAR HISTOGRAM overlay ? and we lost the price candle overlay which we were getting it from the first one. could you check that please ,Apprentice ? with many thanks.


---

## Re: Generic Overlay

**Apprentice** · Thu Mar 02, 2017 4:27 am

Oops, upload the wrong file.
Please, Re-Download Generic Overlay.


---

## Re: Generic Overlay

**Apprentice** · Mon Mar 06, 2017 4:58 am

MT4/MQ4 version is available here.
[viewtopic.php?f=38&t=64503](https://fxcodebase.com/code/viewtopic.php?f=38&t=64503)


---

## Re: Generic Overlay

**easytrading** · Tue Mar 14, 2017 8:50 pm

Hello Apprentice,
could we please, have another version of Generic Overlay that could recognize (2) different indicators with their inputs and then produce their lines crossing overlay ? just for example : Dynamic trend with FantailVMA3 .with many thanks in advance.


---

## Re: Generic Overlay

**Apprentice** · Wed Mar 15, 2017 4:40 am

Two Indicator Generic Overlay.lua added.


---

## Re: Generic Overlay

**easytrading** · Sun Aug 12, 2018 7:31 pm

Hello Apprentice,

If you please ,could you add Line color change overlay to the filter types of Generic Overlay ? that will be great help to us with my appreciation .


---

## Re: Generic Overlay

**Apprentice** · Mon Aug 13, 2018 5:12 am

Candle color based on the selected Data Stream?


---

## Re: Generic Overlay

**easytrading** · Mon Aug 13, 2018 7:14 am

candle color based on indicator line color change like for example Kalman_Filter.lua .thank you


---

## Re: Generic Overlay

**Apprentice** · Tue Aug 14, 2018 4:27 am

I hope I understand your intent.

 [Generic Overlay Indicator Line Helper.lua](files/120523/Generic%20Overlay%20Indicator%20Line%20Helper.lua)

 [Generic Overlay Oscillator Line Helper.lua](files/120523/Generic%20Overlay%20Oscillator%20Line%20Helper.lua)


---

## Re: Generic Overlay

**easytrading** · Mon Aug 20, 2018 3:21 am

hello Apprentice,
if you please,

1) is it possible to add line style option to Generic Overlay Indicator Line Helper.lua .
2) Generic Overlay Oscillator Line Helper.lua is not showing any thing on chart ? could you check it please ? with many thanks.


---

## Re: Generic Overlay

**Apprentice** · Tue Aug 21, 2018 5:15 am

Style option added.
Oscillator fixed.


---

## Re: Generic Overlay

**easytrading** · Thu Nov 22, 2018 5:55 pm

Hello Apprentice,

If you please ,could you develop another version of Generic Overlay that will give us price overlay based on when the indicator Line change his mode color from blue to red like for example Kalman_Filter.lua that will be great help to us with my appreciation .


---

## Re: Generic Overlay

**Apprentice** · Sat Nov 24, 2018 6:33 am

Try Generic Overlay.lua
[viewtopic.php?f=17&t=62211](https://fxcodebase.com/code/viewtopic.php?f=17&t=62211)


---

## Re: Generic Overlay

**easytrading** · Tue Apr 20, 2021 7:00 pm

Hello Apprentice ,

could we have the MT4/MQ4 version of Generic Overlay indicator ? with highly appreciation .


---

## Re: Generic Overlay

**Apprentice** · Wed Apr 21, 2021 11:37 am

Your request is added to the development list.
Development reference 393.


---

## Re: Generic Overlay

**Apprentice** · Wed Apr 28, 2021 8:55 am

MT4 doesn't support it.
