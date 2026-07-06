# Moving_Average_VWAP_Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=71473  
> Forum: 31 · Topic 71473 · 4 post(s)


---

## Moving_Average_VWAP_Strategy

**Apprentice** · Sat Sep 04, 2021 2:53 am

![WHEATF m1 (09-04-2021 0952).png](images/143452/WHEATF%20m1%20%2809-04-2021%200952%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=143403](https://fxcodebase.com/code/viewtopic.php?f=27&p=143403)
Moving_Average_VWAP.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=71472](https://fxcodebase.com/code/viewtopic.php?f=17&t=71472)

 [Moving_Average_VWAP_Strategy.lua](files/143452/Moving_Average_VWAP_Strategy.lua)


---

## Re: Moving_Average_VWAP_Strategy

**omgepe** · Fri Sep 24, 2021 1:51 am

dear Apprentice,

thanks for the work
could you do some optimize for this strategy,
cause it need confirmation for the last candle.
so this is the strategy

let say in time frame 5minute,
when last candle confirm close >VwapValue5 and Close>MAVwap21 then Open Long position with the Open price for the next candle
and when last candle confirm close Close<VwapValue5 and Close<MAVwap21 then Short position with the open price for the next candle

 [33621](files/143744/last%20candle.PNG)

thanks
gp


---

## Re: Moving_Average_VWAP_Strategy

**Apprentice** · Fri Sep 24, 2021 6:28 am

Your request is added to the development list.
Development reference 864.


---

## Re: Moving_Average_VWAP_Strategy

**Apprentice** · Thu Nov 25, 2021 10:36 am

There is a parameter for that: Execution Type. Set it to End of Turn
