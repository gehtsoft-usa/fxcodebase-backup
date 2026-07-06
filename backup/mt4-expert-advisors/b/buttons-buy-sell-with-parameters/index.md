# buttons Buy / Sell with parameters

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=74150  
> Forum: 38 · Topic 74150 · 3 post(s)


---

## buttons Buy / Sell with parameters

**Ludo69** · Tue Sep 12, 2023 5:15 am

Hi every coder
i 'll like to make an EA able to create active order in the 2 directions Buy (Green button ) Sell ( Red button )
parameters are:
ecn : yes / no
Slippage: 3;
lot: 0.1;
TP in PIPS : 150; if 0 = devise needed
TP in Devise : 0; if 0 = PIPS needed
SL in PIPS : 25;
SL in Devises : 0 ;
Trailing Stop in pips : 50;

when the EA is Active to a window, when you clic on RED Bouton 1 Sell order is placed to the current price using the parameters define upper.
and when Green bouton is slected, 1 buy order is active using the parameters.

ecn is possible Yes if the account is agree.

when clicing GREEN Button

ticket = OrderSend(NULL, OP_BUY, lot, Ask, Slippage, BuySL, BuyTP, "LIVE_CHOICE", MagicID, 0, clrGreen);

thank for your help.


---

## Re: buttons Buy / Sell with parameters

**Apprentice** · Tue Sep 12, 2023 10:37 am

We have added your request to the development list.
Development reference 839.


---

## Re: buttons Buy / Sell with parameters

**Apprentice** · Sat Sep 16, 2023 4:11 am

Try this version.
[https://fxcodebase.com/code/viewtopic.p ... 92#p152592](https://fxcodebase.com/code/viewtopic.php?f=38&t=74171&p=152592#p152592)
