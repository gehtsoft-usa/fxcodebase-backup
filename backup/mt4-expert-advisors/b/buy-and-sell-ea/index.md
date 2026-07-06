# Buy_and_Sell_EA

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=69116  
> Forum: 38 · Topic 69116 · 30 post(s)


---

## Buy_and_Sell_EA

**Apprentice** · Tue Nov 12, 2019 5:48 am

Based on request.
[viewtopic.php?f=38&t=69109](https://fxcodebase.com/code/viewtopic.php?f=38&t=69109)

 [Buy_and_Sell_EA.mq4](files/129698/Buy_and_Sell_EA.mq4)


---

## Re: Buy_and_Sell_EA

**ajc922** · Fri Nov 22, 2019 12:58 am

Apprentice, could you please add 2 inputs to this? Please add a trailing stop loss and a trailing take profit. Thank you!


---

## Re: Buy_and_Sell_EA

**Apprentice** · Fri Nov 22, 2019 5:09 am

Your request is added to the development list.
Development reference 341.


---

## Re: Buy_and_Sell_EA

**Apprentice** · Fri Nov 22, 2019 6:22 am

[Buy_and_Sell_EA.mq4](files/129892/Buy_and_Sell_EA.mq4)

Try this version.

I also need a definition for the trailing limit logic.


---

## Re: Buy_and_Sell_EA

**ajc922** · Fri Nov 22, 2019 4:06 pm

Are you saying that you need to know what to name the input? Sorry I'm not sure what you are asking. If you name it trailing stop and trailing take profit that will work great. And please have an option for these inputs to be set in pips and set in %. Thank you


---

## Re: Buy_and_Sell_EA

**Ludo69** · Sun Nov 24, 2019 5:13 pm

Hi,
thanks to be interested in this project.

Fisrt:
as you see on the picture at : [https://ibb.co/DtX1NbY](https://ibb.co/DtX1NbY)
Buy limit order is full ok

Sell limit order is no good to be in accordance with my mind.
the sell limit order have to be under the market price

Exemple ( order 1 and 2) in the picture
For a market price at 1.11192
Buy limit price =1.11292 S/L = 1.11192 T/P = 1.11392 = OK with your EA
Sell limit price = 1.11092 S/L = 1.11192 T/P = 1.10992
if one of them is executed, the orther is canceled and wait the execution of S/L or T/P before to pass 2 news order.

Regards


---

## Re: Buy_and_Sell_EA

**Apprentice** · Mon Nov 25, 2019 6:05 am

[Buy_and_Sell_EA.mq4](files/129922/Buy_and_Sell_EA.mq4)

Try this version.


---

## Re: Buy_and_Sell_EA

**ajc922** · Mon Nov 25, 2019 10:08 pm

What I meant by adding a trailing stop loss input was to add an input that will adjust the stop loss if the trade is profitable so that if the trade reverses and starts to go the other way it won't cross back under the breakeven point and it will stop out and still give you profit. Does that make sense? Sorry if it doesn't. I downloaded the newest version that you uploaded and it still doesn't have a trailing stop loss.


---

## Re: Buy_and_Sell_EA

**Apprentice** · Wed Nov 27, 2019 6:54 am

I do know what the trailing stop is, What is trailing limit?
Can you define it?


---

## Re: Buy_and_Sell_EA

**Ludo69** · Wed Nov 27, 2019 3:12 pm

Hi,
thank you for your work.

just a few things to rectify:
New Purchase and Sale orders are placed before the SL or TP is completed.
1) Can they be placed after the fulfillment of one of the conditions of the current order so that only one order is in progress once the barrier (X) is reached.

2) if it finished on SL can predict a martingale = X numbers of initial lots etc ....

like that we have: 1st order Lot = 0.1 if SL then 2nd order = 1.5 Lot etc ....


---

## Re: Buy_and_Sell_EA

**Apprentice** · Fri Nov 29, 2019 5:46 am

Your request is added to the development list.
Development reference 373.


---

## Re: Buy_and_Sell_EA

**Apprentice** · Wed Dec 04, 2019 5:14 pm

Don't understand the 2).
Martingale - opening more trades while moving against a favorable direction
I don't understand how it relates to SL


---

## Re: Buy_and_Sell_EA

**Ludo69** · Sun Dec 08, 2019 9:47 am

Hi,
2: if the last trade is finished by a SL the next order need to have a double lot to rebuild money until the trade finish by TP after that , restart to 1 Lot.

it's like roulette black or red if you try 1 to red and black is coming the next play you put 2 in red

1,2,4,8,16,32,64,etc.... until the good option arrives.
after that, restart to 1.

it to secure money

because in roulette game we have RED, Black or green for the 0. so it's not a 50/50.

in Forex TP/SL = 50/50


---

## Re: Buy_and_Sell_EA

**kluge123** · Wed Dec 11, 2019 9:13 am

Hi, could anyone help me add to ea . I need to add to the code when to close the store when sl.tp is at zero. A Tralingstop


---

## Re: Buy_and_Sell_EA

**Apprentice** · Wed Dec 11, 2019 5:06 pm

Sure,kluge123 .
Can you provide a bit more information?
If this is NOT a problem, post your request here.
[viewforum.php?f=27](https://fxcodebase.com/code/viewforum.php?f=27)


---

## Re: Buy_and_Sell_EA

**Apprentice** · Thu Dec 12, 2019 5:25 pm

[Buy_and_Sell_EA.mq4](files/130230/Buy_and_Sell_EA.mq4)


---

## Re: Buy_and_Sell_EA

**Ludo69** · Sun Dec 15, 2019 8:50 am

Thanx for it.

Is-it possible :

1) To have it with 5 digits like Gbp/Usd = 1.35102

2) To include an open and close Trade Time like:
- start to trade at the open Trade Time
- Stop to trade at the Close Trade Time with possibility to close all open position or not at this close time.

3) To do not Trade if Spread is > XX

After i thing it'll be very nice EA

Regards.

Regards.


---

## Re: Buy_and_Sell_EA

**Apprentice** · Sun Dec 15, 2019 9:59 am

Your request is added to the development list.
Development reference 440.


---

## Re: Buy_and_Sell_EA

**Apprentice** · Wed Dec 18, 2019 5:07 pm

[Buy_and_Sell_EA.mq4](files/130331/Buy_and_Sell_EA.mq4)

Try this version.


---

## Re: Buy_and_Sell_EA

**Ludo69** · Mon Dec 23, 2019 7:29 pm

Hi,

Is it possible to start new order ( Buy & sell limit ) only when the last position is closed.

in attachment you'll see that the order 3 and 4 are placed before the order 2 is closed.

order 1 and 2 are buy and sell limit.
2 is active so 1 is deleted.
but before to made new order ( like 3 and 4 ) is it possible to wait the end of the plan ( TP or SL ).

regards,

Ludovic


---

## Re: Buy_and_Sell_EA

**Apprentice** · Tue Dec 24, 2019 5:23 am

Your request is added to the development list.
Development reference 473.


---

## Re: Buy_and_Sell_EA

**Apprentice** · Wed Dec 25, 2019 5:44 am

[Buy_and_Sell_EA.mq4](files/130453/Buy_and_Sell_EA.mq4)

Try this version.


---

## Re: Buy_and_Sell_EA

**Ludo69** · Thu Dec 26, 2019 8:14 am

Hi, thank you

V 1.4 is better than v1.5 because a new order Buy and sell are placed after the modify of order when a position is taken and deleted the order in the other direction.
So please continue to devlopt v 1.4.
In this version the SL when buy order is open and modify order is made the SL corresponding to the

When an open position with a buy order is taken, the modified order who make SL and TP position is wrong on SL.
Actualy, the SL corresponding to the breakevent target pip valeur and not to the SL value definited in the section SL TP of order.
it's same un v1.5.

Regards,

Ludovic


---

## Re: Buy_and_Sell_EA

**Apprentice** · Thu Dec 26, 2019 9:25 am

Your request is added to the development list.
Development reference 485.


---

## Re: Buy_and_Sell_EA

**Ludo69** · Thu Dec 26, 2019 10:13 am

oups
a details about my last post:

it's happen only when breakevent is active .

regards


---

## Re: Buy_and_Sell_EA

**Apprentice** · Fri Dec 27, 2019 6:03 am

When an open position with a buy order is taken, the modified order who makes SL and TP position is wrong on SL.
Actually, the SL corresponding to the breakeven target pip value and not to the SL value defined in the section SL TP of order.
Yes, breakeven is not SL/TP. Breakeven moves SL. This is designed to do that.


---

## Re: Buy_and_Sell_EA

**Ludo69** · Sat Dec 28, 2019 1:38 pm

Hi

ok with that SL = SL if breakevent = false and = breakevent pips if breakevent = true.

after multi test ( using differents frame time and forex value ) the v1.5 is ok but maybe perfectible.

**actualy:**
X pips corresponding to the difference between actual price and positioning orders
at first be sure that:
over the price order corresponding to actual price + X pips
under the price order corresponding to actual price - X pips
if it's ok that great.

possible orders are:
over the price order type : buy long or sell short = buy stop or sell limit.
under the price order type : buy long or sell short = buy limit or sell stop.

**if it's possible to modify that in:**
over the price order type : buy long or sell short = buy stop or buy limit or sell stop or sell limit or do nothing.

under the price order type : buy long or sell short = buy stop or buy limit or sell stop or sell limit or do nothing.

to be most interresting, erraze the pending order only if SL or TP is won on the active order.

for exemple XAU:USD :
Price = 1500.00
X =100
over the price order type = buy limit
under the price order type = sell stop
TP = 10
SL = 1000
we have to pending orders:
buy limit order at 1501.00 SL = 1491.00 TP = 1501.10
sell stop order at 1499.00 SL = 1509.00 TP = 1498.90

price is 1501, activation of the 2 orders.
price is 1501.10, buy limit order is closed and sell stop order is deleted and 2 news orders are positionned.

Next Step is martingale option corresponding to an order finished by SL.
In this case next order lot is definited like a variable multiple of base lot.

Thank for your great work.

Regards,

Ludovic


---

## Re: Buy_and_Sell_EA

**Apprentice** · Tue Jan 14, 2020 5:48 am

This is exactly how it works now.


---

## Re: Buy_and_Sell_EA

**kisspfx** · Thu Jan 23, 2020 9:40 am

The comment is not displaying in this EA, please how do I add a custom comment?


---

## Re: Buy_and_Sell_EA

**baowesome** · Fri Feb 07, 2020 1:09 pm

any updates? ex4 file pls thanks
