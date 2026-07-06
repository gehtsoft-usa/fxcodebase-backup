// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72348


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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
enum  pending_order    // Pending Order Type
  {
   stop_order   =     0,      // Buy Stop / Sell Stop
   limit_order    =1   //Buy Limit / Sell Limit

  };

extern   pending_order pending_trade     =    stop_order     ;   // Pending Order Type
extern   double   take_profit    =  10 ;  //Take Profit Pips
extern   double  stop_loss    =  10;  //  Stop Loss Pips
extern  double  lot_size   =  0.10; //Lot Size
extern  int  MAGIC_NUMBER = 11232; //Magic Number
extern string  GER_30 =    "13:30"; //Default Time  HH:MM
int  counter_trade   =   0 ;
datetime   NewCandleTimeCurrent;
extern double    above_line   =    10  ;  //  Above Line Trade Order Pips
extern double    below_line  =   10 ;    // Below Line Trade Order Pips
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(IsNewCandleCurrent())
     {

      counter_trade   = 0 ;
     }


   int   expire_datetime=   StringCompare(TimeToString(Time[0], TIME_MINUTES),GER_30);


   if(expire_datetime       == 0  && counter_trade    ==   0)
     {


      if(pending_trade   ==   stop_order)
        {
         fx_take_trade_stop_order(4,    fx_take_profit_point_initialization(1,       above_line+  MarketInfo(Symbol(), MODE_SPREAD) * Point()))  ;
         fx_take_trade_stop_order(5,    fx_take_profit_point_initialization(0,    above_line -  MarketInfo(Symbol(), MODE_SPREAD) * Point()))  ;

        }

      if(pending_trade   ==  limit_order)
        {
         fx_take_trade_limit_order(4,    fx_take_profit_point_initialization(1,       above_line+  MarketInfo(Symbol(), MODE_SPREAD) * Point()))  ;
         fx_take_trade_limit_order(5,    fx_take_profit_point_initialization(0,    above_line -  MarketInfo(Symbol(), MODE_SPREAD) * Point()))  ;

        }
      counter_trade++;
     }
   fx_close_other_pending_order()   ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_stop_order(int order_type_mapping,   double   price)
  {
   int   response_order_buy_stop  =  OrderSend(Symbol(),4,  lot_size,  NormalizeDouble(price, Digits()),10, fx_stoploss_point(4,   stop_loss,   price), fx_take_profit_point(4,  take_profit, price),"pending",MAGIC_NUMBER,0,clrNONE);
   int     response_order_sell_stop   =  OrderSend(Symbol(),5,  lot_size,  NormalizeDouble(price, Digits()),10, fx_stoploss_point(5,   stop_loss,   price), fx_take_profit_point(5,  take_profit, price),"pending",MAGIC_NUMBER,0,clrNONE);
   if(response_order_buy_stop  <0    || response_order_sell_stop)
     {
      Alert(GetLastError(),   "GetLastError()========================");
     }
   return  0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_limit_order(int order_type_mapping,   double   price)
  {

   int response_order_buy_limit  =  OrderSend(Symbol(),3,  lot_size,  NormalizeDouble(price, Digits()),10, fx_stoploss_point(3,   stop_loss,   price), fx_take_profit_point(3,  take_profit, price),"pending",MAGIC_NUMBER,0,clrNONE);
   int  response_order_sell_limit  =  OrderSend(Symbol(),2,  lot_size,  NormalizeDouble(price, Digits()),10, fx_stoploss_point(2,   stop_loss,   price), fx_take_profit_point(2,  take_profit, price),"pending",MAGIC_NUMBER,0,clrNONE);

   if(response_order_buy_limit   <  0  ||    response_order_sell_limit   <  0)
     {

      Alert(GetLastError(),   "GetLastError()========================");


     }

   return    0 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stoploss_point(int order_type,  double  stop_loss, double price)
  {
   if(stop_loss   ==  0.0)
     {
      return   0 ;
     }
   if(order_type   == 0   ||    order_type    ==  4  || order_type   ==  2)
     {
      return   price -  fx_pips_evaluation() *  stop_loss* Point;
     }
   else
      if(order_type   ==  1  ||  order_type    ==  5  ||  order_type  ==  3)
        {
         return   price   +  fx_pips_evaluation() *  stop_loss* Point;
        }
   return 0  ;
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_point(int order_type,  double  take_profit, double  price)
  {
// Alert  (  take_profit  ,  "Take Profit ");
   if(take_profit    ==   0.0)
     {
      return   0    ;
     }
   else
      if(order_type   == 0   ||    order_type    ==  4  || order_type   ==  2)
        {
         return    price  +  fx_pips_evaluation() *  take_profit* Point;
        }
      else
         if(order_type   ==  1   ||  order_type    ==  5  ||  order_type  ==  3)
           {
            return  price   -  fx_pips_evaluation() *  take_profit* Point;
           }
   return 0  ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_point_initialization(int order_type,  double  take_profit)
  {
// Alert  (  take_profit  ,  "Take Profit ");
   if(take_profit    ==   0.0)
     {
      return   0    ;
     }
   else
      if(order_type   == 0   ||    order_type    ==  4  || order_type   ==  2)
        {
         return    Ask  +  fx_pips_evaluation() *  take_profit* Point;
        }
      else
         if(order_type   ==  1   ||  order_type    ==  5  ||  order_type  ==  3)
           {
            return  Bid   -  fx_pips_evaluation() *  take_profit* Point;
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
bool IsNewCandleCurrent()
  {
   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_D1, 0))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_D1, 0);
      return true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_close_other_pending_order()
  {
   ulong   above_line_ticket    =  0   ;
   ulong   below_line_ticket   =  0;
   bool    above_line_mapping  = false ;
   bool   above_pending_order   =   false  ;
   bool   below_pending_order   = false;
   bool  below_line_mapping   = false  ;


   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderType()    ==   OP_BUY     &&  OrderMagicNumber()   ==  MAGIC_NUMBER)
           {
            above_line_mapping    =  true   ;
           }
         if(OrderType()     ==    OP_SELL  &&  OrderMagicNumber()     ==  MAGIC_NUMBER)
           {
            below_line_mapping      =  true;
           }
         if((OrderType()    ==    OP_BUYSTOP   ||   OrderType()       ==  OP_BUYLIMIT)    &&  OrderMagicNumber()    ==  MAGIC_NUMBER)
           {
            above_line_ticket     =    OrderTicket();
            above_pending_order    =   true ;
           }
         if((OrderType()   ==   OP_SELLSTOP    ||   OrderType()     ==   OP_SELLLIMIT)   &&   OrderMagicNumber()    ==  MAGIC_NUMBER)
           {
            below_line_ticket     =   OrderTicket();
            below_pending_order    =   true;
           }
        }
      if(i  ==   0)
        {
         if(above_line_mapping     ==  true &&    below_pending_order    ==  true)
           {
            OrderDelete(below_line_ticket);
           }
         if(below_line_mapping    ==  true   && above_pending_order    == true)
           {
            OrderDelete(above_line_ticket)   ;
           }
        }
     }
   return    0 ;
  }  
//+------------------------------------------------------------------+
