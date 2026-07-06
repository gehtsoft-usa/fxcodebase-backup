# Keep It Simple and Stupid strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=72493  
> Forum: 31 · Topic 72493 · 1 post(s)


---

## Keep It Simple and Stupid strategy

**Apprentice** · Wed Jul 13, 2022 10:43 am

![EURUSD m1 (07-13-2022 1741).png](images/146726/EURUSD%20m1%20%2807-13-2022%201741%29.png)



MA1 > MA2
MA2 > MA3
MA3 > MA3[ -1]
MA2 > MA2[ -1]
MA1 > MA1[ -1]
Close > MA1
Close[-1]<= MA1[-1]
Close > Open
Close >Close[-2]
ADX > ADX Level

Close Long
Close < MA2

Vice Versa for Short

 [Keep It Simple and Stupid strategy.lua](files/146726/Keep%20It%20Simple%20and%20Stupid%20strategy.lua)
