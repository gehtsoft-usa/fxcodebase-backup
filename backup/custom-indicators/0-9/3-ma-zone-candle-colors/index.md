# 3 MA Zone Candle Colors

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75940  
> Forum: 17 · Topic 75940 · 4 post(s)


---

## 3 MA Zone Candle Colors

**Apprentice** · Fri May 16, 2025 4:05 pm

![USOil D1 (05-16-2025 2303).png](images/159261/USOil%20D1%20%2805-16-2025%202303%29.png)



How it works:
The user defines three moving averages (any method: MVA, EMA, LWMA...).

For each candle, the indicator:

Compares the close price to the values of the three MAs.

Sorts the MAs from lowest to highest.

Determines the candle’s zone:

Below all MAs → Zone 1 → Red

Between lowest and middle MA → Zone 2 → Orange

Between middle and highest MA → Zone 3 → Blue

Above all MAs → Zone 4 → Green

The candle body is painted in the color of the zone it falls into.

 Customization:
Period and method for all 3 moving averages

Candle color for each of the 4 zones

Visual Result:
This gives a quick and intuitive view of:

Whether price is weak (below all MAs),

Ranging (between MAs),

Or strong (above all MAs).

 [3 MA Zone Candle Colors.lua](files/159261/3%20MA%20Zone%20Candle%20Colors.lua)


---

## Re: 3 MA Zone Candle Colors

**Mahadeo1806** · Sat Jul 19, 2025 12:43 pm

Res sir can we make indicator for mt4 and mt5

Thanks in advance


---

## Re: 3 MA Zone Candle Colors

**Apprentice** · Tue Jul 22, 2025 5:39 am

We have added your request to the development list.
Development reference 469


---

## Re: 3 MA Zone Candle Colors

**Apprentice** · Sun Jul 27, 2025 1:11 pm

MT4/MT5 versions
[https://fxcodebase.com/code/viewtopic.p ... 46#p160046](https://fxcodebase.com/code/viewtopic.php?f=38&t=76190&p=160046#p160046)
