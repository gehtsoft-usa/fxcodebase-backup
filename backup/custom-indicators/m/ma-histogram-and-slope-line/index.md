# MA Histogram and Slope Line

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75920  
> Forum: 17 · Topic 75920 · 1 post(s)


---

## MA Histogram and Slope Line

**Apprentice** · Thu May 08, 2025 5:21 am

![EURUSD m1 (05-08-2025 1220).png](images/159186/EURUSD%20m1%20%2805-08-2025%201220%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.p ... 84#p159184](https://fxcodebase.com/code/viewtopic.php?f=27&t=75917&p=159184#p159184)

Histogram

Displays the difference between MA1 and MA2

Dynamically colors the bars:

Blue (UpColor) when value > 0

Red (DownColor) when value < 0

Slope Line

Shows the slope calculated as:
MA2[period] - MA2[period - Shift]

Plotted with user-defined color, width, and style.

 [MA Histogram and Slope Line.lua](files/159186/MA%20Histogram%20and%20Slope%20Line.lua)
