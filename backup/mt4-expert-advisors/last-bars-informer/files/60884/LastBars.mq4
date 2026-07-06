// Id: 9084
//+------------------------------------------------------------------+
//|                                                     LastBars.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property show_inputs

extern int RowNumber=5;
extern color DateTimeColor=PaleGreen;
extern color DataColor=Yellow;
extern int VOffset=15;
extern int HOffset=15;
extern int VStep=20;
extern int HStep=150;
extern int TextSize=12;

string Data[][6];

string ObjName="LastBars";


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


void DrawRow(int Num)
{
 string _DT, _V_1, _V_2, _V_3, _V_4, _V_5;
 if (Num==-1)
 {
  _DT="Date/Time";
  _V_1="Open";
  _V_2="High";
  _V_3="Low";
  _V_4="Close";
  _V_5="Volume";
 }
 else
 {
  _DT=Data[Num][0];
  _V_1=Data[Num][1];
  _V_2=Data[Num][2];
  _V_3=Data[Num][3];
  _V_4=Data[Num][4];
  _V_5=Data[Num][5];
 }
 
 string ON=IndicatorObjPrefix + ObjName+DoubleToStr(Num, 0);
 if (ObjectFind(ON+"DT")==-1) ObjectCreate(ON+"DT", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"O")==-1) ObjectCreate(ON+"O", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"H")==-1) ObjectCreate(ON+"H", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"L")==-1) ObjectCreate(ON+"L", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"C")==-1) ObjectCreate(ON+"C", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"V")==-1) ObjectCreate(ON+"V", OBJ_LABEL, 0, 0, 0);

 ObjectSetText(ON+"DT", _DT, TextSize);
 ObjectSet(ON+"DT", OBJPROP_COLOR, DateTimeColor);
 ObjectSet(ON+"DT", OBJPROP_XDISTANCE, HOffset);
 ObjectSet(ON+"DT", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"DT", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"O", _V_1, TextSize);
 ObjectSet(ON+"O", OBJPROP_COLOR, DataColor);
 ObjectSet(ON+"O", OBJPROP_XDISTANCE, HOffset+HStep);
 ObjectSet(ON+"O", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"O", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"H", _V_2, TextSize);
 ObjectSet(ON+"H", OBJPROP_COLOR, DataColor);
 ObjectSet(ON+"H", OBJPROP_XDISTANCE, HOffset+2*HStep);
 ObjectSet(ON+"H", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"H", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"L", _V_3, TextSize);
 ObjectSet(ON+"L", OBJPROP_COLOR, DataColor);
 ObjectSet(ON+"L", OBJPROP_XDISTANCE, HOffset+3*HStep);
 ObjectSet(ON+"L", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"L", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"C", _V_4, TextSize);
 ObjectSet(ON+"C", OBJPROP_COLOR, DataColor);
 ObjectSet(ON+"C", OBJPROP_XDISTANCE, HOffset+4*HStep);
 ObjectSet(ON+"C", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"C", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"V", _V_5, TextSize);
 ObjectSet(ON+"V", OBJPROP_COLOR, DataColor);
 ObjectSet(ON+"V", OBJPROP_XDISTANCE, HOffset+5*HStep);
 ObjectSet(ON+"V", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"V", OBJPROP_CORNER, 4);
 
 
 
 return;
}

void ShowData()
{
 int i;
 for (i=-1;i<RowNumber;i++)
 {
  DrawRow(i);
 }
 return;
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 return;
}

void GetData()
{
 int i;
 for (i=0;i<RowNumber;i++)
 {
  Data[i][0]=TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
  Data[i][1]=DoubleToStr(Open[i], Digits);
  Data[i][2]=DoubleToStr(High[i], Digits);
  Data[i][3]=DoubleToStr(Low[i], Digits);
  Data[i][4]=DoubleToStr(Close[i], Digits);
  Data[i][5]=DoubleToStr(Volume[i], 0);
 }
 return ;
}

int init()
{
   IndicatorName = GenerateIndicatorName(LastBars);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return 0;
}


int start()
  {
   ArrayResize(Data, RowNumber);
   while (true)
   {
    RefreshRates();
    GetData();
    ShowData();
    if (IsStopped())
    {
     break;
    }
    else
    {
     Sleep(1000);
    }
   } 
   return(0);
  }

