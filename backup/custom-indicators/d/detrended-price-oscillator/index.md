# Detrended Price Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65510  
> Forum: 17 · Topic 65510 · 35 post(s)


---

## Detrended Price Oscillator

**Apprentice** · Sat Jan 06, 2018 7:50 am

![USDSEK H1 (01-06-2018 1201).png](images/116781/USDSEK%20H1%20%2801-06-2018%201201%29.png)



DPO is calculated as (close – moving average (n/2+1) days ago).

 [Detrended Price Oscillator.lua](files/116781/Detrended%20Price%20Oscillator.lua)

 [Detrended Price Oscillator with Channel.lua](files/116781/Detrended%20Price%20Oscillator%20with%20Channel.lua)

 [Detrended Price Oscillator with Alert.lua](files/116781/Detrended%20Price%20Oscillator%20with%20Alert.lua)

 [Smoothed Detrended Price Oscillator with Alert.lua](files/116781/Smoothed%20Detrended%20Price%20Oscillator%20with%20Alert.lua)


---

## Re: Detrended Price Oscillator

**Paul W** · Sun Feb 04, 2018 3:43 pm

could you add an Up/Down colour with transparency feature

thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Mon Feb 05, 2018 5:57 am

Detrended Price Oscillator with Channel.lua added.


---

## Re: Detrended Price Oscillator

**Paul W** · Tue Mar 20, 2018 9:07 pm

A very good indicator

and an important part to a scalping strategy

could you add a cross above/below center (0) audio alert - separate sound files for up and down

please,

and thankyou


---

## Re: Detrended Price Oscillator

**Apprentice** · Thu Mar 22, 2018 8:05 am

Detrended Price Oscillator with Alert.lua added.


---

## Re: Detrended Price Oscillator

**Paul W** · Wed May 09, 2018 12:07 pm

Is it possible to add a "smoothing" line option to - Detrended Price Oscillator with Alert.lua

to reduce the number of signals

thanks


---

## Re: Detrended Price Oscillator

**Apprentice** · Thu May 10, 2018 5:22 am

Smoothed Detrended Price Oscillator with Alert.lua added.


---

## Re: Detrended Price Oscillator

**Paul W** · Thu May 10, 2018 12:16 pm

Smoothed Detrended Price Oscillator with Alert.lua

A good indicator for use on tick-charts

thanks


---

## Re: Detrended Price Oscillator

**Paul W** · Mon Feb 04, 2019 3:29 pm

"Detrended Price Oscillator with Channel.lua"

a good indicator

if possible could you add an enhancement

to better display when the channel has reached a maximum distance from the median

1) add an alert feature similar to volume alert - [viewtopic.php?f=17&t=48694&p=104250&hilit=tick+volume+alert#p75694](https://fxcodebase.com/code/viewtopic.php?f=17&t=48694&p=104250&hilit=tick+volume+alert#p75694)

when alert triggers, (dot-label) keeps advancing (repaints) until a maximum distance from the median is reached

alert applies to both Long and Short

and supports Tick-chart

Thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Thu Feb 07, 2019 5:23 pm

Your request is added to the development list under Id Number 4459


---

## Re: Detrended Price Oscillator

**Apprentice** · Mon Feb 11, 2019 6:16 am

Try this version.

 [Detrended Price Oscillator with Channel.Paul W.lua](files/123827/Detrended%20Price%20Oscillator%20with%20Channel.Paul%20W.lua)


---

## Re: Detrended Price Oscillator

**Paul W** · Mon Feb 11, 2019 4:00 pm

very close

Alert triggers when price reaches/breaks "Buy Level" and "Sell Level" - works well

However - repaint feature does not - Alert level should advance (repaint) until a maximum distance from "0" is attained - then fixes in position

similar in the manner "3_Level_ZZ_Semafor" repaints - where earlier painted lines are erased (disappear) [viewtopic.php?f=17&t=954&hilit=3_LEVEL_ZZ_SEMAFOR](https://fxcodebase.com/code/viewtopic.php?f=17&t=954&hilit=3_LEVEL_ZZ_SEMAFOR)

I was hoping to enhance the indicator to help identify (visually) when a maximum distance from "0" is reached/attained - it helps identify when an exit (to a scalp trade) is near - both Long and Short

Long - "Buy level Alert" - only "Buy level Cross Over" is needed
Short - "Sell level Alert" - only "Sell level Cross Under" is needed

this indicator is one of a composite of others - that I use in a scalping strategy

very much appreciated


---

## Re: Detrended Price Oscillator

**Apprentice** · Wed Feb 13, 2019 5:21 am

Try this version.

 [Detrended Price Oscillator with Channel.Paul W.v2.lua](files/123866/Detrended%20Price%20Oscillator%20with%20Channel.Paul%20W.v2.lua)


---

## Re: Detrended Price Oscillator

**Paul W** · Wed Feb 13, 2019 1:41 pm

very, very close - found a couple of bugs

"alert" counter appears to reset/focus on "Buy level" and "Sell level" ? - and therefore misses valid "alert" triggers - "alert" counter should reset when price crosses "0"

"autoscale" feature appears not to include "alert" symbol - symbol at times is clipped

this is a good indicator - a useful addition, to a composite strategy

Thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Sat Feb 16, 2019 4:18 am

Try this version.

 [Detrended Price Oscillator with Channel.Paul W.v3.lua](files/123945/Detrended%20Price%20Oscillator%20with%20Channel.Paul%20W.v3.lua)

"autoscale" feature appears not to include "alert" symbol - symbol at
times is clipped
It's FXTS2 bug, there is nothing we can do with it


---

## Re: Detrended Price Oscillator

**Paul W** · Sun Feb 17, 2019 4:36 pm

tested latest version

"0" counter reset - works OK

but indicator still misses valid alerts - I can't see a pattern for the error atm - may be related to counter ?

autoscale still clipping some alert-symbols - not sure if this can be fixed ? (would be nice)

I have tested, and this is a very good indicator - currently tuned for DOW and DAX

I very much appreciate your efforts


---

## Re: Detrended Price Oscillator

**Apprentice** · Tue Feb 19, 2019 7:16 am

Try this version.

 [Detrended Price Oscillator with Channel.Paul W.v4.lua](files/124011/Detrended%20Price%20Oscillator%20with%20Channel.Paul%20W.v4.lua)


---

## Re: Detrended Price Oscillator

**Paul W** · Wed Feb 20, 2019 11:40 am

Awesome - am testing atm

Alert symbol still occasionally gets clipped - "Autoscale" appears to focus on the indicator and not the alert-symbol - would be nice if fixed, but is also liveable (not sure if this is fixable ?)

Will make and post some chart examples on how I use this indicator in a scalping strategy - will post shortly

Thx


---

## Re: Detrended Price Oscillator

**Paul W** · Tue Feb 26, 2019 3:17 pm

Here is a simple Scalping Strategy using - Detrended Price Oscillator with Channel.Paul W.v4.lua
[download/file.php?id=23989](https://fxcodebase.com/code/download/file.php?id=23989)

Requires Recursive Median Filter
[viewtopic.php?f=17&t=65722&p=118728&hilit=recursive#p118728](https://fxcodebase.com/code/viewtopic.php?f=17&t=65722&p=118728&hilit=recursive#p118728)

settings are displayed on chart - and are currently tuned for DOW and DAX - FX pairs need to be separately tuned

works well when there is momentum and/or there is frontrunning on Fundamental News releases

note: avoid high-Market-volatility periods, and trade only in the direction of trend


---

## Re: Detrended Price Oscillator

**Paul W** · Tue May 28, 2019 9:49 am

this is a really good indicator - Detrended Price Oscillator with Channel.Paul W.v4.lua

I'm hoping you have some time - to add an enhancement

An option to select a vertical line - that displays on the oscillator and main charts - if that is possible?

it would better help visually to identify entries and exits

Thank you


---

## Re: Detrended Price Oscillator

**Apprentice** · Tue May 28, 2019 4:06 pm

Your request is added to the development list under Id Number 4686


---

## Re: Detrended Price Oscillator

**Paul W** · Thu Dec 26, 2019 2:37 pm

Hello and a Merry Christmas/Holidays

I've been using the vertical line option of **"Detrended Price Oscillator with Channel.Paul W.v4.lua"**

and it works very well - have added vertical lines to main chart - helpful to identify slowing momentum, and nearing swings on tick-charts - see attachment

but, have found a bug - when using the oscillator alert option - will display above-alert, will not display below-alert see attachment

could you pls have a look at

thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Fri Dec 27, 2019 6:01 am

Sure.
Can you provide the indicator code?


---

## Re: Detrended Price Oscillator

**Paul W** · Fri Dec 27, 2019 10:27 am

I am using the version downloaded from this link - the post just above

thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Fri Dec 27, 2019 10:40 am

Your request is added to the development list.
Development reference 495.


---

## Re: Detrended Price Oscillator

**Paul W** · Fri Dec 27, 2019 1:21 pm

if it helps

I tested the oscillator alert using sound files - both the "Alert Cross Over Sound" and "Alert Cross Under Sound" are working correctly

and it is the below "Show Alert" "Down Symbol" that is missing

thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Mon Dec 30, 2019 8:11 am

[Detrended_Price_Oscillator_with_Channel.Paul_W.v4.lua](files/130531/Detrended_Price_Oscillator_with_Channel.Paul_W.v4.lua)

Fixed.


---

## Re: Detrended Price Oscillator

**Paul W** · Tue Dec 31, 2019 12:37 pm

tested, works well

a very good indicator and addition to the strategy

Thanks


---

## Re: Detrended Price Oscillator

**Apprentice** · Sun Jan 05, 2020 10:54 am

Can you provide the rules for the strategy?


---

## Re: Detrended Price Oscillator

**Paul W** · Thu Jan 09, 2020 3:54 pm

Detrended_Price_Oscillator_with_Channel.Paul_W.v4.lua

is one part of a composite of indicators that makes-up a scalping Strategy

and is a visual aid to a manual/user based strategy - currently

here is a video example - [https://youtu.be/nINSKWiXzxs](https://youtu.be/nINSKWiXzxs)


---

## Re: Detrended Price Oscillator

**Paul W** · Tue Aug 30, 2022 9:50 am

Hello

not sure why but this indicator was working fine, but suddenly stopped functioning ?

[https://fxcodebase.com/code/download/file.php?id=27083](https://fxcodebase.com/code/download/file.php?id=27083)

could you have a look pls

thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Wed Aug 31, 2022 4:04 am

Try in now.


---

## Re: Detrended Price Oscillator

**Paul W** · Wed Aug 31, 2022 9:57 am

Gave it a try and unfortunately, the indicator still does not function

downloaded from this link [https://fxcodebase.com/code/download/file.php?id=27083](https://fxcodebase.com/code/download/file.php?id=27083)

would be nice to have working again, but not critical

example configuration that worked previously - and now displays an "error"

thx


---

## Re: Detrended Price Oscillator

**Apprentice** · Wed Aug 31, 2022 11:23 am

[Detrended_Price_Oscillator_with_Channel.Paul_W.v4.lua](files/147304/Detrended_Price_Oscillator_with_Channel.Paul_W.v4.lua)

The file from your link works for me.
Try the file from this post.
If this does not help, please provide the error message.


---

## Re: Detrended Price Oscillator

**Paul W** · Wed Aug 31, 2022 12:42 pm

Downloaded indicator from the post you provided [https://fxcodebase.com/code/download/file.php?id=35870](https://fxcodebase.com/code/download/file.php?id=35870)

indicator still will not fully function ?

lines and channel will not paint, and no alerts will display

"(error)" is what appears in the legend - no other error message that I can see

note: Trading Station did perform an update recently - around the time the indicator failed (unsure if there is any relationship ?)

I hope this helps
