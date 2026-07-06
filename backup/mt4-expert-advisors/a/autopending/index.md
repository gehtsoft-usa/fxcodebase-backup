# AutoPending

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=75913  
> Forum: 38 · Topic 75913 · 5 post(s)


---

## AutoPending

**Apprentice** · Wed May 07, 2025 12:08 pm

Based on the request.
[https://fxcodebase.com/code/viewtopic.p ... 99#p159099](https://fxcodebase.com/code/viewtopic.php?f=38&p=159099#p159099)

 [AutoPending.mq5](files/159158/AutoPending.mq5)


---

## Re: AutoPending

**aloorkar** · Thu May 08, 2025 3:36 am

Not working .

Tried lot of time

but orders not taking after loss


---

## Re: AutoPending

**Apprentice** · Fri May 09, 2025 3:48 am

I remember this sentence from the original request:

"if trade in loss ea will place all other till stoploss ."

Here I meant that the pendings opened by the EA should continue running even if the original position has been closed. That’s also why I gave the pending orders the SL option.

Please clarify what you mean by "but orders not taking after loss."

Should I close the pendings and the running positions that resulted from the pendings? Or, if you open a new position, should it likewise generate new pending positions alongside the existing ones?


---

## Re: AutoPending

**aloorkar** · Fri May 09, 2025 8:32 am

Please see I given it with video
My Poor English making confusion so with video I tried to tell

Please see here

[https://drive.google.com/file/d/1bhXcDD ... p=drivesdk](https://drive.google.com/file/d/1bhXcDD8Xgz60s6kiRQdRO8U_lTWZNXf6/view?usp=drivesdk)


---

## Re: AutoPending

**Apprentice** · Wed May 14, 2025 12:41 pm

[AutoPending_v2.mq5](files/159237/AutoPending_v2.mq5)

Try this version.
