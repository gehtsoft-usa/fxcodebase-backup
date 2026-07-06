//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75492

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

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Blue   
#property indicator_color2 Red   //SaddleBrown
#property indicator_color3 Gray
#property indicator_color4 Gold
#property indicator_color5 Black 
#property indicator_color6 Crimson  
#property indicator_color7 Lime  //Gold  <<<<<<<<<<<<<<<<<<<<<<<<<<
#property indicator_color8 Red  //Gold  <<<<<<<<<<<<<<<<<<<<<<<<<<
#property indicator_level1 300
#property indicator_level2 200
#property indicator_level3 100
#property indicator_level4 -100
#property indicator_level5 -200
#property indicator_level6 -300
#property indicator_levelcolor Black
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1

//---- input parameters
extern int TrendCCI_Period = 14;//14
extern int EntryCCI_Period = 6;//6
extern int LSMAPeriod = 25;     // LSMA period
extern int Trend_period = 5;
extern int  CountBars=1000; 
extern int   CCISize=2;
extern int   TCCISize=1;
extern int   TrendSize=1;
extern int   NoTrendSize=1;
extern bool  ShowLSMA=true;
extern int   LineSize3=1;


#define Notifications_on
#ifdef Notifications_on

input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

void notify(int type)
{
    if (IsNewCandle()) {
        Notifications(type);
    }
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch (lPeriod) {
    case PERIOD_M1:
        return ("M1");
    case PERIOD_M5:
        return ("M5");
    case PERIOD_M15:
        return ("M15");
    case PERIOD_M30:
        return ("M30");
    case PERIOD_H1:
        return ("H1");
    case PERIOD_H4:
        return ("H4");
    case PERIOD_D1:
        return ("D1");
    case PERIOD_W1:
        return ("W1");
    case PERIOD_MN1:
        return ("MN1");
    }
    return IntegerToString(lPeriod);
}

bool IsNewCandle()
{
    static datetime last;
    datetime        current = iTime(NULL, 0, 1);
    if (last != current) {
        last = current;
        return true;
    }
    return false;
}

#endif

double TrendCCI[];
double EntryCCI[];
double CCITrendUp[];
double CCITrendDown[];
double CCINoTrend[];
double CCITimeBar[];
double ZeroLine[];
double LSMABuffer1[];
double LSMABuffer2[];
int EMAPeriod  = 34;     // ??period
int FromZero   = 0;      // Distance from zero level
double LineHighEMA[];
double LineLowEMA[];

int trendUp, trendDown;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
//---- indicators
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID,CCISize);
   SetIndexBuffer(4, TrendCCI);
   SetIndexLabel(4, "TrendCCI");
   SetIndexStyle(0, DRAW_HISTOGRAM, 0,TrendSize);
   SetIndexBuffer(0, CCITrendUp);
   SetIndexLabel (0, NULL);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0,TrendSize);
   SetIndexBuffer(1, CCITrendDown);
   SetIndexLabel (1, NULL);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0,NoTrendSize);
   SetIndexBuffer(2, CCINoTrend);
   SetIndexLabel (2, NULL);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0,NoTrendSize);
   SetIndexBuffer(3, CCITimeBar);
   SetIndexLabel (3, NULL);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID,TCCISize);// 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<
   SetIndexBuffer(5, EntryCCI);
   SetIndexLabel(5, "EntryCCI");
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID,LineSize3);
   SetIndexBuffer(6, LSMABuffer2);
   SetIndexLabel (6, "Trend UP");
   SetIndexArrow(6,167);
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID,LineSize3);
   SetIndexBuffer(7, LSMABuffer1); 
   SetIndexArrow(7,167);
   SetIndexLabel (7, "Trend DN");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
int start() {

   int limit, i, trendCCI, entryCCI;
   int counted_bars = IndicatorCounted();
   static datetime prevtime = 0;
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;

   limit=Bars;//-counted_bars;
   
     SetIndexDrawBegin(0,Bars-CountBars);
     SetIndexDrawBegin(1,Bars-CountBars);
     SetIndexDrawBegin(2,Bars-CountBars);
     SetIndexDrawBegin(3,Bars-CountBars);
     SetIndexDrawBegin(4,Bars-CountBars);
     SetIndexDrawBegin(5,Bars-CountBars);
     SetIndexDrawBegin(6,Bars-CountBars);
     SetIndexDrawBegin(7,Bars-CountBars);
   

      trendCCI = TrendCCI_Period;
      entryCCI = EntryCCI_Period;
   
      IndicatorShortName("[CCI: " + trendCCI + "] [TCCI: " + entryCCI + "] [per LSMA: " + LSMAPeriod + "] [Trend: " + Trend_period + "] Values CCI|TCCI:");   
   
   for(i = limit; i >= 0; i--) {
      CCINoTrend[i] = 0;
      CCITrendDown[i] = 0;
      CCITimeBar[i] = 0;
      CCITrendUp[i] = 0;
      ZeroLine[i] = 0;
      TrendCCI[i] = iCCI(NULL, 0, trendCCI, PRICE_TYPICAL, i);
      EntryCCI[i] = iCCI(NULL, 0, entryCCI, PRICE_TYPICAL, i);
      
      if(TrendCCI[i] > 0 && TrendCCI[i+1] < 0) {
         if (trendDown >  Trend_period) trendUp = 0;
      }
      if (TrendCCI[i] > 0) {
         if (trendUp <  Trend_period){
            CCINoTrend[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp ==  Trend_period) {
            CCITimeBar[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp >  Trend_period) {
            CCITrendUp[i] = TrendCCI[i];
         }
      }
      if(TrendCCI[i] < 0 && TrendCCI[i+1] > 0) {
         if (trendUp >  Trend_period) trendDown = 0;
      }
      if (TrendCCI[i] < 0) {
         
         if (trendDown <  Trend_period){
            CCINoTrend[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown ==  Trend_period) {
            CCITimeBar[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown >  Trend_period) {
            CCITrendDown[i] = TrendCCI[i];
         }
      }
   }

//---- Color Middle Line LSMA
  if(ShowLSMA==true)
  {
  double sum, lengthvar, tmp, wt;
  int shift;
  int Draw4HowLong, loopbegin;

  if (counted_bars<0) return 0;
  if (counted_bars>0) counted_bars--;
  counted_bars = Bars - counted_bars;
  for (shift=0; shift<counted_bars; shift++) {
    LineLowEMA[shift] = -FromZero;
    LineHighEMA[shift] = -FromZero;

    double EmaValue = iMA(NULL, 0, EMAPeriod, 0, MODE_EMA, PRICE_TYPICAL, shift);
    if (Close[shift]>EmaValue) LineHighEMA[shift] = EMPTY_VALUE;
    if (Close[shift]<EmaValue) LineLowEMA[shift] = EMPTY_VALUE;
  }

  Draw4HowLong = Bars-LSMAPeriod - 5;
  loopbegin = Draw4HowLong - LSMAPeriod - 1;

  for(shift=loopbegin; shift>=0; shift--) {
    sum = 0;
    for (i=LSMAPeriod; i>=1; i--) {
      lengthvar = LSMAPeriod + 1;
      lengthvar /= 3;
      tmp = 0;
      tmp = (i - lengthvar) * Close[LSMAPeriod-i+shift];
      sum+=tmp;
    }
    wt = sum * 6 / (LSMAPeriod * (LSMAPeriod + 1));

    LSMABuffer1[shift] = 0;
    LSMABuffer2[shift] = 0;

    if (wt>Close[shift]) LSMABuffer2[shift] = EMPTY_VALUE;
    if (wt<Close[shift]) LSMABuffer1[shift] = EMPTY_VALUE;
     }
  }

  if(LSMABuffer1[0] == 0 && LSMABuffer2[1] == 0) { notify(1); }
  if(LSMABuffer1[1] == 0 && LSMABuffer2[0] == 0) { notify(0); }

//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75492

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