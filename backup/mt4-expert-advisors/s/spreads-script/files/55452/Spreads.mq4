// Id: 8641
//+------------------------------------------------------------------+
//|                                                      Spreads.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property show_inputs

extern color TextColor=PaleGreen;
extern color SymbolColor=Yellow;
extern color SpreadColor=Green;
extern color MaxSpreadColor=Red;
extern int VOffset=15;
extern int HOffset=15;
extern int VStep=20;
extern int HStep=80;
extern int TextSize=12;

string SL[];
double Spreads[][2];

string ObjName="Spreads";

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
   IndicatorName = GenerateIndicatorName("Spreads");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
}

int GetSymbols(string &SymbolsList[])
{

   int FF = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
   if(FF < 0) return(-1);

   int SymbolsNumber = FileSize(FF) / 128;
   ArrayResize(SymbolsList, SymbolsNumber);
   ArrayResize(Spreads, SymbolsNumber);

   for(int i = 0; i < SymbolsNumber; i++)
   {
      FileSeek(FF, 4, SEEK_CUR);
      SymbolsList[i] = FileReadString(FF, 12);
      FileSeek(FF, 112, SEEK_CUR);
   }
   FileClose(FF);
   return(SymbolsNumber);
}

int GetSpread(string _Symbol)
{
 double _Ask=MarketInfo(_Symbol, MODE_ASK);
 double _Bid=MarketInfo(_Symbol, MODE_BID);
 double _Point=MarketInfo(_Symbol, MODE_POINT);
 int _Spread=0;
 if (_Point!=0)
 {
  _Spread=(_Ask-_Bid)/_Point;
 }
 return (_Spread);
}

void FillSpreads()
{
 int ArrSize=ArraySize(SL);
 int i;
 double V0, V1;
 for (i=0;i<ArrSize;i++)
 {
  Spreads[i][0]=GetSpread(SL[i]);
  Spreads[i][1]=MathMax(Spreads[i][0], Spreads[i][1]);
 }
 return;
}

void DrawRow(int Num)
{
 string _Symbol, _S1, _S2;
 color _C_Symbol, _C_S1, _C_S2;
 if (Num==-1)
 {
  _Symbol="Symbol";
  _S1="Curr.";
  _S2="Max.";
  _C_Symbol=TextColor;
  _C_S1=TextColor;
  _C_S2=TextColor;
 }
 else
 {
  _Symbol=SL[Num];
  _S1=DoubleToStr(Spreads[Num][0], 0);
  _S2=DoubleToStr(Spreads[Num][1], 0);
  _C_Symbol=SymbolColor;
  _C_S1=SpreadColor;
  _C_S2=MaxSpreadColor;
 }
 
 string ON=IndicatorObjPrefix + ObjName+DoubleToStr(Num, 0);
 if (ObjectFind(ON+"S")==-1) ObjectCreate(ON+"S", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"S1")==-1) ObjectCreate(ON+"S1", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(ON+"S2")==-1) ObjectCreate(ON+"S2", OBJ_LABEL, 0, 0, 0);

 ObjectSetText(ON+"S", _Symbol, TextSize);
 ObjectSet(ON+"S", OBJPROP_COLOR, _C_Symbol);
 ObjectSet(ON+"S", OBJPROP_XDISTANCE, HOffset);
 ObjectSet(ON+"S", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"S", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"S1", _S1, TextSize);
 ObjectSet(ON+"S1", OBJPROP_COLOR, _C_S1);
 ObjectSet(ON+"S1", OBJPROP_XDISTANCE, HOffset+HStep);
 ObjectSet(ON+"S1", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"S1", OBJPROP_CORNER, 4);
 
 ObjectSetText(ON+"S2", _S2, TextSize);
 ObjectSet(ON+"S2", OBJPROP_COLOR, _C_S2);
 ObjectSet(ON+"S2", OBJPROP_XDISTANCE, HOffset+2*HStep);
 ObjectSet(ON+"S2", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(ON+"S2", OBJPROP_CORNER, 4);
 
 return;
}

void ShowSpreads()
{
 DrawRow(-1);
 int i;
 int ArrSize=ArraySize(SL);
 for (i=0;i<ArrSize;i++)
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

int start()
  {
   GetSymbols(SL);
   while (true)
   {
    RefreshRates();
    FillSpreads();
    ShowSpreads();
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

