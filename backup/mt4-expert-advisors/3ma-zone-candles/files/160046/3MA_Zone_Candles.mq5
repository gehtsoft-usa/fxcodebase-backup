//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76190

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
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_label1  "Candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed, clrOrange, clrBlue, clrGreen

// input parameters
input int            Period1   = 10;            // MA1 Period
input ENUM_MA_METHOD Method1   = MODE_SMA;      // MA1 Method
input int            Period2   = 20;            // MA2 Period
input ENUM_MA_METHOD Method2   = MODE_SMA;      // MA2 Method
input int            Period3   = 30;            // MA3 Period
input ENUM_MA_METHOD Method3   = MODE_SMA;      // MA3 Method

input color          Color1    = clrRed;        // Below all MAs
input color          Color2    = clrOrange;     // Between MA1 & MA2
input color          Color3    = clrBlue;       // Between MA2 & MA3
input color          Color4    = clrGreen;      // Above all MAs

// indicator buffers
double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double ColorBuffer[];

// indicator handles
int handleMA1;
int handleMA2;
int handleMA3;

int OnInit()
  {
// map buffers
   SetIndexBuffer(0,OpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1,HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2,LowBuffer,  INDICATOR_DATA);
   SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);

   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_CANDLES);
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,4);

   IndicatorSetString(INDICATOR_SHORTNAME,"3 MA Zone Candles");

// create MAs
   handleMA1=iMA(_Symbol,_Period,Period1,0,Method1,PRICE_CLOSE);
   handleMA2=iMA(_Symbol,_Period,Period2,0,Method2,PRICE_CLOSE);
   handleMA3=iMA(_Symbol,_Period,Period3,0,Method3,PRICE_CLOSE);

   if(handleMA1==INVALID_HANDLE || handleMA2==INVALID_HANDLE || handleMA3==INVALID_HANDLE)
     {
      Print("Failed to create MA handles");
      return(INIT_FAILED);
     }

// set fixed colors for plot indexes
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Color1);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Color2);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Color3);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,3,Color4);

   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
   if(handleMA1!=INVALID_HANDLE) IndicatorRelease(handleMA1);
   if(handleMA2!=INVALID_HANDLE) IndicatorRelease(handleMA2);
   if(handleMA3!=INVALID_HANDLE) IndicatorRelease(handleMA3);
  }
  
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
// ensure enough bars
   int min_needed=MathMax(MathMax(Period1,Period2),Period3);
   if(rates_total<=min_needed)
      return(0);

// copy MA buffers
   static double ma1[];
   static double ma2[];
   static double ma3[];

   if(CopyBuffer(handleMA1,0,0,rates_total,ma1)<=0) return(0);
   if(CopyBuffer(handleMA2,0,0,rates_total,ma2)<=0) return(0);
   if(CopyBuffer(handleMA3,0,0,rates_total,ma3)<=0) return(0);

   int start=0;

   for(int i=start;i<rates_total;i++)
     {
      double closePrice=close[i];
      double a[3]={ma1[i],ma2[i],ma3[i]};

      // sort ascending (simple)
      if(a[0]>a[1]) { double t=a[0]; a[0]=a[1]; a[1]=t; }
      if(a[1]>a[2]) { double t=a[1]; a[1]=a[2]; a[2]=t; }
      if(a[0]>a[1]) { double t=a[0]; a[0]=a[1]; a[1]=t; }

      int clrIdx;
      if(closePrice < a[0])
         clrIdx=0;
      else if(closePrice < a[1])
         clrIdx=1;
      else if(closePrice < a[2])
         clrIdx=2;
      else
         clrIdx=3;

      OpenBuffer[i] = open[i];
      HighBuffer[i] = high[i];
      LowBuffer[i]  = low[i];
      CloseBuffer[i]= close[i];
      ColorBuffer[i]= clrIdx;
     }
   return(rates_total);
  }

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76190

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