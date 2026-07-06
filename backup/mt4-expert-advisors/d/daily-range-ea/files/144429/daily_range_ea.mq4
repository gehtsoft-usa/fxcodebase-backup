// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
extern double     Lots   =   0.10;
extern double    take_profit   = 10;  // Take profit in pips
extern  double   stop_loss  =  10;    //   Stop Loss in pips
extern   double pips_evaluation =   5  ;   //   Open  trade Buy  and Sell
extern  int  MAGIC_NUMBER =  13424254;
extern  bool send_notification   =   false   ;   // Alert  / Notification 
extern  bool  trade_execution  = true  ;   //  Trade  Execution

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
  }

int start()
  {
//---
   double  daily_range    =   iCustom(Symbol(),  PERIOD_CURRENT, "Daily_Open", 0, 1) ;
   if(daily_range  != 0.0)
     {
      double  up_range  =  daily_range  + fx_pips_evaluation()*pips_evaluation*Point();
      if(ObjectCreate(0, "trendline"+ Symbol() + "UP" + TimeToString(TimeCurrent(),  TIME_DATE),OBJ_TREND, 0,TimeCurrent(),up_range,TimeCurrent() + 3600, up_range))
        {
         ObjectSetInteger(0, "trendline"+ Symbol() + "UP" + TimeToString(TimeCurrent(),  TIME_DATE),OBJPROP_COLOR,clrBlue);
         ObjectSetInteger(0, "trendline"+ Symbol() + "UP" + TimeToString(TimeCurrent(),  TIME_DATE),OBJPROP_RAY_RIGHT,false);
         ObjectSetString(0, "trendline"+ Symbol() + "UP" + TimeToString(TimeCurrent(),  TIME_DATE),OBJPROP_TEXT,"TICKET_" +   up_range) ;
        }



      double  down_range  =  daily_range  - fx_pips_evaluation()*pips_evaluation*Point();
      if(ObjectCreate(0, "trendline"+ Symbol() + "DOWN" +   TimeToString(TimeCurrent(),  TIME_DATE),OBJ_TREND, 0,TimeCurrent(),down_range,TimeCurrent() + 3600,down_range))
        {
         ObjectSetInteger(0,"trendline"+ Symbol() + "DOWN" +   TimeToString(TimeCurrent(),  TIME_DATE),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"trendline"+ Symbol() + "DOWN" +   TimeToString(TimeCurrent(),  TIME_DATE),OBJPROP_RAY_RIGHT,false);
         ObjectSetString(0,"trendline"+ Symbol() + "DOWN" +   TimeToString(TimeCurrent(),  TIME_DATE),OBJPROP_TEXT,"TICKET_" +   down_range) ;
        }
      string output[];
      int order_type   =-1;
      bool  response_order;
      string  description  =   ObjectDescription("trendline"+ Symbol() + "DOWN" +   TimeToString(iTime(Symbol(), PERIOD_D1,  0),  TIME_DATE));
      int k = StringSplit(description, StringGetCharacter("_", 0), output);
      if(k > 1  && ArraySize(output) ==2)
        {
         if(StringToDouble(output[1]) < (Bid + 10*Point) &&    StringToDouble(output[1]) > (Bid - 10*Point))
           {
 if  (  send_notification   ==   true ) {
               Alert   ( "Daily Down  Line " ,output[1]);
               SendNotification("Daily Down  Line " + output[1]);
               
             }

             if (  trade_execution   == true ){
            order_type  =  1;
            if(iSExistTrade(1,    MAGIC_NUMBER))
              {
               return  true;
              }
            response_order  =  OrderSend(Symbol(),order_type,  Lots,order_type ==  0  ?  Ask :  Bid,10, fx_stop_loss_calculation(order_type),fx_take_profit_calculation(order_type),"comment",MAGIC_NUMBER,0,clrNONE);
            if(response_order)
              {
               fx_close_previus_trade(Symbol(),   MAGIC_NUMBER,  0);
              }


           }
           }
        }
      string output_buy[];
      int order_type_buy   =-1;
      bool  response_order_buy;
      string  description_buy  =   ObjectDescription("trendline"+ Symbol() + "UP" +   TimeToString(iTime(Symbol(), PERIOD_D1,  0),  TIME_DATE));
      int k_buy = StringSplit(description_buy, StringGetCharacter("_", 0), output_buy);
      if(k_buy > 1  && ArraySize(output_buy) ==2)
        {
         if(StringToDouble(output_buy[1]) < (Ask + 10*Point) &&    StringToDouble(output_buy[1]) > (Ask - 10*Point))
           {

             if  (  send_notification   ==   true ) {
               Alert   ( "Daily Up  Line " ,  output[1]);
               SendNotification("Daily Up  Line " + output[1]);
               
             }

             if  (  trade_execution  ==  true  ){

     order_type_buy  =  0;
            if(iSExistTrade(0,    MAGIC_NUMBER))
              {
               return  true;
              }
            response_order_buy  =  OrderSend(Symbol(),order_type_buy,  Lots,order_type_buy ==  0  ?  Ask :  Bid,10, fx_stop_loss_calculation(order_type_buy),fx_take_profit_calculation(order_type_buy),"comment",MAGIC_NUMBER,0,clrNONE);
            if(response_order_buy)
              {
               fx_close_previus_trade(Symbol(),   MAGIC_NUMBER,  1);
              }
             }
       
           }
        }
     }

   fx_delete_previous_line();
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_delete_previous_line()
  {
  
   ObjectDelete("trendline"+ Symbol() + "UP" +   TimeToString(iTime(Symbol(), PERIOD_D1,  1),  TIME_DATE));
   ObjectDelete("trendline"+ Symbol() + "DOWN" +   TimeToString(iTime(Symbol(), PERIOD_D1,  1),  TIME_DATE));


   return    0 ;
  }

bool  iSExistTrade(int  order_type,     int magic_no)
  {

   for(int   fx   = 0    ;  fx   <   OrdersTotal()  ;  fx++)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(fx, SELECT_BY_POS))
        {
         if(OrderMagicNumber()  ==  MAGIC_NUMBER &&  order_type  ==  OrderType())
           {
            return  true;
           }
         if(fx  ==  OrdersTotal()-1)
           {
            return  false;

           }

        }
     }

   return false  ;


  }

double  fx_close_previus_trade(string  symbol_mapping,  int magic_no,   int order_type)
  {

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
      bool res = false;

      // Allowed Slippage - the difference between current price and close price.
      int Slippage = 10;

      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY   &&  order_type   ==    OrderType()    &&   OrderMagicNumber()  ==  magic_no)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      else
         if(OrderType() == OP_SELL &&  order_type   ==    OrderType()   &&  OrderMagicNumber()  ==  magic_no)
           {
            res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
           }

      // If there was an error, log it.
      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }

   return 0  ;



  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_mapping_point(double  value,    int   point_digit,  string symbol_mapping)
  {
   if(MarketInfo(symbol_mapping,MODE_DIGITS) >=   point_digit)
     {
      // Alert  ( value , "currency  pnsui=====" ,currency_pair_digit  , "value/currency_pair_digit" ,  currency_pair_digit ,  "return value " ,   value/(currency_pair_digit*10));
      return     value *MarketInfo(symbol_mapping, MODE_POINT) ;
     }
   else
      if(MarketInfo(symbol_mapping,MODE_DIGITS) == 0)
        {

         return  value;
        }
      else
        {
         //  Alert (value,  "Value ", Point() , fx_digit_mapping(currency_pair_digit , 10) ,"Point"  ,"dddddd");
         // Alert(after_decimal_value +value , "=================",   fx_digit_mapping(currency_pair_digit , 10)  ,  "output after decimale "  ,  after_decimal_value   ,  "value" ,  value);
         //Alert  (symbol_mapping ,"===" ,value *SymbolInfoDouble( symbol_mapping , SYMBOL_POINT) , "==",fx_power_mapping(currency_pair_digit , 10) , "fx_power_mapping(currency_pair_digit , 10)" , value/fx_power_mapping(currency_pair_digit , 10) , "value/fx_power_mapping(currency_pair_digit , 10)");
         // MarketInfo(HedgeSymbol,MODE_DIGITS);
         return (value/fx_power_mapping(MarketInfo(symbol_mapping,MODE_DIGITS), 10));
        }



   return   0  ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_power_mapping(int   currency_pair_digit, double  base)
  {

   double  capuring  =  1;
   for(int  i  = 0  ;  i  <    currency_pair_digit  ;   i++)
     {
      capuring   =  capuring *base;

      if(i  ==  currency_pair_digit  -1)
        {
         //  Alert (  capuring , "Capturring  Goes Here");
         return   capuring;
        }

     }

   return  0 ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation()
  {
  //  Alert("ssssss", Digits() *Point());

   if(Digits() == 2)
     {
      return   100;
      //LotSize =  0.01;
     }
   else
      if(Digits() ==  1)
        {
         return  10 ;
        }
      else
         if(Digits() ==  4  ||  Digits() == 5 ||  Digits() == 3)
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
double  fx_stop_loss_calculation(int order_type)
  {
   if(order_type   == 0)
     {
      return   Bid  -  fx_pips_evaluation() *  stop_loss* Point;
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
double  fx_take_profit_calculation(int order_type)
  {
   if(order_type   == 0)
     {
      return   Ask  +  fx_pips_evaluation() *  take_profit* Point;
     }
   else
      if(order_type   ==  1)
        {
         return   Bid   -  fx_pips_evaluation() *  take_profit* Point;

        }

   return 0  ;
  }
//+------------------------------------------------------------------+



/*

 // Time range for trade


 based on this Daily_open line indicator to open a position each time the price cross 5 pips above or below the Daily open price line as below:

Buy above 5 pips from the Daily price line.
Sell below 5 pips from the Daily price line.

and if the price returned on the opposite direction by 5 pips from Daily open after opening a position, first close the previous position and then open immediately another position in that direction. so that to keep only one position opened.and when hitting the target restart the EA when the same conditions met again ( when the price cross 5 pips above or below the Daily open line for the same day.
and to close the open position in the end of the Day . and reopen new position according to the new Daily open line .

using these user parameters:

position lot size: ....lots
first T/p : .... pips
second T/P : .... pips

Thank you with my highly appreciation.
*/