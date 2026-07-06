# Multiple Pass Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75414  
> Forum: 17 · Topic 75414 · 5 post(s)


---

## Multiple Pass Moving Average

**Apprentice** · Mon Dec 09, 2024 2:56 pm

![EURUSD D1 (12-09-2024 2049).png](images/157510/EURUSD%20D1%20%2812-09-2024%202049%29.png)



A multiple pass simple moving average filter is a SMA filter which has been applied multiple times to the same signal.

Two passes through a simple moving average filter produces the same effect as a triangular moving average filter (convolution of a square wave with a square wave is a triangle wave).

After four or more passes, it is equivalent to a Gaussian filter.

 [Multiple Pass Moving Average.lua](files/157510/Multiple%20Pass%20Moving%20Average.lua)


---

## Re: Multiple Pass Moving Average

**Apprentice** · Mon Dec 09, 2024 3:32 pm

![EURUSD D1 (12-09-2024 2128).png](images/157511/EURUSD%20D1%20%2812-09-2024%202128%29.png)



This is a variant of the MPMA that shifts the final output by N/2 periods to the left.
This shift centers the moving average on the price data, reducing the lag introduced by traditional moving averages.
It provides a more accurate representation of the current trend by aligning the moving average closer to the price action.

Advantages:
Provides a more accurate trend representation by reducing lag.
Ideal for detecting reversals and current trend changes more promptly.
Useful in strategies where timing is critical, such as breakout trading or counter-trend strategies.

 [Multiple Pass Moving Average (MPMA) with Shift.lua](files/157511/Multiple%20Pass%20Moving%20Average%20%28MPMA%29%20with%20Shift.lua)


---

## Re: Multiple Pass Moving Average

**Ariel19** · Mon Dec 23, 2024 2:35 am

> **Apprentice wrote:**
>
>
> EURUSD D1 (12-09-2024 2128).png
>
>
> This is a variant of the MPMA that shifts the final output by N/2 periods to the left.
> This shift centers the moving average on the price data, reducing the lag introduced by traditional moving averages.
> It provides a more accurate representation of the current trend by aligning the moving average closer to the price action.
> [agario](https://agargame.io)
> Advantages:
> Provides a more accurate trend representation by reducing lag.
> Ideal for detecting reversals and current trend changes more promptly.
> Useful in strategies where timing is critical, such as breakout trading or counter-trend strategies.
>
>
> Multiple Pass Moving Average (MPMA) with Shift.lua

How does the shift of N/2 periods in the MPMA variant improve the accuracy of trend representation compared to traditional moving averages?


---

## Re: Multiple Pass Moving Average

**Apprentice** · Mon Dec 30, 2024 8:02 pm

**The shift of N/2 periods in the Median Price Moving Average (MPMA) variant improves the accuracy of trend representation compared to traditional moving averages by addressing the lag inherent in most moving averages. Here's how it works:**

**Traditional Moving Averages and Lag**

Lag Issue: Traditional moving averages, like the Simple Moving Average (SMA) or Exponential Moving Average (EMA), inherently lag behind the actual price movement because they rely on averaging past data points. The larger the period N, the greater the lag.
Lag Impact: This lag can delay signals for trend reversals or continuations, making the moving average less effective for responsive trend representation.
**Shift of N/2 in MPMA**

Centering the Moving Average: The N/2 shift aligns the moving average with the median of the data window rather than trailing the current price. This adjustment reduces the visual and analytical lag by effectively repositioning the moving average to reflect the middle of the trend period.
Improved Accuracy: By centering the moving average, it becomes more synchronous with price action, offering a more realistic representation of the underlying trend.
Enhanced Responsiveness: The centered average reduces the delay in detecting changes in trend direction, making it more useful for identifying turning points.
**Why MPMA Specifically?**

Median Price Basis: MPMA uses the median price ((High + Low) / 2) instead of closing prices, providing a smoother and more representative measure of price action within a period.
Trend Fidelity: Combining the median price with the centered average improves the indicator's ability to represent price trends more accurately, as it avoids some of the noise associated with extreme high or low values.
**Practical Impact**

Early Signals: The reduced lag allows for earlier identification of potential trend changes.
Better Decision-Making: Traders and analysts can make more informed decisions, as the centered average provides a clearer and more immediate view of the current trend.
**Summary** In summary, the N/2 shift in the MPMA significantly enhances the utility of the moving average for trend analysis by reducing lag and aligning the indicator more closely with actual market dynamics. This adjustment improves both the timeliness and accuracy of trend representation compared to traditional moving averages.


---

## Re: Multiple Pass Moving Average

**mocodeh613** · Thu Jan 02, 2025 2:13 am

> **Apprentice wrote:**
>
>
> EURUSD D1 (12-09-2024 2049).png
>
>
> A multiple pass simple moving average filter is a SMA filter which has been applied multiple times to the same signal.
>
> Two passes through a simple moving average filter produces the same effect as a triangular moving average filter (convolution of a square wave with a square wave is a triangle wave).
> [duck life](https://duck-life.io)
> After four or more passes, it is equivalent to a Gaussian filter.
>
>
> Multiple Pass Moving Average.lua

Indeed, applying a simple moving average filter multiple times increasingly approximates a Gaussian filter due to the Central Limit Theorem, smoothing the signal more effectively with each pass.
