# Simple MT5 Trading expert based on range and fib

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=73946  
> Forum: 38 · Topic 73946 · 6 post(s)


---

## Simple MT5 Trading expert based on range and fib

**strategiesdevelper** · Wed Jul 19, 2023 8:38 am

Hello, I am new to this forum but not a newbie to trading. I have been trading for over 6 years now and from time to time I work on new strategies. I have been using this strategy for a while now and it seems profitable. I was wondering if someone can help me to automate it. Below are the details,

Entry Criteria:
The EA will mark low and high between time specified (Input Required Start and End time for the range), once that time is passed the EA will look for breakout out of that range within specified period of time (input required time in hours to lookout for breakout, if breakout not happened during that time no trade) by certain number of pips to qualify as breakout (input required breakout pips).
Range filter if the marked range is above certain number of pips the ea should not place any any orders on that day (input required max range)
Pending order deletion time. If pending order is not filled the ea should delete the pending order at certain time (input required time to delete pending orders)
Sell Trade Setup:
If the breakout is detected downward, the ea will draw the fib (0 the high of the range and 100 low of the range), and the fib is drawn on the range that specified in our range timing (ignore the breakout low). The EA will 3 places pending orders exactly in the middle of 50 & 61.8.
Exist Criteria for Buy Trades:
Stop Loss: The EA will place SL above 0.0 level of the fib (Input required for SL distance), this SL is not from the Entry but 0.0 Level of the fib for all three pending orders.
Take Profit: The EA will place three Take profits, First take profit at 100 Fib Level, Second take profit at 161.8 Fib level, and Third Take profit at 261.80 Fib. Once First TP hit at 100 Fib Level, the EA will move the SL to 61.8 FIB level below our sell entry.
Buy Trade Setup:
If the breakout is detected upward, the ea will draw the fib (0 the low of the range and 100 top of the range), and the fib is drawn on the range that specified in our range time (Ignore the breakout high). The EA will 3 places pending orders exactly in the middle of 50 & 61.8.
Exist Criteria for Buy Trades:
Stop Loss: The EA will place SL below 0.0 level of the fib (Input required for SL distance), this SL is not from the Entry but 0.0 Level of the fib for all three pending orders.
Take Profit: The EA will place three Take profits, First take profit at 100 Fib Level, Second take profit at 161.8 Fib level, and Third Take profit at 261.80 Fib. Once First TP hit at 100 Fib Level, the EA will move the SL to 61.8 FIB level above your entry.
Further input required:
The number of buy and sell trades EA can take in a day must be separate input for buy and sell.
Money Management: Fixed Lot, Size Per account balance, and martingale if loss (Optional)
Push notification as soon as pending orders are placed.


---

## Re: Simple MT5 Trading expert based on range and fib

**Apprentice** · Thu Jul 20, 2023 2:00 pm

We have added your request to the development list.
Development reference 620.


---

## Re: Simple MT5 Trading expert based on range and fib

**strategiesdevelper** · Thu Jul 20, 2023 4:05 pm

Hi,

Can you please add time filter too? That will be great.


---

## Re: Simple MT5 Trading expert based on range and fib

**Apprentice** · Tue Aug 01, 2023 5:10 pm

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=73988](https://fxcodebase.com/code/viewtopic.php?f=38&t=73988)


---

## Re: Simple MT5 Trading expert based on range and fib

**blacksheep** · Thu Aug 03, 2023 4:57 pm

Hola. Necesitaba algo como esto. Puedes hacerlo en MT5 por favor?


---

## Re: Simple MT5 Trading expert based on range and fib

**Apprentice** · Tue Aug 08, 2023 3:48 am

We have added your request to the development list.
Development reference 687.
