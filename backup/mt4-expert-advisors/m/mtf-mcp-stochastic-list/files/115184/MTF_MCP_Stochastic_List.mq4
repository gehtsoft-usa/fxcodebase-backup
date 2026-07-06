// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65135

//+------------------------------------------------------------------+
//|                                       MTF_MCP_Stochastic_List.mq4 |
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

extern int      K_Period               = 5;
extern int      D_Period               = 3;
extern int      Slowing                = 3;
extern double   OS_Level               = 30;
extern double   OB_Level               = 70;
extern string   Comment1               = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                  = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M5             = true;
extern bool     Include_M15            = true;
extern bool     Include_M30            = true;
extern bool     Include_H1             = true;
extern bool     Include_H4             = true;
extern bool     Include_D1             = true;
extern bool     Include_W1             = true;
extern bool     Include_MN1            = true;
extern color    Labels_Color           = clrWhite;
extern color    Up_Arrow_Color         = clrLime;
extern color    Dn_Arrow_Color         = clrRed;
extern color    Neutral_Arrow_Color    = clrDarkGray;
extern color    Active_K_D_Cross_Color = clrYellow;

int      i;
datetime LastAlert;
string   WindowName;
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

int init(){
   
   WindowName = "MTF_MCP_Stochastic_List";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
  {
   
   WindowNumber = WindowFind(IndicatorName);
   
   int Pair_y = 50;
   int TF_x   =  800;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_MN1){
      int MN1_x = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel("MN1_Label", MN1_x, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   double stoch_k, stoch_d, stoch_k1, stoch_d1;
   color Arrow_Color;
   
   for (i=0; i < Sym_count; i++) {
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+50, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_M5,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_M5,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_M5,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_M5,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_M5_cross", M5_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_M15){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_M15,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_M15,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_M15,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_M15,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_M15_cross", M15_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_M30){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_M30,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_M30,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_M30,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_M30,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_M30_cross", M30_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_H1){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_H1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_H1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_H1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_H1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_H1_cross", H1_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_H4){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_H4,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_H4,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_H4,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_H4,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_H4_cross", H4_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_D1){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_D1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_D1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_D1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_D1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_D1_cross", D1_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_W1){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_W1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_W1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_W1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_W1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_W1_cross", W1_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      if (Include_MN1){
         stoch_k = iStochastic(Sym_arr[i],PERIOD_MN1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,0);
         stoch_d = iStochastic(Sym_arr[i],PERIOD_MN1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stoch_k1 = iStochastic(Sym_arr[i],PERIOD_MN1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,1);
         stoch_d1 = iStochastic(Sym_arr[i],PERIOD_MN1,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,1);
         if (stoch_k > stoch_d){
            if (stoch_k > OB_Level) Arrow_Color = Up_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, "é", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }else{
            if (stoch_k < OS_Level) Arrow_Color = Dn_Arrow_Color; else Arrow_Color = Neutral_Arrow_Color;
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, "ê", Arrow_Color, 1, WindowNumber, "Wingdings", 12 );
         }
         if ((stoch_k > stoch_d && stoch_k1 < stoch_d1) || (stoch_k < stoch_d && stoch_k1 > stoch_d1)){
            ObjectMakeLabel(Sym_arr[i]+"_MN1_cross", MN1_x-15, Pair_y+3, "l", Active_K_D_Cross_Color, 1, WindowNumber, "Wingdings", 10 );
         }
      }
      
      Pair_y = Pair_y+30;
      
   }
   
//----
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
   return;
}

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (i=0; i < len;) {
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