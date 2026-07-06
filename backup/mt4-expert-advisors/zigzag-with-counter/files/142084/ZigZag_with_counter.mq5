// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71190

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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot ZigZag
#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int InpDepth    =12;  // Depth
input int InpDeviation=5;   // Deviation
input int InpBackstep =3;   // Back Step
input string dg = "===="; // Displaying for information
input color Text_color_Top = Green; // Top Label Text color
input color Text_color_Bottom = Red; // Bottom Label Text color
input int font_size = 12; // Text size
input double V_Shift = 0; // Vertical Label shift
input bool DisplayBars = false; // Bars Counting
input bool DisplayPips = false; // Pips Counting
input bool DisplayVols = false; // Volumes Counting
input bool DisplaySwng = false; // Swing % Calculation
input bool DisplayHLp = false; // Highest/Lowest Prices

//--- indicator buffers
double    ZigZagBuffer[];      // main buffer
double    HighMapBuffer[];     // ZigZag high extremes (peaks)
double    LowMapBuffer[];      // ZigZag low extremes (bottoms)

int       ExtRecalc=3;         // number of last extremes for recalculation

enum EnSearchMode
{
   Extremum=0, // searching for the first extremum
   Peak=1,     // searching for the next ZigZag peak
   Bottom=-1   // searching for the next ZigZag bottom
};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double peaks[];
string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("zz");
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,LowMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, peaks, INDICATOR_CALCULATIONS);
//--- set short name and digits
   string short_name=StringFormat("ZigZag(%d,%d,%d)",InpDepth,InpDeviation,InpBackstep);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set an empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}
//+------------------------------------------------------------------+
//| ZigZag calculation                                               |
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
   if(rates_total<100)
      return(0);
//---
   int    i=0;
   int    start=0,extreme_counter=0,extreme_search=Extremum;
   int    shift=0,back=0,last_high_pos=0,last_low_pos=0;
   double val=0,res=0;
   double curlow=0,curhigh=0,last_high=0,last_low=0;
//--- initializing
   if(prev_calculated==0)
   {
      ArrayInitialize(ZigZagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      ArrayInitialize(peaks, -1);
      start = InpDepth;
   }

//--- ZigZag was already calculated before
   if(prev_calculated>0)
   {
      i=rates_total-1;
      //--- searching for the third extremum from the last uncompleted bar
      while(extreme_counter<ExtRecalc && i>rates_total-100)
      {
         res=ZigZagBuffer[i];
         if(res!=0.0)
            extreme_counter++;
         i--;
      }
      i++;
      start=i;

      //--- what type of exremum we search for
      if(LowMapBuffer[i]!=0.0)
      {
         curlow=LowMapBuffer[i];
         extreme_search=Peak;
      }
      else
      {
         curhigh=HighMapBuffer[i];
         extreme_search=Bottom;
      }
      //--- clear indicator values
      for(i=start+1; i<rates_total && !IsStopped(); i++)
      {
         ZigZagBuffer[i] =0.0;
         LowMapBuffer[i] =0.0;
         HighMapBuffer[i]=0.0;
      }
   }

//--- searching for high and low extremes
   for(shift=start; shift<rates_total && !IsStopped(); shift++)
   {
      //--- low
      val=low[Lowest(low,InpDepth,shift)];
      if(val==last_low)
         val=0.0;
      else
      {
         last_low=val;
         if((low[shift]-val)>InpDeviation*_Point)
            val=0.0;
         else
         {
            for(back=1; back<=InpBackstep; back++)
            {
               res=LowMapBuffer[shift-back];
               if((res!=0) && (res>val))
                  LowMapBuffer[shift-back]=0.0;
            }
         }
      }
      if(low[shift]==val)
         LowMapBuffer[shift]=val;
      else
         LowMapBuffer[shift]=0.0;
      //--- high
      val=high[Highest(high,InpDepth,shift)];
      if(val==last_high)
         val=0.0;
      else
      {
         last_high=val;
         if((val-high[shift])>InpDeviation*_Point)
            val=0.0;
         else
         {
            for(back=1; back<=InpBackstep; back++)
            {
               res=HighMapBuffer[shift-back];
               if((res!=0) && (res<val))
                  HighMapBuffer[shift-back]=0.0;
            }
         }
      }
      if(high[shift]==val)
         HighMapBuffer[shift]=val;
      else
         HighMapBuffer[shift]=0.0;
   }

//--- set last values
   if(extreme_search==0) // undefined values
   {
      last_low=0.0;
      last_high=0.0;
   }
   else
   {
      last_low=curlow;
      last_high=curhigh;
   }

//--- final selection of extreme points for ZigZag
   for(shift=start; shift<rates_total && !IsStopped(); shift++)
   {
      res=0.0;
      switch(extreme_search)
      {
         case Extremum:
            if(last_low==0.0 && last_high==0.0)
            {
               if(HighMapBuffer[shift]!=0)
               {
                  last_high=high[shift];
                  last_high_pos=shift;
                  extreme_search=Bottom;
                  ZigZagBuffer[shift]=last_high;
                  DrawInfo(shift, true, tick_volume);
                  res=1;
               }
               if(LowMapBuffer[shift]!=0.0)
               {
                  last_low=low[shift];
                  last_low_pos=shift;
                  extreme_search=Peak;
                  ZigZagBuffer[shift]=last_low;
                  DrawInfo(shift, false, tick_volume);
                  res=1;
               }
            }
            break;
         case Peak:
            if(LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<last_low && HighMapBuffer[shift]==0.0)
            {
               ZigZagBuffer[last_low_pos]=0.0;
               last_low_pos=shift;
               last_low=LowMapBuffer[shift];
               ZigZagBuffer[shift]=last_low;
               DrawInfo(shift, false, tick_volume);
               res=1;
            }
            if(HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
            {
               last_high=HighMapBuffer[shift];
               last_high_pos=shift;
               ZigZagBuffer[shift]=last_high;
               DrawInfo(shift, true, tick_volume);
               extreme_search=Bottom;
               res=1;
            }
            break;
         case Bottom:
            if(HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>last_high && LowMapBuffer[shift]==0.0)
            {
               ZigZagBuffer[last_high_pos]=0.0;
               last_high_pos=shift;
               last_high=HighMapBuffer[shift];
               ZigZagBuffer[shift]=last_high;
               DrawInfo(shift, true, tick_volume);
            }
            if(LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
            {
               last_low=LowMapBuffer[shift];
               last_low_pos=shift;
               ZigZagBuffer[shift]=last_low;
               DrawInfo(shift, false, tick_volume);
               extreme_search=Peak;
            }
            break;
         default:
            return(rates_total);
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}

int GetPrevious(int period)
{
   for (int i = period - 1; i >= 0; --i)
   {
      if (ZigZagBuffer[i] != 0.0)
      {
         return i;
      }
   }
   return -1;
}

string TextFormat(int bars, double pips, double pips2, double tickvol, string percent1, string HLprice)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digit = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = digit == 3 || digit == 5 ? 10 : 1;
   double pipSize = point * mult;
	string TextLabel = "Peak";
	if (DisplayBars)
      TextLabel = TextLabel + " " + "Bars: " + (MathAbs(bars) + 1);
	if (DisplayPips)
      TextLabel = TextLabel + " " + "Pips: " + MathFloor(MathAbs(pips) / pipSize * 10 + 0.5) / 10;
	if (DisplayVols)
      TextLabel = TextLabel + " " + "Vols: " + tickvol;
	if (DisplaySwng)
      TextLabel = TextLabel + " " + percent1 + " %";
	if (DisplayHLp)
      TextLabel = TextLabel + " " + HLprice;
   return TextLabel;
}

long RegisterTicksVolume(int from, int period, const long &tick_volume[])
{
   long sum = 0;
   for (int i = from; i < period; ++i)
   {
      sum += tick_volume[i];
   }
	return sum;
}

void DrawInfo(int period, bool isUp, const long &tick_volume[])
{
   int first = period;
   int second = GetPrevious(first);
   int third = GetPrevious(second);
   if (third < 0)
   {
      return;
   }
   int bars = iBars(_Symbol, _Period);
   datetime time = iTime(_Symbol, _Period, bars - 1 - period);
   if (isUp)
   {
      double price = ZigZagBuffer[period] + V_Shift;
      string label = TextFormat(first - second, 
         ZigZagBuffer[first] - ZigZagBuffer[second], 
         ZigZagBuffer[second] - ZigZagBuffer[third],
         RegisterTicksVolume(second, first, tick_volume), 
         "+ " + DoubleToString(((ZigZagBuffer[first] / ZigZagBuffer[second]) - 1) * 100, 4),
         "Highest = " + DoubleToString(ZigZagBuffer[first], 5));
      string id = IndicatorObjPrefix + TimeToString(time);
      if (ObjectFind(0, id) == -1)
      {
         if (ObjectCreate(0, id, OBJ_TEXT, 0, time, price))
         {
            ObjectSetString(0, id, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
            ObjectSetInteger(0, id, OBJPROP_COLOR, Text_color_Top);
            ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
         }
      }
      ObjectSetString(0, id, OBJPROP_TEXT, label);
   }
   else
   {
      double price = ZigZagBuffer[period] - V_Shift;
      string label = TextFormat(first - second, 
         ZigZagBuffer[second] - ZigZagBuffer[first], 
         ZigZagBuffer[third] - ZigZagBuffer[second],
         RegisterTicksVolume(second, first, tick_volume), 
         "- " + DoubleToString((ZigZagBuffer[second] - ZigZagBuffer[first]) / ZigZagBuffer[second] * 100, 4),
         "Lowest = " + DoubleToString(ZigZagBuffer[first], 5));
          string id = IndicatorObjPrefix + TimeToString(time);
      if (ObjectFind(0, id) == -1)
      {
         if (ObjectCreate(0, id, OBJ_TEXT, 0, time, price))
         {
            ObjectSetString(0, id, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
            ObjectSetInteger(0, id, OBJPROP_COLOR, Text_color_Bottom);
            ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
         }
      }
      ObjectSetString(0, id, OBJPROP_TEXT, label);
   }
}
//+------------------------------------------------------------------+
//|  Search for the index of the highest bar                         |
//+------------------------------------------------------------------+
int Highest(const double &array[],const int depth,const int start)
{
   if(start<0)
      return(0);

   double max=array[start];
   int    index=start;
//--- start searching
   for(int i=start-1; i>start-depth && i>=0; i--)
   {
      if(array[i]>max)
      {
         index=i;
         max=array[i];
      }
   }
//--- return index of the highest bar
   return(index);
}
//+------------------------------------------------------------------+
//|  Search for the index of the lowest bar                          |
//+------------------------------------------------------------------+
int Lowest(const double &array[],const int depth,const int start)
{
   if(start<0)
      return(0);

   double min=array[start];
   int    index=start;
//--- start searching
   for(int i=start-1; i>start-depth && i>=0; i--)
   {
      if(array[i]<min)
      {
         index=i;
         min=array[i];
      }
   }
//--- return index of the lowest bar
   return(index);
}
//+------------------------------------------------------------------+