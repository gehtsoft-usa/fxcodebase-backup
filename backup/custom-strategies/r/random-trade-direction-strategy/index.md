# Random Trade Direction Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=73057  
> Forum: 31 · Topic 73057 · 1 post(s)


---

## Random Trade Direction Strategy

**Apprentice** · Fri Dec 16, 2022 2:56 pm

![CHN50 m1 (12-16-2022 2046).png](images/148716/CHN50%20m1%20%2812-16-2022%202046%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=148674](https://fxcodebase.com/code/viewtopic.php?f=27&p=148674)

Trades will be created randomly.
Monte-Carlo generator generates numbers between 0 and 100
Buy
If the randomly generated number is greater than 90
Sell
If the randomly generated number is greater than 10

 [Random Trade Direction Strategy.lua](files/148716/Random%20Trade%20Direction%20Strategy.lua)
