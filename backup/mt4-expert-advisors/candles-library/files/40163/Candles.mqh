//+------------------------------------------------------------------+
//|                                                      Candles.mqh |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define CANDLEPROP_CLOSE 0
#define CANDLEPROP_OPEN  1
#define CANDLEPROP_HIGH  2
#define CANDLEPROP_LOW   3
#define CANDLEPROP_COLOR 4
#define CANDLEPROP_WIDTH 5

int CandleDraw(int _Window, datetime _Time, double _Open, double _High, double _Low, double _Close, color _Color, int _Width=3)
{
 if (_Window==-1) return (-1);
 string ObjName="_C"+_Window+_Time;
 if (ObjectFind(ObjName+"B")!=-1)
 {
  ObjectSet(ObjName+"B", OBJPROP_TIME1, _Time);
  ObjectSet(ObjName+"B", OBJPROP_TIME2, _Time);
  ObjectSet(ObjName+"B", OBJPROP_PRICE1, _Open);
  ObjectSet(ObjName+"B", OBJPROP_PRICE2, _Close);
 }
 else
 {
  if (!ObjectCreate(ObjName+"B", OBJ_TREND, _Window, _Time, _Open, _Time, _Close)) return (-1);
 } 
 ObjectSet(ObjName+"B", OBJPROP_COLOR, _Color);
 ObjectSet(ObjName+"B", OBJPROP_RAY, false);
 ObjectSet(ObjName+"B", OBJPROP_WIDTH, _Width);
 
 if (ObjectFind(ObjName+"S")!=-1)
 {
  ObjectSet(ObjName+"S", OBJPROP_TIME1, _Time);
  ObjectSet(ObjName+"S", OBJPROP_TIME2, _Time);
  ObjectSet(ObjName+"S", OBJPROP_PRICE1, _Low);
  ObjectSet(ObjName+"S", OBJPROP_PRICE2, _High);
 }
 else
 {
  if (!ObjectCreate(ObjName+"S", OBJ_TREND, _Window, _Time, _Low, _Time, _High)) return (-1);
 } 
 ObjectSet(ObjName+"S", OBJPROP_COLOR, _Color);
 ObjectSet(ObjName+"S", OBJPROP_RAY, false);
 ObjectSet(ObjName+"S", OBJPROP_WIDTH, 1);

 return (0);
}

int CandleDelete(int _Window, datetime _Time)
{
 if (_Window==-1) return (-1);
 string ObjName="_C"+_Window+_Time;
 if (ObjectFind(ObjName+"B")!=-1)
 {
  ObjectDelete(ObjName+"B");
 }
 
 if (ObjectFind(ObjName+"S")!=-1)
 {
  ObjectDelete(ObjName+"S");
 }

 return (0);

}

void CandlesDeleteAll(int _Window)
{
 int ObjectsCount=ObjectsTotal(OBJ_TREND);
 int i;
 string ObjectTemplate="_C"+_Window;
 string ObjName;
 for (i=ObjectsCount-1;i>=0;i--)
 {
  ObjName=ObjectName(i);
  if (StringFind(ObjName,ObjectTemplate)==0) ObjectDelete(ObjName);
 }
 return;
}

bool IsCandle(int _Window, datetime _Time)
{
 if (_Window==-1) return (false);
 string ObjName="_C"+_Window+_Time;
 if (ObjectFind(ObjName+"B")!=-1)
 {
  return (true);
 }
 else
 {
  return (false);
 }
}

int CandleGet(int _Window, datetime _Time, double& _Open, double& _High, double& _Low, double& _Close, color& _Color, int& _Width)
{
 if (_Window==-1) return (-1);
 string ObjName="_C"+_Window+_Time;
 if (ObjectFind(ObjName+"B")!=-1)
 {
  _Open=ObjectGet(ObjName+"B", OBJPROP_PRICE1);
  _Close=ObjectGet(ObjName+"B", OBJPROP_PRICE2);
  _Color=ObjectGet(ObjName+"B", OBJPROP_COLOR);
  _Width=ObjectGet(ObjName+"B", OBJPROP_WIDTH);
 }
 
 if (ObjectFind(ObjName+"S")!=-1)
 {
  _Low=ObjectGet(ObjName+"S", OBJPROP_PRICE1);
  _High=ObjectGet(ObjName+"S", OBJPROP_PRICE2);
  _Color=ObjectGet(ObjName+"S", OBJPROP_COLOR);
 }
 return (0);
}

int CandleSet(int _Window, datetime _Time, int _index, double _value)
{
 if (_Window==-1) return (-1);
 string ObjName="_C"+_Window+_Time;
 if (_index==CANDLEPROP_CLOSE)
 {
  if (ObjectFind(ObjName+"B")!=-1)
  {
   ObjectSet(ObjName+"B", OBJPROP_PRICE2, _value);
   return (0);
  }
 }
 if (_index==CANDLEPROP_OPEN)
 {
  if (ObjectFind(ObjName+"B")!=-1)
  {
   ObjectSet(ObjName+"B", OBJPROP_PRICE1, _value);
   return (0);
  }
 }
 if (_index==CANDLEPROP_HIGH)
 {
  if (ObjectFind(ObjName+"S")!=-1)
  {
   ObjectSet(ObjName+"S", OBJPROP_PRICE2, _value);
   return (0);
  }
 }
 if (_index==CANDLEPROP_LOW)
 {
  if (ObjectFind(ObjName+"S")!=-1)
  {
   ObjectSet(ObjName+"S", OBJPROP_PRICE1, _value);
   return (0);
  }
 }
 if (_index==CANDLEPROP_COLOR)
 {
  if (ObjectFind(ObjName+"B")!=-1)
  {
   ObjectSet(ObjName+"B", OBJPROP_COLOR, _value);
   if (ObjectFind(ObjName+"S")!=-1)
   {
    ObjectSet(ObjName+"S", OBJPROP_COLOR, _value);
    return (0);
   } 
  }
 }
 if (_index==CANDLEPROP_WIDTH)
 {
  if (ObjectFind(ObjName+"B")!=-1)
  {
   ObjectSet(ObjName+"B", OBJPROP_WIDTH, _value);
   return (0);
  }
 }
 return (-1);
}


