// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76216
 
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers   5
#property indicator_color1    Green
#property indicator_color2    Green
#property indicator_color3    Red
#property indicator_color4    Red
#property indicator_color5    DimGray
#property indicator_width1    2
#property indicator_width3    2
#property indicator_width5    2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame    = PERIOD_CURRENT;  // Time frame
extern int                CalcPeriod   = 50;          // Calculation period
extern ENUM_APPLIED_PRICE CalcPrice    = PRICE_CLOSE; // Price
extern ENUM_MA_METHOD     CalcMaMethod = MODE_SMA;    // MaMethod for price smoothing
extern int                CalcMaPeriod = 1;           // period for price smoothing
extern bool               ShowHisto    = true;        // Display histogram?
extern bool               Interpolate  = true;        // Interpolate in multi time frame mode?


//
//
//
//
//

double buffer1[],buffer2[],buffer3[],buffer4[],buffer5[],prices[],state[];
string indicatorFileName;
bool   returnBars;


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
   SetIndexBuffer(0,buffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,buffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,buffer4); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,buffer5);
   SetIndexBuffer(5,prices);
   SetIndexBuffer(6,state);
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame==-99);
         TimeFrame         = MathMax(TimeFrame,_Period);
      IndicatorShortName(timeFrameToString(TimeFrame)+" Weighted bulls/bears ("+(string)CalcPeriod+","+(string)CalcMaPeriod+")");
   return(0);
}
int deinit() { return(0); }
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) {buffer1[0] = limit+1; return(0); }
           if (TimeFrame!=_Period)
           {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     buffer5[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CalcPeriod,CalcPrice,CalcMaMethod,CalcMaPeriod,4,y);
                     state[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CalcPeriod,CalcPrice,CalcMaMethod,CalcMaPeriod,6,y);
                     buffer1[i] = EMPTY_VALUE;
                     buffer2[i] = EMPTY_VALUE;
                     buffer3[i] = EMPTY_VALUE;
                     buffer4[i] = EMPTY_VALUE;
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           buffer5[i+k] = buffer5[i] + (buffer5[i+n] - buffer5[i]) * k/n;
               }
               if (ShowHisto) 
                  for(int i=limit; i>=0; i--)
                     switch((int)state[i])
                     { 
                        case  -2: buffer3[i]=buffer5[i]; break;
                        case  -1: buffer4[i]=buffer5[i]; break;
                        case   1: buffer2[i]=buffer5[i]; break;
                        default : buffer1[i]=buffer5[i];
                     }                  
               return(0);
            }               

   //
   //
   //
   //
   //

      for(int i=limit; i>=0; i--)
      {
         prices[i] = iMA(NULL,0,CalcMaPeriod,0,CalcMaMethod,CalcPrice,i);
         int    hbar = ArrayMaximum(prices,CalcPeriod,i); double hval=prices[hbar];
         int    lbar = ArrayMinimum(prices,CalcPeriod,i); double lval=prices[lbar];
         double bear = -weight(hval-prices[i],hbar-i+1);
         double bull = +weight(prices[i]-lval,lbar-i+1);
            buffer5[i] = bull*2+bear*2;
            buffer1[i]=EMPTY_VALUE;
            buffer2[i]=EMPTY_VALUE;
            buffer3[i]=EMPTY_VALUE;
            buffer4[i]=EMPTY_VALUE;
            if (i<Bars-1)
               state[i] = (buffer5[i]<0) ? (buffer5[i]<buffer5[i+1]) ? -2 : -1 : (buffer5[i]<buffer5[i+1]) ? 1 : 2 ;
               if (ShowHisto)
               switch((int)state[i])
               { 
                  case  -2: buffer3[i]=buffer5[i]; break;
                  case  -1: buffer4[i]=buffer5[i]; break;
                  case   1: buffer2[i]=buffer5[i]; break;
                  default : buffer1[i]=buffer5[i];
               }                  
      }
   return(0);
}


double weight(double range, double dist) { return(range+range/dist); }

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
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76216
 
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+