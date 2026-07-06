//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74093

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color5  LimeGreen
#property indicator_color6  PaleVioletRed
#property indicator_style5  STYLE_DOT
#property indicator_style6  STYLE_DOT
#property indicator_level1  0

extern int    MaxBars       = 1000; 
extern int    BBPeriod      = 15;
extern int    BBPrice       = PRICE_WEIGHTED;
extern double BBDeviations  = 2.0;
extern color  WickColor     = Gray;
extern color  BodyUpColor   = LimeGreen;
extern color  BodyDownColor = PaleVioletRed;
extern int    BodyWidth     = 3;
extern bool   DrawAsBack    = false;
extern string UniqueID      = "BB bars 1";

//
//
//
//
//

double open[];
double close[];
double high[];
double low[];
double bandUp[];
double bandDn[];
int    window;
 int init()
  {
   SetIndexBuffer(0, open);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(1, close);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(2, high);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(3, low);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(4, bandUp);
   SetIndexBuffer(5, bandDn);
   IndicatorShortName(UniqueID);
   return(0);
  }
 
int deinit()
  {
   string lookFor       = UniqueID + ":";
   int    lookForLength = StringLen(lookFor);
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string objectName = ObjectName(i);
      if(StringSubstr(objectName, 0, lookForLength) == lookFor)
         ObjectDelete(objectName);
     }
   return(0);
  }
 
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
      return(-1);
   if(countedBars > 0)
      countedBars--;
   int drawBars = MaxBars;
   if(drawBars < 1)
      drawBars = Bars;
   int limit = MathMin(MathMin(Bars - countedBars, Bars - 1), drawBars);
  
   window = WindowFind(UniqueID);
    for(int i = limit; i >= 0; i--)
     {
      double deviation = iStdDev(NULL, 0, BBPeriod, 0, MODE_SMA, BBPrice, i);
      double ma        = iMA(NULL, 0, BBPeriod, 0, MODE_SMA, BBPrice, i);
      bandUp[i] =  BBDeviations * deviation;
      bandDn[i] = -BBDeviations * deviation;
      open[i]   = Open[i] - ma;
      close[i]  = Close[i] - ma;
      high[i]   = High[i] - ma;
      low[i]    = Low[i]  - ma;
      drawCandle(i);
     }
   return(0);
  }


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawCandle(int i)
  {
   datetime time = Time[i];
   string   name = UniqueID + ":" + time + ":";
   ObjectCreate(name, OBJ_TREND, window, 0, 0, 0, 0);
   ObjectSet(name, OBJPROP_COLOR, WickColor);
   ObjectSet(name, OBJPROP_TIME1, time);
   ObjectSet(name, OBJPROP_TIME2, time);
   ObjectSet(name, OBJPROP_PRICE1, MathMax(high[i], MathMin(close[i], open[i])));
   ObjectSet(name, OBJPROP_PRICE2, MathMin(low[i], MathMax(close[i], open[i])));
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_BACK, DrawAsBack);
//
//
//
//
//
   name = name + "body";
   ObjectCreate(name, OBJ_TREND, window, 0, 0, 0, 0);
   ObjectSet(name, OBJPROP_TIME1, time);
   ObjectSet(name, OBJPROP_TIME2, time);
   ObjectSet(name, OBJPROP_PRICE1, open[i]);
   ObjectSet(name, OBJPROP_PRICE2, close[i]);
   ObjectSet(name, OBJPROP_WIDTH, BodyWidth);
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_BACK, DrawAsBack);
   if(open[i] < close[i])
      ObjectSet(name, OBJPROP_COLOR, BodyUpColor);
   else
      ObjectSet(name, OBJPROP_COLOR, BodyDownColor);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+