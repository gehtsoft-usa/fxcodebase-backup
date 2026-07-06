// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71435

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

//based on version Andriy Moraru, syanwar (www.viking234.com), admin@viking234.biz, Lot, Swapp Added,Combine n edit by cmkm-2011-(Thhudu@yahoo.com)|

#property indicator_chart_window

enum MoneyType
{
   MTBalance, // Balance
   MTEquity // Equity
};

//---- alert
input int    __________Alert_Spread = 5;
//---- alert
input bool ___Show_Swap = True;
input int corner = 1; //0 ,1 ,2 ,3
input double Lot=0;
input string Pip_Value_Of_Lot="Lot = 0 ( MinLot )";
input int nPip=10;
input MoneyType MT = MTBalance; // Based on

bool normalize = true; //If true then the spread is normalized to traditional pips
color font_color = DarkGreen;
string font = "Arial";
int font_size = 8;

double Poin;
int n_digits = 0;
double divider = 1;

//+-----------------------------------------+
int init()
{
   //Checking for unconvetional Point digits number
   if (Point == 0.00001) Poin = 0.0001; //5 digits
   else if (Point == 0.001) Poin = 0.01; //3 digits
   else Poin = Point; //Normal
   
   ObjectCreate("Spread", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Spread", OBJPROP_CORNER, corner);
   ObjectSet("Spread", OBJPROP_XDISTANCE, 5);
   ObjectSet("Spread", OBJPROP_YDISTANCE, 15);
   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   
   if ((Poin > Point) && (normalize))
   {
      divider = 10.0;
      n_digits = 1;
   }
   
   return(0);
}
//+-----------------------------------------+

int deinit()
{
   ObjectDelete("Spread");
   ObjectDelete("Swap");

   return(0);
}
//+-----------------------------------------+

int start()
{     
//--------Lot-------
   //-----Lot digits----
   int Lot_digits = 1;
   if (Lot<0.1){Lot_digits=2;}
   
//--------Pip-Lot-------
   double pointPrice = MarketInfo(Symbol(), MODE_TICKVALUE);
     
//--------Spread n Pip Value-------  
   RefreshRates();
   double equity = MT == MTBalance ? AccountBalance() : AccountEquity();
   double spread = (Ask - Bid) / Point;
   double tick_size = MarketInfo(_Symbol, MODE_TICKSIZE);
   double loss = pointPrice * nPip * Lot;
   ObjectSetText("Spread", 
      "Spread = " + DoubleToStr(NormalizeDouble(spread / divider, 1), n_digits) + " pips"
      + " | " + DoubleToStr((loss / equity) * 100, 1) + " % Acc"
      + " = $" + DoubleToStr(loss, 2)
      + " (" + IntegerToString(nPip) + "pips) "
      + "[" + DoubleToString(Lot, 2) + " lots]", font_size, font, font_color);
    
//--------alert-------
   int Spread_digit=NormalizeDouble(spread / divider, 1), n_digits;

   if(Spread_digit > __________Alert_Spread) {
   Alert(Symbol()+"  spread=  "+Spread_digit);}
//--------Swap-------
  if (___Show_Swap==true) { // on/off show swap (only this line)
   ObjectCreate("Swap", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Swap","Swap Long =  "+DoubleToStr(MarketInfo(Symbol(), MODE_SWAPLONG),1)+ " $"+
                 "   |  Swap Short =  "+DoubleToStr(MarketInfo(Symbol(), MODE_SWAPSHORT),1)+ " $", font_size, font, DarkGray);
   ObjectSet("Swap", OBJPROP_CORNER, corner);
   ObjectSet("Swap", OBJPROP_XDISTANCE, 5);
   ObjectSet("Swap", OBJPROP_YDISTANCE, 2); }
//+-----------------------------------------+
return(0);
}