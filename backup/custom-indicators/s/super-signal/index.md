# Super Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66909  
> Forum: 17 · Topic 66909 · 10 post(s)


---

## Super Signal

**Apprentice** · Sat Nov 10, 2018 8:09 am

![EURUSD H6 (04-02-2018 0427).png](images/122039/EURUSD%20H6%20%2804-02-2018%200427%29.png)



Based on request.
[viewtopic.php?f=27&t=66906](https://fxcodebase.com/code/viewtopic.php?f=27&t=66906)

 [Super Signal.lua](files/122039/Super%20Signal.lua)

**Note, the indicator have half period forwards insight.**


---

## Re: Super Signal

**papynou34** · Sun Nov 11, 2018 9:22 am

Hello,
Thanks for the indicator.
Is it possible to have a stratégy based upon this indicator?


---

## Re: Super Signal

**mulligan** · Mon Nov 12, 2018 12:38 am

Having a little problem with the indicator. When I bring up a chart, everything looks great. Going forward in time, that being several hours on a 1 minute chart, no signal appears on the chart. Also, no sound or dialog box. If I refresh the indicator, everything shows up on the chart nicely. You help is appreciated.


---

## Re: Super Signal

**Apprentice** · Mon Nov 12, 2018 6:54 am

Try it now.


---

## Re: Super Signal

**Apprentice** · Mon Nov 12, 2018 6:56 am

> Is it possible to have a stratégy based upon this indicator?

You have to be aware, the delay will be significant.
Between 7 and 10 candles with default settings.

Can you provide strategy rules?


---

## Re: Super Signal

**papynou34** · Mon Nov 12, 2018 8:54 am

Hello Apprentice,
I 'll send you the stratégy as soon as i perfectly understant the indicator.
Right now, it seems to me, that the alerte do not work (no dialog box and no sound).


---

## Re: Super Signal

**mulligan** · Mon Nov 12, 2018 11:14 am

The signals on the chart are showing up nicely. Could you please check the sound and dialog box functions. They don't seem to be working. Thanks very much.


---

## Re: Super Signal

**Apprentice** · Mon Nov 12, 2018 5:10 pm

Fixed.


---

## Re: Super Signal

**SANTOSH** · Tue Nov 13, 2018 6:11 am

Hello Apprentice ,

Is it repainting or delaying ?

Regards ,
Santosh Sahu .


---

## Re: Super Signal

**Apprentice** · Tue Nov 13, 2018 6:42 am

Both.
It uses Period/2 candles of future price action.
Great to historian analysis poor to trade signal.
