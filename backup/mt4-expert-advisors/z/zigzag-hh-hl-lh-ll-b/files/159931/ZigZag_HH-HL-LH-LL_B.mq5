//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76157

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
#property indicator_buffers 3
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

input color TopColorHH = clrYellow;
input color TopColorLH = clrLime;
input color BotColorHL = clrRed;
input color BotColorLL = clrYellow;
input int Labeldistance = 2;
input int TxtSize1 = 7;
input int TxtSize2 = 6;
input string Fonts = "Arial Black";
//--- indicator buffers
double    ZigZagBuffer[];      // main buffer
double    HighMapBuffer[];     // ZigZag high extremes (peaks)
double    LowMapBuffer[];      // ZigZag low extremes (bottoms)

int       ExtRecalc=3;         // number of last extremes for recalculation

double Poin, Mut;
int level = 3;
bool firstRun = true;
double lastlow = 0.0, lasthigh = 0.0;
int lastlowpos = -1, lasthighpos = -1;
int whatlookfor = 0;
datetime lastTime = 0;
int lastZigzagIndex = -1;
double lastZigzagValue = 0.0;

enum EnSearchMode
  {
   Extremum=0, // searching for the first extremum
   Peak=1,     // searching for the next ZigZag peak
   Bottom=-1   // searching for the next ZigZag bottom
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,LowMapBuffer,INDICATOR_CALCULATIONS);
//--- set short name and digits
   string short_name=StringFormat("ZigZag(%d,%d,%d)",InpDepth,InpDeviation,InpBackstep);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set an empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "ZZ_Label");
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
      
   // Initialize variables
   Poin = _Point;
   Mut = Labeldistance;
   
   // Delete old labels at the beginning of calculation
   if(prev_calculated == 0) 
   {
      ObjectsDeleteAll(0, "ZZ_Label");
   }

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
      start=InpDepth;
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
                  res=1;
                 }
               if(LowMapBuffer[shift]!=0.0)
                 {
                  last_low=low[shift];
                  last_low_pos=shift;
                  extreme_search=Peak;
                  ZigZagBuffer[shift]=last_low;
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
               res=1;
              }
            if(HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               last_high=HighMapBuffer[shift];
               last_high_pos=shift;
               ZigZagBuffer[shift]=last_high;
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
               res=1;
              }
            if(LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               last_low=LowMapBuffer[shift];
               last_low_pos=shift;
               ZigZagBuffer[shift]=last_low;
               extreme_search=Peak;
               res=1;
              }
            break;
         default:
            return(rates_total);
        }
     }

   // Draw labels after full calculation
   for(i = start; i < rates_total; i++)
   {
      if(ZigZagBuffer[i] != 0.0)
      {
         if(HighMapBuffer[i] != 0.0) 
         {
            DrawHighLabel(i, time, high, low);
         }
         else if(LowMapBuffer[i] != 0.0) 
         {
            DrawLowLabel(i, time, high, low);
         }
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
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

void DrawHighLabel(int shift, const datetime &time_array[], const double &high_array[], const double &low_array[])
{
    string obj_name = "ZZ_Label" + IntegerToString(time_array[shift]);

    //--- Check if object already exists
    if (ObjectFind(0, obj_name) >= 0)
        return;

    double position = high_array[shift] + (Mut * Poin);
    string text = "";
    int size = TxtSize1;
    color clr = TopColorHH;

    //--- Find previous high
    double previousHigh = 0.0;
    int found = -1;
    for (int i = shift - 1; i >= 0; i--)
    {
        if (HighMapBuffer[i] != 0.0 && ZigZagBuffer[i] != 0.0)
        {
            previousHigh = high_array[i];
            found = i;
            break;
        }
    }

    //--- Determine label properties
    if (found >= 0)
    {
        if (high_array[shift] >= previousHigh)
        {
            text = "HH";
            clr = TopColorHH;
            size = TxtSize1;
        }
        else
        {
            text = "LH";
            clr = TopColorLH;
            size = TxtSize2;
        }
    }
    else
    {
        // First high point
        text = "HH";
        clr = TopColorHH;
        size = TxtSize1;
    }

    //--- Create object
    ObjectCreate(0, obj_name, OBJ_TEXT, 0, time_array[shift], position);
    ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, size);
    ObjectSetString(0, obj_name, OBJPROP_FONT, Fonts);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_LOWER);
}

void DrawLowLabel(int shift, const datetime &time_array[], const double &high_array[], const double &low_array[])
{
    string obj_name = "ZZ_Label" + IntegerToString(time_array[shift]);

    //--- Check if object already exists
    if (ObjectFind(0, obj_name) >= 0)
        return;

    double position = low_array[shift] - (Mut * Poin);
    string text = "";
    int size = TxtSize1;
    color clr = BotColorLL;

    //--- Find previous low
    double previousLow = 0.0;
    int found = -1;
    for (int i = shift - 1; i >= 0; i--)
    {
        if (LowMapBuffer[i] != 0.0 && ZigZagBuffer[i] != 0.0)
        {
            previousLow = low_array[i];
            found = i;
            break;
        }
    }

    //--- Determine label properties
    if (found >= 0)
    {
        if (low_array[shift] <= previousLow)
        {
            text = "LL";
            clr = BotColorLL;
            size = TxtSize1;
        }
        else
        {
            text = "HL";
            clr = BotColorHL;
            size = TxtSize2;
        }
    }
    else
    {
        // First low point
        text = "LL";
        clr = BotColorLL;
        size = TxtSize1;
    }

    //--- Create object
    ObjectCreate(0, obj_name, OBJ_TEXT, 0, time_array[shift], position);
    ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, size);
    ObjectSetString(0, obj_name, OBJPROP_FONT, Fonts);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_UPPER);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76157

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