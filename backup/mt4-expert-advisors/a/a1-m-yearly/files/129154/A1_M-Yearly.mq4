// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69006

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
//----
int ExtCountedBars=0;
input int button_x = 20;
input int button_y = 30;

int data = 1;

//Visibility controller v1.1
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
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, x);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, y);
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
VisibilityCotroller _visibility;

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
int init()
{
   IndicatorName = GenerateIndicatorName("A1 M-Yearly");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   _visibility.Init("CloseButton" + IndicatorObjPrefix, IndicatorName, "Show/Hide", button_x, button_y);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//---- TODO: add your code here
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   ObjectsDeleteAll(0, "CloseButton" + IndicatorObjPrefix);
//----
   return(0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (_visibility.HandleButtonClicks())
      start();
}

int start()
{
   _visibility.HandleButtonClicks();
   if (!_visibility.IsVisible())
   {
      data = 1;
      ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
      return 0;
   }
   if(data != 1) 
      return(0);
   double haOpen, haHigh, haLow, haClose;
   if(Bars<=10) 
      return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) 
      return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) 
      ExtCountedBars--;
   int pos = _visibility.IsRecalcNeeded() ? Bars - 1 : Bars - ExtCountedBars - 1;
   _visibility.ResetRecalc();
   int i;
   
   datetime startmonth = Time[pos];
   datetime endmonth = 0;
   datetime timewick;

   int firstyear = TimeYear(Time[pos]);
   int thisyear  = TimeYear(TimeCurrent());
   int year      = thisyear - firstyear;
   int yeardummy = year;
   
   int theyear;
   int yeartemp = 0;
   
   for(i=thisyear; i>= firstyear; i--)
   {
      ObjectCreate(IndicatorObjPrefix + "Yearly Body"+IntegerToString(i),      OBJ_RECTANGLE, 0, 0,0, 0,0);
      ObjectCreate(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(i), OBJ_TREND, 0, 0,0, 0,0);
      ObjectCreate(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(i), OBJ_TREND, 0, 0,0, 0,0);
   }

   while(pos>=0)
   {
      theyear    = TimeYear(Time[pos]);
      haOpen     = Open[pos];
      haClose    = haOpen;
      haHigh     = haOpen;
      haLow      = haOpen;
      startmonth = Time[pos];
      timewick   = Time[pos] + 7 * 60 * 43200; 

      while (pos >= 0 && theyear == TimeYear(Time[pos]))
      {
         haHigh   = MathMax(haHigh, High[pos]);
         haLow    = MathMin(haLow,  Low[pos]) ;
         haClose  = Close[pos];
         yeartemp = theyear;
         endmonth = Time[pos];
         pos--;
      }        
          
      ObjectSet(IndicatorObjPrefix + "Yearly Body"+IntegerToString(yeartemp), OBJPROP_TIME1,  startmonth);
      ObjectSet(IndicatorObjPrefix + "Yearly Body"+IntegerToString(yeartemp), OBJPROP_PRICE1, haOpen);
      ObjectSet(IndicatorObjPrefix + "Yearly Body"+IntegerToString(yeartemp), OBJPROP_TIME2,  endmonth); 
      ObjectSet(IndicatorObjPrefix + "Yearly Body"+IntegerToString(yeartemp), OBJPROP_PRICE2, haClose);
      ObjectSet(IndicatorObjPrefix + "Yearly Body"+IntegerToString(yeartemp), OBJPROP_STYLE,  STYLE_SOLID);
      ObjectSet(IndicatorObjPrefix + "Yearly Body"+IntegerToString(yeartemp), OBJPROP_WIDTH,  2);
      
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_TIME1,  timewick);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_PRICE1, haHigh);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_TIME2,  timewick);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_PRICE2, MathMax(haOpen,haClose));
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_STYLE,  STYLE_SOLID);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_WIDTH,  4);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_RAY,    False);            
 
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_TIME1,  timewick);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_PRICE1, MathMin(haOpen,haClose));
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_TIME2,  timewick);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_PRICE2, haLow);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_STYLE,  STYLE_SOLID);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_WIDTH,  4);
      ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_RAY,    False);            

      if(haOpen < haClose)
      {
         ObjectSet(IndicatorObjPrefix + "Yearly Body"     +IntegerToString(yeartemp), OBJPROP_COLOR, White);
         ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_COLOR, White);
         ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_COLOR, White);
      }
      else
      {
          ObjectSet(IndicatorObjPrefix + "Yearly Body"     +IntegerToString(yeartemp), OBJPROP_COLOR, Red);
          ObjectSet(IndicatorObjPrefix + "Yearly Shadow Up"+IntegerToString(yeartemp), OBJPROP_COLOR, Red);
          ObjectSet(IndicatorObjPrefix + "Yearly Shadow Dn"+IntegerToString(yeartemp), OBJPROP_COLOR, Red);
      }

      yeardummy--;
   }
//----
   data = 2;
   return(0);
  }
//+------------------------------------------------------------------+