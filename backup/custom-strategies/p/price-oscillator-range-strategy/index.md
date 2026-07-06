# Price Oscillator Range Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=71585  
> Forum: 31 · Topic 71585 · 1 post(s)


---

## Price Oscillator Range Strategy

**Apprentice** · Mon Oct 18, 2021 9:18 am

![CHN50 H1 (10-18-2021 1616).png](images/143978/CHN50%20H1%20%2810-18-2021%201616%29.png)



Will only if
Price Oscillator Range < 0.1 or Price Oscillator Range > 0.9

Open Long
Close > MA
Close > High[-2]

Open Close
Close < MA
Close < Low[-2]

Exit Long
Close < MA
Exit Short
Close > MA

Price Oscillator Range
[https://fxcodebase.com/code/viewtopic.php?f=17&t=71584](https://fxcodebase.com/code/viewtopic.php?f=17&t=71584)

 [Price Oscillator Range Strategy.lua](files/143978/Price%20Oscillator%20Range%20Strategy.lua)
