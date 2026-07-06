// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74368

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
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

#property indicator_chart_window

extern int NumLinesAboveBelow  = 300;

extern int SuperLevels         = 500;
extern color LineColorSuper    = C'115,115,115';
extern int LineStyleSuper      = 0;
extern int LineWidthSuper      = 4; 

extern int MSuperLevels        = 100;
extern color LineColorMSuper   = C'116,116,116';
extern int LineStyleMSuper     = 0;
extern int LineWidthMSuper     = 2;

extern int MainLevels          = 50;
extern color LineColorMain     = C'117,117,117';
extern int LineStyleMain       = 1;
extern int LineWidthMain       = 1;

extern bool ShowSubLevels      = true;
extern int SubLevels           = 25;
extern color LineColorSub      = C'110,110,110';
extern int LineStyleSub        = 2;
extern int LineWidthSub        = 1;

string symbol, tChartPeriod,  tShortName ;  
int    digits, period, digits2, mult = 1  ; 
double point ;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   period       =  Period() ;    
   symbol       =  Symbol() ;
   digits       =  Digits ;   
   point        =  Point ;
   
   if(digits == 5 || digits == 3) { mult = 10; digits = digits - 1 ; point = point * 10 ; }   
   
   MainLevels   = MainLevels * mult;
   SubLevels    = SubLevels * mult;
   return(0);
}

int deinit(){
   int obj_total= ObjectsTotal();
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
      if (StringSubstr(name,0,11)=="[SweetSpot]") 
         ObjectDelete(name);
   }
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;
    
   // no need to update these buggers too often   
   if (TimeCurrent()-timelastupdate < 600 && Period()==lasttimeframe)
      return (0);
   
   deinit();  // delete all previous lines
      
   int i, ssp1, style, ssp, thickness; //SubLevels= 50;
   double ds1;
   color linecolor;
   
   if (!ShowSubLevels)
      SubLevels*= 2;
   
   ssp1= Bid / Point;
   ssp1= ssp1 - ssp1%SubLevels;

   for (i= -NumLinesAboveBelow; i<NumLinesAboveBelow; i++){

      ssp= ssp1+(i*SubLevels); 

      if (ssp%(SuperLevels*10)==0){        // % gives back the remainder of a divide, for example: 5 % 2 = 1
         style= LineStyleSuper;
         thickness = LineWidthSuper;
         linecolor= LineColorSuper;
      }else 
      if (ssp%(MSuperLevels*10)==0){        // % gives back the remainder of a divide, for example: 5 % 2 = 1
         style= LineStyleMSuper;
         thickness = LineWidthMSuper;
         linecolor= LineColorMSuper;
      }else 
      if (ssp%MainLevels==0){        
         style= LineStyleMain;
         thickness = LineWidthMain;
         linecolor= LineColorMain;
      }else{
         style= LineStyleSub;
         thickness = LineWidthSub;
         linecolor= LineColorSub;
      }
/*
      if (ssp%(MainLevels*100)==0){
         linecolor= LineColorMain;
         thickness = LineWidthMain;
      }   
      if (ssp%(MainLevels*10)==0){
         linecolor= LineColorSub;
         thickness = LineWidthSub;      
      }
*/
           
      ds1= ssp*Point;
      SetLevel(DoubleToStr(ds1,Digits), ds1,  linecolor, style, thickness, Time[10]);
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1, int linestyle, int thickness, datetime startofday)
{
   int digits= Digits;
   string linename= "[SweetSpot] " + text + " Line";
   string pricelabel; 

   // create or move the horizontal line   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_TREND, 0, Time[0], level, Time[1], level, 0, 0);

//      ObjectCreate(linename, OBJ_HLINE, 0, 0, level);
      
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, thickness);

      ObjectSet(linename, OBJPROP_RAY, true);      
      ObjectSet(linename, OBJPROP_BACK, True);
   }
   else {
      ObjectMove(linename, 0, Time[0], level);
   }
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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