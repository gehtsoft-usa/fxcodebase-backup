# Friday Low Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=76020  
> Forum: 17 · Topic 76020 · 2 post(s)


---

## Friday Low Indicator

**Apprentice** · Mon Jun 09, 2025 12:33 pm

![AUDJPY D1 (06-09-2025 1933).png](images/159554/AUDJPY%20D1%20%2806-09-2025%201933%29.png)



Based on video.
[https://www.youtube.com/shorts/ixhllG20xR4](https://www.youtube.com/shorts/ixhllG20xR4)

This Lua indicator highlights the Friday candle's range (high to low) on Monday only if Friday's low is lower than Thursday's low.
 It's used to visually track significant lows formed on Fridays and how the market reacts the following week.

 [Friday Low Indicator.lua](files/159554/Friday%20Low%20Indicator.lua)


---

## Friday's continuation

**Apprentice** · Mon Jun 09, 2025 1:52 pm

![AUDJPY D1 (06-09-2025 2051).png](images/159555/AUDJPY%20D1%20%2806-09-2025%202051%29.png)



The "Friday’s Continuation" indicator visually highlights the range of the Friday candle on the next Monday, based on a selected price comparison method. It helps traders assess whether Friday's move is continuing or reversing at the beginning of the new week.

"Close": Compares Friday’s close vs Thursday’s close.

"Lower Lows": Compares Friday’s low vs Thursday’s low.

"Higher Highs": Compares Friday’s high vs Thursday’s high.

If the selected condition is met (e.g., Friday’s low is lower than Thursday’s), the indicator:

Draws a filled rectangle from Friday's high to low,

Displays it aligned to Monday’s session on the chart,

This indicator is helpful for:

Spotting momentum or trend continuation from Friday into Monday.

Highlighting potential reversal zones based on unusual Friday candles.

Enhancing week-start trading strategies by giving visual context.

 [Friday's continuation.lua](files/159555/Fridays%20continuation.lua)
