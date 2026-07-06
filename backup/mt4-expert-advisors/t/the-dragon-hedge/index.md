# The Dragon Hedge

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=66713  
> Forum: 38 · Topic 66713 · 13 post(s)


---

## The Dragon Hedge

**Apprentice** · Wed Oct 10, 2018 1:16 pm

Based on request.
[viewtopic.php?f=27&t=66669](https://fxcodebase.com/code/viewtopic.php?f=27&t=66669)

 [The Dragon Hedge.mq4](files/121432/The%20Dragon%20Hedge.mq4)


---

## Re: The Dragon Hedge

**trillionairemac** · Fri Oct 11, 2019 6:24 am

Hey is this an Expert Advisor or an Indicator?


---

## Re: The Dragon Hedge

**Apprentice** · Fri Oct 11, 2019 10:11 am

Expert Advisor


---

## Re: The Dragon Hedge

**ajc922** · Tue Nov 19, 2019 6:31 pm

How do you set it to only make sell trades? When I set the input "what trades should be taken" to sell it still takes buy trades. Can you help with this or add in an input that turns off buy trades?

Thank you!


---

## Re: The Dragon Hedge

**Apprentice** · Wed Nov 20, 2019 6:30 am

Your request is added to the development list.
Development reference 334.


---

## Re: The Dragon Hedge

**ajc922** · Wed Nov 20, 2019 11:59 pm

Apprentice, I'm having trouble getting this EA to make only sell trades with your inputs. Can you run it on your side and tell me if you are able to get a report back that has 0 buy orders please?


---

## Re: The Dragon Hedge

**Apprentice** · Thu Nov 21, 2019 12:43 pm

[The_Dragon_Hedge.mq4](files/129864/The_Dragon_Hedge.mq4)

Try this version.


---

## Re: The Dragon Hedge

**ajc922** · Thu Nov 21, 2019 3:40 pm

I tried the updated EA to see if it would stop any buy trades from happening and it still is returning buy trades even when the input "what trades should be taken" is set to sell. When you run the strategy in your tester and look at the report what is it saying next to "long positions won" for you?


---

## Re: The Dragon Hedge

**Apprentice** · Fri Nov 22, 2019 5:12 am

Your request is added to the development list.
Development reference 343.


---

## Re: The Dragon Hedge

**Apprentice** · Fri Nov 22, 2019 5:51 am

This parameter affects only the initial order. Long positions will be created after that. The whole idea of the EA in the reverting position side. By disabling buy or sell the whole EA will become useless.


---

## Re: The Dragon Hedge

**ajc922** · Fri Nov 22, 2019 4:07 pm

That makes sense. Thank you


---

## Re: The Dragon Hedge

**kkforex** · Mon May 01, 2023 10:41 am

Thanks for the EA, I tested it but it does not close the open trades at the end of day but keeps them open till next days trades are opened... am I missing any setting in EA?... Can we add the time for closing all trades eg London close. Or Close all trades when about 2/3 of ADR is reached?


---

## Re: The Dragon Hedge

**Apprentice** · Wed May 03, 2023 7:39 pm

We have added your request to the development list.
Development reference 399.
