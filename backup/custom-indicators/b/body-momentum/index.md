# Body momentum

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=73353  
> Forum: 17 · Topic 73353 · 1 post(s)


---

## Body momentum

**Apprentice** · Wed Feb 08, 2023 10:59 am

![EURUSD H1 (02-08-2023 1658).png](images/149562/EURUSD%20H1%20%2802-08-2023%201658%29.png)



Based on the source
[https://www.prorealcode.com/prorealtime ... scillator/](https://www.prorealcode.com/prorealtime-indicators/body-momentum-oscillator/)

described by Perry Kaufman.

This simply calculates the momentum of the closes above the opens versus the closes below the opens.

The theory is that as prices move up, closing prices will be higher than opening prices and vice-versa for down.

Above 70 then the Up candles dominate
Below 30 then the Down candles dominate

 [Body momentum.lua](files/149562/Body%20momentum.lua)
