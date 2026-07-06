// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70890

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

// based on EarnForex https://www.earnforex.com/metatrader-indicators/Pinbar-Detector/"

#property description "Pinbar Detector - detects Pinbars on charts."
#property description "Has two sets of predefined settings: common and strict."
#property description "Fully modifiable parameters of Pinbar pattern."
#property description "Usage instructions:"
 

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_width1 2
#property indicator_color2 clrLime
#property indicator_width2 2

input int  CountBars = 0; // CountBars - number of bars to count on, 0 = all.
input int  DisplayDistance = 5; // DisplayDistance - the higher it is the the distance from faces to candles.
input bool UseAlerts = true; // Use Alerts
input bool UseEmailAlerts = false; // Use Email Alerts (configure SMTP parameters in Tools->Options->Emails)
input bool UseCustomSettings = false; // Use Custom Settings - if true = use below parameters:
input double CustomMaxNoseBodySize = 0.33; // Max. Body / Candle length ratio of the Nose Bar
input double CustomNoseBodyPosition = 0.4; // Body position in Nose Bar (e.g. top/bottom 40%)
input bool   CustomLeftEyeOppositeDirection = true; // true = Direction of Left Eye Bar should be opposite to pattern (bearish bar for bullish Pinbar pattern and vice versa)
input bool   CustomNoseSameDirection = false; // true = Direction of Nose Bar should be the same as of pattern (bullish bar for bullish Pinbar pattern and vice versa)
input bool   CustomNoseBodyInsideLeftEyeBody = false; // true = Nose Body should be contained inside Left Eye Body
input double CustomLeftEyeMinBodySize = 0.1; // Min. Body / Candle length ratio of the Left Eye Bar
input double CustomNoseProtruding = 0.5; // Minmum protrusion of Nose Bar compared to Nose Bar length
input double CustomNoseBodyToLeftEyeBody = 1; // Maximum relative size of the Nose Bar Body to Left Eye Bar Body
input double CustomNoseLengthToLeftEyeLength = 0; // Minimum relative size of the Nose Bar Length to Left Eye Bar Length
input double CustomLeftEyeDepth = 0.1; // Minimum relative depth of the Left Eye to its length; depth is difference with Nose's back
 input int button_x = 20; // Button x position
input int button_y = 30; // Button y position

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

// Indicator buffers
double Down[];
double Up[];

// Global variables
int LastBars = 0;
double MaxNoseBodySize = 0.33;
double NoseBodyPosition = 0.4;
bool   LeftEyeOppositeDirection = true;
bool   NoseSameDirection = false;
bool   NoseBodyInsideLeftEyeBody = false;
double LeftEyeMinBodySize = 0.1;
double NoseProtruding = 0.5;
double NoseBodyToLeftEyeBody = 1;
double NoseLengthToLeftEyeLength = 0;
double LeftEyeDepth = 0.2;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   visibility.Init("pinbar", "pinbar", "Show/Hide", button_x, button_y);
//---- indicator buffers mapping  
   SetIndexBuffer(0, Down);
   SetIndexBuffer(1, Up);  
//---- drawing settings
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 87);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 87);
//----
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
//---- indicator labels
   SetIndexLabel(0, "Bearish Pinbar");
   SetIndexLabel(1, "Bullish Pinbar");
//----
   if (UseCustomSettings)
   {
      MaxNoseBodySize = CustomMaxNoseBodySize;
      NoseBodyPosition = CustomNoseBodyPosition;
      LeftEyeOppositeDirection = CustomLeftEyeOppositeDirection;
      NoseSameDirection = CustomNoseSameDirection;
      LeftEyeMinBodySize = CustomLeftEyeMinBodySize;
      NoseProtruding = CustomNoseProtruding;
      NoseBodyToLeftEyeBody = CustomNoseBodyToLeftEyeBody;
      NoseLengthToLeftEyeLength = CustomNoseLengthToLeftEyeLength;
      LeftEyeDepth = CustomLeftEyeDepth;
   }
   return(0);
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
      start();
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   visibility.HandleButtonClicks();
   int NeedBarsCounted;
   double NoseLength, NoseBody, LeftEyeBody, LeftEyeLength;


   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         LastBars = 0;
      }
      else
      {
         ArrayInitialize(Down, EMPTY_VALUE);
         ArrayInitialize(Up, EMPTY_VALUE);
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   else if (!visibility.IsVisible())
   {
      return 0;
   }
   if (LastBars == Bars) return(0);
   NeedBarsCounted = Bars - LastBars;
   if ((CountBars > 0) && (NeedBarsCounted > CountBars)) NeedBarsCounted = CountBars;
   LastBars = Bars;
   if (NeedBarsCounted == Bars) NeedBarsCounted--;

   for (int i = NeedBarsCounted; i >= 1; i--)
   {
      // Won't have Left Eye for the left-most bar.
      if (i == Bars - 1) continue;
      
      // Left Eye and Nose bars's paramaters.
      NoseLength = High[i] - Low[i];
      if (NoseLength == 0) NoseLength = Point;
      LeftEyeLength = High[i + 1] - Low[i + 1];
      if (LeftEyeLength == 0) LeftEyeLength = Point;
      NoseBody = MathAbs(Open[i] - Close[i]);
      if (NoseBody == 0) NoseBody = Point;
      LeftEyeBody = MathAbs(Open[i + 1] - Close[i + 1]);
      if (LeftEyeBody == 0) LeftEyeBody = Point;

      // Bearish Pinbar
      if (High[i] - High[i + 1] >= NoseLength * NoseProtruding) // Nose protrusion
      {
         if (NoseBody / NoseLength <= MaxNoseBodySize) // Nose body to candle length ratio
         {
            if (1 - (High[i] - MathMax(Open[i], Close[i])) / NoseLength < NoseBodyPosition) // Nose body position in bottom part of the bar
            {
               if ((!LeftEyeOppositeDirection) || (Close[i + 1] > Open[i + 1])) // Left Eye bullish if required
               {
                  if ((!NoseSameDirection) || (Close[i] < Open[i])) // Nose bearish if required
                  {
                     if (LeftEyeBody / LeftEyeLength  >= LeftEyeMinBodySize) // Left eye body to candle length ratio
                     {
                        if ((MathMax(Open[i], Close[i]) <= High[i + 1]) && (MathMin(Open[i], Close[i]) >= Low[i + 1])) // Nose body inside Left Eye bar
                        {
                           if (NoseBody / LeftEyeBody <= NoseBodyToLeftEyeBody) // Nose body to Left Eye body ratio
                           {
                              if (NoseLength / LeftEyeLength >= NoseLengthToLeftEyeLength) // Nose length to Left Eye length ratio
                              {
                                 if (Low[i] - Low[i + 1] >= LeftEyeLength * LeftEyeDepth)  // Left Eye low is low enough
                                 {
                                    if ((!NoseBodyInsideLeftEyeBody) || ((MathMax(Open[i], Close[i]) <= MathMax(Open[i + 1], Close[i + 1])) && (MathMin(Open[i], Close[i]) >= MathMin(Open[i + 1], Close[i + 1])))) // Nose body inside Left Eye body if required
                                    {
                                       Down[i] = High[i] + DisplayDistance * Point + NoseLength / 5;
                                       if (i == 1) SendAlert("Bearish"); // Send alerts only for the latest fully formed bar
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      // Bullish Pinbar
      if (Low[i + 1] - Low[i] >= NoseLength * NoseProtruding) // Nose protrusion
      {
         if (NoseBody / NoseLength <= MaxNoseBodySize) // Nose body to candle length ratio
         {
            if (1 - (MathMin(Open[i], Close[i]) - Low[i]) / NoseLength < NoseBodyPosition) // Nose body position in top part of the bar
            {
               if ((!LeftEyeOppositeDirection) || (Close[i + 1] < Open[i + 1])) // Left Eye bearish if required
               {
                  if ((!NoseSameDirection) || (Close[i] > Open[i])) // Nose bullish if required
                  {
                     if (LeftEyeBody / LeftEyeLength >= LeftEyeMinBodySize) // Left eye body to candle length ratio
                     {
                        if ((MathMax(Open[i], Close[i]) <= High[i + 1]) && (MathMin(Open[i], Close[i]) >= Low[i + 1])) // Nose body inside Left Eye bar
                        {
                           if (NoseBody / LeftEyeBody <= NoseBodyToLeftEyeBody) // Nose body to Left Eye body ratio
                           {
                              if (NoseLength / LeftEyeLength >= NoseLengthToLeftEyeLength) // Nose length to Left Eye length ratio
                              {
                                 if (High[i + 1] - High[i] >= LeftEyeLength * LeftEyeDepth) // Left Eye high is high enough
                                 {
                                    if ((!NoseBodyInsideLeftEyeBody) || ((MathMax(Open[i], Close[i]) <= MathMax(Open[i + 1], Close[i + 1])) && (MathMin(Open[i], Close[i]) >= MathMin(Open[i + 1], Close[i + 1])))) // Nose body inside Left Eye body if required
                                    {
                                       Up[i] = Low[i] - DisplayDistance * Point - NoseLength / 5;
                                       if (i == 1) SendAlert("Bullish"); // Send alerts only for the latest fully formed bar
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
   return(0);
}

string TimeframeToString(int P)
{
   switch(P)
   {
      case PERIOD_M1:  return("M1");
      case PERIOD_M5:  return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H4:  return("H4");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN1");
   }
   return("");
}

void SendAlert(string dir)
{
   string per = TimeframeToString(Period());
   if (UseAlerts)
   {
      Alert(dir + " Pinbar on ", Symbol(), " @ ", per);
      PlaySound("alert.wav");
   }
   if (UseEmailAlerts)
      SendMail(Symbol() + " @ " + per + " - " + dir + " Pinbar", dir + " Pinbar on " + Symbol() + " @ " + per + " as of " + TimeToStr(TimeCurrent()));
}