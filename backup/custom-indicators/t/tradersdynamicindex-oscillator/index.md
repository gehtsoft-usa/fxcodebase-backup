# TradersDynamicIndex Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=74010  
> Forum: 17 · Topic 74010 · 4 post(s)


---

## TradersDynamicIndex Oscillator

**Apprentice** · Tue Aug 08, 2023 6:25 am

![EURUSD H1 (08-08-2023 1323).png](images/151973/EURUSD%20H1%20%2808-08-2023%201323%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=151920](https://fxcodebase.com/code/viewtopic.php?f=27&p=151920)
Traders dynamic index
[https://fxcodebase.com/code/viewtopic.php?f=17&t=2069](https://fxcodebase.com/code/viewtopic.php?f=17&t=2069)

 [TradersDynamicIndex Oscillator.lua](files/151973/TradersDynamicIndex%20Oscillator.lua)


---

## Re: TradersDynamicIndex Oscillator

**newton** · Wed Aug 09, 2023 12:44 am

HI APPRENTICE ,

Can u create MTF TRADERS DYNAMIC INDEX OSCILLATOR.

Indicator: trader dynamic index with default parameter

Indicator time frame: m15
Buy level: 50
Buy exit:80
Sell level:50
Sell exit : 20

Indicator time frame: H1
Buy level: 50
Buy exit:80
Sell level:50
Sell exit : 20

Oscillator value =1 if following conditions fullfilled

Trader dynamic index ( M15)
Price line >market base and
Market base >buy level and
Market base < buy exit AND

Trader dynamic index ( H1)
Price line >market base and
Market base >buy level and
Market base < buy exit

Oscillator value =-1 if following conditions fullfilled

Trader dynamic index ( m15)
Price line <market base and
Market base <sell level and
Market base >. sell exit AND

Trader dynamic index ( H1)
Price line <market base and
Market base <sell level and
Market base >. sell exit

Otherwise Oscillator value = 0


---

## Re: TradersDynamicIndex Oscillator

**Apprentice** · Wed Aug 16, 2023 3:33 pm

We have added your request to the development list.
Development reference 743.


---

## Re: TradersDynamicIndex Oscillator

**Apprentice** · Fri Nov 17, 2023 5:14 am

[MTF_TDI_HISTOGRAM.lua](files/153292/MTF_TDI_HISTOGRAM.lua)

Try this version.
