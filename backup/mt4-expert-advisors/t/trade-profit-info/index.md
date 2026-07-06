# Trade Profit Info

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=70093  
> Forum: 38 · Topic 70093 · 16 post(s)


---

## Trade Profit Info

**Apprentice** · Mon Jun 29, 2020 8:25 am

Based on request.
[viewtopic.php?f=27&t=70086](https://fxcodebase.com/code/viewtopic.php?f=27&t=70086)

 [Trade Profit Info.mq4](files/135405/Trade%20Profit%20Info.mq4)


---

## Re: Trade Profit Info

**BTS0301** · Mon Jun 29, 2020 9:45 pm

Thanks! But am I missing something? There's errors throughout and I think I need a file called Ordersiterator, but where can I find that? I've googled it and everything.
Also I'm only after a few lines of code to incorporate into my own that will show the result I'm after. What is the most needed lines of code for this result? From line 82 to end?


---

## Re: Trade Profit Info

**Apprentice** · Tue Jun 30, 2020 3:20 am

Your request is added to the development list.
Development reference 1591.


---

## Re: Trade Profit Info

**Apprentice** · Tue Jun 30, 2020 7:21 am

Try it now.


---

## Re: Trade Profit Info

**BTS0301** · Wed Jul 01, 2020 10:50 pm

Thankyou!
But how can I get it to be 0 until an order is sent? And can it show buy/sell as positive numbers unless the trade has gone in the opposite direction?
Thanks heaps


---

## Re: Trade Profit Info

**Apprentice** · Thu Jul 02, 2020 4:51 am

Try it now.


---

## Re: Trade Profit Info

**BTS0301** · Fri Jul 03, 2020 4:56 am

I had rewritten some of the code and it works for the Buy. But I can't get it to work in reverse properly for the Sell. I incorporated some of your new code but still couldn't get the desired result.
For the Sell, I want profit to show as a positive number and include brokerage (7 * lots) eg. .70c for .1 lots

Code: [Select all](https://fxcodebase.com/code/)
`{
   datetime last = 0;
   double price = 0;
   double lots = 0;
   bool isBuy = true;
   bool isSell = true;
   OrdersIterator it();
   it.WhenSymbol(_Symbol).WhenTrade();
   while (it.Next())
   {
      datetime dt = it.GetOpenTime();
      if (last < dt)
      {
         price = it.GetOpenPrice();
         lots = OrderLots();
         isBuy = it.IsBuy();
         isSell = it.IsSell();
      }
   }
   if (last == 0 && OrderType() == OP_BUY)
   {
      double point = MarketInfo(_Symbol, MODE_POINT);
      int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      double unitCost = MarketInfo(_Symbol, MODE_TICKVALUE);
      double pips = isBuy ? ((close[0] - price) / pipSize)*10 : ((price - close[0]) / pipSize)*10;
      double profit = ((lots * pips * unitCost))- (7 * lots);
      Comment("Pips: " + DoubleToString(pips,0) + "  $: " + DoubleToString(profit, 2));
   }
   else
   if (last == 0 && OrderType() == OP_SELL)
   {
      double point = MarketInfo(_Symbol, MODE_POINT);
      int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      double unitCost = MarketInfo(_Symbol, MODE_TICKVALUE);
      double pips = isSell ? ((price - close[0]) / pipSize)*10 : ((close[0] - price) / pipSize)*10;
      double profit = ((lots * pips * unitCost))- (7 * lots);
      Comment("Pips: " + DoubleToString(pips,0) + "  $: " + DoubleToString(profit, 2));
   }
   
   return 0;
}`


---

## Re: Trade Profit Info

**Apprentice** · Fri Jul 03, 2020 5:07 am

Your request is added to the development list.
Development reference 1625.


---

## Re: Trade Profit Info

**Apprentice** · Mon Jul 06, 2020 1:45 pm

I don't understand what needs to be done. It works fine.


---

## Re: Trade Profit Info

**BTS0301** · Tue Jul 07, 2020 1:42 am

Sell order profits are showing as negative numbers. How can this be changed so that it shows positive profit?


---

## Re: Trade Profit Info

**BTS0301** · Thu Jul 09, 2020 3:17 am

Solved that problem. But the profit lags by .20c for some unknown reason


---

## Re: Trade Profit Info

**BTS0301** · Sun Jul 12, 2020 9:40 pm

A portion of the code I have now...
Can't figure out why the calculations for profit for a sell entry is different for a buy... Please help

Code: [Select all](https://fxcodebase.com/code/)
`int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   datetime last = 0;
   double price = 0;
   double lots = 0;
   bool isBuy = true;
   bool isSell = true;
   OrdersIterator it();
   it.WhenSymbol(_Symbol).WhenTrade();
   while (it.Next())
   {
      datetime dt = it.GetOpenTime();
      if (last < dt)
      {
         price = it.GetOpenPrice();
         lots = OrderLots();
         isBuy = it.IsBuy();
         isSell = it.IsSell();
      }
   }
   if (last == 0 && OrderType() == OP_BUY)
   {
      double point = MarketInfo(_Symbol, MODE_POINT);
      int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      double unitCost = MarketInfo(_Symbol, MODE_TICKVALUE);
      double pips = isBuy ? ((close[0] - price) / pipSize)*10 : ((price - close[0]) / pipSize)*10;
      double profit = ((lots * pips * unitCost)- (7 * lots));
      Comment("Pips: " + DoubleToString(pips,0) + "  $: " + DoubleToString(profit, 2));
   }
   else
   if (last == 0 && OrderType() == OP_SELL)
   {
      double point = MarketInfo(_Symbol, MODE_POINT);
      int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      double pipSize = point * mult;
      double unitCost = MarketInfo(_Symbol, MODE_TICKVALUE);
      double pips = isSell ? ((price - close[0]) / pipSize)*10 : ((close[0] - price) / pipSize)*10;
      double profit = ((lots * pips / unitCost)- (7 * lots));
      Comment("Pips: " + DoubleToString(pips,0) + "  $: " + DoubleToString(profit, 2));
   }
   
   return 0;
}`


---

## Re: Trade Profit Info

**Apprentice** · Mon Jul 13, 2020 8:15 am

Your request is added to the development list.
Development reference 1689.


---

## Re: Trade Profit Info

**Apprentice** · Tue Jul 14, 2020 3:51 am

Because the price needs to move into a different direction to get the profit. The current price is higher than the open price means profit for buy and loss for sell.


---

## Re: Trade Profit Info

**BTS0301** · Thu Jul 23, 2020 9:29 am

But my point is how do I show a winning sell order as a profit... not a negative?


---

## Re: Trade Profit Info

**Apprentice** · Tue Jul 28, 2020 3:46 pm

The current formula does show exactly that.

double pips = isBuy ? ((close[0] - price) / pipSize) : ((price - close[0]) / pipSize)
positive for buy when current price > open price
positive for sell when current price < open price;
