# Stinger66 Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70760  
> Forum: 31 · Topic 70760 · 9 post(s)


---

## Stinger66 Strategy

**Apprentice** · Tue Dec 29, 2020 5:45 pm

Based on request.
[viewtopic.php?f=27&p=139826#p139826](https://fxcodebase.com/code/viewtopic.php?f=27&p=139826#p139826)

 [Stinger66 Strategy.lua](files/139859/Stinger66%20Strategy.lua)


---

## Re: Stinger66 Strategy

**Stinger66** · Tue Dec 29, 2020 8:12 pm

Hi Apprentice,
Thanks for quick reply and looking ok as it is closing the positions in profit at close of bar.
I am using D1 time period and have another strategy that opens trades.
What I am not seeing is the partial closing of positions in loss when the profit trade is closed.
Is this possible and not sure if you understood my original request?

What I am trying to achieve is, if there is more that one position open in the same direction, that the profitable positions are always closed but the losing positions in the same direction are partially closed by the profit amount achieved.
Logic is only for the same direction of positions.

Example.
1. Position 1 is long 100 with a loss of -$1000
2. Position 2 is long 100 with a profit of $500

Position 2 is closed for a profit for $500
Position 1 is partially closed for 50 Units and loss of -$500 and 50 units remains open at at a loss of -$500.

Let me know if this is possible?

Thanks in Advance.


---

## Re: Stinger66 Strategy

**Apprentice** · Sat Jan 02, 2021 3:02 pm

Your request is added to the development list.
Development reference 17.


---

## Re: Stinger66 Strategy

**Apprentice** · Sun Jan 03, 2021 5:30 am

[Stinger66 Strategy.lua](files/139927/Stinger66%20Strategy.lua)

Try this version.


---

## Re: Stinger66 Strategy

**Stinger66** · Fri Jan 15, 2021 7:18 am

Hello,

Strategy is not closing trades as per my request.
I am looking for immediate partial or full close of trades in loss for the opposite amount of the trade in profit that is closed.
The trades in loss that are closed should always be the oldest trades first.

If this can be achieved then I would like to see if this strategy could be converted to an indicator so that this indicator can be accessed from any strategy,.

What I am trying to achieve is, if there is more than one position open in the same direction, that the profitable positions are always closed but the losing positions in the same direction are always partially closed by the profit amount achieved.
Logic is only for the same direction of positions.

Example.
1. Position 1 is long 100 with a loss of -$1000
2. Position 2 is long 100 with a profit of $500

Position 2 is closed for a profit for $500
Position 1 is partially closed for 50 Units and loss of -$500 and 50 units remains open at at a loss of -$500.

Thanks in Advance,

Frank,


---

## Re: Stinger66 Strategy

**Apprentice** · Tue Jan 19, 2021 4:16 am

Your request is added to the development list.
Development reference 102.


---

## Re: Stinger66 Strategy

**Stinger66** · Sat Jan 30, 2021 4:19 pm

Hi Apprentice,

Tried the new version (Stinger66 Close Strategy.lua) but keep getting the following error.

C:/Program Files (x86)/Candleworks/FXTS2/Strategies/Custom/Stinger66 Close Strategy.bin:47: attempt to index global 'source' (a nil value)

Can you please try and fix.

Thanks,
Stinger66.


---

## Re: Stinger66 Strategy

**Apprentice** · Sun Jan 31, 2021 4:10 am

Your request is added to the development list.
Development reference 137.


---

## Re: Stinger66 Strategy

**Apprentice** · Sat Feb 06, 2021 10:46 am

[Stinger66 Close Strategy.lua](files/140557/Stinger66%20Close%20Strategy.lua)

Try this version.
