// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=71412
// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71412

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
#property description "Bollinger Bands with customizable moving average method and applied price"
#property strict

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
//--- indicator parameters
input ENUM_MA_METHOD InpMovingMethod=MODE_SMA;   // Moving Average Method
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE;   // Applied Price
input int    InpBandsPeriod=20;      // Bands Period
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=2.0; // Bands Deviations
//--- buffers
double ExtMovingBuffer[];
double ExtUpperBuffer[];
double ExtLowerBuffer[];
double ExtStdDevBuffer[];
double ExtPriceBuffer[];

input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};

VisibilityCotroller visibility;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- 1 additional buffer used for counting
   IndicatorBuffers(5);
   IndicatorDigits(Digits);
//--- middle line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMovingBuffer);
   SetIndexShift(0,InpBandsShift);
   SetIndexLabel(0,"Bands MA");
//--- upper band
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtUpperBuffer);
   SetIndexShift(1,InpBandsShift);
   SetIndexLabel(1,"Bands Upper");
//--- lower band
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtLowerBuffer);
   SetIndexShift(2,InpBandsShift);
   SetIndexLabel(2,"Bands Lower");
//--- work buffer
   SetIndexBuffer(3,ExtStdDevBuffer);
   SetIndexBuffer(4,ExtPriceBuffer);
//--- check for input parameter
   if(InpBandsPeriod<=0)
     {
      Print("Wrong input parameter Bands Period=",InpBandsPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(1,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(2,InpBandsPeriod+InpBandsShift);
	visibility.Init("show_hide_cb", "CB", "Show/Hide", button_x, button_y);
//--- initialization done
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   visibility.DeInit();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
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
   visibility.HandleButtonClicks();
   int i,pos;

   int pc = prev_calculated;
//---
   if(rates_total<=InpBandsPeriod || InpBandsPeriod<=0)
   {
      return(0);
   }
   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         pc = 0;
      }
      else
      {
         ArrayInitialize(ExtMovingBuffer, EMPTY_VALUE);
         ArrayInitialize(ExtUpperBuffer, EMPTY_VALUE);
         ArrayInitialize(ExtLowerBuffer, EMPTY_VALUE);
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtMovingBuffer,false);
   ArraySetAsSeries(ExtUpperBuffer,false);
   ArraySetAsSeries(ExtLowerBuffer,false);
   ArraySetAsSeries(ExtStdDevBuffer,false);
   ArraySetAsSeries(ExtPriceBuffer,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
//--- initial zero
   if(pc < 1)
   {
      ArrayInitialize(ExtMovingBuffer, EMPTY_VALUE);
      ArrayInitialize(ExtUpperBuffer, EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer, EMPTY_VALUE);
   }
//--- starting calculation
   if(pc > 1)
      pos = pc - 1;
   else
      pos = 0;
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
   {
      //--- price buffer
      switch(InpAppliedPrice)
      {
         case PRICE_CLOSE:
            ExtPriceBuffer[i]=close[i];
            break;
         case PRICE_OPEN:
            ExtPriceBuffer[i]=open[i];
            break;
         case PRICE_HIGH:
            ExtPriceBuffer[i]=high[i];
            break;
         case PRICE_LOW:
            ExtPriceBuffer[i]=low[i];
            break;
         case PRICE_MEDIAN:
            ExtPriceBuffer[i]=(high[i]+low[i])/2;
            break;
         case PRICE_TYPICAL:
         	ExtPriceBuffer[i]=(high[i]+low[i]+close[i])/3;
            break;
         case PRICE_WEIGHTED:
            ExtPriceBuffer[i]=(high[i]+low[i]+close[i]*2)/4;
            break;
      }
      //--- middle line
      switch(InpMovingMethod)
      {
         //--- Simple
         case  MODE_SMA:
            ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,ExtPriceBuffer);
            break;
            //--- Exponential
         case MODE_EMA:
            if(i==0)
            ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,ExtPriceBuffer);
            else
               ExtMovingBuffer[i]=ExponentialMA(i,InpBandsPeriod,ExtMovingBuffer[i-1],ExtPriceBuffer);
            break;
            //--- Smooted
         case MODE_SMMA:
            if(i==0)
            ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,ExtPriceBuffer);
            else
               ExtMovingBuffer[i]=SmoothedMA(i,InpBandsPeriod,ExtMovingBuffer[i-1],ExtPriceBuffer);
            break;
            break;
            //--- Linear Weighted
         case MODE_LWMA:
            ExtMovingBuffer[i]=LinearWeightedMA(i,InpBandsPeriod,ExtPriceBuffer);
            break;
         default:
            break;
      }
      //--- calculate and write down StdDev
      ExtStdDevBuffer[i]=StdDev_Func(i,ExtPriceBuffer,ExtMovingBuffer,InpBandsPeriod);
      //--- upper line
      ExtUpperBuffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*ExtStdDevBuffer[i];
      //--- lower line
      ExtLowerBuffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*ExtStdDevBuffer[i];
      //---
   }
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
{
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position>=period)
   {
      //--- calcualte StdDev
      for(int i=0; i<period; i++)
         StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
      StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
   }
//--- return calculated value
   return(StdDev_dTmp);
}
//+------------------------------------------------------------------+
