# Heiken Ashi Color Overlay

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62944  
> Forum: 17 · Topic 62944 · 11 post(s)


---

## Heiken Ashi Color Overlay

**Apprentice** · Fri Dec 11, 2015 5:13 am

![EURUSD m1 (12-11-2015 1038).png](images/103740/EURUSD%20m1%20%2812-11-2015%201038%29.png)



Based on request.
[viewtopic.php?f=27&t=62919&p=103741#p103741](https://fxcodebase.com/code/viewtopic.php?f=27&t=62919&p=103741#p103741)

 [Heiken Ashi Color Overlay.lua](files/103740/Heiken%20Ashi%20Color%20Overlay.lua)

Arrows are drawn, if Heiken Ashi and Price have same direction.

 [Heiken Ashi MA Color Overlay.lua](files/103740/Heiken%20Ashi%20MA%20Color%20Overlay.lua)

Up Arrows
A)Heiken Ashi Up
B)Price if above MA

Down Arrows
A)Heiken Ashi Up
B)Price if below MA

Shift can be used on B)


---

## Re: Heiken Ashi Color Overlay

**adityabhat89** · Tue Dec 15, 2015 12:28 pm

Hi,

This is a pretty awesome indicator.. I admire the programmers work.. Great job done..

However if the creator is open to suggestions heres one:

This indicator functions perfect as far as the overlay goes..

But the arrows that are drawn get repainted.. anyone this can be resolved without losing the accuracy of the signals?

Regards

Adi


---

## Re: Heiken Ashi Color Overlay

**adityabhat89** · Tue Dec 15, 2015 4:19 pm

Hello Mr Apprentice,

This heiken ashi overlay indicator is absolutely brilliant..

I found it really interesting however there seems to be one bit of a problem.

The arrows that are drawn seem to repaint themselves on the chart everytime the price goes in the opposite direction. This is kind of confusing and I was hoping it could be fixed.

Additionally can this be used with a type of SuperTrend indicator that is not laggy. If you have any alternative to this indicator then would you please let me know...

Thanks in advance and great job!

Regards

Adi


---

## Re: Heiken Ashi Color Overlay

**Apprentice** · Wed Dec 16, 2015 4:54 am

This is only true for Last Active candle.

Can you specify the preferred algorithm.
Something like, only first direction registered will be presented.
Note, in this way, you will have a discrepancy between historical and live generated indications.


---

## Re: Heiken Ashi Color Overlay

**adityabhat89** · Sun Dec 20, 2015 7:24 am

OK... this should work well... yes the first direction should be the one that remains on the chart..Its ok if it turns out to be false if the market moves the other way around.

Additionally what can be added is:

If the closing price of the previous candle is above EMA period 10 then the arrow should point upwards and vice versa.

The use of an EMA should provide a good basis for the prediction of the next candle close. If this can be added I think the indy will atleast have an accuracy of 75% or more.

PS: Its ok if the indicator give one/two false signals out of 10 trades. As long as it does not repaint, it should work great.


---

## Re: Heiken Ashi Color Overlay

**adityabhat89** · Sun Dec 20, 2015 7:32 am

Actually you have given me a better idea..

By adding a superfast MA to the equation the false signals can be reduced.

eg:

Add a 7-10 period EMA

If price as per Heiken ashi chart is green and price closes above the EMA then produce Green arrow.

If price as per heiken ashi chart is red and price closes below EMA then produce red arrow.

In instances where price is above the EMA and heiken ashi price is red then no signal and price is below the ema and heiken ashi is green then no signal..

This should improve the indicator atleast 10 times and in case the price moves against the signal its ok.. but the arrow should still remain.

Lemme know in case need anything else... And thanks a millions for your effort apprentice!

Regards

Aditya Bhat


---

## Re: Heiken Ashi Color Overlay

**Apprentice** · Mon Dec 21, 2015 5:27 am

Heiken Ashi MA Color Overlay.lua added.


---

## Re: Heiken Ashi Color Overlay

**adityabhat89** · Mon Dec 21, 2015 6:09 am

Hey Apprentice,

Wow, is this indicator really coded the way I requested it.... Cant wait to try it...

Just one thing..

What does that shift on B mean? at the end of your latest post???


---

## Re: Heiken Ashi Color Overlay

**tezzuja** · Mon Dec 21, 2015 3:20 pm

Hey Apprentice nice works !
it's possible have overlay with CCi (channel index)
when candle Heikin H up the line zero colored in green and when down colored in red
in this mode we have clarity of trend ...

thank a lot


---

## Re: Heiken Ashi Color Overlay

**Apprentice** · Tue Dec 22, 2015 5:00 am

Requested can be found here.
[viewtopic.php?f=17&t=62969](https://fxcodebase.com/code/viewtopic.php?f=17&t=62969)


---

## Re: Heiken Ashi Color Overlay

**Apprentice** · Sun Oct 14, 2018 6:09 am

The indicator was revised and updated.
