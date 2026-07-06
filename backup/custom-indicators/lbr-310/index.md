# LBR 310

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75066  
> Forum: 17 · Topic 75066 · 2 post(s)


---

## LBR 310

**Apprentice** · Sat Jul 13, 2024 10:00 am

![EURUSD m1 (07-13-2024 1658).png](images/156141/EURUSD%20m1%20%2807-13-2024%201658%29.png)



LBR 310: Linda Bradford Raschke's indicator
Like MACD(3, 10) averaged using simple moving averages(16).

 [LBR-310.lua](files/156141/LBR-310.lua)


---

## Re: LBR 310

**Apprentice** · Sat Jul 13, 2024 10:42 am

![EURUSD m1 (07-13-2024 1741).png](images/156142/EURUSD%20m1%20%2807-13-2024%201741%29.png)



Originally made by Linda Raschke, The S310ROC Indicator combines the Rate of Change (ROC) indicator with the 3-10 Oscillator (Modified MACD) and plots to capture rapid price movements and gauge market momentum.

- Rate of Change (ROC): This component of the indicator measures the percentage change in price over a specified short interval, which can be set by the user (default is 2 days). It is calculated by subtracting the closing price from 'X' days ago from the current close.

- 3-10 Oscillator (MACD; 3,10,16): This is a specialized version of the Moving Average Convergence Divergence (MACD) but uses simple moving averages instead of exponential. Using a fast moving average of 3 days and a slow moving average of 10 days with a smoothing period of 16.

- Down Dots: Appear when all lines (ROC, MACD, Slowline) are sloping downwards, indicating bearish momentum and potentially signaling a sell opportunity.
- Up Dots: Appear when all lines are sloping upwards, suggesting bullish momentum and possibly a buy signal.

 [S310ROC.lua](files/156142/S310ROC.lua)
