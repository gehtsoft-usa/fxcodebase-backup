// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72178
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
#property indicator_chart_window

#property indicator_buffers 3
double BuyArrow[];
double SellArrow[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern    string  s1  = "===Setting   of  Fast Moving Average ===" ;
extern ENUM_TIMEFRAMES timeframe  = PERIOD_CURRENT;    //   Fast MA Time Frame
extern  int  MA_PERIOD   =  3 ;   //  Fast MA Period
extern    ENUM_MA_METHOD  MA_METHOD   = MODE_SMMA; // Fast MA METHOD
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD   =   PRICE_CLOSE;  // FAST MA APPLIED PRICE

//Setting of Slow Moving Average
extern    string s2    = "=== Setting  of Slow Moving  Average ===";
extern ENUM_TIMEFRAMES timeframe_slow_moving  = PERIOD_CURRENT; //  Slow MA Time Frame
extern  int  MA_PERIOD_SLOW_MOVING   =  14  ;   // Slow MA Period
extern    ENUM_MA_METHOD  MA_METHOD_SLOW_MOVING   = MODE_SMMA; // Slow MA Method
extern   ENUM_APPLIED_PRICE   MA_APPLIED_PERIOD_SLOW_MOVING   =   PRICE_CLOSE;  // Slow MA Applied Price
extern   color  BuyingColor    =     clrLime  ;    //  Buying Color
extern   color   SellingColor    =   clrRed   ;   //  Selling Color
enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };


extern    EnableDisable    AlertSendNotification   =   Enable    ;   //  Alert Send Notification



string capture_recent_time  =  0 ;
int BarsBack;
int    NumDays      = 200;
datetime  NewCandleTimeCurrent;
int OnInit()
  {
   capture_recent_time   =   Time[1];
   SetIndexBuffer(1,BuyArrow);
   SetIndexArrow(1,233);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,3,BuyingColor);
   SetIndexLabel(1,"BUYING MA");

   SetIndexBuffer(2,SellArrow);
   SetIndexArrow(2,234);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,3,SellingColor);
   SetIndexLabel(2,"SELLING MA");
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   double      slow_moving_current   =         iMA(Symbol(), timeframe_slow_moving, MA_PERIOD_SLOW_MOVING, 0, MA_METHOD_SLOW_MOVING, MA_APPLIED_PERIOD_SLOW_MOVING,1);
   double  slow_moving_previous  =    iMA(Symbol(), timeframe_slow_moving, MA_PERIOD_SLOW_MOVING, 0, MA_METHOD_SLOW_MOVING, MA_APPLIED_PERIOD_SLOW_MOVING,2);
   double   moving_average_current  =      iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,1);
   double   moving_average_previous  =      iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,2);
   string  capture_time =    Time[1];

if(  IsNewCandleCurrent() )
   {
   if(StringCompare(capture_recent_time,  capture_time) == -1)
     {
      if(moving_average_current    >  slow_moving_current   &&   moving_average_previous    <   slow_moving_previous)
        {
         BuyArrow[1]    =  Close[1] ;
         if(AlertSendNotification    ==   Enable)
           {
            Comment("Buying @ " +   Symbol()) ;
            Alert("Buying @ " +   Symbol()) ;
            SendNotification("Buying @ " +   Symbol())   ;
           }
        }
      if(moving_average_current   <    slow_moving_current  &&    moving_average_previous  >   slow_moving_previous)
        {
         SellArrow[1]   =  Close[1];
         if(AlertSendNotification    ==   Enable)
           {
            Comment("Selling @ " +   Symbol()) ;
            Alert("Selling @ " +   Symbol()) ;
            SendNotification("Selling @ " +   Symbol())   ;
           }
        }
     }


   fx_logic_buffer() ;

  }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_logic_buffer()
  {
   BarsBack = NumDays*(PERIOD_D1/Period());
   int i, limit, counted_bars=IndicatorCounted();

   limit = MathMin(BarsBack,Bars-counted_bars-1);
   for(i=limit; i>=1; i--)
     {
      string  capture_time_h =    Time[i];
      if(StringCompare(capture_recent_time,  capture_time_h) == 1)
        {
         double      slow_moving_current   =         iMA(Symbol(), timeframe_slow_moving, MA_PERIOD_SLOW_MOVING, 0, MA_METHOD_SLOW_MOVING, MA_APPLIED_PERIOD_SLOW_MOVING,i);
         double  slow_moving_previous  =    iMA(Symbol(), timeframe_slow_moving, MA_PERIOD_SLOW_MOVING, 0, MA_METHOD_SLOW_MOVING, MA_APPLIED_PERIOD_SLOW_MOVING,i+1);
         double   moving_average_current  =      iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,i);
         double   moving_average_previous  =      iMA(Symbol(), timeframe, MA_PERIOD, 0, MA_METHOD, MA_APPLIED_PERIOD,i+1);
         if(moving_average_current    >  slow_moving_current   &&   moving_average_previous    <   slow_moving_previous)
           {
            BuyArrow[i]    =  Close[i] ;
           }
         if(moving_average_current   <    slow_moving_current  &&    moving_average_previous  >   slow_moving_previous)
           {
            SellArrow[i]   =  Close[i];
           }
        }

     }


   return   0  ;
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
//+------------------------------------------------------------------+
