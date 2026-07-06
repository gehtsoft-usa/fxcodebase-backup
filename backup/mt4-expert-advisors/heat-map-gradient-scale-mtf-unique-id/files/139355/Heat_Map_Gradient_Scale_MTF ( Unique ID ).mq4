// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70692

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.2"

#property strict    //--- For compatibility with MT4
#property indicator_chart_window
//---
#property indicator_plots   0

//--- ENUMS
enum ENUM_SCALE_TYPE       {DYNAMIC,FIXED};
enum ENUM_INDICATOR_TYPE   {SCALE,GRADIENT,HEATMAP};

//--- INPUTS
input string               indicatorSettings    =  "----- Indicator Settings";      // ■ Indicator Management
input string            UniqueID               = ".";
input ENUM_TIMEFRAMES   periodsel               = 1440; // Selected timeframe
input ENUM_INDICATOR_TYPE  indicatorType        =  HEATMAP;                         // Indicator Type
input bool sort                                 = true; // Sort on value
input int sortmode                              = 1; // 0 = ASCEND 1 - DESCEND
input int Xoffset = 0;  //X Offset Value
input int Yoffset = 0;  //Y Offset Value
input int button_x = 20;
input int button_y = 30;
input string button_uid = "1"; // Button identifier
//--- GLOBALS
string         marketWatchSymbolsList[];
double         percentChange[];
color          colorArray[];
//---
int            symbolsTotal=0;
//---
MqlRates       DailyBar[];
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
double displaylist[28][3];
string rand_value = "";


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
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
{
   MathSrand(GetTickCount());
   rand_value = "_"+ IntegerToString(MathRand());
   EventSetTimer(1);
   ArraySetAsSeries(DailyBar,true);
   visibility.Init("show_hide_gs" + button_uid, "GS" + button_uid, "V", button_x, button_y);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete only what is drawn by your code
   deleteScale(symbolsTotal);
   ChartRedraw();
   visibility.DeInit();
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
  {

//---
   return(rates_total);
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   visibility.HandleButtonClicks();
   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         
      }
      else
      {
         deleteScale(symbolsTotal);
         visibility.ResetRecalc();
         return;
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
     return;
   }
//   int currentSymbolsTotal=SymbolsTotal(true);
     int currentSymbolsTotal = 28;
//--- If we add or remove a symbol to the market watch
   if(symbolsTotal!=currentSymbolsTotal)
     {
      //--- resize arrays 
      ArrayResize(marketWatchSymbolsList,currentSymbolsTotal);
      ArrayResize(percentChange,currentSymbolsTotal);
      ArrayResize(colorArray,currentSymbolsTotal);
      //--- update arrays of symbol's name
      for(int i=0;i<currentSymbolsTotal;i++)
         marketWatchSymbolsList[i]=DefaultPairs[i];         
//         marketWatchSymbolsList[i]=SymbolName(i,true);
      //--- remove panel in excess
      deleteScale(symbolsTotal,currentSymbolsTotal);
      //---
      symbolsTotal=currentSymbolsTotal;
     }

//--- call right drawing function
   switch(indicatorType)
     {
      case SCALE     : Scale(); break;
      case GRADIENT  : Gradient(); break;
      case HEATMAP   : Heatmap(); break;
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| SCALE                                                            |
//+------------------------------------------------------------------+
void Scale()
  {
//--- Variables for the color gradient
//   int length=SymbolsTotal(true); // Number os symbols on market watch
int length = 28;
int j,xoffset;
//--- Set values through for-loop
   for(int i=0;i<length;i++)
     {
      //---
      if(CopyRates(marketWatchSymbolsList[i],periodsel,0,2,DailyBar)!=2)
        {
         printf("Not all data available yet (%s) !",marketWatchSymbolsList[i]);
         return;
        }

      //--- Color 1 parameters
      int r_1 = 0;
      int g_1 = 64;
      int b_1 = 255;

      //--- Color 2 parameters
      int r_2 = 255;
      int g_2 = 255;
      int b_2 = 255;

      //--- Interpolation functions
      int r_value = r_1-i*((r_1-r_2)/(length-1));
      int g_value = g_1-i*((g_1-g_2)/(length-1));
      int b_value = b_1-i*((b_1-b_2)/(length-1));

      //---
      string rgbColor=IntegerToString(r_value)+","+IntegerToString(g_value)+","+IntegerToString(b_value);

      //---
      colorArray[i]=StringToColor(rgbColor);
//      marketWatchSymbolsList[i]=SymbolName(i,true);
      percentChange[i]=((DailyBar[0].close/DailyBar[1].close)-1)*100;
/*
      if (i>13) {
         xoffset = 60;
         j = i-14; 
      } else {
         xoffset = 0;
         j = i;;
      }
      //--- Texts and boxes
      SetPanel("Panel "+IntegerToString(i),0,10+xoffset,32+j*32,50,30,StringToColor(rgbColor),clrWhite,1);
      SetText("Text "+IntegerToString(i),marketWatchSymbolsList[i],13+xoffset,33+j*32,clrBlack,8);
      //---
      if(percentChange[i]>=0)
        {
         SetText("Variation "+IntegerToString(i),"+"+DoubleToString(percentChange[i],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
      else
        {
         SetText("Variation "+IntegerToString(i),DoubleToString(percentChange[i],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
*/
      displaylist[i][0] = percentChange[i];
      displaylist[i][1] = StringToColor(rgbColor);
      displaylist[i][2] = i;
     }

   for(int i=0;i<length;i++)
     {

   if (sort == true) {
      if (sortmode == 0)
      ArraySort(displaylist,WHOLE_ARRAY,0,MODE_ASCEND);
      else
      ArraySort(displaylist,WHOLE_ARRAY,0,MODE_DESCEND);
   }      
      if (i>13) {
         xoffset = 60;
         j = i-14; 
      } else {
         xoffset = 0;
         j = i;;
      }
      //--- Texts and boxes
      SetPanel("Panel " + UniqueID +IntegerToString(i),0,10+xoffset,32+j*32,50,30,displaylist[i][1],clrWhite,1);
      SetText("Text "+UniqueID+ IntegerToString(i),marketWatchSymbolsList[(int)displaylist[i][2]],13+xoffset,33+j*32,clrBlack,8);
      //---
      if(displaylist[i][0]>=0)
        {
         SetText("Variation "+ UniqueID+IntegerToString(i),"+"+DoubleToString(displaylist[i][0],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
      else
        {
         SetText("Variation "+UniqueID+IntegerToString(i),DoubleToString(displaylist[i][0],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
   
   }
  }
//+------------------------------------------------------------------+
//| GRADIENT                                                         |
//+------------------------------------------------------------------+
void Gradient()
  {
   int arrayMax, arrayMin;
   double scaleEdge, scaleMax, scaleMin;

//--- Color 1 parameters
   int r_1 = 255;
   int g_1 = 0;
   int b_1 = 0;
   
//--- Color 2 parameters
   int r_2 = 0;
   int g_2 = 255;
   int b_2 = 0;

//--- Sets values for variables
   for(int i=0;i<symbolsTotal;i++)
     {
      //--- Calculates the daily percent change
//      marketWatchSymbolsList[i]=SymbolName(i,true);
      
      if(CopyRates(marketWatchSymbolsList[i],periodsel,0,2,DailyBar)!=2)
        {
         printf("Not all data available yet (%s) !",marketWatchSymbolsList[i]);
         return;
        }

      //--- Calculates daily percent change
      percentChange[i]=((DailyBar[0].close/DailyBar[1].close)-1)*100;

      //--- Interpolation functions
      int r_value = r_1-i*((r_1-r_2)/(symbolsTotal-1));
      int g_value = g_1-i*((g_1-g_2)/(symbolsTotal-1));
      int b_value = b_1-i*((b_1-b_2)/(symbolsTotal-1));
            
      //--- Sets colors to colorArray[]
      string rgbColor = IntegerToString(r_value)+","+IntegerToString(g_value)+","+IntegerToString(b_value);
      colorArray[i] = StringToColor(rgbColor);
     }

//--- Define gradient colors

int j,xoffset;

   for(int i=0;i<symbolsTotal;i++)
     {
      //---
      arrayMax=ArrayMaximum(percentChange);
      arrayMin=ArrayMinimum(percentChange);
      
      //---
      if(MathAbs(percentChange[arrayMax])>MathAbs(percentChange[arrayMin]))
        {
         scaleEdge=percentChange[arrayMax];
        }
      else
        {
         scaleEdge=percentChange[arrayMin];
        }
      //---
      scaleMax = scaleEdge;
      scaleMin = -scaleEdge;

      //--- Local variable gradientColor
      int gradientColor;
      gradientColor = (int)MathFloor(((scaleMax-percentChange[i])/(scaleMax-scaleMin))*(symbolsTotal-1));

      displaylist[i][0] = percentChange[i];
      displaylist[i][1] = gradientColor;
      displaylist[i][2] = i;
   }

   for(int i=0;i<symbolsTotal;i++)
     {

   if (sort == true) {
      if (sortmode == 0)
      ArraySort(displaylist,WHOLE_ARRAY,0,MODE_ASCEND);
      else
      ArraySort(displaylist,WHOLE_ARRAY,0,MODE_DESCEND);
   }      

      if (i>13) {
         xoffset = 60;
         j = i-14; 
      } else {
         xoffset = 0;
         j = i;;
      }
      //--- Texts and boxes
      SetPanel("Panel "+UniqueID+IntegerToString(i), 0, 10+xoffset, 32+j*32, 80, 30, colorArray[(int)displaylist[i][1]], clrWhite, 1);
      SetText("Text "+UniqueID+IntegerToString(i),marketWatchSymbolsList[(int)displaylist[i][2]],13+xoffset,33+j*32,clrBlack,8);
      if(displaylist[i][0]>=0)
        {
         SetText("Variation "+UniqueID+IntegerToString(i),"+"+DoubleToString(displaylist[i][0],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
      else
        {
         SetText("Variation "+UniqueID+IntegerToString(i),DoubleToString(displaylist[i][0],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
     }
  }
//+------------------------------------------------------------------+
//| HEATMAP                                                          |
//+------------------------------------------------------------------+
void Heatmap()
  {
//--- locals
   double scaleMax,scaleMin,scaleEdge;
//---
   int    arrayMax,arrayMin;
int j,xoffset;

//--- Color 1 parameters
   int r_1 = 0;
   int g_1 = 255;
   int b_1 = 0;

//--- Color 2 parameters
   int r_2 = 255;
   int g_2 = 255;
   int b_2 = 255;

//--- Color 3 parameters
   int r_3 = 255;
   int g_3 = 0;
   int b_3 = 0;

   int midValue=(symbolsTotal%2==0 ? symbolsTotal/2 :(symbolsTotal-1)/2)-1;
//--- Build an array of colors and calculate percentage price's change
   for(int i=0;i<symbolsTotal;i++)
     {
      //--- Local variables
      int r_value = r_2;
      int g_value = g_2;
      int b_value = b_2;

      //--- Calculates the percent change of each symbol
      if(CopyRates(marketWatchSymbolsList[i],periodsel,0,2,DailyBar)==2)
        {
         percentChange[i]=((DailyBar[0].close/DailyBar[1].close)-1)*100;

         if(i<=midValue) // Positive values
           {
            //--- Positive interpolation function
            r_value = r_1-i*(r_1-r_2)/midValue;
            g_value = g_1-i*(g_1-g_2)/midValue;
            b_value = b_1-i*(b_1-b_2)/midValue;
           }
         else
           {
            //--- Negative interpolation function
            r_value = r_2-(i-midValue-1)*(r_2-r_3)/midValue;
            g_value = g_2-(i-midValue-1)*(g_2-g_3)/midValue;
            b_value = b_2-(i-midValue-1)*(b_2-b_3)/midValue;
           }
        }
      //--- Sets all possible colors to the array colorArray[]
      string rgbColor=IntegerToString(r_value)+","+IntegerToString(g_value)+","+IntegerToString(b_value);
      colorArray[i]=StringToColor(rgbColor);
     }

//--- Determine maximum/minimum and the scale value
   arrayMax=ArrayMaximum(percentChange); arrayMin=ArrayMinimum(percentChange);
   if(arrayMax==-1 || arrayMin==-1) return;

//--- Determine the scale
   scaleEdge=MathMax(MathAbs(percentChange[arrayMax]),MathAbs(percentChange[arrayMin]));
//---
   scaleMax=scaleEdge; scaleMin=-scaleEdge;
   
   midValue=(symbolsTotal%2==0 ? symbolsTotal/2 :(symbolsTotal-1)/2);
//--- Sets colors to the heatmap
   for(int i=0;i<symbolsTotal;i++)
     {
      //--- Local variable
      int heatmapColor=0;

      //--- Sets the color position (gradientColor) inside the colorArray
      if(percentChange[i]>0)
        {
         //--- color index between 0 and (symbolsTotal/2)-1
         heatmapColor=(int)MathFloor((1-percentChange[i]/scaleMax)*midValue);
        }
      else if(percentChange[i]<0)
        {
         //--- color index between symbolsTotal/2 and symbolsTotal-1
         heatmapColor=(int)MathCeil((percentChange[i]/scaleMin)*midValue)+midValue-1;
        }
      else
        {
         heatmapColor=midValue; // Mid position
        }

      if(heatmapColor<0) Print("Array out of range, heatmapcolor=",heatmapColor);
      if(heatmapColor>=ArraySize(colorArray)) Print("Array out of range, heatmapcolor=",heatmapColor," colorArray size=",ArraySize(colorArray));

      displaylist[i][0] = percentChange[i];
      displaylist[i][1] = heatmapColor;
      displaylist[i][2] = i;

   }

   if (sort == true) {
      if (sortmode == 0)
      ArraySort(displaylist,WHOLE_ARRAY,0,MODE_ASCEND);
      else
      ArraySort(displaylist,WHOLE_ARRAY,0,MODE_DESCEND);
   }      

   for(int i=0;i<symbolsTotal;i++)
     {
      if (i>13) {
         xoffset = 60;
         j = i-14; 
      } else {
         xoffset = 0;
         j = i;;
      }
      //--- Texts and boxes
      SetPanel("Panel "+UniqueID+IntegerToString(i), 0, 10+xoffset, 32+j*32, 50, 30, colorArray[(int)displaylist[i][1]], clrWhite, 1);
      SetText("Text "+UniqueID+IntegerToString(i),marketWatchSymbolsList[(int)displaylist[i][2]],13+xoffset,33+j*32,clrBlack,8);
      if(displaylist[i][0]>=0)
        {
         SetText("Variation "+UniqueID+IntegerToString(i),"+"+DoubleToString(displaylist[i][0],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
      else
        {
         SetText("Variation "+UniqueID+IntegerToString(i),DoubleToString(displaylist[i][0],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
     }
/*
      //--- Texts and boxes
      if (i>13) {
         xoffset = 60;
         j = i-14; 
      } else {
         xoffset = 0;
         j = i;;
      }
      SetPanel("Panel "+IntegerToString(i),0,10+xoffset,32+j*32,50,30,colorArray[heatmapColor],clrWhite,1);
      SetText("Text "+IntegerToString(i),marketWatchSymbolsList[i],13+xoffset,33+j*32,clrBlack,8);
      if(percentChange[i]>=0)
        {
         SetText("Variation "+IntegerToString(i),"+"+DoubleToString(percentChange[i],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
      else
        {
         SetText("Variation "+IntegerToString(i),DoubleToString(percentChange[i],2)+"%",17+xoffset,46+j*32,clrBlack,8);
        }
     }
*/
//---
  }
//+------------------------------------------------------------------+
//| Remove unneeded objects from main chart                          |
//+------------------------------------------------------------------+
void deleteScale(int from,int to=1)
  {
//---   
   from--;to--;
   for(int i=from;i>=to;i--)
     {
      ObjectDelete(0,"Panel "+UniqueID+IntegerToString(i) + rand_value);
      ObjectDelete(0,"Text "+UniqueID+IntegerToString(i) + rand_value);
      ObjectDelete(0,"Variation "+UniqueID+IntegerToString(i) + rand_value);
     }
  }
//+------------------------------------------------------------------+
//| Draw data about a symbol in a panel                              |
//+------------------------------------------------------------------+
void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   name = name + rand_value;
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x+Xoffset);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y+Yoffset);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+------------------------------------------------------------------+
//| Draw a panel with given color for a symbol                       |
//+------------------------------------------------------------------+
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   name = name + rand_value;
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x+Xoffset);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y+Yoffset);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
//+------------------------------------------------------------------+
