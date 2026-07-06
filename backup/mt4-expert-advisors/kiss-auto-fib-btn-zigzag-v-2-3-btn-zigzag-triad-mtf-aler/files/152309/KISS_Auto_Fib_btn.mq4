//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74097

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#define INDICATOR_NAME "KISS Auto Fib"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string buttonId;
bool recalc = true;
bool show_data = true;
int init()
  {
   IndicatorShortName(INDICATOR_NAME);
   double val;
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = INDICATOR_NAME + UniquebuttonId;
   if(GlobalVariableGet(buttonId + "_visibility", val))
      show_data = val != 0;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(ChartID(), buttonID);
   ObjectCreate(ChartID(), buttonID, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(ChartID(), buttonID, OBJPROP_FONT, font);
   ObjectSetString(ChartID(), buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YDISTANCE, 9999);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleButtonClicks()
  {
   if(ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(buttonId + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
     }
  }
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   handleButtonClicks();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Fibo");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
extern int lookback = 24;
extern int lastbar = 0;
extern color FibColor = Green;
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER;    // btn_corner
extern string             btn_text              = "Show/Hide";
extern string             btn_Font              = "Impact";
extern int                btn_FontSize          = 8;                    //btn_font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrWhite;
extern color              btn_background_color  = C'41,50,56';
extern color              btn_border_color      = C'41,50,56';
extern int                button_x              = 104;                  //btn__x
extern int                button_y              = 20;                   //btn__y
extern int                btn_Width             = 80;                   //btn__width
extern int                btn_Height            = 20;                   //btn__height
extern string             UniquebuttonId        = "KAF";
extern int                btn_Subwindow         = 0;
extern string             button_note2          = "------------------------------";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   handleButtonClicks();
   recalc = false;
   start2();
   if(show_data)
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_ON_color);
     }
   else
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_OFF_color);
      deinit();
     }
   return(0);
  }
  
int start2()
  {
   ObjectDelete("Fibo");
   int    counted_bars = IndicatorCounted();
//----
   double lowest = 1000, highest = 0;
   datetime T1, T2;
   for(int i = lookback + lastbar; i > lastbar + 1; i--)
     {
      double curLow0 = iLow(Symbol(), Period(), i - 2);
      double curLow1 = iLow(Symbol(), Period(), i + 1);
      double curLow2 = iLow(Symbol(), Period(), i);
      double curLow3 = iLow(Symbol(), Period(), i - 1);
      double curLow4 = iLow(Symbol(), Period(), i - 2);
      double curHigh0 = iHigh(Symbol(), Period(), i + 2);
      double curHigh1 = iHigh(Symbol(), Period(), i + 1);
      double curHigh2 = iHigh(Symbol(), Period(), i);
      double curHigh3 = iHigh(Symbol(), Period(), i - 1);
      double curHigh4 = iHigh(Symbol(), Period(), i - 2);
      if(curLow2 <= curLow1 && curLow2 <= curLow1 && curLow2 <= curLow0)
        {
         if(lowest > curLow2)
           {
            lowest = curLow2;
            T2 = iTime(Symbol(), Period(), i);
           }
        }
      if(curHigh2 >= curHigh1 && curHigh2 >= curHigh3 && curHigh2 >= curHigh4)
        {
         if(highest < curHigh2)
           {
            highest = curHigh2;
            T1 = iTime(Symbol(), Period(), i);
           }
        }
     }
   Comment(highest, lowest);
   if(T1 < T2)
     {ObjectCreate("Fibo", OBJ_FIBO, 0, T1, highest, T2, lowest);}
   else
     {
      ObjectCreate("Fibo", OBJ_FIBO, 0, T2, lowest, T1, highest);
     }
//----
   string fiboobjname = "Fibo";
   ObjectSet(fiboobjname, OBJPROP_FIBOLEVELS, 11);
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL, 0.0);
   ObjectSetFiboDescription(fiboobjname, 0, "0.0     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 1, 0.236);
   ObjectSetFiboDescription(fiboobjname, 1, "23.6     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 2, 0.382);
   ObjectSetFiboDescription(fiboobjname, 2, "38.2     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 3, 0.50);
   ObjectSetFiboDescription(fiboobjname, 3, "50.0     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 4, 0.618);
   ObjectSetFiboDescription(fiboobjname, 4, "61.8     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 5, 0.786);
   ObjectSetFiboDescription(fiboobjname, 5, "78.6     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 6, 1.000);
   ObjectSetFiboDescription(fiboobjname, 6, "100.0     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 7, -0.272);
   ObjectSetFiboDescription(fiboobjname, 7, "127.2     %$");
   ObjectSet(fiboobjname, OBJPROP_FIRSTLEVEL + 8, -0.618);
   ObjectSetFiboDescription(fiboobjname, 8, "161.8     %$");
   ObjectSet("Fibo", OBJPROP_LEVELCOLOR, FibColor) ;
   ObjectsRedraw();
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+