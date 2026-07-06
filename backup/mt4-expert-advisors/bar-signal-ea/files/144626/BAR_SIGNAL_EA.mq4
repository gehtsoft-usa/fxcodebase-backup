// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71759

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern bool trade_execution  =  true  ;
extern bool  send_notification  =  true ;
extern  double  Lots  =   0.10;
extern  double take_profit   = 10; //  Take Profit
extern  double stop_loss   = 10; // Stop Loss
extern int  MAGIC_NUMBER  =   1226584;

extern  bool   reverse_trade_opening_close    = false;  //  Close Previous Trade


string  starting_point   =  "NONE";
bool   buying_mode  =   false;
bool  selling_mode    =  false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//  For Buy
   double   data_buy   =   iCustom(Symbol(),  PERIOD_CURRENT, "barsignals",1, 1) ;
//  For Sell
   double   data_sell   =   iCustom(Symbol(),  PERIOD_CURRENT, "barsignals", 3, 1) ;

   double   data_wait_for_buy  =  iCustom(Symbol(),  PERIOD_CURRENT, "barsignals", 2, 1) ;



   if(data_wait_for_buy  !=  2147483647.0)
     {

      starting_point    ="ACTIVATE";


     }

//  data_wait_for_buy   for buy trade 1.0
   double   data_wait_for_sell  =  iCustom(Symbol(),  PERIOD_CURRENT, "barsignals", 0, 1) ;
//  data_wait_for_sell for sell  trade  1.0
//
   if(data_wait_for_sell    !=   2147483647.0)
     {
      starting_point    ="ACTIVATE";
     }
   if(data_buy   != 2147483647.0)
     {
      //   Buying
      if(trade_execution   ==  true)
        {
         if(buying_mode    ==  false    &&  starting_point   == "ACTIVATE")
           {
            buying_mode    =  true  ;
            selling_mode    =  false;
            if(reverse_trade_opening_close    == true)
              {
               fx_close_mode(true, "");
              }
            fx_take_trade_order(0)   ;
           }
        }
      if(send_notification    ==  true)
        {
         if(buying_mode    ==  false    &&  starting_point   == "ACTIVATE")
           {
            string signal_type   = "bull";
            Alert(signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr(fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(0)));
            SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr(fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(0)));

           }
        }

     }



   if(data_sell   != 2147483647.0)
     {
      //  Selling
      if(trade_execution    ==  true)
        {
         if(selling_mode    == false  &&   starting_point    == "ACTIVATE")
           {
            //
            buying_mode    =  false  ;
            selling_mode    =   true ;
            if(reverse_trade_opening_close   ==   true)
              {
               fx_close_mode(true, "");
              }
            fx_take_trade_order(1);
           }
        }


      if(send_notification    ==   true)
        {
         if(selling_mode    == false  &&   starting_point    == "ACTIVATE")
           {
            string signal_type   = "bear";
            Alert(signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr(fx_take_profit_calculation(1)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(1)));
            SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr(fx_take_profit_calculation(1)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(1)));
           }

        }




     }


  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_order(int order_type)
  {
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);
   bool  response_order  =  OrderSend(Symbol(),order_type,  Lots,order_type ==  0  ?  Ask :  Bid,10,  fx_stop_profit_calculation(order_type),  fx_take_profit_calculation(order_type),"comment",MAGIC_NUMBER,0,clrNONE);
   if(!response_order)
     {
      Print(GetLastError(),   "GetLastError()========================");
     }
   else
     {

     }

   return 0 ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_calculation(int order_type)
  {
   if(order_type   == 0)
     {
      return   Ask   +   fx_pips_evaluation() *  take_profit* Point;
     }
   else
      if(order_type   ==  1)
        {
         return   Bid   -  fx_pips_evaluation() *  take_profit* Point;

        }

   return 0  ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stop_profit_calculation(int order_type)
  {
   if(order_type   == 0)
     {
      return   Bid   -   fx_pips_evaluation() *  stop_loss* Point;
     }
   else
      if(order_type   ==  1)
        {
         return   Ask   +  fx_pips_evaluation() *  stop_loss* Point;

        }

   return 0  ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation()
  {

   if(Digits() == 2)
     {
      return   100;
      //LotSize =  0.01;
     }
   else
      if(Digits() ==  4  ||  Digits() == 5)
        {
         return 10;
        }
      else
        {
         return  1;
        }

   return 0;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_close_mode(bool  type,  string addtional)
  {

//  if( )

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
      if(OrderType() == OP_BUY  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
        }


      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }





   return 0  ;
  }
//+------------------------------------------------------------------+
