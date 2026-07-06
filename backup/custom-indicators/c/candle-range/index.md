# Candle Range

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61561  
> Forum: 17 · Topic 61561 · 30 post(s)


---

## Candle Range

**Apprentice** · Sun Nov 30, 2014 2:14 pm

![Candle Range.png](images/97430/Candle%20Range.png)



Candle Range will give Candle length, candle range in Pips.
You can choose between High / Low or Open / Close.

Moving average as a signal line is available.

 [Candle Range.lua](files/97430/Candle%20Range.lua)

 [Candle Range Alert.lua](files/97430/Candle%20Range%20Alert.lua)

 [Candle Range Envelop.lua](files/97430/Candle%20Range%20Envelop.lua)

MQ4/MT4 version is available here.
[viewtopic.php?f=38&t=64316](https://fxcodebase.com/code/viewtopic.php?f=38&t=64316)


---

## Re: Candle Range

**easytrading** · Sun Nov 30, 2014 6:04 pm

exactly that is what i wanted just with one more thing please,to give the Range candle the same color it has it in the price chart ,it will be perfect.

kindest regards.


---

## Re: Candle Range

**Apprentice** · Tue Dec 02, 2014 6:39 pm

Color Option Added.


---

## Re: Candle Range

**easytrading** · Wed Dec 03, 2014 12:18 am

well done Apprentice ..thanks a lot.


---

## Re: Candle Range

**fxcyberman** · Tue Dec 09, 2014 11:00 am

Why high / low and open / close has the same value ?


---

## Re: Candle Range

**Apprentice** · Fri Dec 12, 2014 4:35 am

Fixed. Please Re-Download.


---

## Re: Candle Range

**Apprentice** · Fri Aug 26, 2016 6:21 am

Candle Range Alert.lua added.


---

## Re: Candle Range

**daniel.kovacik** · Fri Aug 26, 2016 7:43 am

Hi,

I was wondering if you can apply there also composite profile?


---

## Re: Candle Range

**Apprentice** · Mon Aug 29, 2016 3:12 am

Please clarify,
Add alert to composite profile?


---

## Re: Candle Range

**daniel.kovacik** · Wed Sep 28, 2016 9:55 am

Hi,

sorry for delay answer. I mean if composite profile can be than indi window... NOT IN CHART!!

It could be also dynamic, so it ll change for every candle N bars back... Maybe better if this profile would be possible to apply individually into these indicators, for volume etc...

Thanks in advance
Regards,
DK


---

## Re: Candle Range

**Apprentice** · Wed Sep 28, 2016 3:50 pm

Your request is added to the development list, Under Id Number 3640
 If someone is interested to do this task, please contact me.


---

## Re: Candle Range

**shortbutlucky** · Mon Oct 10, 2016 1:15 pm

Hi Apprentice,

This is an awesome indicator. I'm trying to recall the data in one of my strategies, but it always seems to show up as nil. Any guidance?

> in Prepare()...
> Average_Bar_Change = core.indicators:create("Candle Range", SRC, "Open/Close", "LWMA", Check_Period);
>
> in ExtUpdate()...
> Average_Bar_Change:update();
> Average_Bar_Change_DATA = Average_Bar_Change.DATA;

-Robby


---

## Re: Candle Range

**Apprentice** · Tue Oct 11, 2016 3:11 am

Try this
Average_Bar_Change_DATA = Average_Bar_Change.DATA[period];
or
Average_Bar_Change_DATA = Average_Bar_Change.DATA[ Average_Bar_Change.DATA:size()-1];


---

## Re: Candle Range

**chipsoft** · Fri Oct 14, 2016 9:16 am

This is fantastic indicator. Kindly add up the facility to draw % of Average above and below the Average line. e.g. Suppose I want to have +150% and -75% envelop around Average line so this indicator have that option. Also along with this kindly change the color of the bars that satisfy those parameters.
Kindly develop the same indicator for MT4 also.

Regards


---

## Re: Candle Range

**Apprentice** · Tue Oct 18, 2016 7:12 am

Candle Range Envelop.lua added.


---

## Re: Candle Range

**chipsoft** · Wed Dec 14, 2016 2:25 pm

Hi Apprentice,
Kindly make some amendment in Candle Range Envelop indicator.

1. Kindly provide different selection options for Up% and down %. In the present form if I select 50% then the envelop will become 50% above and below so equal % added and subtracted from the Signal value. Kindly amend formula so if I need x% for and y% for lower then it will calculate as: the
upper envelop line= Mean+ x%
Lower envelop line= Mean-y%
Hope you understand

2. Kindly also change the colour options also. All the bars that closes above upper envelop line has one colour say Blue. All the bars closes below lower envelop line has one color say: Pink and remaining bars has one colour say Grey.

Thanks


---

## Re: Candle Range

**Apprentice** · Fri Dec 16, 2016 5:16 am

Try it now.


---

## Re: Candle Range

**chipsoft** · Sun Jan 01, 2017 7:47 pm

Thanks very much apprentice. Great Job.
Another request...kindly convert this indicator for MT4 also.

Regards


---

## Re: Candle Range

**chipsoft** · Mon Jan 02, 2017 9:02 am

Hi apprentice, i am requesting for further one more addition in the Candle range envelop indicator. Kindly add N number of periods to calculate the candle range. What this mean is...if I select N=5 this mean I want indicator to calculate previous 5 period range including the current period for calculations of its results. Hope you understand and make this addition to this powerful indicator.

Regards


---

## Re: Candle Range

**Apprentice** · Sat Jan 07, 2017 8:37 am

Your request is added to the development list, Under Id Number 3707
 If someone is interested to do this task, please contact me.

Will this be presented as moving average of last N periods.
Or as Candle (High / Low / Open / Close) of last N periods.


---

## Re: Candle Range

**chipsoft** · Wed Jan 18, 2017 4:25 am

Hi Apprentice,

As per your quire regarding my request under ID Number 3707, this is the rolling candle range of last N periods starting from current period. Suppose I selected N=5 and Average period is 10 this mean I want the indicator to consider 5 days range as one candle and then taking the rolling back average of last 10 candles of which each candle assume to have range equal to rolling back 5 days. Basically N is consolidating range of defined number of candles. Hope you understand if not kindly ask. Kindly also convert this indicator to MT4 as well.
Regards


---

## Re: Candle Range

**Apprentice** · Thu Jan 19, 2017 3:38 pm

"Range Period" Added.


---

## Re: Candle Range

**chipsoft** · Tue Jan 31, 2017 12:42 pm

Thanks very much Apprentice, test working very well. Last amendment to candle envelop indicator, just add one more option for the mean line in the envelop. Now suppose we are calculating mean with 20 periods and it is showing in the indicator. Kindly add another option to add another mean line, say If I want to see where is 10 period average on the indicator then it will pop up there.
Thanks


---

## Re: Candle Range

**Apprentice** · Thu Feb 02, 2017 1:05 pm

Try it now.


---

## Re: Candle Range

**chipsoft** · Tue Feb 07, 2017 5:57 am

Thanks apprentice


---

## Re: Candle Range

**Apprentice** · Mon Feb 05, 2018 8:15 am

The Indicator was revised and updated.


---

## Re: Candle Range

**chipsoft** · Wed Apr 11, 2018 12:32 pm

Hi Apprentice,

Could I have extra option for this great indicator:
1.Kindly add volume option. So it mean instead of candle range we have candle volume as input and other things same.
Regards


---

## Re: Candle Range

**Apprentice** · Thu Apr 12, 2018 4:30 am

Try it now.


---

## Re: Candle Range

**chipsoft** · Thu Apr 12, 2018 6:50 am

Thanks apprentice...there is one error, the selection of Range period is not working with volume option. e.g if I select 5 day range the indicator should select 5 days of volume...I think it is only calculating 1 day volume. Kindly check...
Regards..


---

## Re: Candle Range

**Apprentice** · Fri Apr 13, 2018 6:07 am

Try it now.
