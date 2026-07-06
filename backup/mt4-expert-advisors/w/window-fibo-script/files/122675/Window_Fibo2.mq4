// Id: 23272
//+------------------------------------------------------------------+
//|                                                  Window_Fibo.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property show_inputs

extern color Line_Color=Yellow;
extern color Up_Fibo_Color=Green;
extern color Dn_Fibo_Color=Red;
extern int Label_Size=10;

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
   IndicatorName = GenerateIndicatorName("Window_Fibo2");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}


void DrawLevel(int MinB, int MaxB, int LastB, double Level, int LevelNum)
{
 int LeftPos=MathMax(MinB, MaxB);
 double Level0, Level100;
 color LevelColor;
 if (MinB>MaxB)
 {
  Level0=High[MaxB];
  Level100=Low[MinB];
  LevelColor=Up_Fibo_Color;
 }
 else
 {
  Level0=Low[MinB];
  Level100=High[MaxB];
  LevelColor=Dn_Fibo_Color;
 }
 double PriceLevel=Level*(Level100-Level0)/100.+Level0;
 string ObjName=IndicatorObjPrefix + "WF_F"+LevelNum;
 if (ObjectFind(ObjName)==-1)
 {
  ObjectCreate(ObjName, OBJ_TREND, 0, Time[LeftPos], PriceLevel, Time[0], PriceLevel);
  ObjectSet(ObjName, OBJPROP_COLOR, LevelColor);
  ObjectSet(ObjName, OBJPROP_RAY, true);
  ObjectSet(ObjName, OBJPROP_STYLE, STYLE_DASH);
 }
 else
 {
  if (ObjectGet(ObjName, OBJPROP_TIME1)!=Time[LeftPos])
  {
   ObjectSet(ObjName, OBJPROP_TIME1, Time[LeftPos]);
  }
  if (ObjectGet(ObjName, OBJPROP_PRICE1)!=PriceLevel)
  {
   ObjectSet(ObjName, OBJPROP_PRICE1, PriceLevel);
  }
  if (ObjectGet(ObjName, OBJPROP_PRICE2)!=PriceLevel)
  {
   ObjectSet(ObjName, OBJPROP_PRICE2, PriceLevel);
  }
  if (ObjectGet(ObjName, OBJPROP_COLOR)!=LevelColor)
  {
   ObjectSet(ObjName, OBJPROP_COLOR, LevelColor);
  }
 }
 
 ObjName=IndicatorObjPrefix + "WF_T"+LevelNum;
 string StrLevel=DoubleToStr(PriceLevel, Digits)+" ("+DoubleToStr(Level, 1)+"%)                   ";
 if (ObjectFind(ObjName)==-1)
 {
  ObjectCreate(ObjName, OBJ_TEXT, 0, Time[LastB], PriceLevel);
  ObjectSetText(ObjName, StrLevel, Label_Size, "Times New Roman", LevelColor);
 }
 else
 {
  if (ObjectGet(ObjName, OBJPROP_COLOR)!=LevelColor)
  {
   ObjectSet(ObjName, OBJPROP_COLOR, LevelColor);
  }
  if (ObjectGet(ObjName, OBJPROP_TIME1)!=Time[LastB])
  {
   ObjectSet(ObjName, OBJPROP_TIME1, Time[LastB]);
  }
  if (ObjectGet(ObjName, OBJPROP_PRICE1)!=PriceLevel)
  {
   ObjectSet(ObjName, OBJPROP_PRICE1, PriceLevel);
  }
  if (ObjectDescription(ObjName)!=StrLevel)
  {
   ObjectSetText(ObjName, StrLevel, Label_Size, "Times New Roman", LevelColor);
  }
 }
 
 return;
}

int start()
{
 int MinBar, MaxBar;
 double Min, Max;
 int FirstBar, CountBars, LastBar;
 bool FirstStart=true;
 while (true)
 {
  if (FirstStart)
  {
   FirstStart=false;
   FirstBar=WindowFirstVisibleBar();
   CountBars=WindowBarsPerChart();
   LastBar=FirstBar-CountBars+1;
   LastBar=MathMax(LastBar, 0);
   CountBars=MathMin(CountBars, FirstBar);
   MinBar=iLowest(NULL, 0, MODE_LOW, CountBars, LastBar);
   MaxBar=iHighest(NULL, 0, MODE_HIGH, CountBars, LastBar);
   Min=Low[MinBar];
   Max=High[MaxBar];
  } 
  if (ObjectFind(IndicatorObjPrefix + "WF_HL_Line")==-1)
  {
   ObjectCreate(IndicatorObjPrefix + "WF_HL_Line", OBJ_TREND, 0, Time[MinBar], Min, Time[MaxBar], Max);
   ObjectSet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_COLOR, Line_Color);
   ObjectSet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_RAY, false);
  }
  else
  {
   if (ObjectGet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_TIME1)!=Time[MinBar])
   {
    ObjectSet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_TIME1, Time[MinBar]);
   }
   if (ObjectGet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_TIME2)!=Time[MaxBar])
   {
    ObjectSet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_TIME2, Time[MaxBar]);
   }
   if (ObjectGet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_PRICE1)!=Min)
   {
    ObjectSet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_PRICE1, Min);
   }
   if (ObjectGet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_PRICE2)!=Max)
   {
    ObjectSet(IndicatorObjPrefix + "WF_HL_Line", OBJPROP_PRICE2, Max);
   }
  }
  
  DrawLevel(MinBar, MaxBar, LastBar, 0, 1);
  DrawLevel(MinBar, MaxBar, LastBar, 23.6, 2);
  DrawLevel(MinBar, MaxBar, LastBar, 38.2, 3);
  DrawLevel(MinBar, MaxBar, LastBar, 50, 4);
  DrawLevel(MinBar, MaxBar, LastBar, 61.8, 5);
  DrawLevel(MinBar, MaxBar, LastBar, 76.4, 6);
  DrawLevel(MinBar, MaxBar, LastBar, 100, 7);
  
  WindowRedraw();
  if (IsStopped())
  {
   break;
  }
  else
  {
   Sleep(100);
  } 
 } 
 
 return(0);
}

