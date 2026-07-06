# Price action Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=68419  
> Forum: 31 · Topic 68419 · 11 post(s)


---

## Price action Strategy

**Apprentice** · Tue May 07, 2019 6:54 am

[Price action Strategy.lua](files/126173/Price%20action%20Strategy.lua)

Based on request.
[viewtopic.php?f=27&t=68413](https://fxcodebase.com/code/viewtopic.php?f=27&t=68413)

Strategie based indicator.
[viewtopic.php?f=17&t=70661&p=139159#p139159](https://fxcodebase.com/code/viewtopic.php?f=17&t=70661&p=139159#p139159)


---

## Re: Price action Strategy

**Mountaintrader** · Tue Apr 28, 2020 12:32 pm

Hi Apprentice,

I have noticed that only the first trade to be initiated using this strategy trails its stop loss.

Stop loss on any second or third trades don't trail as per the parameter settings, they remain fixed at the parameter original stop loss value.

The attached screenshot shows three consecutive "Sell" trades activated by the strategy, but only the first trades stop loss trails. Trades 2 & 3 stop loss remained at their original value.

Is it possible to fix so all stops trail ?

Regards

Mountain Trader


---

## Re: Price action Strategy

**Apprentice** · Tue Apr 28, 2020 7:23 pm

Your request is added to the development list.
Development reference 1170.


---

## Re: Price action Strategy

**Apprentice** · Thu Apr 30, 2020 5:27 am

Try it now.


---

## Re: Price action Strategy

**Mountaintrader** · Sat May 09, 2020 2:03 pm

Thank you Apprentice for the fix, stop losses are working as selected.

Regards

Mountain Trader


---

## Re: Price action Strategy

**Mountaintrader** · Thu May 14, 2020 1:44 pm

Hi Apprentice,

In the Price Action Strategy properties, the first user defined parameter is "Distance, pips"

Please could you very briefly explain what exactly does "Distance, pips mean" ?

Thanks

Mountain Trader


---

## Re: Price action Strategy

**Apprentice** · Sat May 16, 2020 4:03 pm

Distance between close and open price.
If lees then set parameter Action will not be executed.


---

## Re: Price action Strategy

**Mountaintrader** · Sun May 17, 2020 2:41 pm

> **Apprentice wrote:**
> Distance between close and open price.
> If lees then set parameter Action will not be executed.

Thank you for the explanation.


---

## Re: Price Action Strategy - Indicator from the Strategy.

**Mountaintrader** · Mon Nov 23, 2020 7:09 pm

Hi Apprentice,

 Is it possible to create a TradeStation 2 indicator that would follow the identical entry parameters as the "Price Action Strategy" (PAS) but replace the trade entry with a wingding marker character painted onto the chart ?

 Although your existing PAS does offer an "Extension Alert Pop-Up Window" this has to be manually cancelled and does not paint a marker on the chart as a permanent record.

Two examples of when a new Indicator would paint a marker on the chart:-

1) BLUE marker painted on the chart at the same price level and time the PAS would have entered a BULLISH trade, and accompanied with a BULLISH audio sound file notification.

2) RED marker painted on the chart at the same price level and time the PAS would have entered a BEARISH trade, and accompanied with a BEARISH audio sound file notification.

Below are the New Indicator Parameters, similar to the PAS.

I hope you can help out and look forward to your reply with any questions.

Thank you

Regards

Mountain Trader

 **New Indicator Parameters**

**CALCULATION Parameter:**
Distance in Pips - 7 (User Definable as per the PAS)

**ALERT Parameters:**
Type of Signal - Direct (Direct/Indirect)
Price Type - Bid (Bid/Ask)
Time Frame - m1 (m5,15m etc)
Alert Execution Type - Live (Live/End of Turn)
Allow Side - Both (Bullish/Bearish/Both)
Add Info to Event Log - Yes (Y/N)
Show Alert - Yes (Y/N)

**COLOURS (RGB):**
Marker BULLISH - BLUE (User Definable)
Marker BEARISH - RED (User Definable)
Indicator Legend - WHITE

**MARKER Styles (Wingdings):**
Marker Style BULLISH - Dec 217 (below link to Wingdings characters)
Marker Style BEARISH - Dec 218 (Name: head2down)
Marker Font Size - 8 (User Definable)

**SOUND Notifications:**
Play Sounds - Yes (Y/N)
Sound File Number 1 - BULLISH Alert Sound File...
Sound File Number 2 - BEARISH Alert Sound File...

**TIME Parameters:**
Convert Time to - EST (UTC, Local etc)
Indicator Start Time - 07:00 am
Indicator Stop Time - 11:00 am

**APPEARANCE:**
Drawing Mode - Middle to Middle
Show Label - No (Y/N)
Show Legend - Yes (Y/N)
Show in Background - Yes (Y/N)

**NAME:**
Indicator Name - "SMP"

**LINKS:**
Wingdings: [https://id33121.securedata.net/alanwoo0 ... dings.html](https://id33121.securedata.net/alanwoo0/demos/wingdings.html)

**Original PAS Strategy:** [viewtopic.php?f=31&t=68419](https://fxcodebase.com/code/viewtopic.php?f=31&t=68419)


---

## Re: Price action Strategy

**Apprentice** · Tue Nov 24, 2020 6:00 am

Your request is added to the development list.
Development reference 2357.


---

## Re: Price action Strategy

**Apprentice** · Fri Nov 27, 2020 7:58 am

Strategie based indicator.
[viewtopic.php?f=17&t=70661&p=139159#p139159](https://fxcodebase.com/code/viewtopic.php?f=17&t=70661&p=139159#p139159)
