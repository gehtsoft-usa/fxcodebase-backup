# EMA DMI STOCHASTIC STRATEGY

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=14745  
> Forum: 31 · Topic 14745 · 5 post(s)


---

## EMA DMI STOCHASTIC STRATEGY

**Apprentice** · Mon Mar 12, 2012 5:57 pm

![EMA DMI STOCHASTIC STRATEGY.png](images/27948/EMA%20DMI%20STOCHASTIC%20STRATEGY.png)



Indicator used:

1.EMA 12, EMA 30, EMA 60
2. DMI (PERIOD 14)
3. STOCHASTIC (5 , 3, 3) with
buy level 50
sell level 50

BUY:
ema 12 > ema 30 >ema 60 and dmi + > dmi - and stochastic k cross over d and stochastic k < buy level[50]

SELL:
ema 12< ema 30< ema60 and dmi+<dmi- and stochastic k cross under d and stochastic k > sell level [50]

exit buy:
ema 12 cross under ema 30

exit sell:
ema 12 cross over ema 30

 [EMA DMI STOCHASTIC STRATEGY.lua](files/27948/EMA%20DMI%20STOCHASTIC%20STRATEGY.lua)


---

## Re: EMA DMI STOCHASTIC STRATEGY

**superleo** · Sat May 05, 2012 11:23 pm

sir,

i request to add

k cross over buy level to buying option and
k cross under sell level for selling option in this strategy


---

## Re: EMA DMI STOCHASTIC STRATEGY

**Apprentice** · Sun May 06, 2012 4:20 am

What about other conditions, they are not used.


---

## Re: EMA DMI STOCHASTIC STRATEGY

**superleo** · Mon May 07, 2012 10:03 pm

sir,
in the original strategy buy and sell options are based on k/d cross over .
my request is to add buy when k cross over os level[20]. and sell when k cross under ob level[80]. this is along with other conditions.


---

## Re: EMA DMI STOCHASTIC STRATEGY

**Apprentice** · Mon Dec 05, 2016 5:45 am

Bump up.
