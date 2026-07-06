// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71405

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red          // Tenkan-sen
#property indicator_color2 Blue         // Kijun-sen
#property indicator_color3 SandyBrown   // Up Kumo
#property indicator_color4 Thistle      // Down Kumo
#property indicator_color5 Lime         // Chikou Span
#property indicator_color6 SandyBrown   // Up Kumo bounding line
#property indicator_color7 Thistle      // Down Kumo bounding line

input int rsi_period = 14; // RSI Period
input int InpTenkan=9;   // Tenkan-sen
input int InpKijun=26;   // Kijun-sen
input int InpSenkou=52;  // Senkou Span B

input int bars_limit = 100000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double ExtTenkanBuffer[];
double ExtKijunBuffer[];
double ExtSpanA_Buffer[];
double ExtSpanB_Buffer[];
double ExtChikouBuffer[];
double ExtSpanA2_Buffer[];
double ExtSpanB2_Buffer[];
//---
int    ExtBegin;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Rsii");
   IndicatorShortName("RSII");

   IndicatorDigits(Digits);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtTenkanBuffer);
   SetIndexDrawBegin(0,InpTenkan-1);
   SetIndexLabel(0,"Tenkan Sen");
//---
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtKijunBuffer);
   SetIndexDrawBegin(1,InpKijun-1);
   SetIndexLabel(1,"Kijun Sen");
//---
   ExtBegin=InpKijun;
   if(ExtBegin<InpTenkan)
      ExtBegin=InpTenkan;
//---
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(2,ExtSpanA_Buffer);
   SetIndexDrawBegin(2,InpKijun+ExtBegin-1);
   SetIndexShift(2,InpKijun);
   SetIndexLabel(2,NULL);
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(5,ExtSpanA2_Buffer);
   SetIndexDrawBegin(5,InpKijun+ExtBegin-1);
   SetIndexShift(5,InpKijun);
   SetIndexLabel(5,"Senkou Span A");
//---
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(3,ExtSpanB_Buffer);
   SetIndexDrawBegin(3,InpKijun+InpSenkou-1);
   SetIndexShift(3,InpKijun);
   SetIndexLabel(3,NULL);
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,ExtSpanB2_Buffer);
   SetIndexDrawBegin(6,InpKijun+InpSenkou-1);
   SetIndexShift(6,InpKijun);
   SetIndexLabel(6,"Senkou Span B");
//---
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtChikouBuffer);
   SetIndexShift(4,-InpKijun);
   SetIndexLabel(4,"Chikou Span");

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(ExtTenkanBuffer,false);
   ArraySetAsSeries(ExtKijunBuffer,false);
   ArraySetAsSeries(ExtSpanA_Buffer,false);
   ArraySetAsSeries(ExtSpanB_Buffer,false);
   ArraySetAsSeries(ExtChikouBuffer,false);
   ArraySetAsSeries(ExtSpanA2_Buffer,false);
   ArraySetAsSeries(ExtSpanB2_Buffer,false);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int pos=InpTenkan-1;
   double high_value;
   double low_value;
   for(int i = pos; i<rates_total; i++)
   {
      high_value=iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, i);
      low_value=iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, i);
      int k=i+1-InpTenkan;
      while(k<=i)
      {
         if(high_value<iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, k))
            high_value=iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, k);
         if(low_value>iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, k))
            low_value=iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, k);
         k++;
      }
      ExtTenkanBuffer[i]=(high_value+low_value)/2;
   }
   pos=InpKijun-1;
   if(prev_calculated>InpKijun)
      pos=prev_calculated-1;
   for(int i=pos; i<rates_total; i++)
   {
      high_value=iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, i);
      low_value=iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, i);
      int k=i+1-InpKijun;
      while(k<=i)
      {
         if(high_value<iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, k))
            high_value=iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, k);
         if(low_value>iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, k))
            low_value=iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, k);
         k++;
      }
      ExtKijunBuffer[i]=(high_value+low_value)/2;
   }
   pos=ExtBegin-1;
   if(prev_calculated>ExtBegin)
      pos=prev_calculated-1;
   for(int i=pos; i<rates_total; i++)
   {
      ExtSpanA_Buffer[i]=(ExtKijunBuffer[i]+ExtTenkanBuffer[i])/2;
      ExtSpanA2_Buffer[i]=ExtSpanA_Buffer[i];
   }
   pos=InpSenkou-1;
   if(prev_calculated>InpSenkou)
      pos=prev_calculated-1;
   for(int i=pos; i<rates_total; i++)
   {
      high_value=iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, i);
      low_value=iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, i);
      int k=i+1-InpSenkou;
      while(k<=i)
      {
         if(high_value<iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, k))
            high_value=iRSI(_Symbol, _Period, rsi_period, PRICE_HIGH, k);
         if(low_value>iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, k))
            low_value=iRSI(_Symbol, _Period, rsi_period, PRICE_LOW, k);
         k++;
      }
      ExtSpanB_Buffer[i]=(high_value+low_value)/2;
      ExtSpanB2_Buffer[i]=ExtSpanB_Buffer[i];
   }
   pos=0;
   if(prev_calculated>1)
      pos=prev_calculated-1;
   for(int i=pos; i<rates_total; i++)
      ExtChikouBuffer[i]=iRSI(_Symbol, _Period, rsi_period, PRICE_CLOSE, i);
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}