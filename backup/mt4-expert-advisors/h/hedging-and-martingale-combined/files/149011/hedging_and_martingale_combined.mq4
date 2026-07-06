// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73166

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

input string startTime1 = "04:00";      //Start time 1
input string finishTime1 = "17:30";     //Finish time 1
input string startTime2 = "18:00";      //Start time 2
input string finishTime2 = "22:00";     //Finish time 2

extern int MagicNumber = 10001;
double Profit = 0, ProfitSymbol = 0;
int           Tp, err, ntp, result, total = 0;
extern    int      EAMagicNumber = 8095;
extern double Lots = 0.01;
extern double Loss = -50;
extern double TakeProfit = 50;
extern int Slippage = 3;
extern double Gap = 5;
string   EAComment            = "Martingale";
double MyPoint = Point;
double TheStopLoss = 0;
double TheTakeProfit = 0;
double lota = 0.01;
double fixlot = 0.01;
double last_price;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
int start()
  {
   int orderstype = 23;
   if(Digits == 3 || Digits == 5)
      MyPoint = Point * 10;
     {
      CheckTotalProfits();
     }
   if(TakeProfit < ProfitSymbol * 100)
     {
      CloseOrders();
     }
   printf(ProfitSymbol * 100);
   printf(Loss);
   price();
   Comment(Bid + (Gap * MyPoint));
   if(TotalOrdersCount() == 0)
     {
      if(ProfitSymbol * 100 == 0)
        {
         int result = 0;
         if((Bid > Close[1]) && (Close[1] > iMA(NULL, PERIOD_H1, 10, 0, MODE_SMA, PRICE_CLOSE, 1)) && checkTime() && IsNewCandle()) // Here is your open buy rule
           {
            result = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, NULL, MagicNumber, 0, Blue);
            orderstype = 23;
            lota = 0.01;
            fixlot = 0.01;
            return (0);
           }
         if((Bid < Close[1]) && (Close[1] < iMA(NULL, PERIOD_H1, 10, 0, MODE_SMA, PRICE_CLOSE, 1)) && checkTime() && IsNewCandle()) // Here is your open Sell rule
           {
            result = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, NULL, MagicNumber, 0, Red);
            orderstype = 32;
            lota = 0.01;
            fixlot = 0.01;
            return (0);
           }
        }
     }
   if((ProfitSymbol * 100 > 0) || (ProfitSymbol * 100 < 0))
     {
      if(Loss > ProfitSymbol * 100)
        {
         if((orderstype == 23) && (last_price - (Gap * MyPoint) >= Bid))
           {
            lota = lota + fixlot;
            result = OrderSend(Symbol(), OP_SELL, lota, Bid, Slippage, 0, 0, NULL, MagicNumber, 0, Red);
            orderstype = 32;
           }
         if((orderstype == 32) && (last_price + (Gap * MyPoint) >= Ask))
           {
            lota = lota + fixlot;
            result = OrderSend(Symbol(), OP_BUY, lota, Ask, Slippage, 0, 0, NULL, MagicNumber, 0, Blue);
            orderstype = 23;
           }
         fixlot = lota;
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
int TotalOrdersCount()
  {
   int result = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == MagicNumber)
         result++;
     }
   return (result);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkTime()
  {
   datetime curTime = TimeCurrent();
   datetime s_time1 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + startTime1);
   datetime f_time1 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + finishTime1);
   datetime s_time2 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + startTime2);
   datetime f_time2 = StringToTime(TimeToString(curTime, TIME_DATE) + " " + finishTime2);
   if((startTime1 == "00:00" || startTime1 == "0") && (finishTime1 == "00:00" || finishTime1 == "0") && (startTime2 == "00:00" || startTime2 == "0") && (finishTime2 == "00:00" || finishTime2 == "0"))
      return true;
   if(curTime >=  s_time1 && curTime < f_time1)
      return true;
   if(curTime >=  s_time2 && curTime < f_time2)
      return true;
   else
      return false;
  }

//+------------------------------------------------------------------+
bool IsNewCandle(void)
  {
   static datetime t_bar = iTime(_Symbol, PERIOD_H1, 0);
   datetime time = iTime(_Symbol, PERIOD_H1, 0);
//---
   if(t_bar == time)
      return false;
   t_bar = time;
//---
   return true;
  }
//+------------------------------------------------------------------+
double CheckTotalProfits()
  {
   Profit = 0;
   ProfitSymbol = 0;
   for(int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--)
     {
      bool order = OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if(!order)
        {
         continue;
        }
      if(OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
         double order_profit = OrderProfit() + OrderSwap() + OrderCommission();
         Profit += order_profit;
         ProfitSymbol += order_profit;
        }
     }
   return(ProfitSymbol);
  }
//+------------------------------------------------------------------+
void CloseOrders()
  {
// Update the exchange rates before closing the orders.
   RefreshRates();
// Log in the terminal the total of orders, current and past.
   Print(OrdersTotal());
// Start a loop to scan all the orders.
// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
        }
      // Create the required variables.
      // Result variable - to check if the operation is successful or not.
      bool res = false;
      // Allowed Slippage - the difference between current price and close price.
      int Slippage = 0;
      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      else
         if(OrderType() == OP_SELL)
           {
            res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
           }
      // If there was an error, log it.
      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
double price()
  {
   int new_var = OrdersTotal() - 1;
   OrderSelect(new_var, SELECT_BY_POS);
   last_price = OrderOpenPrice();
   return(last_price);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
