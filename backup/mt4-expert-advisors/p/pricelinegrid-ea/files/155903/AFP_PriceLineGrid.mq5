// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74368

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

input int NumLinesAboveBelow  = 300;

input int SuperLevels         = 500;
input color LineColorSuper    = C'115,115,115';
input int LineStyleSuper      = 0;
input int LineWidthSuper      = 4;

input int MSuperLevels        = 100;
input color LineColorMSuper   = C'116,116,116';
input int LineStyleMSuper     = 0;
input int LineWidthMSuper     = 2;

input int inpMainLevels          = 50;
input color LineColorMain     = C'117,117,117';
input int LineStyleMain       = 1;
input int LineWidthMain       = 1;

input bool ShowSubLevels      = true;
input int inpSubLevels           = 25;
input color LineColorSub      = C'110,110,110';
input int LineStyleSub        = 2;
input int LineWidthSub        = 1;

string symbol, tChartPeriod, tShortName;
int digits, period, digits2, mult = 1;
int MainLevels, SubLevels;
double point;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   period       =  Period();
   symbol       =  Symbol();
   digits       =  Digits();
   point        =  Point();
   if(digits == 5 || digits == 3)
     {
      mult = 10;
      digits = digits - 1 ;
      point = point * 10 ;
     }
   MainLevels   = inpMainLevels * mult;
   SubLevels    = inpSubLevels * mult;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delLine();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void delLine()
  {
   int obj_total = ObjectsTotal(0);
   for(int i = obj_total; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringSubstr(name, 0, 11) == "[SweetSpot]")
         ObjectDelete(0, name);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
  {
   static datetime timelastupdate = 0;
   static datetime lasttimeframe = 0;
// no need to update these buggers too often
   if(TimeCurrent() - timelastupdate < 600 && Period() == lasttimeframe)
      return (0);
//
   delLine();
//
   int i,  ssp1, style, ssp, thickness; //SubLevels= 50;
   double  ds1;
   color linecolor;
//
   if(!ShowSubLevels)
      SubLevels *= 2;
//
   ssp1 = iClose(Symbol(), Period(), 0) / Point();
   ssp1 = ssp1 - (int)ssp1 % SubLevels;
//
   for(i = -NumLinesAboveBelow; i < NumLinesAboveBelow; i++)
     {
      ssp = ssp1 + (i * SubLevels);
      if(ssp % (SuperLevels * 10) == 0)    // % gives back the remainder of a divide, for example: 5 % 2 = 1
        {
         style = LineStyleSuper;
         thickness = LineWidthSuper;
         linecolor = LineColorSuper;
        }
      else
         if(ssp % (MSuperLevels * 10) == 0)    // % gives back the remainder of a divide, for example: 5 % 2 = 1
           {
            style = LineStyleMSuper;
            thickness = LineWidthMSuper;
            linecolor = LineColorMSuper;
           }
         else
            if(ssp % MainLevels == 0)
              {
               style = LineStyleMain;
               thickness = LineWidthMain;
               linecolor = LineColorMain;
              }
            else
              {
               style = LineStyleSub;
               thickness = LineWidthSub;
               linecolor = LineColorSub;
              }
      ds1 = ssp * Point();
      SetLevel(DoubleToString(ds1, Digits()), ds1,  linecolor, style, thickness, iTime(Symbol(), Period(), 10));
     }
   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle, int thickness, datetime startofday)
  {
   int dig = Digits();
   string linename = "[SweetSpot] " + text + " Line";
   string pricelabel;
// create or move the horizontal line
   if(ObjectFind(0, linename) != 0)
     {
      ObjectCreate(0, linename, OBJ_TREND, 0, iTime(Symbol(), Period(), 0), level, iTime(Symbol(), Period(), 1), level, 0, 0);
      //      ObjectCreate(linename, OBJ_HLINE, 0, 0, level);
      ObjectSetInteger(0, linename, OBJPROP_STYLE, linestyle);
      ObjectSetInteger(0, linename, OBJPROP_COLOR, col1);
      ObjectSetInteger(0, linename, OBJPROP_WIDTH, thickness);
      ObjectSetInteger(0, linename, OBJPROP_RAY_LEFT, true);
      ObjectSetInteger(0, linename, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, linename, OBJPROP_BACK, true);
     }
   else
     {
      ObjectMove(0, linename, 0, iTime(Symbol(), Period(), 0), level);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+