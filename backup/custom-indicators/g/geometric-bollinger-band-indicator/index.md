# Geometric Bollinger Band Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=76535  
> Forum: 17 · Topic 76535 · 1 post(s)


---

## Geometric Bollinger Band Indicator

**Steve_W** · Sat Feb 07, 2026 7:47 am

This indicator is an enhanced version of the standard Bollinger Band indicator
- Selectable moving average type MVA or EMA
- up to to 3 different standard deviation bands
- optional geometric correction for markets that plot better on a log scale - the average and std dev are calculated on log(price) and then converted back with exp()
- price data selectable from close, open, high, low, median, typical and weighted
- configurable line styles

Example plot of Silver on D1 using settings EMA=9, bands 2.0 and 3.0 std dev, with geometric correction enabled

 

![XAGUSD D1 (02-07-2026 1213).png](images/161524/XAGUSD%20D1%20%2802-07-2026%201213%29.png)

*XAGUSD D1*



 [gbb.lua](files/161524/gbb.lua)

The code was developed using ClaudeAI to reduce work but based on an existing indicator that I published as an input template - so coding style could be carried through as a preference. If people wish to do similar, load the file up into the AI, and then instruct it to use as a template and design your new indicator with the rest of the prompt. ClaudeAI is quite capable but Grok can also make a reasonable effort (more bugs likely). Doing it this way reduces the coding cycle and errors, as it already has the basics to work with.
