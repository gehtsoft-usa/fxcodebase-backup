// Id: 19690
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65344

//+------------------------------------------------------------------+
//|                                 MTF_MCP_Multi_Indicator_List.mq4 |
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

extern string   Comment0                 = "- Stochastic Parameters -";
extern int      stoch_k                  = 5;
extern int      stoch_d                  = 3;
extern int      stoch_slowing            = 3;
extern double   stoch_ob_level           = 80;
extern double   stoch_os_level           = 20;
extern string   Comment1                 = "- RSI Parameters -";
extern int      RSI_periods              = 14;
extern double   RSI_Buy_Level            = 50;
extern double   RSI_Sell_Level           = 50;
extern string   Comment2                 = "- CCI Parameters -";
extern int      CCI_periods              = 12;
extern double   CCI_Buy_Level            = 0;
extern double   CCI_Sell_Level           = 0;
extern string   Comment3                 = "- WPR Parameters -";
extern int      WPR_periods              = 14;
extern double   WPR_Buy_Level            = -50;
extern double   WPR_Sell_Level           = -50;
extern double   WPR_ob_level             = -20;
extern double   WPR_os_level             = -80;
extern string   Comment4                 = "- Bulls and Bears Impulse Parameters -";
extern int      Bull_Beal_Impulse_Lenght = 13;
extern string   Comment5                 = "- MACD Parameters -";
extern int      MACD_fast_ema_period     = 12;
extern int      MACD_slow_ema_period     = 26;
extern int      MACD_signal_period       = 9;
extern string   Comment6                 = "- ADX Parameters -";
extern int      ADX_periods              = 14;
extern double   ADX_Entry_Level          = 25;
extern string   Comment7                 = "- StochRSI Parameters -";
extern int      StochRSI_RSI_Periods     = 14;
extern int      StochRSI_K_period        = 5;
extern int      StochRSI_D_period        = 3;
extern int      StochRSI_Slowing         = 3;
extern double   StochRSI_ob_level        = 80;
extern double   StochRSI_os_level        = 20;
extern string   Comment8                 = "- SMA Parameters -";
extern int      SMA1_period              = 5;
extern int      SMA2_period              = 10;
extern int      SMA3_period              = 20;
extern int      SMA4_period              = 50;
extern int      SMA5_period              = 100;
extern int      SMA6_period              = 200;
extern string   Comment9                 = "- EMA Parameters -";
extern int      EMA1_period              = 5;
extern int      EMA2_period              = 10;
extern int      EMA3_period              = 20;
extern int      EMA4_period              = 50;
extern int      EMA5_period              = 100;
extern int      EMA6_period              = 200;
extern string   Comment10                = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
//extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern string   Pairs                    = "EURUSD,GBPUSD,EURGBP";
extern string   TimeFrames               = "5,15,30,60,240";
extern color    Labels_Color             = clrWhite;
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;
extern int      Update_History_Every_Seconds   = 60;

//string TimeFrames = "5,15,30,60,240,1440,10080,43200";


int      i;
string   WindowName;
int      WindowNumber;

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

string TF_arr[]; // TimeFrames
int    TF_count; // Number of TFs

datetime Last_History_Process;

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
   
       double temp = iCustom(NULL, 0, "Stochastic_RSI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Stochastic_RSI' indicator");
       return INIT_FAILED;
   }
   WindowName = "MTF_MCP_Multi_Indicator_List";
   IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   
   if ( TimeCurrent()-Last_History_Process > Update_History_Every_Seconds ){
   
      WindowNumber = WindowFind(IndicatorName);
      
      int Pair_y = 50;
      int TF_x   =  1000;
      int Original_x = TF_x;
      
      split(Sym_arr, Pairs, ",");
      Sym_count = ArraySize(Sym_arr);
      split(TF_arr, TimeFrames, ",");
      TF_count = ArraySize(TF_arr);
      
      string TF_Label;
      
      for (i=0; i < TF_count; i++) {
         TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[i]));
         ObjectMakeLabel(TF_Label+"_Label", TF_x, 20, TF_Label, Labels_Color, 1, WindowNumber, "Arial", 12 );
         TF_x = TF_x-120;
      }
      
      double divisor;
         
      string arrow;
      color  diff_color;
      string font_family;
      
      int j,period, score;
      double Stoch_k, Stoch_d, RSI, CCI, WPR, BBI_EMA, BBI_res, BBI_bulls, BBI_bears, MACD, ADX, DMIplus, DMIminus, StochRSI_k, StochRSI_d;
      double price, sma1, sma2, sma3, sma4, sma5, sma6, ema1, ema2, ema3, ema4, ema5, ema6;
      
      for (i=0; i < Sym_count; i++) {
      
         if (MarketInfo(Sym_arr[i],MODE_DIGITS)==3||MarketInfo(Sym_arr[i],MODE_DIGITS)==5)
            divisor = 10;
         else
            divisor = 1;
         
         ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+120, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
         
         TF_x = Original_x;
         
         for (j=0; j < TF_count; j++) {
            
            score = 0;
            
            TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[j]));
            period = StringToInteger(TF_arr[j]);
            /**/
            // Stochastic
            Stoch_k = iStochastic(Sym_arr[i],period,stoch_k,stoch_d,stoch_slowing,MODE_SMA,0,MODE_MAIN,0);
            Stoch_d = iStochastic(Sym_arr[i],period,stoch_k,stoch_d,stoch_slowing,MODE_SMA,0,MODE_SIGNAL,0);
            if (Stoch_k > Stoch_d && Stoch_k < stoch_ob_level) score+=1;
            if (Stoch_k < Stoch_d && Stoch_k > stoch_os_level) score-=1;
            if (Stoch_k > Stoch_d && Stoch_k > stoch_ob_level) score+=0;
            if (Stoch_k < Stoch_d && Stoch_k < stoch_os_level) score+=0;
            
            // RSI
            RSI = iRSI(Sym_arr[i],period,RSI_periods,PRICE_CLOSE,0);
            if (RSI > RSI_Buy_Level) score+=1;
            if (RSI < RSI_Sell_Level) score-=1;
            
            // CCI
            CCI = iCCI(Sym_arr[i],period,CCI_periods,PRICE_TYPICAL,0);
            if (CCI > CCI_Buy_Level) score+=1;
            if (CCI < CCI_Sell_Level) score-=1;
            
            // Williams Percent
            WPR = iWPR(Sym_arr[i],period,WPR_periods,0);
            if (WPR > WPR_Buy_Level  && WPR < WPR_ob_level) score+=1;
            if (WPR < WPR_Sell_Level && WPR > WPR_os_level) score-=1;
            if (WPR > WPR_Buy_Level  && WPR > WPR_ob_level) score+=0;
            if (WPR < WPR_Sell_Level && WPR < WPR_os_level) score+=0;
            
            // Bears and Bulls Impulse
            BBI_EMA=iMA(Sym_arr[i], period, Bull_Beal_Impulse_Lenght, 0, MODE_EMA, PRICE_CLOSE, 0);
            BBI_res=(iHigh(Sym_arr[i],period,0)-BBI_EMA)+(iLow(Sym_arr[i],period,0)-BBI_EMA);
            if (BBI_res>0.){ BBI_bulls=1.; BBI_bears=-1.; }else{ BBI_bulls=-1.; BBI_bears=1.; }
            if (BBI_res > 0) score+=1;
            if (BBI_res < 0) score-=1;
            
            // MACD
            MACD = iMACD(Sym_arr[i],period,MACD_fast_ema_period,MACD_slow_ema_period,MACD_signal_period,PRICE_CLOSE,MODE_MAIN,0);
            if (MACD > 0) score+=1;
            if (MACD < 0) score-=1;
            
            // ADX and DMI
            ADX = iADX(Sym_arr[i],period,ADX_periods,PRICE_CLOSE,MODE_MAIN,0);
            DMIplus = iADX(Sym_arr[i],period,ADX_periods,PRICE_CLOSE,MODE_PLUSDI,0);
            DMIminus = iADX(Sym_arr[i],period,ADX_periods,PRICE_CLOSE,MODE_MINUSDI,0);
            if (ADX > ADX_Entry_Level && DMIplus > DMIminus) score+=1;
            if (ADX < ADX_Entry_Level && DMIplus < DMIminus) score-=1;
   
            // Stochastic RSI
            StochRSI_k = iCustom(Sym_arr[i],period,"Stochastic_RSI",period,StochRSI_RSI_Periods,StochRSI_K_period,StochRSI_D_period,StochRSI_Slowing,0,0);
            StochRSI_d = iCustom(Sym_arr[i],period,"Stochastic_RSI",period,StochRSI_RSI_Periods,StochRSI_K_period,StochRSI_D_period,StochRSI_Slowing,0,1);
            if (StochRSI_k > StochRSI_d && StochRSI_k < StochRSI_ob_level) score+=1;
            if (StochRSI_k < StochRSI_d && StochRSI_k > StochRSI_os_level) score-=1;
            if (StochRSI_k > StochRSI_d && StochRSI_k > StochRSI_ob_level) score+=0;
            if (StochRSI_k < StochRSI_d && StochRSI_k < StochRSI_os_level) score+=0;
            
            price = iClose(Sym_arr[i],period,0);
            
            // SMA
            sma1 = iMA(Sym_arr[i],period,SMA1_period,0,MODE_SMA,PRICE_CLOSE,0);
            sma2 = iMA(Sym_arr[i],period,SMA2_period,0,MODE_SMA,PRICE_CLOSE,0);
            sma3 = iMA(Sym_arr[i],period,SMA3_period,0,MODE_SMA,PRICE_CLOSE,0);
            sma4 = iMA(Sym_arr[i],period,SMA4_period,0,MODE_SMA,PRICE_CLOSE,0);
            sma5 = iMA(Sym_arr[i],period,SMA5_period,0,MODE_SMA,PRICE_CLOSE,0);
            sma6 = iMA(Sym_arr[i],period,SMA6_period,0,MODE_SMA,PRICE_CLOSE,0);
            if (price > sma1) score+=1; if (price < sma1) score-=1;
            if (price > sma2) score+=1; if (price < sma2) score-=1;
            if (price > sma3) score+=1; if (price < sma3) score-=1;
            if (price > sma4) score+=1; if (price < sma4) score-=1;
            if (price > sma5) score+=1; if (price < sma5) score-=1;
            if (price > sma6) score+=1; if (price < sma6) score-=1;
            
            // EMA
            ema1 = iMA(Sym_arr[i],period,SMA1_period,0,MODE_EMA,PRICE_CLOSE,0);
            ema2 = iMA(Sym_arr[i],period,SMA2_period,0,MODE_EMA,PRICE_CLOSE,0);
            ema3 = iMA(Sym_arr[i],period,SMA3_period,0,MODE_EMA,PRICE_CLOSE,0);
            ema4 = iMA(Sym_arr[i],period,SMA4_period,0,MODE_EMA,PRICE_CLOSE,0);
            ema5 = iMA(Sym_arr[i],period,SMA5_period,0,MODE_EMA,PRICE_CLOSE,0);
            ema6 = iMA(Sym_arr[i],period,SMA6_period,0,MODE_EMA,PRICE_CLOSE,0);
            if (price > ema1) score+=1; if (price < ema1) score-=1;
            if (price > ema2) score+=1; if (price < ema2) score-=1;
            if (price > ema3) score+=1; if (price < ema3) score-=1;
            if (price > ema4) score+=1; if (price < ema4) score-=1;
            if (price > ema5) score+=1; if (price < ema5) score-=1;
            if (price > ema6) score+=1; if (price < ema6) score-=1;
            
            if (score >= 12){
               diff_color = Up_Color;
               arrow = "STRONG BUY";
               font_family = "Arial";
            }else if (score >= 9){
               diff_color = Up_Color;
               arrow = "BUY";
               font_family = "Arial";
            }else if (score <= -12){
               diff_color = Dn_Color;
               arrow = "SELL";
               font_family = "Arial";
            }else if (score <= -9){
               diff_color = Dn_Color;
               arrow = "STRONG SELL";
               font_family = "Arial";
            }else{
               diff_color = Neutral_Color;
               arrow = "û";
               font_family = "Wingdings";
            }
            ObjectMakeLabel(Sym_arr[i]+"_"+TF_Label, TF_x, Pair_y, arrow, diff_color, 1, WindowNumber, font_family, 10 );
            /**/
            TF_x = TF_x-120;
         }
         
         Pair_y = Pair_y+30;
         
      }
      
      Last_History_Process = TimeCurrent();
   
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

string Get_TimeFrame_Label(int TF){
   string Label;
   if (TF==5)     Label = "M5";
   if (TF==15)    Label = "M15";
   if (TF==30)    Label = "M30";
   if (TF==60)    Label = "H1";
   if (TF==240)   Label = "H4";
   if (TF==1440)  Label = "D1";
   if (TF==10080) Label = "W1";
   if (TF==43200) Label = "MN1";
   return(Label);
}