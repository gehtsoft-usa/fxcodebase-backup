# Volume Divergence Markers

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61802  
> Forum: 17 · Topic 61802 · 36 post(s)


---

## Volume Divergence Markers

**Apprentice** · Tue Feb 10, 2015 1:46 pm

![Volume Divergence Markers.png](images/98568/Volume%20Divergence%20Markers.png)



 [Volume Divergence Markers.lua](files/98568/Volume%20Divergence%20Markers.lua)


---

## Re: Volume Divergence Markers

**daniel.kovacik** · Wed Feb 11, 2015 1:48 am

Hi,

how should we interpret this tool?
By the way, its a good idea... Can be added there bullish and bearish divergence?
Its probably based on volume Did you try to do this with transactions indicator from fxcmapps.com?

I look forward to other versions of volume divergences...

Thanks
DK


---

## Re: Volume Divergence Markers

**Apprentice** · Wed Feb 11, 2015 4:00 am

For now, I do not plan to use the real volume,
It is now offered through an external server.
Not by regular FXCM, price server.

So, you all, write to your congressman, to offer real volume data via TS.


---

## Re: Volume Divergence Markers

**SANTOSH** · Tue Apr 21, 2015 12:56 am

![volume div marker edited for buy.png](images/99916/volume%20div%20marker%20edited%20for%20buy.png)



 

![volume div marker edited for sell.png](images/99916/volume%20div%20marker%20edited%20for%20sell.png)



hi ,
did changes in the code , to make it direction bias to flag bull and bear signals !!
Can apprentice look into it , and confirm the same ?
THANKS,
SANTOSH .

 [Volume Divergence Markers1.2.lua](files/99916/Volume%20Divergence%20Markers1.2.lua)


---

## Re: Volume Divergence Markers

**Apprentice** · Tue Apr 21, 2015 2:07 am

Affirmative. The direction is confirmed by Volume direction bias.


---

## Re: Volume Divergence Markers

**SANTOSH** · Tue Apr 21, 2015 12:06 pm

Thanks for the confirmation , apprentice!


---

## Re: Volume Divergence Markers

**SANTOSH** · Wed Apr 22, 2015 8:02 am

can a strategy be build for the same?


---

## Re: Volume Divergence Markers

**Apprentice** · Thu Apr 23, 2015 4:56 am

Requested can be found here.
[viewtopic.php?f=31&t=62138](https://fxcodebase.com/code/viewtopic.php?f=31&t=62138)


---

## Re: Volume Divergence Markers

**Apprentice** · Wed Oct 03, 2018 5:47 am

The indicator was revised and updated.


---

## Re: Volume Divergence Markers

**SANTOSH** · Thu Apr 09, 2020 3:38 am

> **Apprentice wrote:**
> For now, I do not plan to use the real volume,
> It is now offered through an external server.
> Not by regular FXCM, price server.
>
> So, you all, write to your congressman, to offer real volume data via TS.

Can you use the real volume now ?
As fxcm supports real volume for 14 pairs in TS now !


---

## Re: Volume Divergence Markers

**SANTOSH** · Thu Apr 09, 2020 3:39 am

> **Apprentice wrote:**
> For now, I do not plan to use the real volume,
> It is now offered through an external server.
> Not by regular FXCM, price server.
>
> So, you all, write to your congressman, to offer real volume data via TS.

Can you use the real volume now ?
As fxcm supports real volume for 14 pairs in TS now !


---

## Re: Volume Divergence Markers

**Apprentice** · Thu Apr 09, 2020 4:58 am

Your request is added to the development list.
Development reference 1030.


---

## Re: Volume Divergence Markers

**Apprentice** · Fri Apr 10, 2020 6:47 am

![EURUSD D1 (04-10-2020 1156).png](images/132743/EURUSD%20D1%20%2804-10-2020%201156%29.png)



You need to add Real Volume on the chart.

 [Real Volume Divergence Markers.lua](files/132743/Real%20Volume%20Divergence%20Markers.lua)


---

## Re: Volume Divergence Markers

**SANTOSH** · Fri Apr 10, 2020 2:59 pm

Dear Apprentice ,
Can you add the stream of **Net Volume Of Directional Real volume indicator .**
This will easily identify the following :

1. Net volume = Positive , Price = Bearish bar , We get upward green arrow .
2. Net volume = Negative , Price = Bullish bar , We get downward red arrow .

Can you add the above functionality with an alert ?

Regards ,
Santosh


---

## Re: Volume Divergence Markers

**SANTOSH** · Sun Apr 12, 2020 7:31 am

> **SANTOSH wrote:**
> Dear Apprentice ,
> Can you add the stream of **Net Volume Of Directional Real volume indicator .**
> This will easily identify the following :
>
> 1. Net volume = Positive , Price = Bearish bar , We get upward green arrow .
> 2. Net volume = Negative , Price = Bullish bar , We get downward red arrow .
>
> Can you add the above functionality with an alert ?
>
>
> Regards ,
> Santosh

Dear Apprentice,
Any updates on this?

Regards ,
Santosh


---

## Re: Volume Divergence Markers

**Apprentice** · Sun Apr 12, 2020 9:39 am

I do NOT understand your request,
add arrows to Net Volume Of Directional Real volume indicator.
How we calculate Net Volume Of Directional Real volume indicator.


---

## Re: Volume Divergence Markers

**SANTOSH** · Sun Apr 12, 2020 10:45 am

> **Apprentice wrote:**
> I do NOT understand your request,
> add arrows to Net Volume Of Directional Real volume indicator.
> How we calculate Net Volume Of Directional Real volume indicator.

Firstly , Net volume calculation is an inbuilt indicator in Directional real volume indicator .
Net volume = Buy Volume- Sell volume

1. Net volume = Positive , Price = Bearish bar , We get upward green arrow .

**Example given in below picture file**
2. Net volume = Negative , Price = Bullish bar , We get downward red arrow -


---

## Re: Volume Divergence Markers

**Apprentice** · Mon Apr 13, 2020 3:50 am

Your request is added to the development list.
Development reference 1061.


---

## Re: Volume Divergence Markers

**SANTOSH** · Thu Apr 16, 2020 6:29 am

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 1061.

Any recent update in the development above ?

Regards,
Santosh Sahu.


---

## Re: Volume Divergence Markers

**Apprentice** · Fri Apr 17, 2020 4:39 am

![USDJPY H1 (04-17-2020 0948).png](images/132907/USDJPY%20H1%20%2804-17-2020%200948%29.png)



 [Directional Real Volume Delta.lua](files/132907/Directional%20Real%20Volume%20Delta.lua)

Something like this?


---

## Re: Volume Divergence Markers

**SANTOSH** · Fri Apr 17, 2020 8:40 am

> **Apprentice wrote:**
>
>
> The attachment **USDJPY H1 (04-17-2020 0948).png** is no longer available
>
>
>
>
> The attachment **USDJPY H1 (04-17-2020 0948).png** is no longer available
>
>
>
>
> Something like this?

Its still bugged most of the times .
Kindly check the pcitures that i made for more clarification .

Regards,
SANTOSH SAHU .


---

## Re: Volume Divergence Markers

**Apprentice** · Sat Apr 18, 2020 5:48 am

Your request is added to the development list.
Development reference 1084.

Can we skype tomorrow?

A) Arrow will be added only if we have divergence
1. Up Arrow
Price is down, Volume is up
2. Down Arrow
Price is up, Volume is down
B) To add Live/End of turn signal option
C) Add divergence threshold
Will only give a signal if we have...
abs((Volume * pip_size) - abs (open-close )) > divergence threshold


---

## Re: Volume Divergence Markers

**Apprentice** · Mon Apr 20, 2020 7:37 am

[Directional Real Volume Delta Divergence.lua](files/132977/Directional%20Real%20Volume%20Delta%20Divergence.lua)

Try this version.

About C.
I don't see any reason to compare Volume with a price. The difference in price could be 0.0005-0.0010 and the volume could be as high as 1 000 000. It's uncomparable units.


---

## Re: Volume Divergence Markers

**Apprentice** · Mon Apr 20, 2020 9:36 am

Divergence_Threshold option added.


---

## Re: Volume Divergence Markers

**SANTOSH** · Mon Apr 20, 2020 10:48 am

> **Apprentice wrote:**
> Divergence_Threshold option added.

Check the signal legitmacy


---

## Re: Volume Divergence Markers

**Apprentice** · Tue Apr 21, 2020 9:11 am

Your request is added to the development list.
Development reference 1099.


---

## Re: Volume Divergence Markers

**Apprentice** · Wed Apr 22, 2020 10:56 am

[Directional Real Volume Delta Divergence.lua](files/133056/Directional%20Real%20Volume%20Delta%20Divergence.lua)

Something like this?


---

## Re: Volume Divergence Markers

**SANTOSH** · Wed Apr 22, 2020 12:04 pm

> **Apprentice wrote:**
>
>
> The attachment **Directional Real Volume Delta Divergence.lua** is no longer available
>
>
> Something like this?

Dear Apprentice ,
Nice Work .
The alerts are perfect Aligned at +1p when used End of turn .
**But , it still misses a few alert
Have attached picture .**

Regards ,
Santosh Sahu .


---

## Re: Volume Divergence Markers

**SANTOSH** · Fri Apr 24, 2020 7:49 am

Dear Apprentice ,
Any updates on fixing the missed alerts ??

Regards ,
Santosh Sahu.


---

## Re: Volume Divergence Markers

**Apprentice** · Fri Apr 24, 2020 12:48 pm

Your request is added to the development list.
Development reference 1122.


---

## Re: Volume Divergence Markers

**Apprentice** · Mon Apr 27, 2020 4:07 am

[Directional Real Volume Delta Divergence.lua](files/133223/Directional%20Real%20Volume%20Delta%20Divergence.lua)

Try this version.


---

## Re: Volume Divergence Markers

**SANTOSH** · Mon Apr 27, 2020 11:08 am

> **Apprentice wrote:**
>
>
> Directional Real Volume Delta Divergence.lua
>
>
> Try this version.

Great Job Mario,
You finally nailed it .
Appreciate your hard and consistent work


---

## Re: Volume Divergence Markers

**NdedaFX** · Tue Apr 28, 2020 1:35 am

Can we have this in MT4?


---

## Re: Volume Divergence Markers

**Apprentice** · Tue Apr 28, 2020 9:49 am

Your request is added to the development list.
Development reference 1161.


---

## Re: Volume Divergence Markers

**Apprentice** · Thu Apr 30, 2020 5:22 am

MT4 doesn't have DIRECTIONAL_REAL_VOLUME.


---

## Re: Volume Divergence Markers

**solefish1991** · Thu Mar 11, 2021 4:56 am

Does your backtesting using this indicator show real volume or tick volume to be more profitable?
Real volume would only be the real volume present on FXCM's book, no? My understanding is that tick volume, while not having the benefit of showing the number of individual contracts traded at each tick, does have the benefit that it sees more of the market.
