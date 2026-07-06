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



string   upcommingSignal  = "WAITING";


enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };


//  close trade at opposite signal ( close all oppsite order,
//   close opposite orde when in profit, do not close order,
//   close all order when in profit,
//   close all martiangle order )



enum  close_trade   {
   close_all_opposite_order   =  0 ,    //  Close  All  Opposite Order
   close_opposite_order_when_profit   =  1 ,// Close Opposite Order When Profit
   do_not_close_order   =  2   ,  // Do Not Close Order
   close_all_order_when_in_profit  =  3   // Close All Order When in Profit
  // close_all_martinangle_order  = 4   

};


enum   trade_type    {

   Rentry    =    0 , 
  Reverse    =   1  

};


extern    trade_type    trade_entry   =  Reverse ;    //  Trade  Operation  Rentry Trade / Reverse Trade 

extern  close_trade   trade_closing_method   =     close_all_opposite_order;   //  Trade Closing Method

//  Setting of   Default

extern   string  MAX_NUMBER_TRADE   =   "==================================================================== ";  // Maximum Number Trade

// extern  int  TOTAL_MAX_NUMBER_OF_TRADE   =    10;
extern   int MAX_NUMBER_OF_BUY_TRADE   =  5;   //  Maximum NUMBER BUY TRADE
extern  int  MAX_NUMBER_OF_SELL_TRADE =  5;   // MAXIMUM NUMBER SELL TRADE
extern  string s1  = "=========== TIME FILTER ==================" ;
   enum  time_based  {
    pc_time_start_stop_time  = 0 ,    //  PC TIME 
    server_time_start_stop_time  =  1 //  SERVER TIME 
    
};
extern  time_based   TIME_MODE_SELECTION   =   server_time_start_stop_time   ;  //Set time on the basis of server /  pc time     

extern  string  start_time  =  "10:00" ;    //  Start Time  HH:MM
extern string   end_time   =   "20:00"  ;  // End Time HH:MM
datetime NewCandleTimeCurrent   ;
extern    EnableDisable  close_trade_afer_end_time    =   Enable    ;   //   Close Trade After End Times
extern   EnableDisable     take_profit_set  =   Disable  ;   //  Take Profit Set
extern   double   take_profit   = 10   ;  //  Take Profit
extern    EnableDisable   stop_loss_set   =   Disable ; // Stop Loss Set
extern  double    stop_loss   =  10   ;   //  Stop Loss
extern   double   Lots  =    0.01  ; // Lots
extern  int MAGIC_NUMBER  = 398376; // Magic  Number 
extern  string trade_comment  = "Comment"; // Comment
extern  bool  alert_send_notification  =  true ;    //  Alert / Send Notification
extern bool   trade_execution    =  true   ;  //  Trade Execution



extern   EnableDisable  trailling_stop_loss     =    Disable;
extern  double when_to_trail_l4      =   20 ;  //  When to trail
extern  double where_to_trail_l4   =   10 ;   //  Where to trail


extern string s2 =  "******** ADX PERIOD ********";
extern   int   adx_period  =   14;    //  ADX  Period


extern  EnableDisable    useBreakEven   = Disable  ;  // Breakeven
extern   double  when_to_trail_l1   =    7      ;   //  When To Breakeven
extern  double    where_to_trail_l1  =     1;    //  Where to  Breakeven

extern string s3 =  "******** Money Management Setting ********";
extern EnableDisable   MONEY_MANAGEMENT_BOOL  =  Disable;   // Money Management
extern int risk_percentage = 5;   //  Risk Percentage 
// extern ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;     
extern  string  s4   =  "******** Candle Index Setting ********";
extern  int   current_candle_index    =  1   ;   //   Current candle  Index
extern  int  previous_current_candle_index    =  2 ;   //  Previous Candle Index





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
 if(IsNewCandleCurrent())
     {

// double  iADX(
//    string       symbol,        // symbol
//    int          timeframe,     // timeframe
//    int          period,        // averaging period
//    int          applied_price, // applied price
//    int          mode,          // line index
//    int          shift          // shift
//    );
// 0 - MODE_MAIN, 1 - MODE_PLUSDI, 2 - MODE_MINUSDI

 
// double   adx_bar_blue_candle     =    iADX (  Symbol()   ,   PERIOD_CURRENT  ,   adx_period   ,applied_price     ,    MODE_PLUSDI    ,   1    )   ; 
// double   adx_bar_blue_candle_previous  =      iADX (  Symbol()   ,   PERIOD_CURRENT  ,   adx_period   ,applied_price     ,    MODE_PLUSDI    ,   2    )   ; 
// double   adx_bar_red_candle     =    iADX (  Symbol()   ,   PERIOD_CURRENT  ,   adx_period   ,applied_price     ,    MODE_MINUSDI    ,   1    )   ; 
// double   adx_bar_red_candle_previous     =    iADX (  Symbol()   ,   PERIOD_CURRENT  ,   adx_period   ,applied_price     ,    MODE_MINUSDI    ,   2    )   ; 
  
//Comment (  )

double   adx_bar_blue_candle   =   iCustom( Symbol() ,  PERIOD_CURRENT , "ADXbars"     ,  adx_period  , 5  , current_candle_index ) ;   //  positive
double   adx_bar_red_candle_previous     =   iCustom( Symbol() ,  PERIOD_CURRENT    , "ADXbars" ,adx_period , 6  , previous_current_candle_index) ; //  Negative 
double   adx_bar_red_candle   =   iCustom( Symbol() ,  PERIOD_CURRENT , "ADXbars" ,  adx_period , 6  , current_candle_index ) ; // Negative
double   adx_bar_blue_candle_previous   =   iCustom( Symbol() ,  PERIOD_CURRENT , "ADXbars" , adx_period, 5  , previous_current_candle_index ) ;  //   positive 
// Comment (  adx_bar_blue_candle     , "dddddd "   ,  adx_bar_red_candle );
// Comment   (  adx_bar_blue_candle   ,   "adx_bar_blue Candle" , adx_bar_red_candle  ,  "adx_bar_red_candle ");

// Comment (  adx_bar_red_candle   , "=========="  ,   adx_bar_blue_candle_previous   , "Google  --- >" );

// adx_bar_blue_candle    == 2.0 &&  adx_bar_red_candle_previous   ==  1.0
  if ( adx_bar_red_candle  < adx_bar_blue_candle  ){
      //   We need to take trade 
      //  Buying

      // isCountMaxTrade


if  (  alert_send_notification    ==  true     )  {

string signal_type   = "bear";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(0, Symbol()) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(0, Symbol())));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(0 , Symbol())) + "@ SL:" + DoubleToStr( fx_stop_profit_calculation(0,  Symbol())));

}




if(   trade_execution    ==  true  )    

{

        if  (  isCountMaxTrade(0 )   ==  false      )  {

      //  if (  )  {

fx_close_trade_handling(1) ;

  ////////////////////////////////////      

     if  (    trade_entry    ==    Rentry      ) {
      fx_take_trade_order(1);
     }  

      if  (   trade_entry    ==  Reverse &&    (upcommingSignal    ==  "WAITING"    ||    upcommingSignal    == "BUY")  )  {
  //Google  ===

  upcommingSignal    = "SELL";   
fx_take_trade_order(1);





      }


      //  }

        } 


  }

  }

  // adx_bar_red_candle  == 1.0   &&   adx_bar_blue_candle_previous  ==   2.0 
  if  (   adx_bar_red_candle  > adx_bar_blue_candle  ){
    //  We need to take trade 
    //  Selling Take Place 
    // isCountMaxTrade


if  (alert_send_notification   ==  true){
string signal_type   = "bull";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(1  ,  Symbol()) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(1  , Symbol())));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(1  ,  Symbol())) + "@ SL:" + DoubleToStr(  fx_stop_profit_calculation(1 ,  Symbol())));

}



   if  (  trade_execution    ==   true)   {
    if  (   isCountMaxTrade(1)   ==  false  )  {




   fx_close_trade_handling(0) ;


  ////////////////////   Addding  Signal    ///////////////////////////////   


  if (  trade_entry    ==   Rentry   ) {
fx_take_trade_order(0);
}


if  (   trade_entry     == Reverse    &&   (upcommingSignal    ==  "WAITING"    ||    upcommingSignal    == "SELL"))  {

upcommingSignal    ="BUY";
fx_take_trade_order(0);

}




}


  }




  }

  }

 if  (  (StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   start_time )    ==   0     || StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   start_time )   ==  1) && 
       ( StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   end_time )  ==  -1  ||  StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   end_time )  == 0   ) 
       ){

      //   Trading  Time
       }



 else if  (   close_trade_afer_end_time    == Enable    )  {

 if   (   (StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   end_time )    ==   0     || StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   end_time )   ==  1))  {
  //  Trade  Close Time 
     
  fx_close_mode(  true ,   "");

 } 


  }

if  (  trailling_stop_loss   == Enable ) {

fx_trail();

  }

   if(useBreakEven    ==  Enable)
     {

      fx_trail_breakeven();
     }

   
  }











//+------------------------------------------------------------------+




int   fx_order_modification(int ticket,  double  order_open_price,    double  local_storage_stop_loss,  double   order_take_profit,   int expiration, string additional,   int order_magic_number)
  {
//OrderTicket()  , OrderOpenPrice() ,local_strage ,OrderTakeProfit(), 0 , "NONE" ,  OrderMagicNumber()

// OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(StopLoss*pips),OrderOpenPrice()+(TakeProfit*pips), 0, CLR_NONE); // OP_BUY
// Alert (   local_storage_stop_loss ,   "Local Storage Stop Loss" );
   bool    res   =    OrderModify(ticket,  order_open_price,  local_storage_stop_loss,  order_take_profit,   expiration,CLR_NONE);
   if(!res)
     {
      Alert("Error in OrderModify. Error code=",GetLastError());
     }

   return    0 ;
  }



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
double  fx_take_profit_calculation(int order_type,  string symbol_mapping)
  {
   if(order_type   == 0)
     {
      return   fx_asker(symbol_mapping)   +   fx_pips_evaluation(symbol_mapping) *  take_profit* Point;
     }
   else
      if(order_type   ==  1)
        {
         return  fx_bidder(symbol_mapping )   -  fx_pips_evaluation(symbol_mapping) *  take_profit* Point;

        }

   return 0  ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stop_profit_calculation(int order_type,  string symbol_mapping)
  {
   if(order_type   == 0)
     {
      return   fx_bidder(symbol_mapping)   -   fx_pips_evaluation(symbol_mapping) *  stop_loss* Point;
     }
   else
      if(order_type   ==  1)
        {
         return   fx_asker(symbol_mapping)   +  fx_pips_evaluation(symbol_mapping) *  stop_loss* Point;

        }

   return 0  ;
  }
//+------------------------------------------------------------------+








//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation(string  symbol_mapping)
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


  int  fx_trail()
  {

   for( int fx   =    0 ;    fx < OrdersTotal()  ; fx++)
     {

      if(OrderSelect(fx,  SELECT_BY_POS))
        {
         // double point = MarketInfo(OrderSymbol(), MODE_POINT);
         //       int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);

         if(OrderType()   ==  0   &&  OrderSymbol()   ==  Symbol()   &&   OrderMagicNumber()  == MAGIC_NUMBER)
           {
            double   bid_price    =    fx_bidder(OrderSymbol()) ;


                if  ( bid_price  -  OrderOpenPrice()  >  when_to_trail_l4* fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT ))  {
            // if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l3* fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              // {
               double   local_strage  =   bid_price -  where_to_trail_l4* fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss() <  local_strage   || OrderStopLoss()  == 0.0)
                 {



                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());

                 }
    

              // }




              }
      
    



            
           }


         if(OrderType()  ==  1 &&  OrderSymbol()   == Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER )
           {
            //  Symbol Mapping Goes Here
            //     Print (  "Selling");
            double  ask_price  = fx_asker(OrderSymbol());
              // if ( SET_SL_LEVEL_3    ==  Enable   ) {
                

                   if( OrderOpenPrice() - ask_price  >  when_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               
               double  local_strage   =  ask_price + where_to_trail_l4  * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
              // Alert (  )
               if(OrderStopLoss()  >  local_strage || OrderStopLoss()  == 0.0 )
                 {
                    // Alert   ( "================Googel ===============" );
                  
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());


                 }

              }
 




           }
           
  /*         
           if(StringToDouble(OrderStopLoss()) == 0.0   &&    (take_profit_bool    == Enable   ||   stop_loss_bool  == Enable))
              {

              //  fx_order_modification(OrderTicket(), OrderOpenPrice(),stop_loss_bool   == Enable  ?  fx_stop_profit_calculation(OrderType(), OrderSymbol()) : 0 ,take_profit_bool   == Enable ? fx_take_profit_calculation(OrderType(), OrderSymbol()) :   0 , 0, "NONE",  OrderMagicNumber());

              }


*/
        }


     }


   return   0 ;
  }


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

      if (  addtional   == "")
     { if(OrderType() == OP_BUY  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
        }}


        if  ( addtional  == "1"   ||  addtional   =="0"  )  {
          if(OrderType() == OP_BUY  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER  && StringToInteger(addtional)   ==   0 )
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER && StringToInteger(addtional)   ==   1)
        {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
        }
        }


      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }





   return 0  ;
  }


  int  fx_take_trade_order(int order_type)
  {
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);


      

   bool  response_order  =  OrderSend(Symbol(),order_type,    fx_lots_mapping ( Lots  ,  stop_loss_set   ==   Enable    ? fx_stop_profit_calculation(order_type   , Symbol())   :  0,  take_profit_set   == Enable   ?  fx_take_profit_calculation(order_type , Symbol())    :        0  , order_type ),order_type ==  0  ?  Ask :  Bid,10,  stop_loss_set   ==   Enable    ? fx_stop_profit_calculation(order_type   , Symbol())   :  0,  take_profit_set   == Enable   ?  fx_take_profit_calculation(order_type , Symbol())    :        0,true,MAGIC_NUMBER,0,clrNONE);

   if(!response_order)
     {
      Print(GetLastError(),   "GetLastError()========================");
     }
   else
     {

     }




   return 0 ;
  }

   


   double   fx_lots_mapping( double   Lots,  double     stop_loss_value , double   take_profit_value  ,  int   order_type   )  {
      

if  (   MONEY_MANAGEMENT_BOOL    ==  Enable   )
{
if  (  stop_loss_set     == Enable  )  {

double min_value    =  MarketInfo(Symbol(),MODE_MINLOT);
if  ( order_type   ==    0  )  {
  
double  sladjust   =      Bid   -  stop_loss_value   ;   

  
  
 return   min_value  <=    GetLots (  sladjust    )   ?    GetLots (  sladjust    ) :     min_value ;        

}
if   ( order_type    ==  1 )  {
double   sladjust      =    stop_loss_value     - Ask  ;  
return  min_value  <=    GetLots (  sladjust    )   ?    GetLots (  sladjust    )  :     min_value  ;

}     
}

}

     return    Lots   ;  
   }
   
   



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





   bool  isCountMaxTrade(  int   order_type){

int   count_trade      =  0 ;
  for (   int  i   = 0   ;   i <   OrdersTotal()   ;  i++  ) {

      if  (   OrderSelect(    i  , SELECT_BY_POS )  ) {
           if  ( OrderType()   ==   order_type    &&  OrderSymbol()   ==  Symbol()   &&   OrderMagicNumber()   == MAGIC_NUMBER ){
                count_trade  =  count_trade  +1;
           }

      
       if ( OrdersTotal()-1   ==   i )  {
            if  (  count_trade   >=   MAX_NUMBER_OF_BUY_TRADE  ){
              return   true   ;  
            }
            if  (  count_trade   >=   MAX_NUMBER_OF_SELL_TRADE  ){
              return   true   ;  
            }
       }
      }
  }
   


return   false ; 
  }
bool max_number_of_trade(  int  order_type_mapping    ) {

   int   count_trade_sell    =   0  ; 
   int count_trade_buy    =  0 ;
 
 for  ( int  fx  =  0   ;    fx <OrdersTotal()  ;  fx++) {

  if  ( OrderSelect(fx ,   SELECT_BY_POS)){
        if (  OrderType()   ==  OP_BUY   &&  OrderType()    ==  order_type_mapping ) {
              count_trade_buy   =  count_trade_buy  +1  ;
              if  ( count_trade_buy   <=      MAX_NUMBER_OF_BUY_TRADE){
              }
                  return   true ; 

        }

        if(  OrderType()    ==  OP_SELL && OrderType()   ==   order_type_mapping)  {

            if  (   count_trade_sell  <=   MAX_NUMBER_OF_SELL_TRADE) {
             count_trade_sell    =  count_trade_sell    +  1;
             return    true;
             }
        }

  }


 }


 return  false;
    

}




double GetLots(double SLAdjustment)
  {

   double lot;
   if(SLAdjustment !=0)
     {
      double riskAmount = risk_percentage;
      riskAmount = riskAmount/100;
      double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
      double moneyRisk = AccountEquity() * riskAmount;
      double tickMovement = SLAdjustment/Point;
      double tickMovementValue = tickMovement * tickVal;
      lot= NormalizeDouble(moneyRisk / tickMovementValue,2);
      
     }
   return(lot);
  }
  
int fx_close_trade_handling(int order_type  )  {
 
 for  (   int    i   =  0   ;i <  OrdersTotal()  ; i++){

      int Slippage = 0;
      double floating_profit;
      double  opposite_floating_profit ; 
      bool   res  ;  
      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
      
        if (  trade_closing_method  == close_all_opposite_order) {
      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY && order_type    ==   OrderType()  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      if(OrderType() == OP_SELL&& order_type    ==   OrderType() && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
        }
        }


if (  trade_closing_method  == close_opposite_order_when_profit) {
      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY && order_type    ==   OrderType()  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
        //  res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        opposite_floating_profit    =  opposite_floating_profit   + OrderProfit()  +  OrderSwap()  +  OrderCommission()   ;  
        }
      if(OrderType() == OP_SELL&& order_type    ==   OrderType() && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER)
        {
        //  res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
        opposite_floating_profit    =  opposite_floating_profit   + OrderProfit()  +  OrderSwap()  +  OrderCommission()   ;  
        }
        }

   if(  trade_closing_method   ==  do_not_close_order   )  {
     return  true; 
   }
 
 if (  trade_closing_method  == close_all_order_when_in_profit) {
      // Closing the order using the correct price depending on the type of order.


      floating_profit  =    floating_profit + OrderProfit()  +  OrderSwap()  +  OrderCommission()   ;  
   if (  OrdersTotal() -1   ==   i)  {

      if ( floating_profit + AccountBalance() > AccountBalance()) {

      fx_close_mode(true  , ""); 

      }
   }


 }



 if (  trade_closing_method  == close_opposite_order_when_profit) {
      // Closing the order using the correct price depending on the type of order.


      opposite_floating_profit  =    opposite_floating_profit + OrderProfit()  +  OrderSwap()  +  OrderCommission()   ;  
   if (  OrdersTotal() -1   ==   i)  {


       if ( opposite_floating_profit + AccountBalance() > AccountBalance()) {

      fx_close_mode(true  , order_type); 

       }
   }


 }     

 }

  return    0   ; 
}




int  fx_trail_breakeven()
  {
   for(int b = OrdersTotal() -1  ;  b>=  0   ;   b--)
     {
      if(OrderSelect(b,  SELECT_BY_POS))
        {
         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol() &&  OrderMagicNumber()   == MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l1 *fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double   local_strage  =   OrderOpenPrice()  +  where_to_trail_l1* fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss()   <   OrderOpenPrice()  && ask_price  >OrderOpenPrice())
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }
           }


         if(OrderType()  ==  1   &&   OrderSymbol()    == Symbol() && OrderMagicNumber()   == MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double  local_strage   =   OrderOpenPrice()  - where_to_trail_l1   * fx_pips_evaluation(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
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



  /*
Requirement 

please help make this indicator into EA
when blue : buy
when red : sell
- option to change the parameter of the indicator

features
- take profit, trailing stop, breakeven
- risk lot / auto lot
- number order per signal
- do/do not take order for consequtive signal ( to make order per open bar/candle )
- add lot size if previous order loss ( for every closed order, closed trade same order type,every open trades, open trades same order type, all trades )
- close trade at opposite signal ( close all oppsite order, close opposite orde when in profit, do not close order, close all order when in profit, close all martiangle order )
- max number of trade
- max number of buy
- max number of sell
- time filter
( using local time
/ pc time )-
close all trader after end time ( true/false )
-magic number

 

*/