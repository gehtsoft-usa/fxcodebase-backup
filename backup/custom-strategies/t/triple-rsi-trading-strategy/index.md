# Triple RSI Trading Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=74703  
> Forum: 31 · Topic 74703 · 1 post(s)


---

## Triple RSI Trading Strategy

**Apprentice** · Sat Mar 16, 2024 4:06 pm

![EURUSD H1 (03-16-2024 2204).png](images/154717/EURUSD%20H1%20%2803-16-2024%202204%29.png)



Based on post
[https://twitter.com/QuantifiedStrat/sta ... 35379?s=20](https://twitter.com/QuantifiedStrat/status/1768725342838235379?s=20)
We backtest the following modified trading rules:

* The 5-day RSI is below 30, and
* The 5-day RSI reading is down for the third day in a row, and
* The 5-day RSI reading was below 60 three trading days ago, and
* The close is higher than the 200-day moving average, and
* If 1-4 are true, then buy at the close.
* Sell at the close when the 5-day RSI crosses above 50.

(Short side was added)

 [Triple RSI Trading Strategy.lua](files/154717/Triple%20RSI%20Trading%20Strategy.lua)
