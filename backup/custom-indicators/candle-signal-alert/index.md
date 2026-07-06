# Candle Signal Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63817  
> Forum: 17 · Topic 63817 · 6 post(s)


---

## Candle Signal Alert

**Apprentice** · Fri Aug 26, 2016 10:17 am

![EURUSD m1 (08-26-2016 1629).png](images/107853/EURUSD%20m1%20%2808-26-2016%201629%29.png)



Based on.
[viewtopic.php?f=27&t=63538#p106499](https://fxcodebase.com/code/viewtopic.php?f=27&t=63538#p106499)

Up
Close[-2] < Open [-2]
Close[-1] < Open [-1]
Close[0] > Open [0]
Close[0] > Open [-2]

Down
Close[-2] > Open [-2]
Close[-1] > Open [-1]
Close[0] < Open [0]
Close[0] < Open [-2]

 [Candle Signal Alert.lua](files/107853/Candle%20Signal%20Alert.lua)

 [Candle Signal Alert with Trade.lua](files/107853/Candle%20Signal%20Alert%20with%20Trade.lua)


---

## Re: Candle Range Indicator

**gpfd1985** · Wed Sep 07, 2016 4:53 pm

I think I may have requested this in the past but I if I did sorry for the repeat. I was wondering if u could turn off the signal on one side or the other. In other words if the pair is in a down trend I want to be able to turn off the up candle range arrow and see only the down arrow vise versa for up trend. It clutters up the charts with both sides turned on.
Thank u so much


---

## Re: Candle Signal Alert

**Apprentice** · Fri Sep 09, 2016 10:17 am

ALLOWEDSIDE filter added.


---

## Re: Candle Signal Alert

**Apprentice** · Tue Aug 28, 2018 11:24 am

The indicator was revised and updated.


---

## Re: Candle Signal Alert

**Reymondpolanco** · Wed Aug 29, 2018 1:16 am

Can you add the option to trade automatically and add the option to set the stop on BE when the trade have X positive pips or set a trailing stop


---

## Re: Candle Signal Alert

**Apprentice** · Wed Aug 29, 2018 4:33 am

Your request is added to the development list under Id Number 4245
