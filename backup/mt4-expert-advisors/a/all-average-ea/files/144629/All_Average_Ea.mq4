// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71760

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
#property strict






//  iMA(NULL, PERIOD_CURRENT, 28, 0, MODE_SMA, PRICE_CLOSE, 0)
//  Setting   of  Fast Moving Average


datetime  NewCandleTimeCurrent ;

extern    string  s1  = "Setting   of  Fast Moving Average" ;
extern ENUM_TIMEFRAMES timeframe  = PERIOD_CURRENT; 
extern  int  MA_PERIOD   =  14  ;   
extern    ENUM_MA_METHOD  MA_METHOD   = MODE_SMA;
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD   =   PRICE_CLOSE;  





//Setting of Slow Moving Average 
extern    string s2    = "Setting  of Slow MOving  Average";  
extern ENUM_TIMEFRAMES timeframe_slow_moving  = PERIOD_CURRENT; 
extern  int  MA_PERIOD_SLOW_MOVING   =  200  ;   
extern    ENUM_MA_METHOD  MA_METHOD_SLOW_MOVING   = MODE_SMA;
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD_SLOW_MOVING   =   PRICE_CLOSE; 


//  Setting  of ADX
extern   string  s3   =  "Setting of ADX" ; 
extern   ENUM_TIMEFRAMES  adx_timefame  =   PERIOD_CURRENT ; 
extern   int   adx_period  =   14;  
extern   ENUM_APPLIED_PRICE  ADX_APPLIED_PRICE =  PRICE_CLOSE   ;



//  Setting of RSI
extern  string  s4  =   "Setting of RSI" ;  
extern  ENUM_TIMEFRAMES   rsi_timeframe   = PERIOD_CURRENT  ; 
extern  int   rsi_period   =  14 ; 
extern   ENUM_APPLIED_PRICE RSI_APPLIED   =  PRICE_CLOSE ; 


//  Setting of   Default
extern   double   take_profit   = 10   ; 
extern  double    stop_loss   =  10   ; 
extern   double   Lots  =    0.01  ;
extern  int MAGIC_NUMBER  = 398376;
extern  string trade_comment  = "Comment"; // Comment
extern  bool  alert_send_notification  =  true ;    //  Alert / Send Notification
extern bool   trade_execution    =  true   ;  //  Trade Execution


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
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
 
if(IsNewCandleCurrent()){



fx_handling();



}

 




   
  }



  int   fx_handling() {
double      slow_moving_current   =         iMA(Symbol(), timeframe_slow_moving , MA_PERIOD_SLOW_MOVING , 0, MA_METHOD_SLOW_MOVING, MA_APPLIED_PERIOD_SLOW_MOVING,1);  
double  slow_moving_previous  =    iMA(Symbol(), timeframe_slow_moving , MA_PERIOD_SLOW_MOVING , 0, MA_METHOD_SLOW_MOVING, MA_APPLIED_PERIOD_SLOW_MOVING,2);  
double   moving_average_current  =      iMA(Symbol(), timeframe , MA_PERIOD , 0, MA_METHOD, MA_APPLIED_PERIOD,1);  
double   moving_average_previous  =      iMA(Symbol(), timeframe , MA_PERIOD , 0, MA_METHOD, MA_APPLIED_PERIOD,2);  

double rsi_current   =    iRSI(Symbol(), rsi_timeframe, rsi_period, RSI_APPLIED, 1);
double  rsi_previous  =  iRSI(Symbol(), rsi_timeframe, rsi_period, RSI_APPLIED, 2);

double  adx_current  =   iADX(Symbol()  , adx_timefame  , adx_period , ADX_APPLIED_PRICE ,MODE_MAIN  ,  1) ; 
// double adx_previos  =   iADX(Symbol()  , adx_timefame  , adx_period , ADX_APPLIED_PRICE , MODE_MAIN,  2) ; 


//  
//First index Fast Line Moving (50)  > First Simple Line Moving  ( 200)
//Second index Fast Line Moving(50)   <  Second index Simple  Line Moving (200) 
//   For  Buying 



//   Fast Moving Average   Cross Slow Moving Average
   if    (  moving_average_current    >  slow_moving_current   &&   moving_average_previous    <   slow_moving_previous  ){
if   (adx_current >  30  &&     adx_current   <  45        ) {
  //
   if  (  rsi_current >   50    &&  rsi_current     <    70  ){
      // Buying 
      Comment ("Buying    ====== ");

      if  ( trade_execution    ==  true){

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
//First index Fast Line Moving (50)  < First Simple Line Moving  ( 200)
//Second index Fast Line Moving(50)   >  Second index Simple  Line Moving (200) 
//  For Selling 
//   Fast Moving Average   Cross Slow Moving Average
if   (   moving_average_current   <    slow_moving_current  &&    moving_average_previous  >   slow_moving_previous       )  {
if  (  adx_current   >  30     &&   adx_current   <  45 ) {
   if  (  rsi_current > 30    &&   rsi_current  <    50  ) {
     // Selling
     Comment ("Selling  ====== ");
     if  (  trade_execution    == true   ) {
     fx_take_trade_order(1) ; 

     }

     if (  alert_send_notification    == true )  {
     string signal_type   = "bear";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(1) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(1)));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(1)) + "@ SL:" + DoubleToStr(  fx_stop_profit_calculation(1)));


     }
   }
}

  }




    return   0 ; 
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


  
/*
BUY RULE:
Fast MA crosses above Slow MA
ADX (14) > 30, ADX (14) < 45
RSI (14) > 50, RSI (14) < 70

SELL RULE:
Fast MA crosses below Slow MA
ADX (14) > 30, ADX (14) < 45
RSI (14) > 30, RSI (14) < 50
*/