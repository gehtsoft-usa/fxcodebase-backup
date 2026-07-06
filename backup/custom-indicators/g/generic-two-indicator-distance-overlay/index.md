# Generic Two Indicator Distance Overlay

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72554  
> Forum: 17 · Topic 72554 · 5 post(s)


---

## Generic Two Indicator Distance Overlay

**Apprentice** · Sun Jul 24, 2022 4:59 am

![EURUSD H8 (07-24-2022 1155).png](images/146867/EURUSD%20H8%20%2807-24-2022%201155%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=72546](https://fxcodebase.com/code/viewtopic.php?f=17&t=72546)

Find the difference between any two indicators and color the candle one color when the difference exceeds a user-defined threshold and another color when it falls below the threshold.

 [Generic Two Indicator Distance Overlay.lua](files/146867/Generic%20Two%20Indicator%20Distance%20Overlay.lua)


---

## Re: Generic Two Indicator Distance Overlay

**Sheera123** · Sun Jul 24, 2022 9:56 am

Hi Apprentice,

Thanks for creating the indicator. But it doesn't seem to be detecting when the difference is above or below the threshold. See attached pic for an example of what I want it to show. I am assuming, "Candle Color Level" is the threshold value and when I set it higher that 0, all the candles are colored with the same color.

I think you will have to add a 3rd color for when the difference is below the threshold. So the logic would be like this:

Up/Down trend:
1 - If 1st indicator is above 2nd indicator and difference is greater than threshold, color 1.
2 - If 1st indicator is below 2nd indicator and difference is greater than threshold, color 2.

Range:
3 - If 1st indicator is above 2nd indicator and difference is less than threshold, color 3.
4 - If 1st indicator is below 2nd indicator and difference is less than threshold, color 3.

The difference between the 1st and 2nd indicator is measured in pips.

Hope this makes it a bit clearer.

Thanks again,
Shawn H.


---

## Re: Generic Two Indicator Distance Overlay

**Apprentice** · Wed Jul 27, 2022 2:24 am

Try it now.


---

## Re: Generic Two Indicator Distance Overlay

**Sheera123** · Wed Jul 27, 2022 6:52 am

Works as expected now. Now I just have to play around with it to see which combination of TF and indicators gives the best results.

Thank you very much.

Shawn H.


---

## Re: Generic Two Indicator Distance Overlay

**Apprentice** · Thu Jul 28, 2022 8:03 am

Make sure to share the info...
