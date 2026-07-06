# Balanced ATR

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66715  
> Forum: 17 · Topic 66715 · 1 post(s)


---

## Balanced ATR

**Apprentice** · Wed Oct 10, 2018 4:03 pm

![EURUSD m1 (10-10-2018 2105).png](images/121439/EURUSD%20m1%20%2810-10-2018%202105%29.png)



ATR (Average True Range) was introduced first by Welles Wilder in his book “New concepts in technical trading”. The version you find in every trading software doesn’t take in consideration that ATR was built originally to deal only with commodities. This means that if we have stock A and stock B with the same ATR, but respectively a close price of 200 Euros and 30 Euros, they are considered to be equal in terms of ATR but in reality they are very different in terms of ability to perform well in the market and in terms of volatility.

This code should help to adapt Wilder’s ATR to the stock world.

 [Balanced ATR.lua](files/121439/Balanced%20ATR.lua)
