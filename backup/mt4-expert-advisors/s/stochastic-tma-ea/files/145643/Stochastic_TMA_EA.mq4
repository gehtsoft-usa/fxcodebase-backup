// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72071

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


enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };

extern  string   s0   =  " ==== EA Setting ====== " ;    
extern   double   take_profit   = 10   ; 
extern  double    stop_loss   =  10   ; 
extern   double   Lots  =    0.01  ;
extern  int MAGIC_NUMBER  = 398376;
extern  string trade_comment  = "Comment"; // Comment
extern  bool  alert_send_notification  =  true ;    //  Alert / Send Notification
extern bool   trade_execution    =  true   ;  //  Trade Execution


extern    string  s1  = "==============================Setting   of  Moving Average ==============================" ;
extern ENUM_TIMEFRAMES timeframe  = PERIOD_CURRENT;
extern  int  MA_PERIOD   =  10  ;
extern    ENUM_MA_METHOD  MA_METHOD   = MODE_SMA;
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD   =   PRICE_CLOSE;



extern string   LabelSto            = "====================Stochastic Settings=================";

// Stochastic KPeriod
extern int      KPeriod             = 6;
// Stochastic DPeriod
extern int      DPeriod             = 3;
// Stochastic Slowing
extern int      Slowing             = 3;

extern    ENUM_MA_METHOD  STOCHASTIC_MA_METHOD   = MODE_SMA;  //  Stochastic  MA Method

double   stochastic_buy_level   =   50  ;


double    stochastic_sell_level   =  50 ;
int  index    =   0 ;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

/*

SIGNAL BUY: You have to give a buy signal when the stochastic oscillator crosses the blue line above the red line and is below the 50 level; at the same time the price has to be above the 10 simple EMA, and the price has to be below the center line of the TMA.

SIGNAL SELL: It has to give a buy signal when the stochastic oscillator crosses the red line above the blue one and is above the 50 level; at the same time the price has to be below the 10 simple EMA, and the price has to be above the center line of the TMA.

Adds the option to modify the EMA, stochastic and TMA

*/
extern  string s2 =  "======= Setting  For  indicator  ===="   ;
extern string TimeFrame       = "current time frame";
extern int    HalfLength      = 56;
extern int    Price           = PRICE_WEIGHTED;
extern double BandsDeviations = 1.618;
extern bool   Interpolate     = true;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsOnHighLow = false;
datetime   NewCandleTimeCurrent    ;


extern   EnableDisable  trailling_stop_loss     =    Disable;
extern  double when_to_trail_l4      =   20 ;  //  When to trail
extern  double where_to_trail_l4   =   10 ;   //  Where to trail

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

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

      double   moving_average_current  =      iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,1);
      double stoc_0=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,STOCHASTIC_MA_METHOD,1,0,1);   //   K line
      double stoc_1=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,STOCHASTIC_MA_METHOD,1,1,1);   //   D line
      double previous_stoc_0=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,STOCHASTIC_MA_METHOD,1,0,2);   //   K line
      double previous_stoc_1=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,STOCHASTIC_MA_METHOD,1,1,2);   //   D line

      double   tma_mladen    =   iCustom(Symbol(),  PERIOD_CURRENT, "TMA+CG", TimeFrame,HalfLength, Price,BandsDeviations,Interpolate, alertsOn,alertsOnCurrent, alertsOnHighLow, 0, 1) ;                 //  positive

      if(stoc_0   <  stochastic_buy_level)
        {

         if(previous_stoc_0 < previous_stoc_1 && stoc_0 > stoc_1)
           {
         
            if(Ask  >=   moving_average_current)
              {
         
               if(tma_mladen >=  Ask)
                 {
         

             if  (  trade_execution    == true)  {

fx_take_trade_order(  0   ) ; 

             } 

              if  (  alert_send_notification    == true ) {
        string signal_type   = "bull";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(0) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(0)));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr( fx_stop_profit_calculation(0)));
      }    
                 


                 }


              }





           }


        }

      if(stoc_0    >   stochastic_sell_level)
        {
         //  For  Selling  Concept
         if(previous_stoc_0 >previous_stoc_1 && stoc_0 < stoc_1)
           {
            
            if(Bid  <=   moving_average_current)
              {
               
               if(tma_mladen <=  Ask)
                 {
                  
if  (  trade_execution   ==  true)  {

fx_take_trade_order(1) ; 

}
 if  (  alert_send_notification    == true ) {
        string signal_type   = "bear";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(0) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(0)));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr( fx_stop_profit_calculation(0)));
      }


                 }
              }


           }



        }



     }

if  (  trailling_stop_loss   == Enable ) {

fx_trail();

  }
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



  double  fx_take_profit_calculation( int order_type  ){

 
  if (order_type   == 0){
      return   Ask  +  fx_pips_evaluation() *  take_profit* Point;
  }
  else  if(  order_type   ==  1){
    return   Ask   -  fx_pips_evaluation() *  take_profit* Point;

  }

  return 0  ; 
}



   double  fx_stop_profit_calculation( int order_type  ){


  if (order_type   == 0){
      return   Bid  -  fx_pips_evaluation() *  stop_loss* Point;
  }
  else  if(  order_type   ==  1){
    return   Ask   +  fx_pips_evaluation() *  stop_loss* Point;

  }

  return 0  ; 
}



  int  fx_take_trade_order(int order_type)
  {
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);

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



  int fx_pips_evaluation()
  {
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



 int  fx_trail()
  {

   for( int fx   =    0 ;    fx < OrdersTotal()  ; fx++)
     {

      if(OrderSelect(fx,  SELECT_BY_POS))
        {
         if(OrderType()   ==  0   &&  OrderSymbol()   ==  Symbol()   &&   OrderMagicNumber()  == MAGIC_NUMBER)
           {
            double   bid_price    =    fx_bidder(OrderSymbol()) ;


                if  ( bid_price  -  OrderOpenPrice()  >  when_to_trail_l4* fx_pips_evaluation_3(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT ))  {

               double   local_strage  =   bid_price -  where_to_trail_l4* fx_pips_evaluation_3(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss() <  local_strage   || OrderStopLoss()  == 0.0)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
    

              // }




              }
      
    



            
           }


         if(OrderType()  ==  1 &&  OrderSymbol()   == Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER )
           {
            double  ask_price  = fx_asker(OrderSymbol());
                   if( OrderOpenPrice() - ask_price  >  when_to_trail_l4 * fx_pips_evaluation_3(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               
               double  local_strage   =  ask_price + where_to_trail_l4  * fx_pips_evaluation_3(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  >  local_strage || OrderStopLoss()  == 0.0 )
                 {
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



  int fx_pips_evaluation_3(string  symbol_mapping)
  {
   int digits = (int)MarketInfo(symbol_mapping, MODE_DIGITS);
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


  int   fx_order_modification(int ticket,  double  order_open_price,    double  local_storage_stop_loss,  double   order_take_profit,   int expiration, string additional,   int order_magic_number)
  {
   bool    res   =    OrderModify(ticket,  order_open_price,  local_storage_stop_loss,  order_take_profit,   expiration,CLR_NONE);
   if(!res)
     {
     // Alert("Error in OrderModify. Error code=",GetLastError());
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
