// Id: 23433
// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67182

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 2
#property indicator_plots   2
//--- plot upVolume
#property indicator_label1  "upVolume"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot dnVolume
#property indicator_label2  "dnVolume"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrFireBrick
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

 
//--- input parameters
input int      Difference = 50;
input int      LabelShift = 25;
input bool     ShowVolumeLabels = true;
input int      FontSize = 7;
input color    FontColorUp=clrBlue;
input color    FontColorDn=clrRed;
input color    FontColorNow=clrBlack;
// input int      DivBy = 1;
input color    WaveColor  = clrBlack;
input int      WaveWidth  = 1;



//--- indicator buffers
double         upVolumeBuffer[];
double         dnVolumeBuffer[];
double         barDirection[];
double         trendDirection[];
double         waveDirection[];
double         upPipBuffer[];
double         dnPipBuffer[];
double         volumeTracker[];
double         pipTracker[];

double         highestHigh[];
double         lowestLow[];
double            hhBar[];
double            llBar[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(13);

   IndicatorName = GenerateIndicatorName("WeisWaveRM4");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexBuffer(0, upVolumeBuffer);
   SetIndexBuffer(1, dnVolumeBuffer);
   SetIndexBuffer(2, trendDirection);
   SetIndexBuffer(3, waveDirection);
   SetIndexBuffer(4, barDirection);
   SetIndexBuffer(5, upPipBuffer);
   SetIndexBuffer(6, dnPipBuffer);
   SetIndexBuffer(7, volumeTracker);
   SetIndexBuffer(8, pipTracker);
   SetIndexBuffer(9, highestHigh);
   SetIndexBuffer(10, lowestLow);   
   SetIndexBuffer(11, hhBar);
   SetIndexBuffer(12, llBar);
   
   SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexStyle(8, DRAW_NONE);
   SetIndexStyle(9, DRAW_NONE);
   SetIndexStyle(10, DRAW_NONE);
   SetIndexStyle(11, DRAW_NONE);
   SetIndexStyle(12, DRAW_NONE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   return(0);
}
int  waveChangeBar = -1;
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
   RefreshRates();
   int limit = prev_calculated == 0 ? rates_total - 2 : rates_total - prev_calculated;

   if (waveChangeBar == -1)
   {
      waveChangeBar = limit + 1;
      highestHigh[waveChangeBar] = NormalizeDouble(close[waveChangeBar],5);
      lowestLow[waveChangeBar] = NormalizeDouble(close[waveChangeBar],5);
      hhBar[waveChangeBar] = waveChangeBar;
      llBar[waveChangeBar] = waveChangeBar;
   }

   string waveID = IndicatorObjPrefix + TimeToString(time[waveChangeBar], TIME_DATE|TIME_MINUTES) + "-TL";
   if (!ObjectFind(0, waveID)&&(time[0]> time[waveChangeBar]  && close[waveChangeBar]>0 && tick_volume[waveChangeBar]>0  && close[0]>0 )) {
      ObjectCreate(0, waveID, OBJ_TREND, 0, time[waveChangeBar], close[waveChangeBar], time[waveChangeBar], close[waveChangeBar]);
      ObjectSet(waveID, OBJPROP_RAY, false);
      ObjectSet(waveID, OBJPROP_WIDTH, WaveWidth);
      ObjectSet(waveID, OBJPROP_COLOR, WaveColor);
   }
   double shift = LabelShift / MathPow(10, Digits);
   double shift1 = (LabelShift+30) / MathPow(10, Digits);

   for(int i = limit; i>=0; i--) {
      // Determine this bar's direction
      if (NormalizeDouble(close[i],5) - NormalizeDouble(close[i+1],5) >  0) barDirection[i] = +1;    // current close higher
      if (NormalizeDouble(close[i],5) - NormalizeDouble(close[i+1],5) == 0) barDirection[i] =  0;    // current close equal
      if (NormalizeDouble(close[i],5) - NormalizeDouble(close[i+1],5) <  0) barDirection[i] = -1;    // current close lower

      if (barDirection[limit]   == EMPTY_VALUE) barDirection[limit]   = barDirection[i];
      if (trendDirection[limit] == EMPTY_VALUE) trendDirection[limit] = barDirection[i];
      if (waveDirection[limit]  == EMPTY_VALUE) waveDirection[limit]  = barDirection[i];

      // Determine highset high and lowest low
      if (NormalizeDouble(close[i],5) > highestHigh[i + 1]) {
         highestHigh[i] = NormalizeDouble(close[i],5);
         hhBar[i] = i;
      }
      else {
         highestHigh[i] = highestHigh[i + 1];
         hhBar[i] = hhBar[i + 1];
      }
      
      if (NormalizeDouble(close[i],5) < lowestLow[i + 1]) {
         lowestLow[i] = NormalizeDouble(close[i],5);
         llBar[i] = i;
      }
      else {
         lowestLow[i] = lowestLow[i + 1];
         llBar[i] = llBar[i + 1];
      }
      // Determine if this bar has started a new trend
      if ((barDirection[i] != 0) && (barDirection[i] != barDirection[i+1]))
         trendDirection[i] = barDirection[i];
      else
         trendDirection[i] = trendDirection[i+1];

      // Determine if this bar has started a new wave
      double waveTest = 0.0;
      if (waveDirection[i+1] == 1) {
         waveTest = highestHigh[i];
      }
      if (waveDirection[i+1] == -1) {
         waveTest = lowestLow[i];
      }
      double waveDifference = (MathAbs(waveTest - NormalizeDouble(close[i],5))) * MathPow(10, Digits);
      if (trendDirection[i] != waveDirection[i+1] && waveDifference >= Difference) {
         waveDirection[i] = trendDirection[i];
         if (waveDirection[i] == 1) {
            highestHigh[i] = NormalizeDouble(close[i],5);
            hhBar[i] = i;
            waveChangeBar = (int)llBar[i];
         }
         else {
            lowestLow[i] = NormalizeDouble(close[i],5);
            llBar[i] = i;
            waveChangeBar = (int)hhBar[i];
         }
        
         if( time[i]> time[waveChangeBar]  && close[waveChangeBar]>0 && tick_volume[waveChangeBar]>0  && close[i]>0 )
         {
            ObjectSet(waveID, OBJPROP_TIME2, time[waveChangeBar]);
            ObjectSet(waveID, OBJPROP_PRICE2, NormalizeDouble(close[waveChangeBar],5));
         }
         waveID = IndicatorObjPrefix + TimeToString(time[waveChangeBar], TIME_DATE|TIME_MINUTES) + "-TL";
         if(time[i]> time[waveChangeBar]  && close[waveChangeBar]>0 && tick_volume[waveChangeBar]>0  && close[i]>0 )
         {
            ObjectCreate(0, waveID, OBJ_TREND, 0, time[waveChangeBar], NormalizeDouble(close[waveChangeBar],5));
            ObjectSet(waveID, OBJPROP_RAY, false);
            ObjectSet(waveID, OBJPROP_WIDTH, WaveWidth);
            ObjectSet(waveID, OBJPROP_COLOR, WaveColor);
         }

         volumeTracker[waveChangeBar] = (double)tick_volume[waveChangeBar];
         pipTracker[waveChangeBar] = (NormalizeDouble(open[waveChangeBar],5)-NormalizeDouble(close[waveChangeBar],5))/Point;;
         for (int k = waveChangeBar - 1; k>=i; k--) {
            volumeTracker[k] = volumeTracker[k + 1] + tick_volume[k];
            pipTracker[k] = pipTracker[k + 1] + (NormalizeDouble(open[k],5)-NormalizeDouble(close[k],5))/Point;
            if (waveDirection[i] == 1) {
               upVolumeBuffer[k] = volumeTracker[k];
               dnVolumeBuffer[k] = 0;
               
               upPipBuffer[k]=MathAbs(pipTracker[k]);
               dnPipBuffer[k]=0;
            }
            if (waveDirection[i] == -1) {
               upVolumeBuffer[k] = 0;
               dnVolumeBuffer[k] = volumeTracker[k];

               upPipBuffer[k]=0;
               dnPipBuffer[k]=MathAbs(pipTracker[k]);
            }
         }

         if (ShowVolumeLabels == true ) {
            if (waveDirection[i] == 1 && dnPipBuffer[waveChangeBar]>0) {
               string lastVolLabel = IndicatorObjPrefix + TimeToString(time[waveChangeBar], TIME_DATE|TIME_MINUTES) + "-VOL";
               ObjectCreate(0, lastVolLabel, OBJ_TEXT, 0, time[waveChangeBar], NormalizeDouble(low[waveChangeBar]-shift,5));
               ObjectSet(lastVolLabel, OBJPROP_ANGLE, -0);
               ObjectSet(lastVolLabel, OBJPROP_ANCHOR, ANCHOR_CENTER);
      
               ObjectSetText(lastVolLabel,StringConcatenate( DoubleToString(dnVolumeBuffer[waveChangeBar]/1000, 1),"K"),FontSize, NULL, FontColorDn);
            }
            else if (waveDirection[i] == -1 && upPipBuffer[waveChangeBar]>0){
               string lastVolLabel = IndicatorObjPrefix + TimeToString(time[waveChangeBar], TIME_DATE|TIME_MINUTES) + "-VOL";
               ObjectCreate(0, lastVolLabel, OBJ_TEXT, 0, time[waveChangeBar],NormalizeDouble(high[waveChangeBar]+shift,5));
               ObjectSet(lastVolLabel, OBJPROP_ANGLE, 0);
               ObjectSet(lastVolLabel, OBJPROP_ANCHOR, ANCHOR_CENTER);
         
               ObjectSetText(lastVolLabel, StringConcatenate( DoubleToString(upVolumeBuffer[waveChangeBar]/1000, 1),"K"), FontSize, NULL, FontColorUp);
            }
         }
      }
      else {
         waveDirection[i] = waveDirection[i+1];
         volumeTracker[i] = volumeTracker[i + 1] + tick_volume[i];
         pipTracker[i] = pipTracker[i + 1] + (NormalizeDouble(open[i],5)-NormalizeDouble(close[i],5)) /Point ;
      }
      // Set the indicators
      if (waveDirection[i] ==  1) {
         upVolumeBuffer[i] = volumeTracker[i];
         dnVolumeBuffer[i] = 0;
         upPipBuffer[i]=MathAbs(pipTracker[i]);
         dnPipBuffer[i]=0;
      }
      if (waveDirection[i] == -1) {
         upVolumeBuffer[i] = 0;
         dnVolumeBuffer[i] = volumeTracker[i];
         upPipBuffer[i]=0;
         dnPipBuffer[i]=MathAbs(pipTracker[i]);
      }
   }
 
   ObjectSet(waveID, OBJPROP_TIME2, time[0]);
   ObjectSet(waveID, OBJPROP_PRICE2, NormalizeDouble(close[0],5));
   if (ShowVolumeLabels == true) {
      double price = NormalizeDouble(close[0] > close[1] ? high[0] + shift1 : low[0] - shift1, 5);
      if (ObjectFind(0, IndicatorObjPrefix + "VOLC") >= 0)
      {
         ObjectSet(IndicatorObjPrefix + "VOLC", OBJPROP_TIME1, time[0]);
         ObjectSet(IndicatorObjPrefix + "VOLC", OBJPROP_PRICE1, price);
      }
      else
      {
         ObjectCreate(0, IndicatorObjPrefix + "VOLC", OBJ_TEXT, 0, time[0], price);
         ObjectSet(IndicatorObjPrefix + "VOLC", OBJPROP_ANGLE, 0);
         ObjectSet(IndicatorObjPrefix + "VOLC", OBJPROP_ANCHOR, ANCHOR_LEFT);
      }
      ObjectSetText(IndicatorObjPrefix + "VOLC", StringConcatenate(DoubleToString(MathAbs(dnVolumeBuffer[0]-upVolumeBuffer[0])/1000,1), "K"), FontSize, NULL, FontColorNow);
   }  

//--- return value of prev_calculated for next call
   return(rates_total);
}

string StringPadLeft(string inStr, ushort padStr, int totalStrLen) {
   string result;
   StringInit(result, totalStrLen, padStr);
   result = StringConcatenate(result, inStr);
   
   int pos = StringLen(inStr);
  
   return StringSubstr(result, pos, totalStrLen);
}
//+------------------------------------------------------------------+
