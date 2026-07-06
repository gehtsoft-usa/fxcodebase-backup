# Trend Checker

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=73102  
> Forum: 17 · Topic 73102 · 1 post(s)


---

## Trend Checker

**Apprentice** · Wed Jan 04, 2023 3:12 am

![EURUSD m1 (01-04-2023 0911).png](images/148889/EURUSD%20m1%20%2801-04-2023%200911%29.png)



Based on the source
[https://www.prorealcode.com/prorealtime ... ker-graph/](https://www.prorealcode.com/prorealtime-indicators/trend-checker-graph/)
The indicator compares the price now to the price at the beginning of each look-back period and decides if it is up or down. The longer the lookback period the more weight is given to the result in the final calculation as it is difficult to argue with a long-term trend.

Above zero indicates that long trades are favored and below zero that short trades are favored.
My addition was the simple moving average of the results.

 [Trend Checker.lua](files/148889/Trend%20Checker.lua)
