# Real Volume Tick Volume Ratio

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=62266  
> Forum: 17 · Topic 62266 · 20 post(s)


---

## Real Volume Tick Volume Ratio

**Apprentice** · Tue May 26, 2015 4:39 am

![Real Volume Tick volume Ratio.png](images/100660/Real%20Volume%20Tick%20volume%20Ratio.png)



Based on request.
[viewtopic.php?f=27&t=62258](https://fxcodebase.com/code/viewtopic.php?f=27&t=62258)
Ratio= Real Volume /Tick Volume
Central = MA of Ratio
Top = Central + STDEV
Bottom = Central - STDEV

 [Real Volume Tick volume Ratio.lua](files/100660/Real%20Volume%20Tick%20volume%20Ratio.lua)


---

## Re: Real Volume Tick Volume Ratio

**Pedrotorres** · Fri May 29, 2015 8:39 am

Hi Apprentice,

It makes marketscope crashing, I suppose because of division per zero when volume are loading before ticks. Could you fix it plz?


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Sun Jun 07, 2015 3:47 am

Division by zero is covered with adequate checks.

I believe handling of Real Volume can be a problem.
Without insight into the Real Volume indicator code can not say more.

Can u provide any error code or crash report.


---

## Re: Real Volume Tick Volume Ratio

**asedic** · Mon Aug 03, 2015 4:21 pm

Hi Appretince, thanks for this indicator.

Thank you.


---

## Re: Real Volume Tick Volume Ratio

**rtsayers** · Mon Aug 10, 2015 1:58 pm

Hi Apprentice would you be able to make the Hawkeye volume indicator?
 I uploaded in mt4 file format. I believe this is the right one?


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Wed Jul 19, 2017 8:13 am

The indicator was revised and updated.


---

## Re: Real Volume Tick Volume Ratio

**jaricarr** · Tue Aug 29, 2017 12:38 am

Hi Apprentice,

Looks like I don't have the Real Volume installed. Can you please make it downloadable.


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Tue Aug 29, 2017 3:40 am

Real volume is only available for some currency pairs.
For other currency pairs fxcm did not make real volume available.


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Fri Aug 31, 2018 5:14 am

The indicator was revised and updated.


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Tue Dec 11, 2018 1:46 pm

Hi there!

Could you make a MT4 version of this indicator?

Volume Ratio being the up volume divided by the down volume of each bar, and plot is as a line?

Thanks!


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Wed Dec 12, 2018 5:42 am

As far as I know.
MT4 only have one Volume type.
Therefore, we cannot compute this ratio.


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Wed Dec 12, 2018 11:19 am

> **Apprentice wrote:**
> As far as I know.
> MT4 only have one Volume type.
> Therefore, we cannot compute this ratio.

Check this indi, the same way he does here can be use to build the ratio indicator:

[https://www.mql5.com/en/market/product/21008](https://www.mql5.com/en/market/product/21008)


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Thu Dec 13, 2018 5:40 pm

The ratio I am looking for, actually is the up/down volume ratio, which can be accomplish dividing the up ticks by the down ticks of each bar. I think it is this way that they made that cumulative delta indi I posted in the other thread.


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Thu Dec 13, 2018 5:50 pm

This is what I mean, if you use this formula for forex it is possible to do what I asked:


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Fri Dec 14, 2018 1:42 pm

The above indicator, maybe I'll investigate.
The indicator in the article definitely NOT.
Will need up and down tick volume info.


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Fri Dec 14, 2018 2:01 pm

> **Apprentice wrote:**
> The above indicator, maybe I'll investigate.
> The indicator in the article definitely NOT.
> Will need up and down tick volume info.

I think that if you tweak that same cumulative delta indicator to divide the up ticks by the down ticks of each bar then you will get the up down ratio.


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Mon Dec 17, 2018 5:40 am

Unfortunately, I don't think it's possible to write this indicator.


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Mon Dec 17, 2018 12:47 pm

> **Apprentice wrote:**
> Unfortunately, I don't think it's possible to write this indicator.

Oh, but I don't understand.

Bear with me. If the cumulative delta indicator plots the difference between the up ticks and down ticks, like for example, if a bar has 100 ticks up volume and 80 ticks down volume the delta is +20, if the next bar has 80 ticks up volume and 100 ticks down volume, the delta is -20, this keeps getting plot as a line, right?

But what if instead of the difference, you just tweak the same indicator to divide the up ticks by the down ticks? So following the same example, a bar with 100 ticks up volume and 80 ticks down volume would have a ratio of 1.25, and the next bar (80 up 100 down) would have 0.8. This just needs to be plotted as a line.


---

## Re: Real Volume Tick Volume Ratio

**Apprentice** · Tue Dec 18, 2018 4:51 am

We only have info about the total tick.
The total ticks are the sum of up and down ticks.
Tick Volume = ABS(Up Tick+Down Tick)


---

## Re: Real Volume Tick Volume Ratio

**logicgate** · Tue Dec 18, 2018 7:34 am

> **Apprentice wrote:**
> We only have info about the total tick.
> The total ticks are the sum of up and down ticks.
> Tick Volume = ABS(Up Tick+Down Tick)

So how does that cumulative delta indi works? If it doesn't know the value of the up ticks and down ticks, how can it plot the difference? (Cumulative Delta = Up Tick - Down Tick)
