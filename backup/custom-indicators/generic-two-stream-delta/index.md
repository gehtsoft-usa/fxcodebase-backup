# Generic Two Stream Delta

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69655  
> Forum: 17 · Topic 69655 · 8 post(s)


---

## Generic Two Stream Delta

**Apprentice** · Fri Apr 10, 2020 9:13 am

![EURUSD H1 (04-10-2020 1421).png](images/132749/EURUSD%20H1%20%2804-10-2020%201421%29.png)



For selected indicator, will calculate the difference for selected streams.

 [Generic Two Stream Delta.lua](files/132749/Generic%20Two%20Stream%20Delta.lua)


---

## Generic Two Indicator Delta

**Apprentice** · Mon May 25, 2020 9:03 am

![AUDCAD H1 (05-25-2020 1413).png](images/134280/AUDCAD%20H1%20%2805-25-2020%201413%29.png)



 [Generic Two Indicator Delta.lua](files/134280/Generic%20Two%20Indicator%20Delta.lua)

 [Tick Generic Two Indicator Delta.lua](files/134280/Tick%20Generic%20Two%20Indicator%20Delta.lua)


---

## Re: Generic Two Stream Delta

**Cactus** · Tue May 26, 2020 8:07 pm

Hello Apprentice,

Long time. I will be more active on the forums again.
This is nice. Will be very useful. I love templates like this, makes creating strategies a lot easier.
Even though there are Python alternatives available I still find myself using Lua the most.

I found the "Generic Two Stream Delta" not displaying on chart. This was due to " indicator:type(core.Indicator)" actually needing to be "core.Oscillator" for anyone wondering


---

## Re: Generic Two Stream Delta

**Apprentice** · Wed May 27, 2020 5:00 am

Fixed.


---

## Re: Generic Two Stream Delta

**coffeezoo** · Sat Apr 01, 2023 12:39 am

Dear Apprentice
Could you explain what input you chose to come up with a nice screenshot like that?
Thank you.


---

## Re: Generic Two Stream Delta

**Apprentice** · Mon Apr 03, 2023 8:02 am

With Generic Two Indicator Delta.lua
you can select any two indicator streams,
and calculate their difference.
As for the one I used in my example,
I have no idea.


---

## Re: Generic Two Stream Delta

**coffeezoo** · Mon Apr 03, 2023 10:39 am

How can I select real volume on the offer for one stream and real volume on the bid for the other?
Thank you.


---

## Re: Generic Two Stream Delta

**Apprentice** · Wed Apr 05, 2023 8:28 am

You can use Real Volume Indicator.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=69949](https://fxcodebase.com/code/viewtopic.php?f=17&t=69949)
FXCM does not provide Bid/Ask volume breakdown.
