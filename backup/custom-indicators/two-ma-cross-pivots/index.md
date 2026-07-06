# Two MA Cross Pivots

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60057  
> Forum: 17 · Topic 60057 · 26 post(s)


---

## Two MA Cross Pivots

**Apprentice** · Tue Dec 03, 2013 7:59 am

![MA Cross Pivots.png](images/91325/MA%20Cross%20Pivots.png)



Indicator will draw vertical & horizontal line for each cross between two moving averages.

 [Two MA Cross Pivots.lua](files/91325/Two%20MA%20Cross%20Pivots.lua)

 [Two MA Cross Pivots (Stable).lua](files/91325/Two%20MA%20Cross%20Pivots%20%28Stable%29.lua)

The indicator was revised and updated


---

## Re: Two MA Cross Pivots

**speakinmymind** · Tue Dec 03, 2013 10:00 am

The lines seem to dissappear therefore not always capturing every cross. Color of lines seem to change as well.

These issues are especially present when scrolling in/out.

Thanks


---

## Re: Two MA Cross Pivots

**Apprentice** · Tue Dec 03, 2013 10:50 am

Until fix, u can use less precise, stable version.


---

## Re: Two MA Cross Pivots

**speakinmymind** · Tue Dec 03, 2013 7:49 pm

Thanks! Greatly appreciated!


---

## Re: Two MA Cross Pivots

**speakinmymind** · Wed Dec 04, 2013 12:15 am

When I use the pivot method that looks back a number of crosses I keep getting an error.

When I use the pivot method that uses on chart crosses everything is fine.

Please help, thanks!!


---

## Re: Two MA Cross Pivots

**Apprentice** · Wed Dec 04, 2013 1:12 am

As u i wrote until fix, use stable version.
Or redownload, to make sure u will have newest version of indicator.


---

## Re: Two MA Cross Pivots

**speakinmymind** · Wed Dec 04, 2013 1:59 am

> **Apprentice wrote:**
> As u i wrote until fix, use stable version.
> Or redownload, to make sure u will have newest version of indicator.

I tried redownloading the stable version again. The issue is that it seems to support a limited number of lookback crosses.

I would set a number, say 12 crosses, it will usually error.

If it does not error, then changing timeframes (for the chart not indicator) seems to cause it to error.


---

## Re: Two MA Cross Pivots

**speakinmymind** · Wed Dec 04, 2013 2:08 am

I have found the cause and fix!!!

This indicator needs all of the bars loaded required to complete your requested cross count.

If this indicator errors, scroll out as far as possible to load as many bars as you can, then open the indicator and hit ok again!

I guess a cosmetic request would be to make this automatic by having the indicator in loading mode somehow to prevent the error.

Thanks again!!! Great indicator!!


---

## Re: Two MA Cross Pivots

**evgeniyn** · Wed Dec 04, 2013 3:38 am

Thank you, Apprentice.
Some strange behavior of Pivot Line Style in stable version. Line style always shown as +1 to selected style (for example Solid shown as Dashed, Dashed as Dotted, etc).


---

## Re: Two MA Cross Pivots

**speakinmymind** · Thu Dec 05, 2013 1:47 pm

Could you please create a strategy that buys on the green line (ask price only) and sells at the red line (bid price only) for user defined MVA's and lookback crosses. Thanks!!


---

## Re: Two MA Cross Pivots

**speakinmymind** · Thu Dec 05, 2013 1:49 pm

Could you please create a strategy that buys on the green line (ask price only) and sells at the red line (bid price only) for user defined MVA's and lookback crosses. Thanks!!


---

## Re: Two MA Cross Pivots

**Apprentice** · Fri Dec 06, 2013 3:19 am

Basically this is a classic crossover strategy, of two moving averages.
On the forum you will find several implementations.


---

## Re: Two MA Cross Pivots

**speakinmymind** · Fri Dec 06, 2013 12:40 pm

Can you make it so that a user defined number of lookback crosses are a different color than the rest? Thanks!


---

## Re: Two MA Cross Pivots

**speakinmymind** · Sat Dec 07, 2013 5:10 pm

Can you please allow this to support more crosses? Say 1000?


---

## Re: Two MA Cross Pivots

**Apprentice** · Sun Dec 08, 2013 6:49 am

Limit increased to 1000.


---

## Re: Two MA Cross Pivots

**speakinmymind** · Thu Dec 12, 2013 8:59 am

Can you please add the ability to change the style of verticle lines.

Also, can you make it so that the horizontal lines do not extend backwards (into the past)?


---

## Re: Two MA Cross Pivots

**Apprentice** · Fri Dec 13, 2013 4:08 am

Pivot Line Style already exists, you can elaborate.


---

## Re: Two MA Cross Pivots

**speakinmymind** · Tue Dec 17, 2013 12:31 pm

Is it possible to have the most current darker and the further in the past the cross is the lines get lighter?


---

## Re: Two MA Cross Pivots

**Apprentice** · Wed Dec 18, 2013 3:51 pm

[Two MA Cross Pivots.lua](files/91598/Two%20MA%20Cross%20Pivots.lua)

Try This Version.
Line thickness is determined by position from the edges of the chart. (X-axis)


---

## Re: Two MA Cross Pivots

**speakinmymind** · Wed Dec 18, 2013 11:12 pm

Wow, great, thanks!


---

## Re: Two MA Cross Pivots

**Taskryr** · Sun Jun 29, 2014 8:35 pm

Is it possible to create a cross pivot indicator with Three MAs instead of two? Where long pivot has shortest MA on top and longest below and vice versa for short pivot?


---

## Re: Two MA Cross Pivots

**Apprentice** · Mon Jun 30, 2014 2:05 am

I'm not sure whether I understand.
Can the present this as with logic like this.
If ... Then ....

Also, Why u do not you used two instances of Two MA Cross Pivots?


---

## Re: Two MA Cross Pivots

**Taskryr** · Mon Jun 30, 2014 6:36 pm

I tried using the indicator twice, but when the 1st crosses the 2nd it is not necessarily the same as when the 2nd crosses the 3rd and the 1st can cross back over the 2nd before the 1st and 3rd align. . . then I just had a lot of confusion on my screen . . . anyway.

With Three MAs.

Pivot Up when the short MA is above the medium AND the medium MA is above the long MA so that all are in perfect alignment from top to bottom.

Pivot Down when the short MA is below the medium AND the medium MA is below the long in perfect alignment.

Thanks


---

## Re: Two MA Cross Pivots

**7510109079** · Mon Oct 06, 2014 1:11 pm

[https://www.dropbox.com/s/86kzq94ww45xenq/MA_Cross_Dot.lua?dl=0](https://www.dropbox.com/s/86kzq94ww45xenq/MA_Cross_Dot.lua?dl=0)

For anyone who is interested I had this one coded. It connects the MA cross of 2 MAs with the subsequent one and shows the no pips difference. Red pips are losses. Green pips are gains.

e.g. negative green pip no. is a gain that a short trade would have made


---

## Re: Two MA Cross Pivots

**thetruth** · Fri Nov 14, 2014 10:41 am

thaks for the indi
good job.


---

## Re: Two MA Cross Pivots

**Apprentice** · Tue Jun 27, 2017 4:18 am

The indicator was revised and updated.
