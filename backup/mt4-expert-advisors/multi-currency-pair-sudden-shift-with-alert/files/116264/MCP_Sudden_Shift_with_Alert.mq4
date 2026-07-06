// Id: 19846
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65406

//+------------------------------------------------------------------+
//|                                  MCP_Sudden_Shift_with_Alert.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window

#property  indicator_buffers 16
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_color3  clrLime
#property indicator_color4  clrRed
#property indicator_color5  clrLime
#property indicator_color6  clrRed
#property indicator_color7  clrLime
#property indicator_color8  clrRed
#property indicator_color9  clrLime
#property indicator_color10 clrRed
#property indicator_color11 clrLime
#property indicator_color12 clrRed
#property indicator_color13 clrLime
#property indicator_color14 clrRed
#property indicator_color15 clrLime
#property indicator_color16 clrRed
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1

extern double Pips_Shift  = 10;
extern string Pairs       = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool   Sound_Alert = true;
extern bool   Email_Alert = false;

datetime LastAlert;

//---- indicator buffers
double Shift_1_Up[], Shift_1_Dn[];
double Shift_2_Up[], Shift_2_Dn[];
double Shift_3_Up[], Shift_3_Dn[];
double Shift_4_Up[], Shift_4_Dn[];
double Shift_5_Up[], Shift_5_Dn[];
double Shift_6_Up[], Shift_6_Dn[];
double Shift_7_Up[], Shift_7_Dn[];
double Shift_8_Up[], Shift_8_Dn[];

string IndName;
int      WindowNumber;

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
      
   SetIndexBuffer(0,Shift_1_Up);
   SetIndexStyle (0,DRAW_ARROW);
   SetIndexArrow (0,233);
   SetIndexBuffer(1,Shift_1_Dn);
   SetIndexStyle (1,DRAW_ARROW);
   SetIndexArrow (1,234);
   
   SetIndexBuffer(2,Shift_2_Up);
   SetIndexStyle (2,DRAW_ARROW);
   SetIndexArrow (2,233);
   SetIndexBuffer(3,Shift_2_Dn);
   SetIndexStyle (3,DRAW_ARROW);
   SetIndexArrow (3,234);
   
   SetIndexBuffer(4,Shift_3_Up);
   SetIndexStyle (4,DRAW_ARROW);
   SetIndexArrow (4,233);
   SetIndexBuffer(5,Shift_3_Dn);
   SetIndexStyle (5,DRAW_ARROW);
   SetIndexArrow (5,234);
   
   SetIndexBuffer(6,Shift_4_Up);
   SetIndexStyle (6,DRAW_ARROW);
   SetIndexArrow (6,233);
   SetIndexBuffer(7,Shift_4_Dn);
   SetIndexStyle (7,DRAW_ARROW);
   SetIndexArrow (7,234);
   
   SetIndexBuffer(8,Shift_5_Up);
   SetIndexStyle (8,DRAW_ARROW);
   SetIndexArrow (8,233);
   SetIndexBuffer(9,Shift_5_Dn);
   SetIndexStyle (9,DRAW_ARROW);
   SetIndexArrow (9,234);
   
   SetIndexBuffer(10,Shift_6_Up);
   SetIndexStyle (10,DRAW_ARROW);
   SetIndexArrow (10,233);
   SetIndexBuffer(11,Shift_6_Dn);
   SetIndexStyle (11,DRAW_ARROW);
   SetIndexArrow (11,234);
   
   SetIndexBuffer(12,Shift_7_Up);
   SetIndexStyle (12,DRAW_ARROW);
   SetIndexArrow (12,233);
   SetIndexBuffer(13,Shift_7_Dn);
   SetIndexStyle (13,DRAW_ARROW);
   SetIndexArrow (13,234);
   
   SetIndexBuffer(14,Shift_8_Up);
   SetIndexStyle (14,DRAW_ARROW);
   SetIndexArrow (14,233);
   SetIndexBuffer(15,Shift_8_Dn);
   SetIndexStyle (15,DRAW_ARROW);
   SetIndexArrow (15,234);
   
   SetLevelValue(0,4.5);
   SetLevelValue(1,4.0);
   SetLevelValue(2,3.5);
   SetLevelValue(3,3.0);
   SetLevelValue(4,2.5);
   SetLevelValue(5,2.0);
   SetLevelValue(6,1.5);
   SetLevelValue(7,1.0);
   SetLevelValue(8,0.5);
   
   IndName = "MCP Sudden Shift";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,5.0);
   
//---- initialization done
   return(0);
  }


int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i, j;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   WindowNumber = WindowFind(IndName);
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   string Alerts;
   
   if (Sym_count > 8)Sym_count = 8;
   double Label_Pos = 4.5;
   double pips_high, pips_low;
   Alerts = "";
   for (i=0; i < Sym_count; i++) {
      Etiqueta("Sudden_Shift_"+Sym_arr[i]," - "+Sym_arr[i],Label_Pos-0.1, Time[0]+(Period()*60*3));
      for (j=limit; j>=0; j--){
         pips_high = (1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],0,j)-iOpen(Sym_arr[i],0,j));
         pips_low  = (1/MarketInfo(Sym_arr[i],MODE_POINT))*(iOpen(Sym_arr[i],0,j)-iClose(Sym_arr[i],0,j));
         if (MarketInfo(Sym_arr[i],MODE_DIGITS)==3||MarketInfo(Sym_arr[i],MODE_DIGITS)==5){
            pips_high/=10;
            pips_low/=10;
         }
         if (iClose(Sym_arr[i],0,j) > iOpen(Sym_arr[i],0,j) && pips_high > Pips_Shift){
            Assign_Value(i,j,"up",Label_Pos-0.3);
            if (j==0) Alerts+= Sym_arr[i]+"(up) ";
         }
         if (iClose(Sym_arr[i],0,j) < iOpen(Sym_arr[i],0,j) && pips_low  > Pips_Shift){
            Assign_Value(i,j,"dn",Label_Pos-0.3);
            if (j==0) Alerts+= Sym_arr[i]+"(down) ";
         }
      }
      Label_Pos-= 0.5;
   }
   if (Time[0] > LastAlert && Alerts!=""){
      if (Sound_Alert) Alert("Sudden Shift Alert ("+Pips_Shift+" pips): "+Alerts);
      if (Email_Alert) SendMail("Sudden Shift Alert", Alerts);
      LastAlert = TimeCurrent();
   }
      
//---- done
   return(0);
}

double Assign_Value(int pair,int bar, string direction, double val){
   
   if (pair==0){
      if (direction=="up") Shift_1_Up[bar] = val;
      if (direction=="dn") Shift_1_Dn[bar] = val;
   }
   if (pair==1){
      if (direction=="up") Shift_2_Up[bar] = val;
      if (direction=="dn") Shift_2_Dn[bar] = val;
   }
   if (pair==2){
      if (direction=="up") Shift_3_Up[bar] = val;
      if (direction=="dn") Shift_3_Dn[bar] = val;
   }
   if (pair==3){
      if (direction=="up") Shift_4_Up[bar] = val;
      if (direction=="dn") Shift_4_Dn[bar] = val;
   }
   if (pair==4){
      if (direction=="up") Shift_5_Up[bar] = val;
      if (direction=="dn") Shift_5_Dn[bar] = val;
   }
   if (pair==5){
      if (direction=="up") Shift_6_Up[bar] = val;
      if (direction=="dn") Shift_6_Dn[bar] = val;
   }
   if (pair==6){
      if (direction=="up") Shift_7_Up[bar] = val;
      if (direction=="dn") Shift_7_Dn[bar] = val;
   }
   if (pair==7){
      if (direction=="up") Shift_8_Up[bar] = val;
      if (direction=="dn") Shift_8_Dn[bar] = val;
   }
   
   return(0);
   
}

int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind(IndName), tTime+Period()*60*2, dPrice);
  ObjectSetText(IndicatorObjPrefix + sName, " "+sLabel, 8, "Lucida Console", clrWhite);
  ObjectMove(IndicatorObjPrefix + sName,0,tTime+Period()*60*2, dPrice);
  return(0);
}

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (int i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] = item;
    
    i = pos+1;
  }
}
