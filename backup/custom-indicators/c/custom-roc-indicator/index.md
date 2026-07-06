# Custom ROC Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66889  
> Forum: 17 · Topic 66889 · 1 post(s)


---

## Custom ROC Indicator

**Apprentice** · Sun Nov 04, 2018 8:40 am

![EURUSD W1 (11-04-2018 1248).png](images/121948/EURUSD%20W1%20%2811-04-2018%201248%29.png)



The ROC indicator has smaller lag if compared to a simple MA.

Calculating coefficient for different timeframes
K2=5;K3=15; Timeframe M1
K2=3;K3= 6; Timeframe M5
K2=2;K3= 4; Timeframe M15
K2=2;K3= 8; Timeframe M30
K2=4;K3=24; Timeframe H1
K2=6;K3=42; Timeframe H4
K2=7;K3=30; Timeframe D1
K2=4;K3=12; Timeframe W1
K2=3;K3=12; Timeframe MN

1. Line - supporting MA for building a price rate line on the current timeframe;
2. Line - price rate of change on the current timeframe;
3. Line - price rate of change on the nearest higher timeframe;
4. Line - price rate of change on the next higher timeframe;
5. Line - an average line of the rate of price change;
6. Line - a smoothed average line of the rate of price change.

 [Custom ROC Indicator.lua](files/121948/Custom%20ROC%20Indicator.lua)
