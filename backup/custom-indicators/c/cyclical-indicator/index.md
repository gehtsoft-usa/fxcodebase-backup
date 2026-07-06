# Cyclical Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=33582  
> Forum: 17 · Topic 33582 · 27 post(s)


---

## Cyclical Indicator

**Apprentice** · Wed Mar 20, 2013 3:13 am

![Capture (1).PNG](images/56999/Capture%20%281%29.PNG)



 [cyclical indicator.lua](files/56999/cyclical%20indicator.lua)

 [Smoothed CI.lua](files/56999/Smoothed%20CI.lua)

Please Install CMA.bin for this one
[viewtopic.php?f=17&t=24476](https://fxcodebase.com/code/viewtopic.php?f=17&t=24476)


---

## Re: Cyclical Indicator

**mulligan** · Wed Mar 20, 2013 9:26 am

Great indicator. Is it possible to get the up and down color option added? Thanks, as always, for your work.


---

## Re: Cyclical Indicator

**juju1024** · Wed Mar 20, 2013 5:40 pm

Thank you for your great work


---

## Re: Cyclical Indicator

**Apprentice** · Thu Mar 21, 2013 5:22 am

Style Options Added.


---

## Re: Cyclical Indicator

**lucmat** · Thu Mar 21, 2013 6:34 am

Hi all
I don't if it's only my problem, but this indicator draws a readable line only with "method 1";
with other method the output lines are too erratic.
I've tried with old and beta version of TS....
Could you give me some feedback?

Thanks

Lucmat


---

## Re: Cyclical Indicator

**Apprentice** · Thu Mar 21, 2013 7:08 am

This behavior is expected.


---

## Re: Cyclical Indicator

**lucmat** · Thu Mar 21, 2013 7:15 am

Dear Apprentice
do you think it's possible to smooth these erratic lines with centered moving average?
Thanks
Lucmat


---

## Re: Cyclical Indicator

**Apprentice** · Sat Mar 23, 2013 5:22 am

Smoothed version Added.
As for CMA.
In fact, the CMA will add even more noise.
You can test this by Adding this code at line 32

Code: [Select all](https://fxcodebase.com/code/)
`indicator.parameters: addStringAlternative ("MAMethod", "CMA", "CMA", "CMA");`


---

## Re: Cyclical Indicator

**juju1024** · Sun Mar 24, 2013 9:57 pm

hi,

Is it possible to get choice dynamic or static mode option added please ?

Cordialy


---

## Re: Cyclical Indicator

**Apprentice** · Mon Mar 25, 2013 5:37 pm

Your request has been added to the development list.


---

## Re: Cyclical Indicator

**StefPasc** · Wed Apr 03, 2013 10:39 pm

Dear Apprentice

can you please give me some reference for the cyclical indicator ?
For example how it works, some basic idea of how it smooths data or maybe a link to read more
iformation about it.
Thanks in advance


---

## Re: Cyclical Indicator

**Apprentice** · Thu Apr 04, 2013 5:27 am

This indicator was written, by requesting.
[viewtopic.php?f=27&t=19419&hilit=Cyclical+Indicator](https://fxcodebase.com/code/viewtopic.php?f=27&t=19419&hilit=Cyclical+Indicator)
Maybe lucmat has more information.
lucmat, can you clarify.

I can tell you this.
Cyclical Indicator uses the CMA moving average.
It brings a bit of cheating in equation.
CMA use future data points.
Cyclical Indicator will try to show in which phase of the cycle we are currently.


---

## Re: Cyclical Indicator

**lucmat** · Thu Apr 04, 2013 5:32 pm

> **StefPasc wrote:**
> Dear Apprentice
>
> can you please give me some reference for the cyclical indicator ?
> For example how it works, some basic idea of how it smooths data or maybe a link to read more
> iformation about it.
> Thanks in advance

Dear StefPasc
this indicator try to draw a cycle by making difference of two centered moving averages.
In link posted by Apprentice you should learn how it is build in excel and other information, while indicator in .lua has still some problems.
It smooths data with centered moving averages, so be careful because it repaints!
Don't hesitate if you want to know other.

Lucmat


---

## Re: Cyclical Indicator

**lucmat** · Thu Apr 04, 2013 5:35 pm

> **Apprentice wrote:**
> Smoothed version Added.
> As for CMA.
> In fact, the CMA will add even more noise.
> You can test this by Adding this code at line 32
>
>
> Code: [Select all](https://fxcodebase.com/code/)
> `indicator.parameters: addStringAlternative ("MAMethod", "CMA", "CMA", "CMA");`

Dear Apprentice,
I've tried so many solution but I shouldn't be able to recreate the same indicator like excel one.
Patience!!!
Thanks

Lucmat


---

## Re: Cyclical Indicator

**StefPasc** · Tue Apr 09, 2013 12:08 am

Dear Apprentice and Lucmat

thank you for the information provided
The indicator seems very promising despite the repainting issue.
Thanks again


---

## Re: Cyclical Indicator

**lucmat** · Tue Jun 11, 2013 4:12 am

Hey Apprentice
May you translate this indicator in .lua Language?

Thanks in advance for your help!

Lucmat


---

## Re: Cyclical Indicator

**Apprentice** · Wed Jun 12, 2013 6:43 am

Your request is added to the development list.


---

## Re: Cyclical Indicator

**lucmat** · Thu Jun 20, 2013 9:46 am

> **lucmat wrote:**
> Hey Apprentice
> May you translate this indicator in .lua Language?
>
> Thanks in advance for your help!
>
> Lucmat

This indicator repaints
...so be careful...
use it in conjunction with other indicator...
Thanks

Lucmat


---

## Re: Cyclical Indicator

**Jamwal Suriya** · Thu Jun 27, 2013 1:12 am

Great indicator. Is it possible to get the up and down color option added?
Thanks, as always, for your work.


---

## Re: Cyclical Indicator

**Apprentice** · Fri Jun 28, 2013 2:40 am

I do not understand your intention.
Can you explain in more detail.
Now we have, Line Up / Down Line Color option.


---

## Re: Cyclical Indicator

**mjf1288** · Tue Sep 17, 2013 9:29 pm

It looks like there is some issue with calculating the last bar. The last bar always seems to be showing a bad value. Is there any way this could be fixed? Thanks


---

## Re: Cyclical Indicator

**transformer** · Wed Sep 18, 2013 9:13 am

can you create a simple strategy based on this indicator:

buy level:0
sell level:0

buy: cyclical indicator cross over buy level
sell cyclical indicaor cross under sell level


---

## Re: Cyclical Indicator

**Tigre3** · Wed Sep 18, 2013 9:24 am

> **mjf1288 wrote:**
> It looks like there is some issue with calculating the last bar. The last bar always seems to be showing a bad value. Is there any way this could be fixed? Thanks

I use cyclical analysis too.. try to use a stochastic set:

Periods: 0,5 of cyclie
%K: 0,25 of cycle.
%D isn't necessary.

As you can see it has the same form (you can calculate the momentum too.. same results) but it also shows divergence.

Try it!


---

## Re: Cyclical Indicator

**Apprentice** · Wed Sep 18, 2013 12:11 pm

Your request is added to the development list.


---

## Re: Cyclical Indicator

**mjf1288** · Wed Sep 18, 2013 3:31 pm

> **transformer wrote:**
> can you create a simple strategy based on this indicator:
>
>
> buy level:0
> sell level:0
>
>
> buy: cyclical indicator cross over buy level
> sell cyclical indicaor cross under sell level

I have proposed a strategy with cyclical and William Vix Fix. Been using it discretionary, but I need to automate it. Here is the request that I put in. [viewtopic.php?f=27&t=59414](https://fxcodebase.com/code/viewtopic.php?f=27&t=59414)


---

## Re: Cyclical Indicator

**Apprentice** · Sun Oct 07, 2018 9:23 am

The indicator was revised and updated.


---

## Re: Cyclical Indicator

**Alexander.Gettinger** · Wed Jan 16, 2019 9:25 pm

> **lucmat wrote:**
> Hey Apprentice
> May you translate this indicator in .lua Language?
>
> Thanks in advance for your help!
>
> Lucmat

Please try this indicator:

 [SMA_Centered_Oscillator.lua](files/123382/SMA_Centered_Oscillator.lua)
