# Macrossover with MACD Confirmation Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=7604  
> Forum: 31 · Topic 7604 · 9 post(s)


---

## Macrossover with MACD Confirmation Strategy

**Apprentice** · Tue Oct 25, 2011 11:15 am

Buying Rules:
1.ema 20>ema100;
2.macd>buying level;
3.ema 5 crossover ema 20

Exit Buy
when ema 5 cross under ema 20
or macd line crossunder macd signal line

Selling Rules:
1.ema 20<ema100;
2.macd<selling level;
3.ema 5 cross under ema 20

Exit Sell
when ema 5 cross over ema 20
or macd line crossover macd signal line

 [Macrossover with MACD Confirmation Strategy.lua](files/16852/Macrossover%20with%20MACD%20Confirmation%20Strategy.lua)

The Strategy was revised and updated on November 19, 2018.


---

## Re: Macrossover with MACD Confirmation Strategy

**jtatalov** · Tue Oct 25, 2011 2:59 pm

The Strategy says "1st, 2nd, 3rd period EMA how do these relate to the description of 5,20,100 EMA


---

## Re: Macrossover with MACD Confirmation Strategy

**jtatalov** · Tue Oct 25, 2011 3:08 pm

Also what is the buy level and sell lever refer to?


---

## Re: Macrossover with MACD Confirmation Strategy

**Apprentice** · Tue Oct 25, 2011 5:03 pm

1st - 5
 2nd -20
 3rd -100

Buy & sell levels can be defined via parameters.
Define the line below / above the MACD gives a Short / Long Indications


---

## Re: Macrossover with MACD Confirmation Strategy

**jtatalov** · Tue Oct 25, 2011 5:40 pm

> **Apprentice wrote:**
>
> Buy & sell levels can be defined via parameters.
> Define the line below / above the MACD gives a Short / Long Indications

Please forgive me, but this is still a little too vague for me to understand. Can you be a little more specific with regard to which line you are referring to? Is this like a shift function


---

## Re: Macrossover with MACD Confirmation Strategy

**newton** · Wed Oct 26, 2011 1:30 am

hi,
level buy and level sell are values of macd histogram. if it is more than 0 it is upper trend . and if it is less than 0 it is down trend . if we set at little higher level like .00003/-.00003 in case of eurusd we can get better entries.


---

## Re: Macrossover with MACD Confirmation Strategy

**jtatalov** · Wed Oct 26, 2011 2:46 am

Ah, this makes more sense...thanks Newton


---

## Re: Macrossover with MACD Confirmation Strategy

**speedytina** · Wed Oct 26, 2011 7:57 am

Hi Apprentice...

If I understand the rules correctly. strategy should only open long trades when 5 and 10 EMA's cross and they are both above the 100 EMA. Short trades should only be opened when the 5 and 10 EMA's cross and they are both below the 100 ema. I am finding however that trades are being opened when the 5 and 10 EMA's cross regardless of their position in relation to the 100 EMA. In other words, both long and short trades are being triggered above the 100 EMA and long and short trades are being triggered below the 100 EMA. The 100 EMA does not figure in the trades at all.

Am I misunderstanding the rules? If not, what settings do I have to adjust to get the the 100 EMA involved.

I hope my question is clear.

Regards


---

## Re: Macrossover with MACD Confirmation Strategy

**Apprentice** · Fri Dec 02, 2016 8:13 am

Bump up.
