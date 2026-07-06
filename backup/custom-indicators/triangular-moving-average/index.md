# Triangular Moving Average

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72993  
> Forum: 17 · Topic 72993 · 3 post(s)


---

## Triangular Moving Average

**Apprentice** · Thu Dec 01, 2022 5:00 am

![ETHUSD H1 (12-01-2022 1059).png](images/148512/ETHUSD%20H1%20%2812-01-2022%201059%29.png)



The Triangular Moving Average (TMA) is similar to other moving averages (exponential and weighted) except it uses a different weighting scheme. Exponential and weighted moving averages assign the majority of the weight to the most recent data. Simple moving averages assign the weight equally across all the data. With a triangular moving average, it is double smoother (it is averaged twice) so the majority of the weight is assigned to the middle portion of the data.

The triangular moving average (TMA) is a weighted average of the last n prices (P), whose result is equivalent to a double-smoothed simple moving average:

SMA = (P1 + P2 + P3 + P4 + ... + Pn) / n
TMA = (SMA1 + SMA2 + SMA3 + SMA4 + ... SMAn) / n

 [Triangular Moving Average.lua](files/148512/Triangular%20Moving%20Average.lua)


---

## Re-Averaged Moving Average

**Apprentice** · Thu Dec 01, 2022 12:34 pm

![ETHUSD H1 (12-01-2022 1831).png](images/148531/ETHUSD%20H1%20%2812-01-2022%201831%29.png)



 

![ETHUSD H1 (12-01-2022 1837).png](images/148531/ETHUSD%20H1%20%2812-01-2022%201837%29.png)



Re-Averaged Moving Average will allow you to Re-Averaged the data as many times as you want.

Number of Re-Averaging
1 - Regular MA
MA of Price
2 - Triangular Moving Average
MA of MA of Price
3 - MA of MA of MA of Price
...

 [Re-Averaged Moving Average.lua](files/148531/Re-Averaged%20Moving%20Average.lua)


---

## Re-Averaged Moving Average Band

**Apprentice** · Thu Dec 01, 2022 1:27 pm

![ETHUSD H1 (12-01-2022 1920).png](images/148532/ETHUSD%20H1%20%2812-01-2022%201920%29.png)



 

![ETHUSD H1 (12-01-2022 1921).png](images/148532/ETHUSD%20H1%20%2812-01-2022%201921%29.png)



 

![ETHUSD H1 (12-01-2022 1924).png](images/148532/ETHUSD%20H1%20%2812-01-2022%201924%29.png)



To Declutter the chart this version will only show
the maximum, and minimum value of the Re-Averaged Moving Averages.
Mean value between maximum and minimum,
and the Last Re-Averaged Moving Average

Individual components are still here as an option.

 

![ETHUSD H1 (12-01-2022 1949).png](images/148532/ETHUSD%20H1%20%2812-01-2022%201949%29.png)



Triangular Moving Average only

 [Re-Averaged Moving Average Band.lua](files/148532/Re-Averaged%20Moving%20Average%20Band.lua)
