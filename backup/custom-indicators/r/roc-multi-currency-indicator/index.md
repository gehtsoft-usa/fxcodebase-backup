# roc-multi-currency-indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=71411  
> Forum: 17 · Topic 71411 · 7 post(s)


---

## roc-multi-currency-indicator

**Apprentice** · Tue Aug 10, 2021 8:08 am

![GBPUSD W1 (08-10-2021 1507).png](images/143169/GBPUSD%20W1%20%2808-10-2021%201507%29.png)



MT4 version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=71408](https://fxcodebase.com/code/viewtopic.php?f=38&t=71408)

 [roc-multi-currency-indicator.lua](files/143169/roc-multi-currency-indicator.lua)


---

## Re: roc-multi-currency-indicator

**Apprentice** · Tue Aug 10, 2021 8:15 am

![GBPUSD m1 (08-10-2021 1515).png](images/143170/GBPUSD%20m1%20%2808-10-2021%201515%29.png)



 [Multi Currency ROC.lua](files/143170/Multi%20Currency%20ROC.lua)


---

## Re: roc-multi-currency-indicator

**mayk01** · Mon Apr 22, 2024 4:26 am

Hi,
Great!
Is it possible to extend it to the other instruments on my list and not just currencies?
If an option is not on my list, e.g. EUR, then even if I set it to false, it says an error to add it to my Instrument list.

Regards,
M.


---

## Re: roc-multi-currency-indicator

**Apprentice** · Mon Apr 22, 2024 10:41 am

Non forex version can be writen.
Can you provide the list of the instruments?
We will need 7 instruments for each of the 8 groups.


---

## Re: roc-multi-currency-indicator

**mayk01** · Tue Apr 23, 2024 4:37 am

I don't quite understand the 8 groups, I have several groups in the Instrument list. What am I looking at wrong? (TS2)
What I consider important:
US Bonds (10, 2, 30D)
US stock markets (Nas100, SPX, US30)
European bonds
Gold (Xau/Usd)
Bitcoin (Btc/USD)
EUR/CHF
USD/JPY
CHN50
USOIL
Dollar
GBP/USD
VIX
Perhaps a couple of other American shares, e.g. Nvidia, Tesla.


---

## Re: roc-multi-currency-indicator

**Apprentice** · Sat Apr 27, 2024 2:56 am

We have added your request to the development list.
Development reference 345


---

## Re: roc-multi-currency-indicator

**Apprentice** · Mon Dec 02, 2024 2:52 pm

![USDCAD H1 (12-02-2024 2051).png](images/157426/USDCAD%20H1%20%2812-02-2024%202051%29.png)



I re-coded it differently.
The user car writes a formula in the parameters (but only + and - are supported).
It’ll be divided by the number of instruments in the end.
For example, EUR/USD+USD/JPY-CAD/JPY will be an equivalent to (EUR/USD+USD/JPY-CAD/JPY)/3

 [Grouped_ROC.lua](files/157426/Grouped_ROC.lua)
