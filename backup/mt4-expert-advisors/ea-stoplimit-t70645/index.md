# EA_STOPLIMIT

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=70645  
> Forum: 38 · Topic 70645 · 4 post(s)


---

## EA_STOPLIMIT

**Apprentice** · Fri Nov 20, 2020 4:07 am

Based on request.
[viewtopic.php?f=27&t=70623](https://fxcodebase.com/code/viewtopic.php?f=27&t=70623)

 [EA_STOPLIMIT.mq4](files/139024/EA_STOPLIMIT.mq4)


---

## Re: EA_STOPLIMIT

**nh0xh4mzuj** · Fri Nov 20, 2020 7:45 am

Thanks for your work.
EA works very well.
please explain EA options.
Distance to orders:
Stop in pips
Limit in pips
Slippage, points.


---

## Re: EA_STOPLIMIT

**Apprentice** · Sun Nov 22, 2020 4:56 am

Your request is added to the development list.
Development reference 2344.


---

## Re: EA_STOPLIMIT

**Apprentice** · Sun Nov 22, 2020 6:02 pm

Distance = 500 pips. // If there is an open order. for example buy 1.2000. ea will not open a buy pending order at 1.2000.
values are always rounded at 500pip.
Stop... standard stop loss
Limit... standard take profit
slippage... standard parameters for all EA's in MT4
