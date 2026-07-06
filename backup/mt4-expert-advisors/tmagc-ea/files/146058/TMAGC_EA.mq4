// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71813
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

enum   entry_type
  {

   singleEntry   =     0,
   MultipleEntry   =1

  }  ;


extern  string  s1    =   "===indicator  Setting===" ;
extern    int     TimeFrame    =    240   ;
extern   int  HalfLength    =   20   ;
extern   int  Price   =     0 ;
extern  double   BandsDeviation    = 2.6    ;
extern bool    interpolate  =  false    ;
extern   bool  alertsOn    =   false  ;
extern  bool  altertsOnCurrent   =  false  ;
extern   bool  alertOnHighLow   =  false  ;
extern   bool    alertmessage   =   false   ;
extern   bool  alertSound   = false ;
extern  bool alertEmail    =  false   ;
extern  bool  Chart_to_front   =  false ;
datetime    NewCandleTimeCurrent    ;





extern        double take_profit   =  10   ;  //  Take Profit
extern        double   stop_loss     =  10   ; //  Stop Loss 
extern    double   Lots  =   0.1;   // Lot Size
extern     int MAGIC_NUMBER    =   476753;  //  Magic Number


extern   bool   useTrailling   =  false;  //TRAILLING ACTIVE
extern  double when_to_trail_l4      =   20 ;  // ACTIVE WHEN ONSIDE X PIPS
extern  double where_to_trail_l4   =   10 ;  //  TRAIL EVEN PLUS X PIPS

extern    bool   useBreakEven    =  false   ; //STOP LOSS TO BREAKEVEN ACTIVE
extern   double  when_to_trail_l1   =    7      ;//  ACTIVE WHEN ONSIDE X PIPS
extern  double    where_to_trail_l1  =     1;//  BREAK EVEN PLUS X PIPS


//    Removing  Multiple trade
string  upcommingSignal    =  "NONE" ;

extern entry_type   orderPlaced      =      MultipleEntry;
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


   if(IsNewCandleCurrent())
     {
      fx_iCustom_logic()  ;
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
int  fx_iCustom_logic()
  {
   int i =1;
   double     mladen_data_buying     =   iCustom(Symbol(),  PERIOD_CURRENT, "TMA0CG",      TimeFrame,     HalfLength,  Price,    BandsDeviation,  interpolate,  alertsOn,   altertsOnCurrent, alertOnHighLow,   alertmessage, alertSound, alertEmail, Chart_to_front,   3,      i) ;
   if(mladen_data_buying        != 2147483647.0)
     {
      if(orderPlaced    ==   MultipleEntry)
        {
         fx_take_trade_order(0) ;
        }
      if(orderPlaced    ==    singleEntry       && (upcommingSignal       == "NONE"   ||  upcommingSignal    == "SELLING"))
        {
         upcommingSignal    =  "BUYING";
         fx_take_trade_order(0) ;
        }
     }
   double     mladen_data_selling     =   iCustom(Symbol(),  PERIOD_CURRENT, "TMA0CG",      TimeFrame,     HalfLength,  Price,    BandsDeviation,  interpolate,  alertsOn,   altertsOnCurrent, alertOnHighLow,   alertmessage, alertSound, alertEmail, Chart_to_front,   4,      i) ;
   if(mladen_data_selling        != 2147483647.0)
     {
      if(orderPlaced    ==   MultipleEntry)
        {
         fx_take_trade_order(1) ;
        }
      if(orderPlaced    == singleEntry  && (upcommingSignal   == "NONE"   ||   upcommingSignal    == "BUYING"))
        {
         upcommingSignal    =   "SELLING";
         fx_take_trade_order(1)   ;
        }
     }
   return  0 ;
  }






//+------------------------------------------------------------------+




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
int  fx_take_trade_order(int order_type)
  {
   int   response_order  =  OrderSend(Symbol(),order_type,  Lots,order_type ==  0  ?  Ask :  Bid,10,  order_type   ==   0   ?  fx_stoploss_point(0)   :  fx_stoploss_point(1),order_type ==  0  ?  fx_take_profit_point(0)  :  fx_take_profit_point(1),"FRACTAL",MAGIC_NUMBER,0,clrNONE);



   if(response_order  <0)
     {
      Print(GetLastError(),   "GetLastError()========================");



     }

   return   0 ;

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_point(int order_type)
  {
// Alert  (  take_profit  ,  "Take Profit ");
   if(take_profit    ==   0.0)
     {
      return   0    ;
     }
   else
      if(order_type   == 0)
        {
         return   Ask  +   take_profit* Point;
        }
      else
         if(order_type   ==  1)
           {
            return   Ask   -   take_profit* Point;
           }
   return 0  ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stoploss_point(int order_type)
  {
   if(stop_loss   ==  0.0)
     {
      return   0 ;
     }
   if(order_type   == 0)
     {
      return   Bid  -    stop_loss* Point;
     }
   else
      if(order_type   ==  1)
        {
         return   Ask   +    stop_loss* Point;
        }
   return 0  ;
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
         // double point = MarketInfo(OrderSymbol(), MODE_POINT);
         //       int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);

         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol())
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;




            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l1 *fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               // if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l1 *fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
               //   {
               double   local_strage  =   OrderOpenPrice()  +  where_to_trail_l1* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss()   <   OrderOpenPrice()  && ask_price  >OrderOpenPrice())
                 {



                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());

                 }


               // }




              }


           }


         if(OrderType()  ==  1   &&   OrderSymbol()    == Symbol())
           {
            //  Symbol Mapping Goes Here
            //     Print (  "Selling");
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            // if ( SET_SL_LEVEL_3    ==  Enable   ) {



            //  }

            //  else   if (    ) {

            //  Alert  (  fx_point(0 ,  OrderTicket())    ,   OrderTicket()  , "===Fx Point  ===");

            if(OrderOpenPrice() - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               // Alert   ( " ===============mapping Condition  ========================" ,  local_strage  )  ;
               double  local_strage   =   OrderOpenPrice()  - where_to_trail_l1   * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               //  Alert   ( " ===============mapping Condition  ========================" ,  local_strage  ,   "sd"  ,  OrderStopLoss()    )  ;
               if(OrderStopLoss()  > OrderOpenPrice() &&  bid_price  < OrderOpenPrice())
                 {

                  // Alert   ( "9098sss");

                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());


                 }

              }

            //  }


           }



         /////////////////////////////////////////////////////////////////////////////////








        }


     }


   return   0 ;
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
         // double point = MarketInfo(OrderSymbol(), MODE_POINT);
         //       int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);

         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol())
           {
            double   bid_price    =    fx_bidder(OrderSymbol()) ;


            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l4* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               // if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l3* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
               // {
               double   local_strage  =   bid_price -  where_to_trail_l4* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss() <  local_strage)
                 {



                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());

                 }


               // }




              }






           }


         if(OrderType()  ==  1  &&  OrderSymbol()    == Symbol())
           {
            //  Symbol Mapping Goes Here
            //     Print (  "Selling");
            double  ask_price  = fx_asker(OrderSymbol());
            // if ( SET_SL_LEVEL_3    ==  Enable   ) {

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
//OrderTicket()  , OrderOpenPrice() ,local_strage ,OrderTakeProfit(), 0 , "NONE" ,  OrderMagicNumber()

// OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(StopLoss*pips),OrderOpenPrice()+(TakeProfit*pips), 0, CLR_NONE); // OP_BUY
   bool    res   =    OrderModify(ticket,  order_open_price,  local_storage_stop_loss,  order_take_profit,   expiration,CLR_NONE);
   if(!res)
     {
      Alert("Error in OrderModify. Error code=",GetLastError());
     }

   return    0 ;
  }
//+------------------------------------------------------------------+
