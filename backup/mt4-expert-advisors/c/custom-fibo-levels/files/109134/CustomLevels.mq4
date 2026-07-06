//+------------------------------------------------------------------+
//|                                                     QuickFib.mq4 |
//|                                                                  |
//| Draw the fib from the highest high in the currently visibly bars |
//| to the lowest low, and a couple "contour lines" to show the      |
//| basic range that the pair is trading in.                         |
//|                                                                  |
//|                                   Copyright © 2010, Jason Hooper |
//|                                         http://www.chartbin.net/ |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers         0

extern color ColorUptrend = clrDarkSlateGray;
extern color ColorDowntrend = clrMaroon;
extern color ColorRetracementRemaining = clrBisque;
extern color ColorHighPrice = clrCrimson;
extern color ColorLowPrice = clrGreen;
extern bool DrawRetracementBlocks = true;

string indId = "QuickFib_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(0);
   
   return(0);
}

int deinit()
{
   DeleteAllObjects();
   
   return(0);
}

int start()
{
   // Lazy, could be improved to redraw only what needs to be redrawn
   DeleteAllObjects();
   PlotObjects();
   
   return(0);
}


void DeleteAllObjects()
{
   // Delete all objects created by the indicator
   for (int i = ObjectsTotal() - 1;  i >= 0;  i--)
   {
      string name = ObjectName(i);
      
      if (StringSubstr(name, 0, StringLen(indId)) == indId)
         ObjectDelete(name);
   }
}

void PlotObjects()
{
   int bar = WindowFirstVisibleBar();
   
   // If price breaking out to new highs or lows, don't redraw the fib until the next bar
   // That's what the -1 and 1 are for.
   int shiftLowest = iLowest(NULL, 0, MODE_LOW, bar - 1, 1);
   int shiftHighest = iHighest(NULL, 0, MODE_HIGH, bar - 1, 1);
   
   bool isSwingDown = shiftHighest > shiftLowest;
   string objOuterId = indId + "outer";
   string objInnerId = indId + "inner";
   string objTopPrice = indId + "topPrice";
   string objBottomPrice = indId + "bottomPrice";
   string objRetRect = indId + "retracementRectangle";
   //double retracementExtent;
   int shiftMostRetraced;
    
   if (isSwingDown == true)
   {     
      ObjectCreate(objOuterId, OBJ_FIBO, 0, Time[shiftHighest], High[shiftHighest], Time[shiftLowest], Low[shiftLowest]);   
      ObjectSet(objOuterId, OBJPROP_COLOR, ColorDowntrend);
      ObjectSet(objOuterId, OBJPROP_LEVELCOLOR, ColorDowntrend);
      ObjectSet(objOuterId, OBJPROP_LEVELSTYLE, STYLE_DOT);      
      
      if (DrawRetracementBlocks)
      {
         if (shiftLowest > 0)
         {
            // Draw a rectangle showing the part of the fib retracement that has not occurred
            shiftMostRetraced = iHighest(NULL, 0, MODE_HIGH, shiftLowest - 1, 0);
      
            ObjectCreate(objRetRect, OBJ_RECTANGLE, 0, Time[shiftMostRetraced], High[shiftHighest], Time[0], High[shiftMostRetraced]);      
            ObjectSet(objRetRect, OBJPROP_COLOR, ColorRetracementRemaining);
         }
      }
   
      DrawContourLines(shiftHighest, shiftLowest, ColorDowntrend);
   }
   else
   {
      ObjectCreate(objOuterId, OBJ_FIBO, 0, Time[shiftLowest], Low[shiftLowest], Time[shiftHighest], High[shiftHighest]);
    
      ObjectSet(objOuterId, OBJPROP_COLOR, ColorUptrend);
      ObjectSet(objOuterId, OBJPROP_LEVELCOLOR, ColorUptrend);
      ObjectSet(objOuterId, OBJPROP_LEVELSTYLE, STYLE_DOT);

      if (DrawRetracementBlocks)
      {
         if (shiftHighest > 0)
         {
            // Draw a rectangle showing the part of the fib retracement that has not occurred
            shiftMostRetraced = iLowest(NULL, 0, MODE_LOW, shiftHighest - 1, 0);
         
            ObjectCreate(objRetRect, OBJ_RECTANGLE, 0, Time[shiftMostRetraced], Low[shiftLowest], Time[0], Low[shiftMostRetraced]);      
            ObjectSet(objRetRect, OBJPROP_COLOR, ColorRetracementRemaining);
         }
      }

      DrawContourLines(shiftHighest, shiftLowest, ColorUptrend);
   }
   
   double Fib_Values[5] = {0,0.0141,0.414,0.642,1};
   FiboLevelsSet(5,Fib_Values, 0, objOuterId);

   // Draw price flags
   ObjectCreate(objTopPrice, OBJ_ARROW, 0, Time[shiftHighest], High[shiftHighest]);
   ObjectCreate(objBottomPrice, OBJ_ARROW, 0, Time[shiftLowest], Low[shiftLowest]);
   
   ObjectSet(objTopPrice, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);      
   ObjectSet(objBottomPrice, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
   ObjectSet(objTopPrice, OBJPROP_COLOR, ColorHighPrice);
   ObjectSet(objBottomPrice, OBJPROP_COLOR, ColorLowPrice);
  
}

void DrawContourLines(int shiftHighest, int shiftLowest, color clr)
{   
   int shiftContourDown = shiftHighest;
   double highestSlope = 0;
   string objId_ContourDown = indId + "ContourDown";
   string objId_ContourUp = indId + "ContourUp";
   
   for (int i = shiftHighest - 10;  i > 1;  i--)      
   {
      double thisSlope = (High[i] - High[shiftHighest]) / (shiftHighest - i);
      
      if (thisSlope >= highestSlope || highestSlope == 0)
      {
         shiftContourDown = i;      
         highestSlope = thisSlope;
      }
   }
   
   ObjectCreate(objId_ContourDown, OBJ_TREND, 0, Time[shiftHighest], High[shiftHighest], Time[shiftContourDown], High[shiftContourDown]);
   ObjectSet(objId_ContourDown, OBJPROP_RAY, true);
   ObjectSet(objId_ContourDown, OBJPROP_WIDTH, 1);
   ObjectSet(objId_ContourDown, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(objId_ContourDown, OBJPROP_COLOR, clr);
   
   double lowestSlope = 0;
   int shiftContourUp = 0;
   
   for (i = shiftLowest - 10;  i > 1;  i--)      
   {
      thisSlope = (Low[i] - Low[shiftLowest]) / (shiftLowest - i);
      
      if (thisSlope <= lowestSlope || lowestSlope == 0)
      {
         shiftContourUp = i;
         lowestSlope = thisSlope;
      }
   }
   
   ObjectCreate(objId_ContourUp, OBJ_TREND, 0, Time[shiftLowest], Low[shiftLowest], Time[shiftContourUp], Low[shiftContourUp]);
   ObjectSet(objId_ContourUp, OBJPROP_RAY, true);
   ObjectSet(objId_ContourUp, OBJPROP_WIDTH, 1);
   ObjectSet(objId_ContourUp, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(objId_ContourUp, OBJPROP_COLOR, clr);      
}

//+------------------------------------------------------------------+
//| Set number of levels and their parameters                        |
//+------------------------------------------------------------------+
bool FiboLevelsSet(int levels, double &values[], const long chart_ID, const string    name){
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels);
   for(int i=0;i<levels;i++){
      //--- level value
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,values[i]);      
      //--- level description
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,"%$ ("+DoubleToString(100*values[i],1)+"%%)");
     }
//--- successful execution
   return(true);
  }