// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71633


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

//+------------------------------------------------------------------------------------------------+
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

extern  int  trade_arrow_execution  =   2   ;   //  No of arrow to execute trade
extern  double  Lots  =   0.10;
extern  double take_profit   = 10; //  Take Profit
extern  double stop_loss   = 10; // Stop Loss
extern int  MAGIC_NUMBER  =   1226584;

extern bool   trade_execution    =  true   ;  //  Trade Execution
extern  bool  alert_send_notification  =  true ;    //  Alert / Send Notification



bool   buy_side  = true;   
bool  sell_side  =  true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {



   
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

fx_indicator_mapping();


  }



  int fx_indicator_mapping(){

//---
string  sequential_array[];
for  (  int i  =   0 ;   i <   200   ;   i++ ){
double   data_sell   =   iCustom( Symbol() ,  PERIOD_CURRENT , "mladen_indicator" , 4  , i ) ;
double   data_buy  =   iCustom( Symbol() ,  PERIOD_CURRENT , "mladen_indicator" , 3  , i ) ;






 if  (  data_buy   != 2147483647.0 ) {
 ArrayResize(sequential_array,ArraySize(sequential_array)+1);
 sequential_array[ArraySize(sequential_array) -1]  =    "BUY";
    
    
 } 
 
 
 if  (  data_sell  != 2147483647.0 ){
 ArrayResize(sequential_array,ArraySize(sequential_array)+1);
  sequential_array[ArraySize(sequential_array) -1]  = "SELL";
  

 
 }


   
 
  
   }   
   
   
   
   // Print Recent  
   
   int  count_buy  = 0   ;  
   int count_sell   =  0;
   
   for  (   int  j =   0  ;   j <    trade_arrow_execution && j <  ArraySize(sequential_array) ;   j++ ){
   
 
 
   
   
   if  (  sequential_array[j] == "BUY"){
 count_buy  =  count_buy +  1;  
   }
   
   if  (  sequential_array[j] == "SELL" )   {
   
   
   count_sell =  count_sell + 1;
   
   }
 
 if  (   trade_arrow_execution-1    ==    j)   {
 
 
 if  (  count_buy   == trade_arrow_execution  )   {
 
 
 
 if  ( buy_side   ==  true  )   {
buy_side   =  false   ; 
sell_side   =  true;

if(alert_send_notification   ==  true  ){
string signal_type   = "bull";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(0) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(0)));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr( fx_stop_profit_calculation(0)));
}


 if (  trade_execution     == true  )   {
 
 fx_take_trade_order(    0     )   ; 
 
 
 }
 }
 

 
 

 
  }  

  if  (  count_sell   == trade_arrow_execution  )   {
 
 
 
 
 if (sell_side   == true  )  {

   buy_side    = true  ; 
   sell_side  =  false;

if  (alert_send_notification   ==  true){
string signal_type   = "bear";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(1) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(1)));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(1)) + "@ SL:" + DoubleToStr(  fx_stop_profit_calculation(1)));

}

 if  (  trade_execution   ==   true  )   {
 
  fx_take_trade_order( 1 )   ;
  
  } 
 
 }


}

  
 

 
 
 
 }
   
   } 



    return 0 ;
  }
  
  
  
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



  int fx_pips_evaluation()
  {
   double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   if(ticksize == 0.00001 || ticksize == 0.001)
     {
      return   10;
      //LotSize =  0.01;
     }
   else
     {
      return 1;
     }

   return 0;
  }