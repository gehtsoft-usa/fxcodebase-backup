# CCI MACD STOCHASTIC STRATEGY

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61347  
> Forum: 31 · Topic 61347 · 2 post(s)


---

## CCI MACD STOCHASTIC STRATEGY

**Apprentice** · Mon Oct 20, 2014 1:31 pm

![CCI MACD STOCHASTIC STRATEGY.png](images/96629/CCI%20MACD%20STOCHASTIC%20STRATEGY.png)



Based on the request.
[http://www.fxcodebase.com/code/viewtopi ... 331#p96557](http://www.fxcodebase.com/code/viewtopic.php?f=27&t=61331#p96557)
INDICATORS:
1.CCI(PERIOD 50)
buy level:0
sell level:0
2.STOCHASTIC(5,3,3)
over bought level:80
over sold level:20
3.MACD WITH DEFAULT PARAMETERS
BUY LEVEL :0
SELL LEVEL:0

Open Long
 CCI> BUY LEVEL
 AND MACD > BUY LEVEL
 AND STOCHASTIC DLINE CROSSOVER OVERSOLD LEVEL

Open Short
 CCI< SELL LEVEL
 AND MACD< SELL LEVEL
 AND STOCHASTIC D LINE CROSSUNDER OVERBOUGHT LEVEL

 [CCI MACD STOCHASTIC STRATEGY.lua](files/96629/CCI%20MACD%20STOCHASTIC%20STRATEGY.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: CCI MACD STOCHASTIC STRATEGY

**Apprentice** · Sun Dec 11, 2016 9:11 am

Strategy was revised and updated.
