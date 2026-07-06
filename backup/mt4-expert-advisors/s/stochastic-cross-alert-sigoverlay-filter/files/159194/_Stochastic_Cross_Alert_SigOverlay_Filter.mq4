//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75923

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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

//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 LawnGreen
#property indicator_color2 Red
#property indicator_width1  1
#property indicator_width2  1
//----
extern bool SoundON=false;
extern bool EmailON=false;

//---- input parameters
extern int KPeriod=5;
extern int DPeriod=3;
extern int Slowing=3;
extern int MA_Method=0; // SMA 0, EMA 1, SMMA 2, LWMA 3
extern int PriceField=0; // Low/High 0, Close/Close 1
extern int OverBoughtLevel  =80;
extern int OverSoldLevel    =20;
extern bool show_KD_cross=false;
extern bool show_K_OBOScross=true;
extern bool show_D_OBOScross=false;
extern string note_Price="PriceField:  Low/High = 0, Close/Close = 1";
extern string _MA_Method="SMA0 EMA1 SMMA2 LWMA3";

// ---- 
// stoch[i] = iStochastic(NULL, 0, f_KPeriod, f_DPeriod, f_Slowing, f_MA_Method, f_PriceField, MODE_MAIN, i);

extern string t="Filter settings"; // -------------------
extern bool useFilter=false; // Filter with color stoch?
extern int f_KPeriod=10; // k Period
extern int f_DPeriod=3; // d Period
extern int f_Slowing=3; // slowing
extern int f_MA_Method=3; // SMA 0, EMA 1, SMMA 2, LWMA 3
extern int f_PriceField=0; // Low/High 0, Close/Close 1


double CrossUp[];
double CrossDown[];
int flagval1=0;
int flagval2=0;

double stoch[];
double stochSignal[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
   
   SetIndexBuffer(2, stoch);
   SetIndexBuffer(3, stochSignal);


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  int start() 
  {
   int limit, i, counter;
   double tmp=0;
   double fastMAnow, slowMAnow, fastMAprevious, slowMAprevious;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
   int trend=0;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
     for(i=1; i<=limit; i++) 
     {
      counter=i;
      Range=0;
      AvgRange=0;


      stoch[i] = iStochastic(NULL, 0, f_KPeriod, f_DPeriod, f_Slowing, f_MA_Method, f_PriceField, MODE_MAIN, i);
      stochSignal[i] = iStochastic(NULL, 0, f_KPeriod, f_DPeriod, f_Slowing, f_MA_Method, f_PriceField, MODE_SIGNAL, i);

      if (stoch[i] > stochSignal[i]) trend=1; else trend=-1;

      for(counter=i ;counter<=i+9;counter++)
        {
         //       AvgRange=AvgRange+MathAbs(iStochastic(NULL, 0, KPeriod, DPeriod, Slowing,MA_Method, PriceField, MODE_MAIN, i)-iStochastic(NULL, 0, KPeriod, DPeriod, Slowing,MA_Method, PriceField, MODE_MAIN, i+1));
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/10;
      fastMAnow=iStochastic(NULL, 0, KPeriod, DPeriod, Slowing,MA_Method, PriceField, MODE_MAIN, i);
      fastMAprevious=iStochastic(NULL, 0, KPeriod, DPeriod, Slowing,MA_Method, PriceField, MODE_MAIN, i+1);
      slowMAnow=iStochastic(NULL, 0, KPeriod, DPeriod, Slowing,MA_Method, PriceField, MODE_SIGNAL, i);
      slowMAprevious=iStochastic(NULL, 0, KPeriod, DPeriod, Slowing,MA_Method, PriceField, MODE_SIGNAL, i+1);
      CrossUp[i]=EMPTY_VALUE;
      CrossDown[i]=EMPTY_VALUE;
      if
         (((show_KD_cross)&&(fastMAnow > slowMAnow) && (fastMAprevious < slowMAprevious))||
            ((show_K_OBOScross)&&(fastMAnow > OverSoldLevel) && (fastMAprevious < OverSoldLevel))||
            ((show_D_OBOScross)&&(slowMAnow > OverSoldLevel) && (slowMAprevious < OverSoldLevel)) )
        {
         if (i==1 && flagval1==0)
           {
            flagval1=1;
            flagval2=0;
            if (SoundON) Alert("BUY signal at Ask=",Ask,"\n Bid=",Bid,"\n Time=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()),"\n Symbol=",Symbol()," Period=",Period());
            if (EmailON) SendMail("BUY signal alert","BUY signal at Ask="+DoubleToStr(Ask,4)+", Bid="+DoubleToStr(Bid,4)+", Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
           }
         
         
           if (useFilter) {
              if (trend==1) {
                CrossUp[i]=Low[i] - Range*0.5;
                } else {
                  CrossDown[i]=EMPTY_VALUE;
                }
            } else
            {
              CrossUp[i]=Low[i] - Range*0.5;
              CrossDown[i]=EMPTY_VALUE;
              //         CrossUp[i] = AvgRange;
            }
        }
      
        else if
            (((show_KD_cross)&&(fastMAnow < slowMAnow) && (fastMAprevious > slowMAprevious))||
               ((show_K_OBOScross)&&(fastMAnow < OverBoughtLevel) && (fastMAprevious > OverBoughtLevel))||
               ((show_D_OBOScross)&&(slowMAnow < OverBoughtLevel) && (slowMAprevious > OverBoughtLevel)) )
           {
            if (i==1 && flagval2==0)
              {
               flagval2=1;
               flagval1=0;
               if (SoundON) Alert("SELL signal at Ask=",Ask,"\n Bid=",Bid,"\n Date=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime()),"\n Symbol=",Symbol()," Period=",Period());
               if (EmailON) SendMail("SELL signal alert","SELL signal at Ask="+DoubleToStr(Ask,4)+", Bid="+DoubleToStr(Bid,4)+", Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
              }

            if (useFilter) {
               if (trend==-1) {
                   CrossDown[i]=High[i] + Range*0.5;
                 } else {
                   CrossDown[i]=EMPTY_VALUE;
                 }
            } else {
              CrossDown[i]=High[i] + Range*0.5;
              //        CrossDown[i] = AvgRange;
              CrossUp[i]=EMPTY_VALUE;
            }
           }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75923

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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