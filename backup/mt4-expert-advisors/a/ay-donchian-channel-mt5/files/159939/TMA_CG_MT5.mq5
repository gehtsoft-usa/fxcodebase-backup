//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76159

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
#property indicator_buffers 7
#property indicator_plots   5

#property indicator_label1  "TMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_DOT
#property indicator_width1  1

#property indicator_label2  "Upper Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrNONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Lower Band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrNONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Down Arrow"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLime
#property indicator_width4  10

#property indicator_label5  "Up Arrow"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_width5  10

input string TimeFrame         = "current time frame";
input bool            RePaint  = false;
input int    HalfLength        = 21;
input ENUM_APPLIED_PRICE Price = PRICE_WEIGHTED;
input double BandsDeviations   = 2.1;
input bool   Interpolate       = true;
input bool   alertsOn          = false;
input bool   alertsOnCurrent   = false;
input bool   alertsOnHighLow   = false;
input string SetArrows         = "Set_arrows";
input int    CodeUp            = 119;
input int    CodeDn            = 119;
input int    Size              = 8;
input double Gap               = 1.5;
input bool   alertsMessage     = false;
input bool   alertsSound       = false;
input bool   alertsEmail       = false;

double tmBuffer[];
double upBuffer[];
double dnBuffer[];
double wuBuffer[];
double wdBuffer[];
double dnArrow[];
double upArrow[];

int    timeFrame;
string IndicatorFileName;
bool   calculatingTma = false;
bool   returningBars  = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   timeFrame = StringToTimeFrame(TimeFrame);
   int halfLength = MathMax(HalfLength, 2);
   
   SetIndexBuffer(0, tmBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, upBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, dnBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, dnArrow, INDICATOR_DATA);
   SetIndexBuffer(4, upArrow, INDICATOR_DATA);
   SetIndexBuffer(5, wuBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, wdBuffer, INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(3, PLOT_ARROW, CodeDn);
   PlotIndexSetInteger(4, PLOT_ARROW, CodeUp);
   
   ArraySetAsSeries(tmBuffer, true);
   ArraySetAsSeries(upBuffer, true);
   ArraySetAsSeries(dnBuffer, true);
   ArraySetAsSeries(dnArrow, true);
   ArraySetAsSeries(upArrow, true);
   ArraySetAsSeries(wuBuffer, true);
   ArraySetAsSeries(wdBuffer, true);
   
   IndicatorFileName = MQL5InfoString(MQL5_PROGRAM_NAME);
   
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
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(time, true);
   
   if(prev_calculated == 0)
   {
      ArrayInitialize(tmBuffer, EMPTY_VALUE);
      ArrayInitialize(upBuffer, EMPTY_VALUE);
      ArrayInitialize(dnBuffer, EMPTY_VALUE);
      ArrayInitialize(dnArrow, EMPTY_VALUE);
      ArrayInitialize(upArrow, EMPTY_VALUE);
      ArrayInitialize(wuBuffer, 0);
      ArrayInitialize(wdBuffer, 0);
   }
   
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0) limit++;
   if(limit < 0) return(0);
   if(limit > rates_total - 1) limit = rates_total - 1;
   
   double atrBuffer[];
   ArrayResize(atrBuffer, rates_total);
   ArraySetAsSeries(atrBuffer, true);
   int atrHandle = iATR(_Symbol, _Period, 20);
   CopyBuffer(atrHandle, 0, 0, rates_total, atrBuffer);
   
   double priceBuffer[];
   ArrayResize(priceBuffer, rates_total);
   ArraySetAsSeries(priceBuffer, true);
   
   for(int i = limit; i >= 0; i--)
   {
      switch(Price)
      {
         case PRICE_CLOSE:     priceBuffer[i] = close[i]; break;
         case PRICE_OPEN:      priceBuffer[i] = open[i];  break;
         case PRICE_HIGH:      priceBuffer[i] = high[i];  break;
         case PRICE_LOW:       priceBuffer[i] = low[i];   break;
         case PRICE_MEDIAN:    priceBuffer[i] = (high[i] + low[i]) / 2.0; break;
         case PRICE_TYPICAL:   priceBuffer[i] = (high[i] + low[i] + close[i]) / 3.0; break;
         case PRICE_WEIGHTED:  priceBuffer[i] = (high[i] + low[i] + close[i] + close[i]) / 4.0; break;
      }
   }
   
   CalculateTMA(rates_total, prev_calculated, limit, priceBuffer);
   
   for(int i = limit; i >= 0; i--)
   {
      dnArrow[i] = EMPTY_VALUE;
      upArrow[i] = EMPTY_VALUE;
      
      if(i < rates_total - 1)
      {
         if(high[i+1] > upBuffer[i+1] && close[i+1] > open[i+1] && close[i] < open[i])
            upArrow[i] = high[i] + atrBuffer[i] / Gap / 2.0;
         
         if(low[i+1] < dnBuffer[i+1] && close[i+1] < open[i+1] && close[i] > open[i])
            dnArrow[i] = low[i] - atrBuffer[i] / Gap / 2.0;
      }
   }
   
   if(alertsOn)
   {
      int bar = alertsOnCurrent ? 0 : 1;
      
      if(alertsOnHighLow)
      {
         if(high[bar] > upBuffer[bar] && high[bar+1] < upBuffer[bar+1])
            DoAlert("high penetrated upper bar");
         if(low[bar] < dnBuffer[bar] && low[bar+1] > dnBuffer[bar+1])
            DoAlert("low penetrated lower bar");
      }
      else
      {
         if(close[bar] > upBuffer[bar] && close[bar+1] < upBuffer[bar+1])
            DoAlert("close penetrated upper bar");
         if(close[bar] < dnBuffer[bar] && close[bar+1] > dnBuffer[bar+1])
            DoAlert("close penetrated lower bar");
      }
   }
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate TMA values                                             |
//+------------------------------------------------------------------+
void CalculateTMA(const int rates_total,
                 const int prev_calculated,
                 const int limit,
                 const double &priceBuffer[])
{
   double FullLength = 2.0 * HalfLength + 1.0;
   
   for(int i = limit; i >= 0; i--)
   {
      if(i > rates_total - HalfLength - 1)
      {
         tmBuffer[i] = priceBuffer[i];
         continue;
      }
      
      double sum = (HalfLength + 1) * priceBuffer[i];
      double sumw = (HalfLength + 1);
      
      for(int j = 1, k = HalfLength; j <= HalfLength; j++, k--)
      {
         if(i + j < rates_total)
         {
            sum += k * priceBuffer[i + j];
            sumw += k;
         }
         
         if(RePaint && i - j >= 0)
         {
            sum += k * priceBuffer[i - j];
            sumw += k;
         }
      }
      
      tmBuffer[i] = sumw != 0 ? sum / sumw : tmBuffer[i + 1];
      
      double diff = priceBuffer[i] - tmBuffer[i];
      
      if(i == rates_total - HalfLength - 1)
      {
         upBuffer[i] = tmBuffer[i];
         dnBuffer[i] = tmBuffer[i];
         if(diff >= 0)
         {
            wuBuffer[i] = MathPow(diff, 2);
            wdBuffer[i] = 0;
         }
         else
         {
            wdBuffer[i] = MathPow(diff, 2);
            wuBuffer[i] = 0;
         }
         continue;
      }
      
      if(diff >= 0)
      {
         wuBuffer[i] = (wuBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         wdBuffer[i] = wdBuffer[i + 1] * (FullLength - 1) / FullLength;
      }
      else
      {
         wdBuffer[i] = (wdBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         wuBuffer[i] = wuBuffer[i + 1] * (FullLength - 1) / FullLength;
      }
      
      upBuffer[i] = tmBuffer[i] + BandsDeviations * MathSqrt(wuBuffer[i]);
      dnBuffer[i] = tmBuffer[i] - BandsDeviations * MathSqrt(wdBuffer[i]);
   }
}

//+------------------------------------------------------------------+
//| Alert function                                                   |
//+------------------------------------------------------------------+
void DoAlert(string doWhat)
{
   static string   previousAlert = "";
   static datetime previousTime = 0;
   
   if(previousAlert != doWhat || previousTime != TimeCurrent())
   {
      previousAlert = doWhat;
      previousTime = TimeCurrent();
      
      string message = StringFormat("%s at %s TMA : %s", _Symbol, TimeToString(TimeLocal(), TIME_SECONDS), doWhat);
      
      if(alertsMessage) Alert(message);
      if(alertsEmail)   SendMail("TMA Alert", message);
      if(alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//| Convert timeframe string to enum                                 |
//+------------------------------------------------------------------+
int StringToTimeFrame(string tfs)
{
   StringToUpper(tfs);
   
   if(tfs == "M1" || tfs == "1")     return PERIOD_M1;
   if(tfs == "M5" || tfs == "5")     return PERIOD_M5;
   if(tfs == "M15" || tfs == "15")   return PERIOD_M15;
   if(tfs == "M30" || tfs == "30")   return PERIOD_M30;
   if(tfs == "H1" || tfs == "60")    return PERIOD_H1;
   if(tfs == "H4" || tfs == "240")   return PERIOD_H4;
   if(tfs == "D1" || tfs == "1440")  return PERIOD_D1;
   if(tfs == "W1" || tfs == "10080") return PERIOD_W1;
   if(tfs == "MN" || tfs == "43200") return PERIOD_MN1;
   
   return _Period;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76159

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