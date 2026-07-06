// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72681

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
//|                                                                       https://mario-jemic.com/ |
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
extern    string indicator_set  =  "================Setting Indicator =============================";
extern int  VP_Bars    =  1000 ;  
extern int   VP_Version   =  1; 
extern  bool     VP_Alert  =   0 ;
extern  bool    VP_Channel_Alerts  =  0;
extern  bool  Email_Signal   =  0;
extern int   VP_WMA  =  3 ; 
extern int  SlowerWMA = 8  ;  
extern int FasterSidusEMA    =   18 ; 
extern int SlowerSidus     =  28 ; 



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
/*
Hi fellow traders .. i need help coding an ea that works with following rules .
1. buy arrow appear on closed bull renko bar .. ea takes buy position
2.sell arrow appear on closed bear renko bar .. ea takes sell position
3. ea have original indicator settings and i can change it if needed
4. ea have money managment
5 . ea have sl and tp
6 ea have partial close and breakeven option
i really hope some one will be nice enough to code it ..
indicator could be downloaded form this post attachment

*/

enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };

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

extern  string  start_time  =  "01:00" ;    //  Start Time  HH:MM
extern string   end_time   =   "23:00"  ;  // End Time HH:MM
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

extern  EnableDisable    useBreakEven   = Disable  ;  // Breakeven
extern   double  when_to_trail_l1   =    7      ;   //  When To Breakeven
extern  double    where_to_trail_l1  =     1;    //  Where to  Breakeven

extern string s3 =  "******** Money Management Setting ********";
extern EnableDisable   MONEY_MANAGEMENT_BOOL  =  Disable;   // Money Management
extern int risk_percentage = 5;   //  Risk Percentage 
// extern ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;     

int  index    = 0  ; 
string  time_mapping  =    "NONE" ;  




string    upcommingSignal      =  "NONE"  ;


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
 int  start ()
  {

   

/*
Hi fellow traders .. i need help coding an ea that works with following rules .
1. buy arrow appear on closed bull renko bar .. ea takes buy position
2.sell arrow appear on closed bear renko bar .. ea takes sell position
3. ea have original indicator settings and i can change it if needed
4. ea have money managment
5 . ea have sl and tp
6 ea have partial close and breakeven option
i really hope some one will be nice enough to code it ..
indicator could be downloaded form this post attachment
*/

if(  IsNewCandleCurrent()) {



//  Variable On  indicator  
//  int  VP_Bars    =  1000 ;  
//  int   VP_Version   =  1; 
//   bool     VP_Alert  =   0 ;
//   bool    VP_Channel_Alerts  =  0;
//   bool  Email_Signal   =  0;
//  int   VP_WMA  =  3 ; 
//  int  SlowerWMA = 8  ;  
//  int FasterSidusEMA    =   18 ; 
//  int SlowerSidus     =  28 ; 


double   valukanProfit_Buy   = iCustom(Symbol(), PERIOD_CURRENT, "Vulkan_Profit",VP_Bars  , VP_Version   ,VP_Alert  , VP_Channel_Alerts  ,  Email_Signal   , VP_WMA , SlowerWMA , FasterSidusEMA , SlowerSidus  , 0  , 1);
double   valukanProfit_Sell   = iCustom(Symbol(), PERIOD_CURRENT, "Vulkan_Profit",VP_Bars  , VP_Version   ,VP_Alert  , VP_Channel_Alerts  ,  Email_Signal     , VP_WMA , SlowerWMA , FasterSidusEMA , SlowerSidus , 1  ,1);
double   valukanProfit_Buy_buy  = iCustom(Symbol(), PERIOD_CURRENT, "Vulkan_Profit",VP_Bars  , VP_Version   ,VP_Alert  , VP_Channel_Alerts  ,  Email_Signal   , VP_WMA , SlowerWMA , FasterSidusEMA , SlowerSidus  , 2  , 1);
double   valukanProfit_Sell_sell   = iCustom(Symbol(), PERIOD_CURRENT, "Vulkan_Profit",VP_Bars  , VP_Version   ,VP_Alert  , VP_Channel_Alerts  ,  Email_Signal     , VP_WMA , SlowerWMA , FasterSidusEMA , SlowerSidus , 3  ,1);
 


  // ObjectCreate(0,"HORIZONTAL_2"+ index++,OBJ_VLINE,0,Time[i],0);






if   (  valukanProfit_Buy   !=    2147483647.0     || valukanProfit_Buy_buy  !=    2147483647.0         )  {
      // For  Buying Concept  Here 
 
  
// ObjectCreate(0,"Buying"+ index++,OBJ_VLINE,0,Time[1],0);
if  (  alert_send_notification    ==  true   &&  fx_time_mapping()   ==  true       )  {

string signal_type   = "bull";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(0, Symbol()) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(0, Symbol())));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(0 , Symbol())) + "@ SL:" + DoubleToStr( fx_stop_profit_calculation(0,  Symbol())));
// break ; 
}

if  (  trade_execution    ==   true)   {
if  (  isCountMaxTrade(0 )   ==  false    &&  fx_time_mapping()   ==  true       )  {
fx_take_trade_order(0);

}

}
  
time_mapping    =    Time[1];

//break ; 
}
if  (    valukanProfit_Sell  !=   2147483647.0      ||  valukanProfit_Sell_sell  !=   2147483647.0  ) {
    // For Selling  Concept Here 
    if  (alert_send_notification   ==  true    &&  fx_time_mapping()   ==  true   ){
string signal_type   = "bear";
Alert (signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr (fx_take_profit_calculation(1  ,  Symbol()) ) + "@ SL:" + DoubleToStr ( fx_stop_profit_calculation(1  , Symbol())));
SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr( fx_take_profit_calculation(1  ,  Symbol())) + "@ SL:" + DoubleToStr(  fx_stop_profit_calculation(1 ,  Symbol())));
 
}



if  (  trade_execution    ==   true)   {

if  (  isCountMaxTrade(1 )   ==  false    &&  fx_time_mapping()   ==  true     )  {
fx_take_trade_order(1);
}

}
time_mapping    =    Time[1];


}




}

   if  (  trailling_stop_loss   == Enable ) {

fx_trail();

  }

   if(useBreakEven    ==  Enable)
     {

      fx_trail_breakeven();
     }

return    0 ;
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
           
        }


     }


   return   0 ;
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


    bool IsNewCandleCurrent()
  {

// return    true ;  
   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 1))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 1);
      return true;
     }





  }




  bool     fx_time_mapping(){
 return    true;  
 
 if  (  (StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   start_time )    ==   0     || StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   start_time )   ==  1) && 
       ( StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   end_time )  ==  -1  ||  StringCompare(TimeToString(   TIME_MODE_SELECTION ==  server_time_start_stop_time   ?  TimeCurrent()  :  TimeLocal() , TIME_MINUTES) ,   end_time )  == 0   ) 
       ){
        
       
       return  true    ;  
       }

       else   { 

         false    ;
       }

    return    false      ;  
  }



