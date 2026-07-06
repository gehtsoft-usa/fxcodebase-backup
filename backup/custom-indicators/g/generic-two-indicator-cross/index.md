# Generic Two Indicator Cross

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66231  
> Forum: 17 · Topic 66231 · 34 post(s)


---

## Generic Two Indicator Cross

**Apprentice** · Thu Jun 28, 2018 4:21 pm

![USDOLLAR D1 (06-28-2018 2122).png](images/119728/USDOLLAR%20D1%20%2806-28-2018%202122%29.png)



Will give an alert if two selected indicator output lines cross.
In this example, we have 50 and 200 moving average line cross.

 [Generic Two Indicator Cross.lua](files/119728/Generic%20Two%20Indicator%20Cross.lua)

 [Generic Four Line Indicator Cross.lua](files/119728/Generic%20Four%20Line%20Indicator%20Cross.lua)

 [Tick-Chart-Generic Four Line Indicator Cross.lua](files/119728/Tick-Chart-Generic%20Four%20Line%20Indicator%20Cross.lua)


---

## Re: Generic Two Indicator Cross

**easytrading** · Fri Jun 29, 2018 12:01 am

is it possible Apprantece , to add 2 more Data stream line for each indicator so the Max data stream will be 3 for each indicator to be choose for crossing with the other indicator .thank you very much.


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Aug 08, 2018 9:45 am

Generic Four Line Indicator Cross.lua added.


---

## Re: Generic Two Indicator Cross

**Paul W** · Wed Aug 08, 2018 12:13 pm

this could be good

is it possible for the generic indicator (4 line) to support Tick-charts ?

Thanks


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Aug 08, 2018 12:37 pm

Tick-Chart-Generic Four Line Indicator Cross.lua added.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Thu Oct 14, 2021 8:58 am

Thank you for your "four line indicator Cross" indicator. Could you change it to a "FIVE line indicator Cros" Please? For my trades I am using MM7, 20, 50, 100, 200. Could you also make each MA change color when they go up, down or neutral. (3 colors).
Thanks for your help.
Sincerely yours.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Fri Oct 15, 2021 4:16 am

Thank you for your "four line indicator Cross" indicator. Could you change it to a "FIVE line indicator Cros" Please? For my trades I am using five MM. Could you also make each MA change color when they go up, down or neutral. (3 colors).
Thanks for your help.
Sincerely yours.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Fri Oct 15, 2021 5:32 am

> **Apprentice wrote:**
>
>
> USDOLLAR D1 (06-28-2018 2122).png
>
>
> Will give an alert if two selected indicator output lines cross.
> In this example, we have 50 and 200 moving average line cross.
>
>
> Generic Two Indicator Cross.lua
>
>
>
>
> Generic Four Line Indicator Cross.lua
>
>
>
>
> Tick-Chart-Generic Four Line Indicator Cross.lua

Thank you for your "four line indicator Cross" indicator. Could you change it to a "FIVE line indicator Cros" Please? For my trades I am using five MM. Could you also make each MA change color when they go up, down or neutral. (3 colors).
Thanks for your help.
Sincerely yours.


---

## Re: Generic Two Indicator Cross

**Apprentice** · Sat Oct 16, 2021 6:52 am

[Generic Five Line Indicator Cross.lua](files/143965/Generic%20Five%20Line%20Indicator%20Cross.lua)

Try this version.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Mon Oct 18, 2021 10:20 am

error


---

## Re: Generic Two Indicator Cross

**Xtian56** · Mon Oct 18, 2021 10:25 am

error


---

## Re: Generic Two Indicator Cross

**Xtian56** · Tue Oct 19, 2021 3:47 pm

![erreur 1 stream.png](images/143988/erreur%201%20stream.png)

*358 incorrect index of stream*



> **Apprentice wrote:**
>
>
> The attachment **erreur 1 stream.png** is no longer available
>
>
> Try this version.

Thank you so much.
I don't understand why I am getting this message with this MVA flag
Thanks for your help


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Oct 20, 2021 6:07 am

MVA only has one stream.
You can NOT use 2, 3, 4, 5...


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Oct 20, 2021 6:13 am

For what parameter?


---

## Re: Generic Two Indicator Cross

**Apprentice** · Tue Oct 26, 2021 4:21 am

Data stream number for MVA can only be 1


---

## Re: Generic Two Indicator Cross

**Xtian56** · Tue Oct 26, 2021 5:23 am

> **Apprentice wrote:**
> For what parameter?

Hello and thank you for the answers
The indicators are as follows:
MVA N°1 = 7 périodes
MVA N°2 = 20 périodes
MVA N°3 = 50 périodes
MVA N°4 = 100 périodes
MVA N° 5 = 200 périodes
they are now displayed all except the last one, number 5

is it possible that the signals trigger as in :
Generic Four line indicator cross.lua

thank you so much


---

## Re: Generic Two Indicator Cross

**Apprentice** · Thu Oct 28, 2021 4:31 am

Generic Five Line Indicator Cross bug fixed.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Mon Nov 01, 2021 1:18 pm

Thank you for the answer. After a new download I get stuck on this error message with the same 5 indicators: MVA 7, 20, 50, 100, 200

new request :

is it possible that the signals are triggered as in:
Generic four-line cross.lua indicator

thank you so much


---

## Re: Generic Two Indicator Cross

**Apprentice** · Tue Nov 02, 2021 9:37 am

It is best not to change that parameter.
MVA max value is 1.
MACD max value is 3
and so on.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Tue Nov 02, 2021 12:01 pm

> **Apprentice wrote:**
> It is best not to change that parameter.
> MVA max value is 1.
> MACD max value is 3
> and so on.

Thank you for your reply
Here is my entry: 1 at each MVA and I get after this error message 438


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Nov 03, 2021 10:28 am

[Generic Five Line Indicator Cross.lua](files/144163/Generic%20Five%20Line%20Indicator%20Cross.lua)

Try this version.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Fri Nov 05, 2021 7:44 am

> **Apprentice wrote:**
>
>
> The attachment **Generic Five Line Indicator Cross.lua** is no longer available
>
>
> Try this version.

Thank you very much this is working now.
Is it possible to now modify the buy & sell signals so that they are like in "FOUR MOVING AVERRAGE ALERT" please?


---

## Re: Generic Two Indicator Cross

**Apprentice** · Fri Nov 05, 2021 10:38 am

I’m not sure what was required.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Fri Nov 05, 2021 6:30 pm

> **Apprentice wrote:**
> I’m not sure what was required.

Thank you for your reply.

Signals when prices pass all MVAs:
from above => Buy
from below => Sell

Thanks for your help


---

## Re: Generic Two Indicator Cross

**Apprentice** · Sat Nov 06, 2021 3:32 am

[Generic Five Line Price Cross Indicator.lua](files/144189/Generic%20Five%20Line%20Price%20Cross%20Indicator.lua)

Try this version.


---

## Re: Generic Two Indicator Cross

**Xtian56** · Sun Nov 07, 2021 4:13 pm

> **Apprentice wrote:**
>
>
> Generic Five Line Price Cross Indicator.lua
>
>
> Try this version.

Thank you for your reply.

I'm sorry because I use the google translation (french / english)

About the signals I wanted to say:
Signals when prices exceed the "LAST" MVA:
from above => Buy
from below => Sell

Thanks for your help


---

## Re: Generic Two Indicator Cross

**Xtian56** · Sun Nov 07, 2021 4:49 pm

> **Apprentice wrote:**
>
>
> The attachment **Generic Five Line Price Cross Indicator.lua** is no longer available
>
>
> Try this version.

In summary, here are the wanted & desired signals.
thank you so much


---

## Re: Generic Two Indicator Cross

**Apprentice** · Mon Nov 08, 2021 12:34 pm

Your request is added to the development list.
Development reference 976.


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Nov 10, 2021 4:45 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=71634](https://fxcodebase.com/code/viewtopic.php?f=17&t=71634)


---

## Re: Generic Two Indicator Cross

**enotikos** · Sat Feb 26, 2022 2:17 am

Hi,
Can you add in the "Generic two indicator cross" the ability to open trades (with stop loss, limit, trailing stop).

Thank you.


---

## Re: Generic Two Indicator Cross

**Apprentice** · Mon Feb 28, 2022 10:06 am

Your request is added to the development list.
Development reference 134.


---

## Re: Generic Two Indicator Cross

**Apprentice** · Tue Sep 13, 2022 2:17 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=72708](https://fxcodebase.com/code/viewtopic.php?f=17&t=72708)


---

## Re: Generic Two Indicator Cross

**Paul W** · Wed Aug 21, 2024 1:13 pm

Can you add oscillators to be compatible with this indicator ?

Thanks


---

## Re: Generic Two Indicator Cross

**Apprentice** · Wed Aug 21, 2024 4:14 pm

We have added your request to the development list.
Development reference 660
