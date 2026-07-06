# MTF MCP 3 MA Break Out View

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=76252  
> Forum: 17 · Topic 76252 · 1 post(s)


---

## MTF MCP 3 MA Break Out View

**Apprentice** · Mon Aug 18, 2025 2:29 pm

![EURUSD H8 (08-18-2025 2134).png](images/160290/EURUSD%20H8%20%2808-18-2025%202134%29.png)



 

![MTF MCP 3 MA BREAK OUT VIEW(UNK) (08-18-2025 2128).png](images/160290/MTF%20MCP%203%20MA%20BREAK%20OUT%20VIEW%28UNK%29%20%2808-18-2025%202128%29.png)



For each selected currency pair and timeframe, the script calculates three moving averages (MA1, MA2, MA3).

It then checks the last candle:
If close > MA1 and open < MA1 (candle crosses MA1 upward) → signal "Up"
But only if confirmation is enabled and the trend is aligned (MA1 > MA2 > MA3),
or if confirmation is turned off.

If close < MA1 and open > MA1 (candle crosses MA1 downward) → signal "Down"
With confirmation, it requires MA1 < MA2 < MA3 (downtrend alignment)
or if confirmation is turned off.

 [MTF MCP 3 MA Break Out View.lua](files/160290/MTF%20MCP%203%20MA%20Break%20Out%20View.lua)
