# Relative Volume Standard Deviation

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75938  
> Forum: 17 · Topic 75938 · 1 post(s)


---

## Relative Volume Standard Deviation

**Steve_W** · Thu May 15, 2025 3:01 am

I used Grok to port a Pine Script from this link
[https://www.tradingview.com/v/Eize4T9L/](https://www.tradingview.com/v/Eize4T9L/)

The prompts along the way included these terms
- with a coding style used in this recent indicator [https://fxcodebase.com/code/viewtopic.php?f=17&t=75868](https://fxcodebase.com/code/viewtopic.php?f=17&t=75868) - so it looks more like my own code style
- to use blue and grey bar colours with default bar width

A few trivial bugs and alterations along the way but maybe 15mins or work for the final version

The file header explains the indicator:
--
-- "RelativeVolumeStDev.lua"
--
--
-- Developed from Pine Script source for Relative Volume Standard Deviation from here: [https://www.tradingview.com/v/Eize4T9L/](https://www.tradingview.com/v/Eize4T9L/)
-- This indicator calculates the standard deviation of volume relative to its moving average
-- The volume deviation is normalized by the standard deviation and plotted as columns
-- Values above a threshold are colored blue; others are grey
-- Negative values can be optionally hidden
-- Displays as an oscillator in a separate panel below the price chart
--

 [RelativeVolumeStDev.lua](files/159251/RelativeVolumeStDev.lua)

 

![GBPUSD m15 (05-15-2025 0826).png](images/159251/GBPUSD%20m15%20%2805-15-2025%200826%29.png)
