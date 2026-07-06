// Id: 17686
//+------------------------------------------------------------------+
//|                                                    DEMARK_V1.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern int   lookback                 = 4;
extern color Buy_Setup_Color          = clrGreen;
extern color Sell_Setup_Color         = clrRed;
extern color Perfect_Buy_Setup_Color  = clrGreen;
extern color Perfect_Sell_Setup_Color = clrRed;
extern color TDST_Support_Color       = clrLawnGreen;
extern color TDST_Resistance_Color    = clrIndianRed;
extern bool  Enable_TD_Countdown      = false;
extern color Buy_Countdown_Color      = clrLime;
extern color Sell_Countdown_Color     = clrFireBrick;
extern int   Limit_Bars               = 2000;

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
    IndicatorName = GenerateIndicatorName("Demark Indicators");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   ObjectsDeleteAll();
   
   return(0);
  
}

int deinit(){
   
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   
   return(0);
  
}

int start(){

   int i, a;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   bool   InBuySU, InSellSU, BuySUComplete, SellSUComplete = false;
   int    BuySUCount, SellSUCount, bCountdown, sCountdown = 0;
   double TDSTResVal, TDSTSupVal;
   double CountTest=0;
   
   if (Limit_Bars>0) limit=Limit_Bars;
   
   for(i=limit; i>=0; i--){
   
      /**/
      if (InBuySU && BuySUCount < 9){
         // we're currently in an uncompleted prospective TD Buy Setup.
         if (Close[i] < Close[i + lookback]){
            // the setup remains intact
            BuySUCount = BuySUCount + 1;
            ObjectMakeText(IndicatorObjPrefix +  "BuySU_"+i, Time[i], Low[i]-(5*pipSize), BuySUCount, Buy_Setup_Color, "Arial", 8 );
            if (BuySUCount == 9){
               // The TD Buy Setup has just completed.
               BuySUComplete = true;
               InBuySU = false;
               // calculate the new TDST Resistance level.
               TDSTResVal = MaxMin(i+8, 4, "max");
               // draw the new TDST Resistance level back to bar #1 of the TDSetup.
               Level(IndicatorObjPrefix + "TDSTRes_"+i, Time[i+8], TDSTResVal, Time[i], TDST_Resistance_Color, 2, STYLE_SOLID);
               // looking for perfect Setup
               if ((Low[i] <= Low[i+3] && Low[i] <= Low[i+2]) || (Low[i+1] <= Low[i+3] && Low[i+1] <= Low[i+2])){
                  ObjectMakeText(IndicatorObjPrefix + "BuyPSU_"+i, Time[i], Low[i]-(5*pipSize), "é", Perfect_Buy_Setup_Color, "Wingdings", 10 );
                  // Perfect Setup found starting TP Countdown
                  sCountdown = 0;
                  bCountdown = 1;
                  ObjectMakeText(IndicatorObjPrefix + "BuyCNT_"+i, Time[i], Low[i]-(10*pipSize), bCountdown, Buy_Countdown_Color, "Arial", 8 );
               }
            }
         }
         else{
            // the setup has been broken
            for (a = 1; a<=BuySUCount; a++){
               // clear away the existing setup numbers
               ObjectDelete(IndicatorObjPrefix + "BuySU_"+(i+a));
            }
            // reset the TD Buy Setup tracking variables
            InBuySU = false;
            BuySUCount = 0;
         }  
      }
      else if (InSellSU == true && SellSUCount < 9){
         // we're currently in an uncompleted prospective TD Sell Setup.
         if (Close[i] > Close[i + lookback]){
            // the setup remains intact
            SellSUCount = SellSUCount + 1;
            ObjectMakeText(IndicatorObjPrefix + "SellSU_"+i, Time[i], High[i]+(5*pipSize), SellSUCount, Sell_Setup_Color, "Arial", 8 );
            if (SellSUCount == 9){
               // The TD Sell Setup has just completed.
               SellSUComplete = true;
               InSellSU = false;
               // calculate a new TDST Support level.
               TDSTSupVal = MaxMin(i+8, 4, "min");
               // draw the new TDST Support level back to bar #1 of the TDSetup.
               Level(IndicatorObjPrefix + "TDSTSup"+i, Time[i+8], TDSTSupVal, Time[i], TDST_Support_Color, 2, STYLE_SOLID);
               // looking for perfect Setup
               if ((High[i] >= High[i+3] && High[i] >= High[i+2]) || (High[i+1] >= High[i+3] && High[i+1] >= High[i+2])){
                  ObjectMakeText(IndicatorObjPrefix + "SellPSU_"+i, Time[i], High[i]+(5*pipSize), "ê", Perfect_Sell_Setup_Color, "Wingdings", 10 );
                  // Perfect Setup found starting TP Countdown
                  bCountdown = 0 ;
                  sCountdown = 1;
                  ObjectMakeText(IndicatorObjPrefix + "SellCNT_"+i, Time[i], High[i]+(10*pipSize), sCountdown, Sell_Countdown_Color, "Arial", 8 );
               }
            }
         }
         else{
            // the setup has been broken
            for (a = 1; a<=BuySUCount; a++){
               // clear away the existing setup numbers
               ObjectDelete(IndicatorObjPrefix + "SellSU_"+(i+a));
            }
            // reset the TD Buy Setup tracking variables
            InSellSU = false;
            SellSUCount = 0;
         }
      }

      if (InBuySU == false && InSellSU == false){
         // we're not currently in any possible TD Setup.  Check whether one is just starting.
         if (Close[i + 1] > Close[i + 1 + lookback] && Close[i] < Close[i + lookback]){
            // a Bearish TD Price Flip has occurred.  This is bar 1 of a possible TD Buy Setup.
            InBuySU = true;
            BuySUComplete = false;
            BuySUCount = 1;
            SellSUCount = 0;
            ObjectMakeText(IndicatorObjPrefix +  "BuySU_"+i, Time[i], Low[i]-(5*pipSize), BuySUCount, Buy_Setup_Color, "Arial", 8 );
         }
         else if (Close[i + 1] < Close[i + 1 + lookback] && Close[i] > Close[i + lookback]){
            // a Bullish TD Price Flip has occurred.  This is bar 1 of a possible TD Sell Setup.
            InSellSU = true;
            SellSUComplete = false;
            SellSUCount = 1;
            BuySUCount = 0;
            ObjectMakeText(IndicatorObjPrefix + "SellSU_"+i, Time[i], High[i]+(5*pipSize), SellSUCount, Sell_Setup_Color, "Arial", 8 );
         }
      }
      // extend the existing TDST Level lines up to the current bar.
      Level(IndicatorObjPrefix + "TDSTRes_"+i, Time[i+1], TDSTResVal, Time[i], TDST_Resistance_Color, 2, STYLE_SOLID);
      Level(IndicatorObjPrefix + "TDSTSup_"+i, Time[i+1], TDSTSupVal, Time[i], TDST_Support_Color, 2, STYLE_SOLID);
      
      // TD Countdown Calculations
      //if bTDCountDown == true then
      if (bCountdown >= 1 && bCountdown < 13 && Close[i] <= Close[i+2]){
         if (bCountdown==8) CountTest=Close[i];
         ObjectMakeText(IndicatorObjPrefix + "BuyCNT_"+i, Time[i], Low[i]-(10*pipSize), bCountdown, Buy_Countdown_Color, "Arial", 8 );
         bCountdown = bCountdown + 1;
      }
      if (CountTest != 0){
         if  (bCountdown == 13 && Close[i] <= Close[i+1] && Close[i] > CountTest){
            ObjectMakeText(IndicatorObjPrefix + "BuyCNTS_"+i, Time[i], Low[i]-(15*pipSize), "é", Buy_Countdown_Color, "Wingdings", 10 );
         }
         if  (bCountdown == 13 && Close[i] <= Close[i+1] && Close[i] <= CountTest){
            bCountdown=0;
            ObjectMakeText(IndicatorObjPrefix + "BuyCNT_"+i, Time[i], Low[i]-(20*pipSize), "Buy Countdown Completed", Buy_Countdown_Color, "Arial", 8 );
            ObjectMakeText(IndicatorObjPrefix + "BuyCNTS_"+i, Time[i], Low[i]-(15*pipSize), "é", Buy_Countdown_Color, "Wingdings", 10 );
         }
      }
      
      if (sCountdown >= 1 && sCountdown < 13 && Close[i] >= Close[i+2]){
         if (sCountdown==8) CountTest=Close[i];
         ObjectMakeText(IndicatorObjPrefix + "SellCNT_"+i, Time[i], High[i]+(10*pipSize), sCountdown, Sell_Countdown_Color, "Arial", 8 );
         sCountdown = sCountdown + 1;
      }
      if (CountTest != 0){
         if  (sCountdown == 13 && Close[i] >= Close[i+1] && Close[i] < CountTest){
            ObjectMakeText(IndicatorObjPrefix + "SellCNTS_"+i, Time[i], High[i]+(15*pipSize), "ê", Sell_Countdown_Color, "Wingdings", 10 );
         }
         if  (sCountdown == 13 && Close[i] >= Close[i+1] && Close[i] >= CountTest){
            sCountdown=0;
            ObjectMakeText(IndicatorObjPrefix + "SellCNT_"+i, Time[i], High[i]+(20*pipSize), "Sell Countdown Completed", Sell_Countdown_Color, "Arial", 8 );
            ObjectMakeText(IndicatorObjPrefix + "SellCNTS_"+i, Time[i], High[i]+(15*pipSize), "ê", Sell_Countdown_Color, "Wingdings", 10 );
         }
      }
      /**/      
   
   }

   return(0);

}

double MaxMin(int from, int n, string type){
   int j;
   double max, min, result;
   for (j=from; j>=(from-n+1); j--){
      if (j==from){
         max = High[j];
         min = Low[j];
      }
      else{
         if (High[j]>max) max = High[j];
         if (Low[j] <min) min = Low[j];
      }
   }
   if (type=="max") result = max;
   if (type=="min") result = min;
   return(result);
}

// Position Text
void ObjectMakeText( string nm, datetime tiempo1, double precio1, string Texto, color TColor, string Font = "Arial", int FSize = 7 ){
   ObjectDelete(nm);
   ObjectCreate( nm, OBJ_TEXT, 0, tiempo1, precio1 );
   ObjectSetText( nm, Texto, FSize, Font, TColor );
   ObjectSet(nm, OBJPROP_TIME1, tiempo1);
   ObjectSet(nm, OBJPROP_PRICE1, precio1);
   return;
}

// Draw Level
void Level(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style){
   ObjectDelete(Nombre);
   ObjectCreate(Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(Nombre, OBJPROP_STYLE, style);
   ObjectSet(Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(Nombre, OBJPROP_RAY, False);
   ObjectSet( Nombre, OBJPROP_BACK, true );
}