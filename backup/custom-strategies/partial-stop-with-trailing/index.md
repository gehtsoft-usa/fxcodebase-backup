# Partial Stop with Trailing

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70044  
> Forum: 31 · Topic 70044 · 7 post(s)


---

## Partial Stop with Trailing

**Apprentice** · Fri Jun 19, 2020 5:06 am

Based on request.
[viewtopic.php?f=27&t=70035](https://fxcodebase.com/code/viewtopic.php?f=27&t=70035)

 [Partial Stop with Trailing.lua](files/135107/Partial%20Stop%20with%20Trailing.lua)


---

## Re: Partial Stop with Trailing

**7200100470** · Mon Jun 22, 2020 5:59 pm

I tried it on 7 different opened positions ... Maybe there is something I did not catch.
it asks me for which trade to activate it. .... I selected it
then it asks me for which opened position to activate it .... I selected the same trade as above .... and I pointed to the exact trade.... therefore, I don't understand the difference of the two.

Then I tried to fix the 1) "trailing start" and the 2) "trailing stop".... I guess these are:
1) the number of PIPS to be touched before the trailing stop is activated
2) the number of PIPS of the trailing...

after starting this strategy, .... nothing happened when the condition 1) was met.

I mean that the trailing start condition was met, but no close of the operation was carried out when the stop point was also met....
I am not sure that this work, or maybe I did something wrong,

Can you please check?

Thanks

Stefano


---

## Re: Partial Stop with Trailing

**Apprentice** · Wed Jun 24, 2020 4:23 am

Your request is added to the development list.
Development reference 1547.


---

## Re: Partial Stop with Trailing

**Apprentice** · Wed Jun 24, 2020 5:33 am

It does trailing only. The selected trade should be with a stop.


---

## Re: Partial Stop with Trailing

**7200100470** · Thu Jun 25, 2020 3:10 am

Dead Apprentice,
So it means that if I want to use it on a trade not having a settled "stop", first I have to settle such a stop and then define the trailing activity with this strategy ? And what if the trade already has a trailing stop defined?

I am not sure if I understand exactly how to use it.

There is also the possibility to activate this strategy to "all trades"; will it work only on trades with a predefined stop and how ?
Thanks again for the clarifications, probably with an example it might be clearer for me.

Regards


---

## Re: Partial Stop with Trailing

**Apprentice** · Thu Jun 25, 2020 4:29 am

Your request is added to the development list.
Development reference 1554.


---

## Re: Partial Stop with Trailing

**Apprentice** · Thu Jun 25, 2020 5:40 am

The strategy does not know where to put the stop if there is no any.
It only moves it.
The price moved n pips into the profit -> stop moved n pips. That is why it works only with trades with a stop. There will be a conflict if you already have a trailing defined.

Basically, the strategy will "fight" with the server and it'll behave strangely. The stop will move back and forward.
