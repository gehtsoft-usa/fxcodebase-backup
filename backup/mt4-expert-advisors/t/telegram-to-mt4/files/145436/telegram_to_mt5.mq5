// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72004


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  |
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   |
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
//+------------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict


//+------------------------------------------------------------------+
//| Expert initialzation function                                   |
//+------------------------------------------------------------------+
#include <JAson.mqh>
#include <Trade\Trade.mqh> //Instatiate Trades Execution Library
#include <Trade\OrderInfo.mqh> //Instatiate Library for Orders Information
#include <Trade\PositionInfo.mqh> //Instatiate Library for Positions Information
//---
CTrade         m_trade; // Trades Info and Executions library
COrderInfo     m_order; //Library for Orders information
CPositionInfo  m_position; // Library for all position features and information
//#include   <json.mqh>
//#include <requests/requests.mqh>

enum tradePair
  {
   CURRENT_PAIR   =    0,
   ALL_SYMBOL  = 1

  };


input    string  default_spliter   =  "@";  //  Default Spliter
int  capture_previous_update_id  =      0;
input  int  check_telegram_updates   = 2;   //  In Second Get Update Telegram
input  string  currencyNameSuffix  = "";   //  Currency Name Suffix   ---  EURUSD.s

input   bool  DEFAULT_LOTS   =   true ;
input  double  Lots  =  0.01;
input    tradePair  TradePairMethod  =     ALL_SYMBOL   ;
input   int  MAGIC_NUMBER   =   3232982;

input  bool  detection_mode   =  true  ;
input string trade_comment  = "";
string InpToken="1713382528:AAHoApYKcGBuTLyvgfFfDD5FgRzC2JkcLoA";//  Telegram Token
input  string  setting_trail  = "==== Setting Trail ===";
input bool  trailiing  =   false ; // Trailling  Enable / Disable
input  int  WhenToTrail = 10;   // When to trail
input int where_to_trail  =  6; // Where to trail

input    bool   useBreakEven    =  false   ; //STOP LOSS TO BREAKEVEN ACTIVE
input   double  when_to_trail_l1   =    7      ;//  ACTIVE WHEN ONSIDE X PIPS
input  double    where_to_trail_l1  =     1;//  BREAK EVEN PLUS X PIPS
extern bool      lot_size_basis_risk_percentage  =   false;  //  Risk Percentage On The Basis of  Lot Size
extern    double  risk_in_percentage  =   2  ;  //  Risk in Percentage
input   bool    TAKE_PROFIT_ENABLE    =   false ;
input   double    take_profit     =   10  ;   //  Take Profit Pips

input  bool    STOP_LOSS_ENABLE    =  false    ;
input   double   stop_loss      =  10     ;    //   Stop   Loss  Pips
int OnInit()
  {
   EventSetTimer(check_telegram_updates);
   telegram_to_mt5();

   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   if(check_telegram_updates  >=  2)
     {



      telegram_to_mt5();






     }
   else
     {
      Alert("Get Updates Time in Second Should Be greater than 2");

     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string telegram_to_mt5()
  {

   CJAVal js;
   string headers;
   char post[], result[];
   int res = WebRequest("GET", "https://api.telegram.org/bot"+InpToken+"/getUpdates?offset=-1", "", NULL, 10000, post, ArraySize(post), result, headers);
   string  server_response_data   =CharArrayToString(result);
   js.Deserialize(result);
  //  Print(js["result"][0]["update_id"].ToStr(), "===Update  Id===");
   Print(js["result"][0]["channel_post"]["chat"]["title"].ToStr(), "===Title===");
   Print(js["result"][0]["channel_post"]["text"].ToStr(), "===Chat===");
   string   update_id  =  js["result"][0]["update_id"].ToStr()    ;
   if(capture_previous_update_id  !=   update_id)
     {
      capture_previous_update_id     =  update_id   ;
      string channel_post_chat  =    js["result"][0]["channel_post"]["chat"]["title"].ToStr();
      string channel_post_text  =  js["result"][0]["channel_post"]["text"].ToStr();
      string output[];
      StringSplit(channel_post_text, StringGetCharacter("\n", 0),output);
      string   symbol_mapping   =  "";
      string   symbol_mapping_base    =  "";
      string  trade_close  =  "" ;
      string  trade_close_base  =  "" ;
      string modify    = "";
      string modify_base    = "";
      string   price_mapping   =  "0";
      string    type_mapping    =   "" ;
      string   tp_mapping   ="0";
      string  sl_mapping  = "0"  ;
      string   lot_mapping  = "0";
      for(int i    =    0 ;   i <  ArraySize(output)  ;   i++)
        {
         if(detection_mode  == false)
           {
            if(i ==  0)
              {
               symbol_mapping   =      fx_spliter(output[i])   +  currencyNameSuffix;
              //  Alert(symbol_mapping, "symbol_mapping");
              }

            if(i ==  1)
              {
               price_mapping   =      fx_spliter(output[i]);
              //  Alert(price_mapping, "price");
              }
            if(i == 2)
              {
               type_mapping  =      fx_spliter(output[i]);
              //  Alert(type_mapping, "type");
              }

            if(i == 3)
              {
               tp_mapping   =   fx_spliter(output[i]);
              //  Alert(tp_mapping, "tp");
              }

            if(i == 4)
              {
               sl_mapping    =  fx_spliter(output[i]);
              //  Alert(sl_mapping, "sl");
              }


            if(i == 5)
              {
               lot_mapping    =  fx_spliter(output[i]);
              //  Alert(lot_mapping, "sl");

              }
           }

         if(detection_mode    == true)
           {
            string split_data  = fx_spliter_base(output[i]);
            if((split_data)   == ("tradeclose"))
              {
               trade_close_base  =  "tradeclose";
               trade_close   =      fx_spliter(output[i]);
              //  Alert(trade_close, "trade_close");
              }


            if((split_data)   == ("modify"))
              {
               modify_base   ="modify";
               modify   =      fx_spliter(output[i]);
              //  Alert(modify, "modify");
              }

            if((split_data)   == "symbol")
              {
               symbol_mapping_base  ="symbol";
               symbol_mapping   =      fx_spliter(output[i])   +  currencyNameSuffix;
              //  Alert(symbol_mapping, "symbol_mapping");
              }

            if((split_data)   == ("price"))
              {
               price_mapping   =      fx_spliter(output[i]);
              //  Alert(price_mapping, "price =====   TESTING   ");
              }
            if((split_data)   == ("type"))
              {
               type_mapping  =      fx_spliter(output[i]);
              //  Alert(type_mapping, "type");
              }

            if((split_data)   == "tp")
              {
               tp_mapping   =   fx_spliter(output[i]);
              //  Alert(tp_mapping, "tp");
              }

            if((split_data)   =="sl")
              {
               sl_mapping    =  fx_spliter(output[i]);
              //  Alert(sl_mapping, "sl");
              }


            if((split_data)  == "lot")
              {
               lot_mapping    = (fx_spliter(output[i])) == "default"   ?   Lots  : fx_spliter(output[i]) ;
              //  Alert(lot_mapping, "sl");

              }

           }

        }

      if(symbol_mapping_base   ==   "symbol")
        {
         fx_take_action_order(symbol_mapping,   price_mapping, type_mapping, sl_mapping,  tp_mapping,  lot_mapping) ;
         
        }
      if(trade_close_base   ==   "tradeclose")
        {
         // fx_take_action_order( symbol_mapping ,   price_mapping , type_mapping  , sl_mapping  ,  tp_mapping     ,  lot_mapping  ) ;
         if((trade_close)   ==  "cat"   || trade_close    =="CAT")
           {
            fx_close_mode(true, "");
           }
         if((trade_close)   !=   "cat")
           {
            fx_close_mode(true, trade_close);
           }
        }

      if(modify_base   ==   "modify")
        {
         int   order_type_capture   = fx_check_order_type(modify) ;
         if(order_type_capture <=1  &&    order_type_capture  !=  -1)
           {
            MqlTradeRequest request= {};
            request.action=TRADE_ACTION_SLTP;         // setting a pending order
            // request.magic=magic_number;                  // ORDER_MAGIC
            request.position=modify;
            request.symbol= fx_order_open_symbol(modify);                       // symbol
            request.sl=sl_mapping ;
            //  NormalizeDouble(order_stop_loss, _Digits);                                 // Stop Loss is not specified
            request.tp=tp_mapping;
            request.magic=MAGIC_NUMBER;
            //  NormalizeDouble(order_take_profit, _Digits);                                 // Take Profit is not specified
            //--- form the order type
            MqlTradeResult result= {};
            OrderSend(request,result);
          
           }


         else
           {

            bool    res   =    m_trade.OrderModify(modify,  fx_order_open_price_order_mode(modify),  sl_mapping,  tp_mapping, ORDER_TIME_GTC,0);
            

           }
        }





     }






   return  "0";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_order_open_price(int   ticketnumber)
  {

   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket   ==      ticketnumber)
        {
         return   PositionGetDouble(POSITION_PRICE_OPEN);
        }
     }
   return  0 ;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_order_open_price_order_mode(int   ticketnumber)
  {

   for(int i = OrdersTotal() - 1; i >= 0; i--) // loop all orders available
      if(m_order.SelectByIndex(i))  // select an order
        {
         if(m_order.Ticket()    == ticketnumber)
           {
            return    m_order.PriceOpen();

           }

        }



   return  0 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fx_order_open_symbol(int   ticketnumber)
  {
   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket   ==      ticketnumber)
        {
         return   PositionGetString(POSITION_SYMBOL);
        }
     }
   return  0 ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_modify()
  {

   return   0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_close_mode(bool  type,  string addtional)
  {

// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for(int i = PositionsTotal() - 1; i >= 0; i--) // loop all Open Positions
     {
      if(m_position.SelectByIndex(i))  // select a position
        {
         m_trade.PositionClose(m_position.Ticket()); // then delete it --period
         Sleep(100); // Relax for 100 ms

        }
     }
   for(int i = OrdersTotal() - 1; i >= 0; i--) // loop all orders available
      if(m_order.SelectByIndex(i))  // select an order
        {
         m_trade.OrderDelete(m_order.Ticket()); // delete it --Period
         Sleep(100); // Relax for 100 ms
        }
   return 0  ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  fx_take_action_order(string   symbol_mapping_2, string   price_mapping_2,  string  type_mapping_2,   double  sl_mapping_2,   double  tp_mapping_2,  string   lot_mapping_2)
  {
   
   if(TradePairMethod   == CURRENT_PAIR)
     {
      if(symbol_mapping_2   ==    Symbol())
        {
         // Trade Excution  Here
         fx_take_trade_order(symbol_mapping_2,   price_mapping_2,  type_mapping_2,  sl_mapping_2,    tp_mapping_2,  lot_mapping_2);
        }
     }
   if(TradePairMethod   == ALL_SYMBOL)
     {
      fx_take_trade_order(symbol_mapping_2,   price_mapping_2,  type_mapping_2,  sl_mapping_2,    tp_mapping_2,  lot_mapping_2);
     }
   return   "0"   ;
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_order(string   symbol_mapping_2, string   price_mapping_3,  string  type_mapping,   double  sl_mapping_3,   double  tp_mapping_3,  string   lot_mapping_3)
  {
   string   local_type_mapping =  type_mapping;
   string   local_price_mapping_3   = price_mapping_3;


   MqlTradeRequest request= {};
   MqlTick last_tick= {};
   SymbolInfoTick(symbol_mapping_2,last_tick);
   double price=  NormalizeDouble(fx_type_mapping_price(local_type_mapping, local_price_mapping_3, symbol_mapping_2),SymbolInfoInteger((symbol_mapping_2), SYMBOL_DIGITS));
   
   request.action=   fx_type_mapping_testing(local_type_mapping)  >1  ?TRADE_ACTION_PENDING  : TRADE_ACTION_DEAL   ;         // setting a pending order
   request.magic=MAGIC_NUMBER;                  // ORDER_MAGIC
   request.symbol=symbol_mapping_2;                      // symbol
   request.volume= fx_lots_mapping(lot_mapping_3);                          // volume in 0.1 lots
   int order_type_mapping   =  fx_type_mapping_testing(local_type_mapping) ;
   request.sl=STOP_LOSS_ENABLE  ==  true ? fx_stop_profit_calculation(order_type_mapping, price, symbol_mapping_2)   : sl_mapping_3;
// sl_mapping_3;
// fx_stoploss_open(order_type    ,   price  ,  symbol_mapping  );                                 // Stop Loss is not specified
   request.tp=TAKE_PROFIT_ENABLE  ==  true    ?  fx_take_profit_calculation(order_type_mapping, price,symbol_mapping_2) : tp_mapping_3 ;
   request.type= order_type_mapping;
   request.type_filling =ORDER_FILLING_IOC;
   request.price=  price; // open price
   request.comment =  trade_comment;
   MqlTradeResult result= {};
   OrderSend(request,result);
  //  Alert(GetLastError());
   return 0 ;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_calculation(int order_type,  double  price_value,  string  symbol_map)
  {
   if(order_type   == 0)
     {
      return   price_value   +   fx_pips_evaluation(symbol_map) *  take_profit* SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);
     }
   else
      if(order_type   ==  1)
        {
         return   price_value   -  fx_pips_evaluation(symbol_map) *  take_profit*  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);

        }

   return 0  ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stop_profit_calculation(int order_type,   double  price_value, string symbol_map)
  {
   if(order_type   == 0)
     {
      return   price_value   -   fx_pips_evaluation(symbol_map) *  stop_loss*  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);
     }
   else
      if(order_type   ==  1)
        {
         return   price_value   +  fx_pips_evaluation(symbol_map) *  stop_loss*  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);

        }

   return 0  ;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   fx_lots_mapping(double   Lots_mapping)
  {
   if(lot_size_basis_risk_percentage     ==  false)
     {
      return   Lots_mapping ;
     }
   if(lot_size_basis_risk_percentage    == true)
     {
      return       Lots_mapping   *(AccountInfoDouble(ACCOUNT_BALANCE)/100)*risk_in_percentage ;
     }
   return   Lots_mapping;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fx_type_mapping_price(string   type_mapping_for_price,  string price_mapping,  string  symbol_map)
  {

   if(type_mapping_for_price  ==  "buy"       ||   type_mapping_for_price    ==   "0"  || price_mapping == "current")
     {
      return  fx_asker(symbol_map) ;
     }
   if(type_mapping_for_price  =="sell"  ||   type_mapping_for_price    =="1"  || price_mapping == "current")
     {
      return     fx_bidder(symbol_map) ;  ;
     }
   if(type_mapping_for_price    == "buy_limit"   ||   type_mapping_for_price   == "2"   ||  type_mapping_for_price   == "buylimit")
     {

      return   price_mapping;

     }
   if(type_mapping_for_price  == "sell_limit"   ||   type_mapping_for_price  == "3"  || type_mapping_for_price   == "selllimit")
     {
      return  price_mapping;

     }
   if(type_mapping_for_price   =="sell_stop"  || type_mapping_for_price  ==  "4"  ||  type_mapping_for_price   == "sellstop")
     {
      return  price_mapping;

     }

   if(type_mapping_for_price   =="buy_stop"   ||  type_mapping_for_price  == "5" ||  type_mapping_for_price   == "buystop")
     {
      return  price_mapping;

     }

   return    "0" ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_asker(string  symbol_mapping)
  {
   MqlTick last_tick= {};
   SymbolInfoTick(symbol_mapping,last_tick);
   
   return   NormalizeDouble(last_tick.ask,SymbolInfoInteger((symbol_mapping), SYMBOL_DIGITS));


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_bidder(string symbol_mapping)
  {
   MqlTick last_tick= {};
   SymbolInfoTick(symbol_mapping,last_tick);
   return   NormalizeDouble(last_tick.bid, SymbolInfoInteger((symbol_mapping), SYMBOL_DIGITS));


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   fx_type_mapping_testing(string  type_mapping_testing)
  {

   string   type_mapping_lower   =  StringToLower(type_mapping_testing);

   if(type_mapping_testing  ==  "buy"       ||   type_mapping_testing    ==   "0")
     {
      return ORDER_TYPE_BUY ;
     }
   if(type_mapping_testing  =="sell"  ||   type_mapping_testing    =="1")
     {

      return   ORDER_TYPE_SELL;
     }
   if(type_mapping_testing    == "buy_limit"   ||   type_mapping_testing   == "2"  ||  type_mapping_testing  == "buylimit")
     {
      return   ORDER_TYPE_BUY_LIMIT;

     }
   if(type_mapping_testing  == "sell_limit"   ||   type_mapping_testing  == "3" ||  type_mapping_testing   =="selllimit")
     {
      return  ORDER_TYPE_SELL_LIMIT;

     }
   if(type_mapping_testing   =="sell_stop"  || type_mapping_testing  ==  "4" ||  type_mapping_testing   =="sellstop")
     {
      return   ORDER_TYPE_SELL_STOP;

     }

   if(type_mapping_testing   =="buy_stop"   ||  type_mapping_testing  == "5"  ||  type_mapping_testing   =="buystop")
     {
      return   ORDER_TYPE_BUY_STOP;

     }


   return   -1 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string    fx_spliter(string  data)
  {
   string output[];
   StringSplit(data, StringGetCharacter(default_spliter, 0),output);


   if(ArraySize(output)  == 2)
     {

      return (output[1]);

     }

   return  "";

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string    fx_spliter_base(string  data)
  {
   string output[];
   StringSplit(data, StringGetCharacter(default_spliter, 0),output);


   if(ArraySize(output)  == 2)
     {

      return (output[0]);

     }

   return  "";

  }



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(trailiing == true)
     {

      mql5_adjust_to_trail();




     }

   if(useBreakEven    ==  true)
     {
      fx_trail_breakeven();

     }




  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation(string symbol_map)
  {

   int digits = SymbolInfoInteger((symbol_map), SYMBOL_DIGITS);

   if(digits == 2)
     {
      return   100;

     }
   else
      if(digits ==  1)
        {
         return  10 ;
        }
      else
         if(digits ==  4  ||  digits == 5 ||  digits == 3)
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
int    fx_check_order_type(string modify)
  {

   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket   ==      modify)
        {
         return   PositionGetInteger(POSITION_TYPE) ;
        }
     }





   return   -1 ;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int mql5_adjust_to_trail()
  {

//+------------------------------------------------------------------+





   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(TradePairMethod  ==   CURRENT_PAIR)
        {
         if(PositionGetString(POSITION_SYMBOL) ==  _Symbol  && (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  0)
           {
            double bid_price  =  fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(bid_price -  PositionGetDouble(POSITION_PRICE_OPEN) >     WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {

               double   local_strage  =   bid_price -  where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <  local_strage)
                 {
                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));
                 }
              }

            if(PositionGetDouble(POSITION_SL)  == 0.0)
              {
              }
           }


         if(PositionGetString(POSITION_SYMBOL) ==  _Symbol  && (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  1)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  >  WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =  ask_price +where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)  >  local_strage)
                 {
                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN), local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));


                 }

              }

           }


        }

      if(TradePairMethod  ==   ALL_SYMBOL)
        {
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  0)
           {
            double bid_price  =  fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(bid_price -  PositionGetDouble(POSITION_PRICE_OPEN) >    WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {

               double   local_strage  =   bid_price -  where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <  local_strage)
                 {



                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));

                 }

              }

            if(PositionGetDouble(POSITION_SL)  == 0.0)
              {
              }


           }


         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  1)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  > WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =  ask_price +where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)  >  local_strage)
                 {

                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN), local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));


                 }

              }

           }




        }


     }


   return 0;
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_trail_breakeven()
  {

   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(TradePairMethod  ==  CURRENT_PAIR  && PositionGetString(POSITION_SYMBOL)   ==  Symbol())
        {
         if(PositionGetInteger(POSITION_TYPE) ==  0  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;




            if(bid_price  -  PositionGetDouble(POSITION_PRICE_OPEN)  >  when_to_trail_l1 *fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double   local_strage  =   PositionGetDouble(POSITION_PRICE_OPEN)  +  where_to_trail_l1* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <   PositionGetDouble(POSITION_PRICE_OPEN)  && ask_price  >PositionGetDouble(POSITION_PRICE_OPEN))
                 {



                  fx_order_modification(ticket,  PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));

                 }






              }


           }


         if(PositionGetInteger(POSITION_TYPE) ==  1  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {

            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;



            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =   PositionGetDouble(POSITION_PRICE_OPEN)  - where_to_trail_l1   * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);

               if(PositionGetDouble(POSITION_SL)   > PositionGetDouble(POSITION_PRICE_OPEN) &&  bid_price  < PositionGetDouble(POSITION_PRICE_OPEN))
                 {



                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));


                 }

              }




           }


        }





      if(TradePairMethod  ==  ALL_SYMBOL)
        {
         if(PositionGetInteger(POSITION_TYPE) ==  0  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(bid_price  -  PositionGetDouble(POSITION_PRICE_OPEN)  >  when_to_trail_l1 *fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {

               double   local_strage  =   PositionGetDouble(POSITION_PRICE_OPEN)  +  where_to_trail_l1* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <   PositionGetDouble(POSITION_PRICE_OPEN)  && ask_price  >PositionGetDouble(POSITION_PRICE_OPEN))
                 {
                  fx_order_modification(ticket,  PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));
                 }

              }


           }


         if(PositionGetInteger(POSITION_TYPE) ==  1  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =   PositionGetDouble(POSITION_PRICE_OPEN)  - where_to_trail_l1   * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);

               if(PositionGetDouble(POSITION_SL)   > PositionGetDouble(POSITION_PRICE_OPEN) &&  bid_price  < PositionGetDouble(POSITION_PRICE_OPEN))
                 {


                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));


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
double  fx_mapping_point(double  value,    int   point_digit,  string symbol_mapping)
  {
   if(SymbolInfoInteger((symbol_mapping), SYMBOL_DIGITS) >=   point_digit)
     {
      return     value *SymbolInfoDouble(symbol_mapping, SYMBOL_POINT) ;
     }
   else
      if(SymbolInfoInteger((symbol_mapping), SYMBOL_DIGITS) == 0)
        {

         return  value;
        }
      else
        {

         return (value/fx_power_mapping(SymbolInfoInteger((symbol_mapping), SYMBOL_DIGITS), 10));
        }



   return   0  ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_order_modification(int ticket,  double  order_open_price, double order_stop_loss,  double  order_take_profit, int expiration,  string color_value,  double  magic_number)
  {
   MqlTradeRequest request= {};
   request.action=TRADE_ACTION_SLTP;         // setting a pending order
   request.magic=magic_number;                  // ORDER_MAGIC
   request.position=ticket;
   request.symbol=_Symbol;                       // symbol
   request.sl=order_stop_loss ;
   request.tp=order_take_profit;
   MqlTradeResult result= {};
   OrderSend(request,result);
   return  0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation_2(string  symbol_mapping)
  {
   int digits = SymbolInfoInteger((symbol_mapping), SYMBOL_DIGITS) ;
   if(digits == 2)
     {
      return   100;
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
double  fx_power_mapping(int   currency_pair_digit, double  base)
  {

   double  capuring  =  1;
   for(int  i  = 0  ;  i  <    currency_pair_digit  ;   i++)
     {
      capuring   =  capuring *base;
      if(i  ==  currency_pair_digit  -1)
        {
         return   capuring;
        }

     }

   return  0 ;
  }
//+------------------------------------------------------------------+
