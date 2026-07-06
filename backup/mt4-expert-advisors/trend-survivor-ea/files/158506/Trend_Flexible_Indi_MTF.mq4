// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75677

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 6
#property strict

#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrBlue
#property indicator_color4  clrRed

#property indicator_label5 "Arrow Up"
#property  indicator_type5  DRAW_ARROW
#property indicator_color5 clrPaleGreen
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Arrow Down"
#property  indicator_type6  DRAW_ARROW
#property indicator_color6 clrBlack
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];


//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame    = PERIOD_CURRENT;    // Time frame
input int              period       = 10;                // Super trend period
input double           multiplier   = 3.0;               // Super trend multiplier
input int              WickWidth    = 1;                 // Candle wick width
input int              BodyWidth    = 2;                 // If auto width = false then use this
input bool             UseAutoWidth = true;              // Auto adjust candle body width

input string T2                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrPaleGreen;           // Arrow Up Color:
input color  ArrowDnClr            = clrBlack;               // Arrow Down Color:
input bool   desktop_notifications = true;                   // Desktop Notifications

double valhu[],valhd[],valhbu[],valhbd[],Up[],Dn[],valc[],Trend[],count[];
string indicatorFileName;
int candlewidth=0;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,multiplier,WickWidth,BodyWidth,UseAutoWidth,_buff,_y)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   if (UseAutoWidth)
   {
      int scale = int(ChartGetInteger(0,CHART_SCALE));
      switch(scale) 
	   {
	      case 0: candlewidth =  1; break;
	      case 1: candlewidth =  1; break;
		   case 2: candlewidth =  2; break;
		   case 3: candlewidth =  3; break;
		   case 4: candlewidth =  6; break;
		   case 5: candlewidth = 14; break;
	   }
	}
   else { candlewidth = BodyWidth; }
   IndicatorBuffers(11);
   SetIndexBuffer(0, valhu, INDICATOR_DATA);  SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,WickWidth);
   SetIndexBuffer(1, valhd, INDICATOR_DATA);  SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,WickWidth);
   SetIndexBuffer(2, valhbu,INDICATOR_DATA);  SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,candlewidth);
   SetIndexBuffer(3, valhbd,INDICATOR_DATA);  SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,candlewidth);
   SetIndexBuffer(4, ArrowUp, INDICATOR_DATA); SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, ArrowUpClr); SetIndexArrow(4, 233);
   SetIndexBuffer(5, ArrowDn, INDICATOR_DATA); SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, ArrowDnClr); SetIndexArrow(5, 234);

   SetIndexBuffer(6, Trend, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, Up,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, Dn,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, valc,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, count, INDICATOR_CALCULATIONS); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int      rates_total,
                const int      prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   int i,counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit=fmin(rates_total-counted_bars,rates_total-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(8,0)*TimeFrame/_Period));
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  valc[i] = _mtfCall(7,y);
                  if (valc[i]== 1)
                  {
                     valhu[i]  = high[i]; 
                     valhd[i]  = low[i];
                     valhbu[i] = fmax(open[i],close[i]);
                     valhbd[i] = fmin(open[i],close[i]);
                     
                     if (valc[i+1]== -1) { ArrowUp[i] = low[i]; }
                  }               
                  if (valc[i]== -1)
                  {
                    valhu[i]  = low[i];
                    valhd[i]  = high[i];
                    valhbu[i] = fmin(open[i],close[i]);
                    valhbd[i] = fmax(open[i],close[i]);
                    
                    if (valc[i+1]== 1) { ArrowDn[i] = high[i]; }
                    
                  }           
            }
   return(rates_total);
   }               
         
   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--)
   {
      double atr    = iATR(NULL,0,period,i);
      double cprice =  close[i];
      double mprice = (high[i]+low[i])/2;
      Up[i]  = mprice+multiplier*atr;
      Dn[i]  = mprice-multiplier*atr;
         
      //
      //
      //
      //
      //
         
      valc[i] = (i<rates_total-1) ? (cprice > Up[i+1]) ? 1 : (cprice < Dn[i+1]) ? -1 : valc[i+1] : 0;
      if (valc[i] ==  1) { Dn[i] = fmax(Dn[i],Dn[i+1]); Trend[i] = Dn[i]; }
      if (valc[i] == -1) { Up[i] = fmin(Up[i],Up[i+1]); Trend[i] = Up[i]; }
      if (valc[i]== 1)
      {
         valhu[i]  = high[i]; 
         valhd[i]  = low[i];
         valhbu[i] = fmax(open[i],close[i]);
         valhbd[i] = fmin(open[i],close[i]);
         if (valc[i+1]== -1) { 
            ArrowUp[i] = low[i]-50*_Point; 
            if (desktop_notifications== true && i == 0) 
               Alert("UP Signal at ",Symbol()," ",timeFrameToString(_Period)," ",TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
         }
      }               
      if (valc[i]== -1)
      {
         valhu[i]  = low[i];
         valhd[i]  = high[i];
         valhbu[i] = fmin(open[i],close[i]);
         valhbd[i] = fmax(open[i],close[i]);
         if (valc[i+1]== 1) { 
            ArrowDn[i] = high[i]+50*_Point; 
            if (desktop_notifications== true && i == 0)
               Alert("DOWN Signal at ",Symbol()," ",timeFrameToString(_Period)," ",TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
         }
      }               
  }
return(rates_total);
}      
                  
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75677

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 