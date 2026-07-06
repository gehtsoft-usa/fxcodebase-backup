# MTF MCP Filter Heat Map

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=63597  
> Forum: 38 · Topic 63597 · 1 post(s)


---

## MTF MCP Filter Heat Map

**Apprentice** · Sun Jun 12, 2016 12:24 pm

![MTF MCP Filter Heat Map (MT4).png](images/106748/MTF%20MCP%20Filter%20Heat%20Map%20%28MT4%29.png)



uptrend: color green
ADX(PERIOD)> ADX(PERIOD-1)
AND DMI[POSITIVE]> DMI[NEGATIVE]
AND MACD> 0

downtrend: color red
ADX(PERIOD)> ADX(PERIOD-1)
AND DMI[POSITIVE]< DMI[NEGATIVE]
AND MACD< 0

sideway: not uptrend, not downtrend, colorgrey

 [#MTF_HeatMap.mq4](files/106748/MTF_HeatMap.mq4)
