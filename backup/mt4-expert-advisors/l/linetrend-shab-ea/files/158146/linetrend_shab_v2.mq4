// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75585

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
#property indicator_chart_window
#property strict

#property indicator_buffers 9
#property indicator_color1 DeepSkyBlue  // up[]
#property indicator_width1 2
#property indicator_color2 Tomato       // down[]
#property indicator_width2 2
#property indicator_color3 DeepSkyBlue  // atrlo[]
#property indicator_width3 1
#property indicator_color4 Tomato       // atrhi[]
#property indicator_width4 1
#property indicator_color5 DeepSkyBlue  // arrup[]
#property indicator_width5 1
#property indicator_color6 Tomato      // arrdwn[]
#property indicator_width6 1


extern int    Amplitude        = 2;
extern bool   ShowBars         = false;
extern bool   ShowArrows       = true;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern double tp_pip           = 20; // TP Pips
extern double sl_pip           = 20; // SL Pips

bool nexttrend;
double minhighprice,maxlowprice;
double up[],down[],atrlo[],atrhi[],trend[];
double arrup[],arrdwn[];
double tp[],sl[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(9); // +1 buffer - trend[]
   
   SetIndexBuffer(0,up);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,down);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,atrlo);
   SetIndexBuffer(3,atrhi);
   SetIndexBuffer(4,arrup);
   SetIndexBuffer(5,arrdwn);
   SetIndexBuffer(6,trend);
   
   SetIndexBuffer(7,tp);
   SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 1, Green);
   SetIndexBuffer(8,sl);
   SetIndexStyle(8, DRAW_LINE, STYLE_SOLID, 1, Red);
   
   SetIndexEmptyValue(0,0.0); SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(6,0.0);
   
   if(ShowBars)
   {
      SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID);
   }
   else
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
   if(ShowArrows)
   {
     SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(4,233);
     SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(5,234);
   }
   else
   {
     SetIndexStyle(4,DRAW_NONE);
     SetIndexStyle(5,DRAW_NONE);
   } 
          
     
   nexttrend=0;
   minhighprice= High[Bars-1];
   maxlowprice = Low[Bars-1];
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFix { } ExtFix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double atr,lowprice_i,highprice_i,lowma,highma;
   int workbar=0;
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
   
   for(int i=Bars-2; i>=0; i--)
     {
      lowprice_i=iLow(Symbol(),Period(),iLowest(Symbol(),Period(),MODE_LOW,Amplitude,i));
      highprice_i=iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,Amplitude,i));
      lowma=NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_LOW,i),Digits());
      highma=NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_HIGH,i),Digits());
      trend[i]=trend[i+1];
      atr=iATR(Symbol(),0,100,i)/2;

      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;

      if(nexttrend==1)
        {
         maxlowprice=MathMax(lowprice_i,maxlowprice);

         if(highma<maxlowprice && Close[i]<Low[i+1])
           {
            trend[i]=1.0;
            nexttrend=0;
            minhighprice=highprice_i;
           }
        }
      if(nexttrend==0)
        {
         minhighprice=MathMin(highprice_i,minhighprice);

         if(lowma>minhighprice && Close[i]>High[i+1])
           {
            trend[i]=0.0;
            nexttrend=1;
            maxlowprice=lowprice_i;
           }
        }
      if(trend[i]==0.0)
        {
         if(trend[i+1]!=0.0)
           {
            up[i]=down[i+1];
            up[i+1]=up[i];
            arrup[i] = up[i] - 2*atr;
           }
         else
           {
            up[i]=MathMax(maxlowprice,up[i+1]);
           }
         atrhi[i] = up[i] - atr;
         atrlo[i] = up[i];
         down[i]=0.0;
        }
      else
        {
         if(trend[i+1]!=1.0)
           {
            down[i]=up[i+1];
            down[i+1]=down[i];
            arrdwn[i] = down[i] + 2*atr;           
           }
         else
           {
            down[i]=MathMin(minhighprice,down[i+1]);
           }
         atrhi[i] = down[i] + atr;
         atrlo[i] = down[i];
         up[i]=0.0;
        }


     if(arrup[i] != EMPTY_VALUE) {
        double cl = Close[i];
        double t =  cl + tp_pip * _Point*10;
        double s =  cl - sl_pip * _Point*10;
         tp[i]   = t;
         sl[i]   = s;
         for(int j=1; j < 4; j++)
         {
           tp[i+j] = t;
           sl[i+j] = s;            
         }
     }
     if(arrdwn[i] != EMPTY_VALUE) {
         double cl = Close[i];
         double t = cl - tp_pip * _Point*10;
         double s = cl + sl_pip * _Point*10;
         tp[i]   = t;
         sl[i]   = s;
         for(int j=1; j < 4; j++)
         {
           tp[i+j] = t;
           sl[i+j] = s;            
         }
     }
    
    }
     manageAlerts();

   return (0);
  }
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
  int whichBar = 0;
   if (alertsOn)
   {
      if (alertsOnCurrent)
               whichBar = 0;
      else     whichBar = 1; 
         if (arrup[whichBar]  != EMPTY_VALUE) doAlert(whichBar,"up");
         if (arrdwn[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down");
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," HalfTrend signal ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"HalfTrend "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75585

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