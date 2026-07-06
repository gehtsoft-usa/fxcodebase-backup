// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72377

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
#property version "1.0"
#property strict
extern int  shortMA  =     14;
extern int  longMA    = 100  ;





extern    string  s1  = "Setting of Moving Average" ;
extern ENUM_TIMEFRAMES timeframe  = PERIOD_CURRENT;   //    Moving Average Timeframe
extern  int  MA_PERIOD   =  8  ; //  Moving Average Period
extern    ENUM_MA_METHOD  MA_METHOD   = MODE_EMA;  //  Moving Average Method 
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD   =   PRICE_CLOSE; //  Moving Average Applied




extern    string   s2     =   "Setting of Band Deviation";
extern ENUM_TIMEFRAMES band_timeframe  = PERIOD_CURRENT;   //    Bollinger Band timeframe
extern     int  band_period    =   25     ;    //   Bollinger Band  Period
extern      double    band_deviation    =   2   ;   //  Bollinger Band Deviation
extern     int    band_shift       =    0 ;       //  Bollinger  Band Shift
extern   ENUM_APPLIED_PRICE   BAND_APPLIED_PERIOD   =   PRICE_CLOSE;    //  Bollinger Band Applied




extern   bool   useTrailling   =  false;  //TRAILLING ACTIVE
extern  double when_to_trail_l4      =   20 ;  // Active When Onside X Pips
extern  double where_to_trail_l4   =   10 ;  //  Trail Even Plus X Pips

extern    bool   useBreakEven    =  false   ; //Stop Loss To Breakeven Active
extern   double  when_to_trail_l1   =    7      ;//  Active When Onside X Pips
extern  double    where_to_trail_l1  =     1;//  Break Even Plus X Pips

//  Setting of   Default
extern   double   take_profit   = 10   ; //  Take Profit
extern  double    stop_loss   =  10   ; //  Stop Loss
extern   double   Lots  =    0.01  ;  //  Lots
extern  int MAGIC_NUMBER  = 398376;  // Magic Number

string capture_recent_time  =  0 ;
datetime    NewCandleTimeCurrent;



extern    bool     CLOSE_ON_CAO_CHANGES   =      true;      //   Close Trade On CAO  Indicator  Changes
int OnInit()
  {


   capture_recent_time =  Time[1];

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
   if(IsNewCandleCurrent())
     {
      double   CAO_DATA_BUY   =      iCustom(Symbol(),  PERIOD_CURRENT, "Cao3", shortMA,  longMA,     1, 1)    ;
      double   CAO_DATA_SELL   =      iCustom(Symbol(),  PERIOD_CURRENT, "Cao3", shortMA,  longMA,     2, 1)    ;
      if(CLOSE_ON_CAO_CHANGES    == true)
        {
         if(CAO_DATA_SELL    !=    0.0  &&   CAO_DATA_BUY    ==  0.0)
           {
            fx_close_mode(true,    0);
           }
         if(CAO_DATA_SELL  ==  0.0    &&  CAO_DATA_BUY    !=  0.0)
           {
            fx_close_mode(true,    1);
           }
        }
      double   moving_average_fast_period_current_candle    =          iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,1);
      double      band_deviation_cureent_candle    =     iBands(Symbol(),band_timeframe, band_period,  band_deviation, band_shift,BAND_APPLIED_PERIOD,MODE_MAIN,1);
      double   moving_average_fast_period_previous_candle    =          iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,2);
      double      band_deviation_previous_candle    =     iBands(Symbol(),band_timeframe, band_period,  band_deviation, band_shift,BAND_APPLIED_PERIOD,MODE_MAIN,2);
      if(moving_average_fast_period_previous_candle   >   band_deviation_previous_candle     && moving_average_fast_period_current_candle  <=  band_deviation_cureent_candle    &&      CAO_DATA_BUY    ==   0.0)
        {
         fx_take_trade_order(1) ;
        }
      if(moving_average_fast_period_previous_candle   < band_deviation_previous_candle   &&  moving_average_fast_period_current_candle   >= band_deviation_cureent_candle    &&    CAO_DATA_SELL  ==    0.0)
        {
         fx_take_trade_order(0) ;
        }
     }
   if(useTrailling   == true)
     {
      fx_trail();
     }
   if(useBreakEven    ==  true)
     {
      fx_trail_breakeven();
     }


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
         return   Ask   -  fx_pips_evaluation() *  take_profit* Point;

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
int fx_pips_evaluation()
  {
   if(Digits() == 2)
     {
      return   100;
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
int  fx_trail()
  {
   for(int b = OrdersTotal() -1  ;  b>=  0   ;   b--)
     {
      if(OrderSelect(b,  SELECT_BY_POS))
        {
         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol())
           {
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l4* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double   local_strage  =   bid_price -  where_to_trail_l4* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss() <  local_strage)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }


         if(OrderType()  ==  1  &&  OrderSymbol()    == Symbol())
           {
            double  ask_price  = fx_asker(OrderSymbol());
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l4 * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double  local_strage   =  ask_price + where_to_trail_l4  * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  >  local_strage)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }
        }
     }


   return   0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_trail_breakeven()
  {
   for(int b = OrdersTotal() -1  ;  b>=  0   ;   b--)
     {
      if(OrderSelect(b,  SELECT_BY_POS))
        {
         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol())
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;

            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l1 *fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {

               double   local_strage  =   OrderOpenPrice()  +  where_to_trail_l1* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss()   <   OrderOpenPrice()  && ask_price  >OrderOpenPrice())
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }


         if(OrderType()  ==  1   &&   OrderSymbol()    == Symbol())
           {

            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double  local_strage   =   OrderOpenPrice()  - where_to_trail_l1   * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  > OrderOpenPrice() &&  bid_price  < OrderOpenPrice())
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }
        }
     }


   return   0 ;
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation_2(string  symbol_mapping)
  {
// double point = MarketInfo(OrderSymbol(), MODE_POINT);
   int digits = (int)MarketInfo(symbol_mapping, MODE_DIGITS);
   if(digits == 2)
     {
      return   100;
      //LotSize =  0.01;
     }
   else
      if(digits ==  4  ||  digits == 5)
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
double    fx_asker(string symbol_mapping)
  {


   return  MarketInfo(symbol_mapping, MODE_ASK);

   return   0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    fx_bidder(string symbol_mapping)
  {


   return  MarketInfo(symbol_mapping, MODE_BID);

   return   0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_order_modification(int ticket,  double  order_open_price,    double  local_storage_stop_loss,  double   order_take_profit,   int expiration, string additional,   int order_magic_number)
  {
   bool    res   =    OrderModify(ticket,  order_open_price,  local_storage_stop_loss,  order_take_profit,   expiration,CLR_NONE);
   if(!res)
     {
      Alert("Error in OrderModify. Error code=",GetLastError());
     }

   return    0 ;
  }




//+------------------------------------------------------------------+


/*
Documnetation

Hi i was wondering if the it is possible to have this EA made please.

EMA, bollinger band and CAO3 need to be able to change the settings on them.
EMA and bollinger band are just the standard mt4 indicators.

Entry buy:
Entry made on confirmed EMA crossing the middle Bollinger band line (on open of yellow arrow entry on open) with green colour CAO
Image

Close buy:
on the close candle of a red CAO or trailing/set TP (which ever requirement is hit first)
..........

Entry short:
Entry made on confirmed EMA crossing the middle Bollinger band line (on open of yellow arrow entry on open) with red colour CAO
Image

Close short:
on the close candle of a green CAO or trailing/set TP (which ever requirement is hit first)
..........

also hoping to have these other variables in the settings of the EA if also possible please?
Image


*/





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_order(int order_type)
  {

   bool  response_order  =  OrderSend(Symbol(),order_type,  Lots,order_type ==  0  ?  Ask :  Bid,10,  fx_stop_profit_calculation(order_type),  fx_take_profit_calculation(order_type),true,MAGIC_NUMBER,0,clrNONE);

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
bool IsNewCandleCurrent()
  {
   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);
      return true;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_close_mode(bool  type,   int   order_type_mapping)
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
      if(OrderType() == OP_BUY   &&    order_type_mapping    ==  0)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      else
         if(OrderType() == OP_SELL   &&   order_type_mapping     ==   1)
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
