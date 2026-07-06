# Strategy for automatic stop and limit orders.

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=11080  
> Forum: 31 · Topic 11080 · 9 post(s)


---

## Strategy for automatic stop and limit orders.

**Alexander.Gettinger** · Fri Jan 06, 2012 5:36 am

The strategy creates stop and limit orders to the new open positions in accordance with the specified parameters.

Download:

 [Auto_Stop_Limit.lua](files/22606/Auto_Stop_Limit.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: Strategy for automatic stop and limit orders.

**jtatalov** · Sat Jan 07, 2012 12:06 pm

Can you please add a fractional exit component to this strategy, see [http://fxcodebase.com/code/viewtopic.php?f=27&t=8235](https://fxcodebase.com/code/viewtopic.php?f=27&t=8235)


---

## Re: Strategy for automatic stop and limit orders.

**sho-me-pips** · Sun Jul 15, 2012 11:50 pm

Please make to work with FIFO accounts.

I added "E" to "L" or "S"...
valuemap.OrderType = "L"; to valuemap.OrderType = "LE";

The orders are setting correctly, however strategy will create MANY orders instead of only one each. Should remove other order when trade is complete.


---

## Re: Strategy for automatic stop and limit orders.

**thetruth** · Thu Jul 26, 2012 5:45 pm

this strategy is exellent, thanks and good work!!
but i think, is incomplete, can you add option for trailing stop fixed or dynamic??
with the option of how many pips in fixed option?
thanks and good work again!!


---

## Re: Strategy for automatic stop and limit orders.

**mjf1288** · Sun Aug 12, 2012 11:12 pm

Hello,

it seems that this strategy cannot work on US account. I keep getting the error message- "failed to create stop command disabled" Could someone help me get this work?

thanks


---

## Re: Strategy for automatic stop and limit orders.

**Apprentice** · Mon Aug 13, 2012 2:04 am

It seems that there are some compatibility problems with it.
I send Note to Alex.


---

## Re: Strategy for automatic stop and limit orders.

**sho-me-pips** · Fri Dec 27, 2013 9:19 am

Hi Alex,

Would you please modify this strategy to work with FIFO accounts. We would appreciate it.


---

## Re: Strategy for automatic stop and limit orders.

**Jacqueline.anna** · Tue Jan 06, 2015 1:05 am

C line is 5 Period Moving Average of closing price.
See indicator description.


---

## Re: Strategy for automatic stop and limit orders.

**Apprentice** · Sun Dec 11, 2016 1:00 pm

Strategy was revised and updated.
