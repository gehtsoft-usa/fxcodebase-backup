# VSA Volumeter

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=68395  
> Forum: 17 · Topic 68395 · 11 post(s)


---

## VSA Volumeter

**Apprentice** · Tue Apr 30, 2019 6:07 am

![EURUSD H1 (04-30-2019 1111).png](images/126058/EURUSD%20H1%20%2804-30-2019%201111%29.png)



Based on request.
[viewtopic.php?f=27&t=68381](https://fxcodebase.com/code/viewtopic.php?f=27&t=68381)
Is calculated as upVolume / (upVolume + downVolume) * 100;

 [VSA Volumeter.lua](files/126058/VSA%20Volumeter.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=68610](https://fxcodebase.com/code/viewtopic.php?f=38&t=68610)


---

## Re: VSA Volumeter

**Mohamed85** · Tue Apr 30, 2019 10:08 am

Thank yo so much Apprentice, the calculation procedure is exactly what is required to provide the value on a scale from 0 to 100, nice touch.

by checking the indicator behavior , it seems like it is not working as intended, I'll try to figure out the problem and come back to you...

Thanks again


---

## Re: VSA Volumeter

**Mohamed85** · Tue Apr 30, 2019 12:06 pm

There shouldn't be such an extreme spikes in the indicator unless there is extreme imbalance in the most recent wave,which is not the case here....probably that is the reason for the very high and very low readings posted by the indicator.

it might be the look back period and how it is shifted within the code, not sure actually.

can you please check it?

Regards.


---

## Re: VSA Volumeter

**Mohamed85** · Wed May 01, 2019 5:18 am

> **Mohamed85 wrote:**
> There shouldn't be such an extreme spikes in the indicator unless there is extreme imbalance in the most recent wave,which is not the case here....probably that is the reason for the very high and very low readings posted by the indicator.
>
> it might be the look back period and how it is shifted within the code, not sure actually.
>
> can you please check it?
>
> Regards.

Hi Apprentice, I kept checking the indicator behavior and found out that there is potential two fixes for it.
1. by changing the look back period to one week data, regardless of the time frame in use ... so I''ll imagine that at the moment the week starts the code shall calculate the previous week and as bar by bar from the new week introduced to the calculation, a bar by bar shall be removed from the previous week's oldest data ... and so on till the new week replace the previous one ....

by doing so, I think of limiting the disturbance occurring to the calculation due to the omission of the highly active times(Ex. NY session) when it is considered as old data and replacing it by low active times ( Ex. Asia session)when considered the new data.

2. in addition to the absolute values of 35 and 55, may be we can add another option which is relative difference, where if the indicator dropped a value theoretically between 15 and 20 from the most recent high that would give oversold condition (green), and the opposite if the indicator raised the same value from the most recent low that would be considered as overbought (red) otherwise neutral reading (blue)

below is an excerpt from the original wyckoff documents describing the tool this is just for info.

The Volumeter is a timing tool only. It indicates over bought and over sold conditions. The Volumeter measures a ratio of the volume in the intra-day buying waves relative to the volume in the intra-day selling waves over a five-day period. However, longer time periods can be used to provide longer term over bought and over sold indications.
Theoretically, the Volumeter reading of a market or an issue can range from zero to one hundred. However, neither of these extremes has ever been recorded or is likely to ever be recorded. A reading of zero would require five consecutive days during which there were only one intra-day wave per day and only down waves for each of the five days.
A reading of one hundred would require five consecutive days during which there were only one intra-day wave per days and only up waves for each of the five days. Decades of monitoring Volumeter readings have revealed that readings of 55 or higher should be viewed as indicating an overbought condition and that readings of 35 or lower should be viewed as indicating over sold conditions.
A reading of 44 indicates absolute neutrality. When an overbought condition is indicated, the price is vulnerable to down side progress. When an oversold condition is indicated, the price is vulnerable to upside progress. If an overbought or oversold condition on one day is replaced by a more over bought or more oversold condition the next day, the vulnerability of the price to a reaction or rally increases. The degree to which the market or an issue is over bought or oversold does not provide any indication as to the size of the reaction or rally that is being forecasted. These indications are provided by figure charts. Although over bought or oversold indications may develop at any time as the price action unfolds from day to day, those that develop when the price is in primary buying or selling positions are the most important.


---

## Re: VSA Volumeter

**Apprentice** · Wed May 01, 2019 6:10 am

Your request is added to the development list under Id Number 4628
Also, what if we simply add this ratio to ZigZag_Counter.lua as extra output label.


---

## Re: VSA Volumeter

**Mohamed85** · Wed May 01, 2019 6:38 am

Thank you so much for the follow up and support,
I think adding a value to the zigzag counter is a brilliant idea, that will save space on the chart for the price it self, I wish we could see it if possible.
but we may need to fix the spikes issue first, to make sure it reflects the correct values.

Regards.


---

## Re: VSA Volumeter

**Apprentice** · Tue May 07, 2019 7:20 am

Try this version.

 [VSA Volumeter.lua](files/126183/VSA%20Volumeter.lua)


---

## Re: VSA Volumeter

**Mohamed85** · Tue May 14, 2019 6:42 pm

Thank you so much Apprentice, and sorry for my late reply ... I were trying to test it thoroughly prior any comment ... now that I've found the same issue on the new version as well, so I went further to study the other variables and the one that I found has the most significant impact on the indicator behavior is the zigzag parameters ... 3,3,3 seems to be working pretty well, and I've used 1500 bar on the first version ... 38 - 50 overbought/ oversold values ... this combination seems working nice on most of the markets, however some markets shall needs minor adjustments.
below are samples using the mentioned parameters.

and thanks again for your continuous support.


---

## Re: VSA Volumeter

**JaxPacific** · Tue Jun 25, 2019 6:03 am

Is this available or possible in mt4?


---

## Re: VSA Volumeter

**Apprentice** · Wed Jun 26, 2019 4:20 am

Your request is added to the development list under Id Number 4748


---

## Re: VSA Volumeter

**Apprentice** · Fri Jun 28, 2019 4:01 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=68610](https://fxcodebase.com/code/viewtopic.php?f=38&t=68610)
