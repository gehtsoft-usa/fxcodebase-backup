# Hidden Gap VSA Volume

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64691  
> Forum: 17 · Topic 64691 · 8 post(s)


---

## Hidden Gap VSA Volume

**Apprentice** · Mon May 29, 2017 6:05 am

![USDCHF m1 (05-29-2017 1112).png](images/112610/USDCHF%20m1%20%2805-29-2017%201112%29.png)



Based on the original.
[https://www.tradingview.com/script/TpTW ... SA-Volume/](https://www.tradingview.com/script/TpTWXr0u-Hidden-Gap-s-VSA-Volume/)

 [Hidden Gap VSA Volume.lua](files/112610/Hidden%20Gap%20VSA%20Volume.lua)

The indicator was revised and updated


---

## Re: Hidden Gap VSA Volume

**amvt85** · Mon Aug 27, 2018 3:26 pm

> **Apprentice wrote:**
>
>
> USDCHF m1 (05-29-2017 1112).png
>
>
> Based on the original.
> [https://www.tradingview.com/script/TpTW ... SA-Volume/](https://www.tradingview.com/script/TpTWXr0u-Hidden-Gap-s-VSA-Volume/)
>
>
> Hidden Gap VSA Volume.lua
>
>
>
> The indicator was revised and updated

Hello,

Why is this indicator showing volume spikes in the beginning of the day 24 hr period time? I have this problem with usd/jpy and nzd/usd.

[https://photoland.io/i/k4dCl](https://photoland.io/i/k4dCl)

Thanks!


---

## Re: Hidden Gap VSA Volume

**Apprentice** · Tue Aug 28, 2018 3:39 am

![USDJPY H1 (08-28-2018 0841).png](images/120820/USDJPY%20H1%20%2808-28-2018%200841%29.png)



Volume data is provided by fxcm server.


---

## Re: Hidden Gap VSA Volume

**amvt85** · Tue Aug 28, 2018 7:23 am

> **Apprentice wrote:**
>
>
> USDJPY H1 (08-28-2018 0841).png
>
>
> Volume data is provided by fxcm server.

But those spikes are not in any other pairs only in usd/jpy and nzd/usd? I'm using the 1 hr volume. It must be how vsa volume is calculated? Because comparing hidden gap vs real volume indicator? Their's a big difference in reading? [https://photoland.io/i/kHMcY](https://photoland.io/i/kHMcY)

Thanks!


---

## Re: Hidden Gap VSA Volume

**Apprentice** · Tue Aug 28, 2018 11:15 am

Only data used is tick volume provided by fxcm servers,
We only calculate MVA of this stream.

 

![NZDUSD m15 (08-28-2018 1620).png](images/120829/NZDUSD%20m15%20%2808-28-2018%201620%29.png)



If you compare you'll see both have the same value.


---

## Re: Hidden Gap VSA Volume

**amvt85** · Thu Aug 30, 2018 4:11 pm

> **Apprentice wrote:**
> Only data used is tick volume provided by fxcm servers,
> We only calculate MVA of this stream.
>
>
>
> NZDUSD m15 (08-28-2018 1620).png
>
>
>
> If you compare you'll see both have the same value.

I understand what you're saying but there should not be volume spikes like this though? [https://photoland.io/i/k9yyg](https://photoland.io/i/k9yyg) Compare to the real volume indicator? I'm I missing something? This is only happening with jpy/usd and nzd/usd the rest of the pairs are ok.


---

## Re: Hidden Gap VSA Volume

**Apprentice** · Thu Aug 30, 2018 4:23 pm

Two present different data sets.
Real volume is based on FXCM users volume.
Tick volume is based on a number of price changes.
Two they are not in direct, do not have, one hundred percent correlation.


---

## Re: Hidden Gap VSA Volume

**amvt85** · Thu Aug 30, 2018 7:37 pm

> **Apprentice wrote:**
> Two present different data sets.
> Real volume is based on FXCM users volume.
> Tick volume is based on a number of price changes.
> Two they are not in direct, do not have, one hundred percent correlation.

What I'm trying to point out is these volume spikes distorts this indicator readings? Because this is not happening with mt4 with the same indicator. It's spiking at the beginning of the day when it's the quietest phase of the market. And the weird part about it is it's only happening with those two pairs.
