# PartialAmountStrategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=64940  
> Forum: 31 · Topic 64940 · 3 post(s)


---

## PartialAmountStrategy

**Apprentice** · Sat Jul 22, 2017 8:28 am

Based on the request.
[viewtopic.php?f=27&t=64928](https://fxcodebase.com/code/viewtopic.php?f=27&t=64928)

 [PartialAmountStrategy.lua](files/113696/PartialAmountStrategy.lua)


---

## Re: PartialAmountStrategy

**amazon1a** · Fri Feb 23, 2018 3:40 pm

Hi Apprentice,

I like this Strategy very much, but I wonder if it could be modified so that it could be attached to an existing trade?

Also, it would be a bit more useful if Limit levels could be specified prior to Entry. As it stands now it appears to be best to set a broad Limit then modify after the Trade is initiated by an Entry order. There is only one Limit line in the Control Panel which is set up for all trades in the basket. Could get closed out prematurely once Trade is running in our favor.

Maybe TP1, TP2, TP3 etc

Many thanks as always, AG


---

## Re: PartialAmountStrategy

**amazon1a** · Sat Feb 24, 2018 1:00 pm

Hi Apprentice,

It looks like this Strategy would work out even better if you could do this instead.

 Multiple position OCO request by colajam1979

Thanks, AG
