// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71429

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
#property link "http://fxcodebase.com"
#property version "1.0"

// refer to http://homepage2.nifty.com/portal/tech/vr.htm
//#property copyright "00 - 00mql4@gmail.com"

//---- indicator settings
#property indicator_separate_window

#property indicator_buffers 3

#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Red

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID

//---- defines

//---- indicator parameters
input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT; // Timeframe
input int nVR = 14;                               // period of VR
input bool bShowVRA = true;                       // VR[A]
input bool bShowVRB = true;                       // VR[B]
input bool bShowWVR = true;                       // Wako VR
input int nMaxBars = 0;                           // number of bars, 0: no limit

//---- indicator buffers
double BufferVRA[]; // 0: VR[A]
double BufferVRB[]; // 1: VR[B]
double BufferWVR[]; // 2: Wako VR

//---- vars
string sIndicatorName;
string sIndVolumeRatio = "00-VolumeRatio_v100";

//----------------------------------------------------------------------
string TimeFrameToStr(ENUM_TIMEFRAMES timeFrame)
{
   switch (timeFrame)
   {
   case PERIOD_M1:
      return "M1";
   case PERIOD_M5:
      return "M5";
   case PERIOD_D1:
      return "D1";
   case PERIOD_H1:
      return "H1";
   case PERIOD_H4:
      return "H4";
   case PERIOD_M15:
      return "M15";
   case PERIOD_M30:
      return "M30";
   case PERIOD_MN1:
      return "MN1";
   case PERIOD_W1:
      return "W1";
   }
   return "";
}

//----------------------------------------------------------------------
void init()
{

   sIndicatorName = sIndVolumeRatio + "(" + TimeFrameToStr(timeFrame) + "," + nVR + ")";

   IndicatorShortName(sIndicatorName);

   SetIndexBuffer(0, BufferVRA);
   SetIndexBuffer(1, BufferVRB);
   SetIndexBuffer(2, BufferWVR);

   SetIndexLabel(0, "VR[A]");
   SetIndexLabel(1, "VR[B]");
   SetIndexLabel(2, "Wako VR");

   SetIndexDrawBegin(0, nVR);
   SetIndexDrawBegin(1, nVR);
   SetIndexDrawBegin(2, nVR);

   SetLevelValue(0, 0.0);
   SetLevelValue(1, 100.0);
   SetLevelValue(2, -100.0);
}

//----------------------------------------------------------------------
void start()
{
   int limit;
   int counted_bars = IndicatorCounted();

   if (counted_bars > 0)
   {
      counted_bars--;
   }

   limit = Bars - counted_bars;
   limit = MathMax(limit, nMaxBars);

   for (int i = 0; i < limit; i++)
   {
      if (timeFrame != Period() && timeFrame != PERIOD_CURRENT)
      {
         datetime t = Time[i];
         int x = iBarShift(NULL, timeFrame, t);
         BufferVRA[i] = iCustom(NULL, timeFrame, sIndVolumeRatio, timeFrame, nVR, bShowVRA, bShowVRB, bShowWVR, nMaxBars, 0, x);
         BufferVRB[i] = iCustom(NULL, timeFrame, sIndVolumeRatio, timeFrame, nVR, bShowVRA, bShowVRB, bShowWVR, nMaxBars, 1, x);
         BufferWVR[i] = iCustom(NULL, timeFrame, sIndVolumeRatio, timeFrame, nVR, bShowVRA, bShowVRB, bShowWVR, nMaxBars, 2, x);
         continue;
      }

      BufferVRA[i] = EMPTY_VALUE;
      BufferVRB[i] = EMPTY_VALUE;
      BufferWVR[i] = EMPTY_VALUE;

      double u = 0;
      double d = 0;
      double s = 0;

      for (int j = 0; j < nVR; j++)
      {
         x = i + j;
         double open = Open[x];
         double close = Close[x];
         double v = Volume[x];
         if (close > open)
         {
            u += v;
         }
         else if (close < open)
         {
            d += v;
         }
         else
         {
            // open == close
            s += v;
         }
      }

      double denom, vr;
      if (bShowVRA)
      {
         denom = d + s / 2.0;
         if (denom == 0)
         {
            vr = 0;
         }
         else
         {
            vr = (u + s / 2.0) / denom * 100.0;
         }
         BufferVRA[i] = vr;
      }
      if (bShowVRB)
      {
         denom = d + d + s;
         vr = 0;
         if (denom == 0)
         {
            vr = 0;
         }
         else
         {
            vr = (u + s / 2.0) / denom * 100.0;
         }
         BufferVRB[i] = vr;
      }
      if (bShowWVR)
      {
         denom = u + d + s;
         if (denom == 0)
         {
            vr = 0;
         }
         else
         {
            vr = (u - d - s) / denom * 100.0;
         }
         BufferWVR[i] = vr;
      }
   }
}