# RangeVolume Ratio

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60274  
> Forum: 17 · Topic 60274 · 8 post(s)


---

## RangeVolume Ratio

**Apprentice** · Tue Feb 04, 2014 3:50 am

![RangeVolumeRatio.png](images/92473/RangeVolumeRatio.png)



As requested.
[viewtopic.php?f=17&t=60273](https://fxcodebase.com/code/viewtopic.php?f=17&t=60273)

RangeVolume Ratio
"High/Low" Method
(high-low)/volume
"Open/Close" Method
abs(open-close)/volume

 [RangeVolumeRatio.lua](files/92473/RangeVolumeRatio.lua)

 [Shmen Resistance.lua](files/92473/Shmen%20Resistance.lua)

The indicator was revised and updated


---

## Re: RangeVolume Ratio

**Patrick Sweet** · Tue Feb 04, 2014 3:23 pm

Thank you.
for those who are interested.

Shman Resistance indicator measures the ratio of volume to the bar price range
Measures path of least (or most) resistance by comparing the bars range (Open to Close OR High to Low) to the volume. It can also give the reverse ratio (Volume divided by range instead of range divided by Volume) to get the path of most resistance. The two Min settings are just to filter out unusual spikes from 0 to small volume or range days. The RPath bool is for changing from a "Path of Least Resistance indi" to a "Path of Most rRsistance indi."

The above text came from the web. I mistakenly included (but now deleted) a paragraph were the person said 'he did it himself' which may have given others the impression I did this. WISH I COULD NOT did not and unfortunately cannot.

Thank you for getting this up so fast your coding is superb!

Patrick


---

## Re: RangeVolume Ratio

**Patrick Sweet** · Wed Feb 05, 2014 7:31 am

Hi
Bug? When I leave Shmen running in a template in MScope, change to another template for another pair, and then come back to the first one, I have to manually update Shmen.
It seems to stop drawing when you switch views/templates.

Can that be fixed?
Patrick


---

## Re: RangeVolume Ratio

**Apprentice** · Wed Feb 05, 2014 2:58 pm

Please Re-Download.


---

## Re: RangeVolume Ratio

**Alexander.Gettinger** · Thu Jun 05, 2014 4:39 pm

MQL4 version of Range Volume Ratio oscillator and Shmen Resistance oscillator: [viewtopic.php?f=38&t=60790](https://fxcodebase.com/code/viewtopic.php?f=38&t=60790).


---

## Re: RangeVolume Ratio

**Apprentice** · Mon Jun 19, 2017 8:05 am

The indicator was revised and updated.


---

## Re: RangeVolume Ratio

**Forexcheckup** · Thu May 02, 2019 3:35 pm

Hi
on the volume ratio bars
Would it be possible to make volume ratio bars blue if the price candle is an up bar and the volume bars red if price bar is is down candle. Thank you


---

## Re: RangeVolume Ratio

**Apprentice** · Fri May 03, 2019 7:12 am

Try it now.
