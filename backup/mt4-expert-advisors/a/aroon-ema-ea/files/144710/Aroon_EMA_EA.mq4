// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71787

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

enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };

//Setting of Slow Moving Average
datetime  NewCandleTimeCurrent ;
extern    string s2    = "Setting  of Slow MOving  Average";
extern ENUM_TIMEFRAMES timeframe_slow_moving  = PERIOD_CURRENT;   // MA TIMEFRAME
extern  int  MA_PERIOD   =  50  ;
extern    ENUM_MA_METHOD  MA_METHOD_MOVING   = MODE_SMA;
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD_MOVING   =   PRICE_CLOSE;



//  Setting of RSI
extern  string  s4  =   "Setting of RSI" ;
extern  ENUM_TIMEFRAMES   rsi_timeframe   = PERIOD_CURRENT  ; // RSI TIMEFRAME
extern  int   rsi_period   =  14 ;
extern   ENUM_APPLIED_PRICE RSI_APPLIED   =  PRICE_CLOSE ;



//  Setting of   Default
extern   EnableDisable     take_profit_set  =   Disable  ;
extern   double   take_profit   = 10   ;

extern    EnableDisable   stop_loss_set   =   Disable ;
extern  double    stop_loss   =  10   ;
extern   double   Lots  =    0.01  ;
extern  int MAGIC_NUMBER  = 398376;
extern  string trade_comment  = "Comment"; // Comment
extern  bool  alert_send_notification  =  true ;    //  Alert / Send Notification
extern bool   trade_execution    =  true   ;  //  Trade Execution
int index  = 0 ;

//+------------------------------------------------------------------+
//|                                                                  |
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
//---
   if(IsNewCandleCurrent())
     {



      // fx_handling();

      // Long when price crosses above EMA and Aroon long signal crosses above.
      // Exit Long when MACD crosses below and RSI crosses below 70.

      // Short when price crosses below EMA and Aroon short signal crosses above.
      // Exit Short when MACD crosses above and RSI crosses above 30


      // Optional Exit signal on the RSI 50 line.

      // Exit Long when MACD crosses below and RSI crosses below 50
      // Exit Short when MACD crosses above and RSI crosses above 50
      double   data_macd_line   =   iCustom(Symbol(),  PERIOD_CURRENT, "MACD_True", 0, 1) ;
      double   data_macd_line_2  =   iCustom(Symbol(),  PERIOD_CURRENT, "MACD_True", 0, 2) ;
      double    data_signal_line  =  iCustom(Symbol(),  PERIOD_CURRENT, "MACD_True", 1, 1) ;
      double    data_signal_line_2  =  iCustom(Symbol(),  PERIOD_CURRENT, "MACD_True", 1, 2) ;


      double   data_bar_macd_line   = iCustom(Symbol(),  PERIOD_CURRENT, "MACD True", 2, 1) ;
      //  Zero   For  Macd line   0
      //Signal Line Macd  Line  1
      //  Bar For MACD Line 2
      double rsi_current    =    iRSI(Symbol(), rsi_timeframe, rsi_period, RSI_APPLIED, 1);
      double  moving_average  =     iMA(NULL, timeframe_slow_moving, MA_PERIOD, 0, MA_METHOD_MOVING, MA_APPLIED_PERIOD_MOVING, 1)  ;


      /// Testing  Aroon   Up  Value Goes Here
      double   data_aroon_up_value        =    iCustom(Symbol(),  PERIOD_CURRENT, "Aroon_Up_Down_2", 0, 1) ;
      double   data_aroon_up_value_2       =    iCustom(Symbol(),  PERIOD_CURRENT, "Aroon_Up_Down_2", 0, 2) ;
      double   data_aroon_down_value        =    iCustom(Symbol(),  PERIOD_CURRENT, "Aroon_Up_Down_2", 1, 1) ;
      double   data_aroon_down_value_2        =    iCustom(Symbol(),  PERIOD_CURRENT, "Aroon_Up_Down_2", 1, 2) ;



      //    Short Trade
      //  Close[1]  < moving_average
      if(Close[1]    <   moving_average)
        {
         // data_aroon_down_value      >  data_aroon_up_value   &&  data_aroon_down_value_2   <  data_aroon_up_value_2
         if(data_aroon_down_value  >   data_aroon_up_value   &&   data_aroon_down_value_2  <  data_aroon_up_value_2)
           {
            //  Close  the  Sell Trade


            if(trade_execution    ==  true)
              {


               fx_take_trade_order(1)  ;

              }


            if(alert_send_notification    == true)
              {
               string signal_type   = "bear";
               Alert(signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr(fx_take_profit_calculation(1)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(1)));
               SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr(fx_take_profit_calculation(1)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(1)));
              }


           }


        }


      //   if  short
      //  Exist of Short Trade

      if(data_macd_line_2  <data_signal_line_2  && data_macd_line  > data_signal_line  && rsi_current   > 30)
        {
         // ObjectCreate(0,"HORIZONTAL_2" + index++,OBJ_VLINE,0,Time[1],0);
         fx_exist_trade(1)  ;


        }






      //   Long trade
      //   Close[1]   >  moving_average
      if(Close[1]  >  moving_average)
        {

         if(data_aroon_down_value     <  data_aroon_up_value   &&  data_aroon_down_value_2  >  data_aroon_up_value_2)
           {
            //

            fx_take_trade_order(0)  ;

            if(alert_send_notification    == true)
              {
               string signal_type   = "bull";
               Alert(signal_type  == "bear"  ?  "Sell" :  "Buy" + "@ TP:" + DoubleToStr(fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(0)));
               SendNotification(signal_type  == "bear"  ?  "Sell" :  "Buy"  + "@ TP:" + DoubleToStr(fx_take_profit_calculation(0)) + "@ SL:" + DoubleToStr(fx_stop_profit_calculation(0)));


              }


           }


        }
      //  Exist of Long Trade

      if(data_macd_line_2  >data_signal_line_2  && data_macd_line  < data_signal_line && data_macd_line   && rsi_current  < 70)
        {
         if(trade_execution    == true)
           {
            // ObjectCreate(0,"HORIZONTAL_2" + index++,OBJ_VLINE,0,Time[1],0);

            fx_exist_trade(0);

           }



        }




     }




  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  fx_take_trade_order(int order_type)
  {
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);

   bool  response_order  =  OrderSend(Symbol(),order_type,  Lots,order_type ==  0  ?  Ask :  Bid,10,  stop_loss_set   ==   Enable    ? fx_stop_profit_calculation(order_type)   :  0,  take_profit_set   == Enable   ?  fx_take_profit_calculation(order_type)    :        0,true,MAGIC_NUMBER,0,clrNONE);

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
int    fx_exist_trade(int  order_type)
  {

   for(int  i   = 0  ;    i <  OrdersTotal()   ;   i++)
     {
      if(OrderSelect(i,  SELECT_BY_POS))
        {
         //
         double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
         double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
         int Slippage = 0;
         if(OrderType()     ==  order_type    &&    OrderMagicNumber()   ==  MAGIC_NUMBER)
           {
            bool     res  =    OrderClose(OrderTicket(), OrderLots(),    OrderType()  ==  0   ? BidPrice  :  AskPrice, Slippage);
            if(res)
              {
               Print("  Order Close Successfully !!!");
              }
            else
              {
               Print(" Order Not  CLose ");
              }

           }

        }


     }



   return    0 ;
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
