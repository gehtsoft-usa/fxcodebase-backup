//+------------------------------------------------------------------+
//|                                         MTF_MCP_VORTEX_Alert.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_separate_window


extern int      Periods                = 14;
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
extern color    Up_VM_Color            = clrLime;
extern color    Dn_VM_Color            = clrRed;
extern color    All_Sync_Color         = clrYellow;
extern bool     Alert_ON               = true;
extern int      Alert_Minutes_Interval = 15;

int      i, j;
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
   
   WindowName = "MTF_MCP_Vortex_Alert";
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
   
   int  TFs, Ups, Dns;
   double sum_v_high, sum_v_low, sum_atr, V_Pos, V_Neg;
   bool Alerts_Found=false;
   string Comentario="";
   
   for (i=0; i < Sym_count; i++) {
   
      TFs = 0;
      Ups = 0;
      Dns = 0;
      
      Comentario+=Sym_arr[i]+" ";
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+50, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_M5,j) - iLow(Sym_arr[i],PERIOD_M5,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_M5,j) - iHigh(Sym_arr[i],PERIOD_M5,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_M5,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         Comentario+=V_Pos+" "+V_Neg+"\n";
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Dns++;
         }
         TFs++;
      }
      if (Include_M15){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_M15,j) - iLow(Sym_arr[i],PERIOD_M15,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_M15,j) - iHigh(Sym_arr[i],PERIOD_M15,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_M15,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      if (Include_M30){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_M30,j) - iLow(Sym_arr[i],PERIOD_M30,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_M30,j) - iHigh(Sym_arr[i],PERIOD_M30,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_M30,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      if (Include_H1){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_H1,j) - iLow(Sym_arr[i],PERIOD_H1,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_H1,j) - iHigh(Sym_arr[i],PERIOD_H1,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_H1,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      if (Include_H4){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_H4,j) - iLow(Sym_arr[i],PERIOD_H4,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_H4,j) - iHigh(Sym_arr[i],PERIOD_H4,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_H4,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      if (Include_D1){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_D1,j) - iLow(Sym_arr[i],PERIOD_D1,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_D1,j) - iHigh(Sym_arr[i],PERIOD_D1,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_D1,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      if (Include_W1){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_W1,j) - iLow(Sym_arr[i],PERIOD_W1,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_W1,j) - iHigh(Sym_arr[i],PERIOD_W1,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_W1,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      if (Include_MN1){
         /* */
         sum_v_high = 0;
         sum_v_low  = 0;
         sum_atr    = 0;
         for (j=(0+Periods-1); j>=0; j--){  
            sum_v_high += MathAbs(iHigh(Sym_arr[i],PERIOD_MN1,j) - iLow(Sym_arr[i],PERIOD_MN1,j+1));
            sum_v_low  += MathAbs(iLow(Sym_arr[i],PERIOD_MN1,j) - iHigh(Sym_arr[i],PERIOD_MN1,j+1));
            sum_atr    += iATR(Sym_arr[i],PERIOD_MN1,1,j);
         }
         V_Pos = sum_v_high/sum_atr * 100;
         V_Neg = sum_v_low /sum_atr * 100;
         /* */
         if (V_Pos > 100){
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, "é", Up_VM_Color, 1, WindowNumber, "Wingdings", 12 );
            Ups++;
         }else{
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, "ê", Dn_VM_Color, 1, WindowNumber, "Wingdings", 12 );
           Dns++;
         }
         TFs++;
      }
      
      // All Sync Mark
      if (Ups==TFs || Dns==TFs)
         ObjectMakeLabel(Sym_arr[i]+"_Sync", Original_x+130, Pair_y, "è", All_Sync_Color, 1, WindowNumber, "Wingdings", 12 );
      else
         ObjectDelete(Sym_arr[i]+"_Sync");
      
      if (Alert_ON && (TimeCurrent()-LastAlert) > (Alert_Minutes_Interval*60)){
         
         if (Ups==TFs || Dns==TFs){
            if (Ups==TFs)
               Alert(Sym_arr[i] + " All TFs in Sync for the Up - Above the "+Periods+" Vortex");
            else
               Alert(Sym_arr[i] + " All TFs in Sync for the Down - Below the "+Periods+" Vortex");
            Alerts_Found = true;
         }
      }
      
      Pair_y = Pair_y+30;
      
   }
   
   //Comment("");
   
   if (Alerts_Found){
      LastAlert = TimeCurrent();
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