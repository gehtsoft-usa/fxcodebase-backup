// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71991

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property strict 

//--- indicator buffers
input string tHLines              = "== Lines Setup ==";  // == Lines Setup ==
input color  clrLines             = clrBlack;// Color Lines
class HLine
{
  string   _name;
  datetime _iniTm;
  double   _price;
  color    _clr;
  string   _txt;

 public:
  HLine(string inpName, datetime inpIniTm, double inpPrice, color inpClr, string inpLabelTxt = "")
  {
    _name  = inpName;
    _iniTm = inpIniTm;
    _price = inpPrice;
    _clr   = inpClr;
    _txt   = inpLabelTxt;
  }
  ~HLine() { ; }

  HLine* price(double inpPrice)
  {
    _price = inpPrice;
    return &this;
  }
  HLine* txt(string inpTxt)
  {
    _txt = inpTxt;
    return &this;
  }

  HLine* fromCandle(int candle)
  {
     _iniTm  = iTime(Symbol(), Period(), candle);
     return &this;
  }

  void draw()
  {
    // draw line
    ObjectCreate(0, _name, OBJ_HLINE, 0, _iniTm, _price, TimeCurrent(), _price);
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);

    // draw label
    if (_txt != "") {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent(), _price);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
      // ObjectSetInteger(0, _name + "Label", OBJPROP_STYLE, STYLE_DOT);
    }
  }

  void erase()
  {
    ObjectDelete(0, _name);
    ObjectDelete(0, _name + "Label");
  }

  HLine* redraw()
  {
    erase();
    draw();
    return &this;
  }

  void changeColor(color clr)
  {
     erase();
     _clr   = clr;
     draw();
  }

};
HLine* line;

double HiM1[1000], HiM5[1000], HiM15[1000], HiM30[1000], HiH1[1000], HiH4[1000], HiD1[1000], HiW1[1000], HiMN[1000];
double LoM1[1000], LoM5[1000], LoM15[1000], LoM30[1000], LoH1[1000], LoH4[1000], LoD1[1000], LoW1[1000], LoMN[1000];
double KeyM1[], KeyM5[], KeyM15[], KeyM30[], KeyH1[], KeyH4[], KeyD1[], KeyW1[], KeyMN[];

// ------------------------------------------------------------------
input int   uMatches  = 3;                // Number of Matches to consider Key Level:
input bool  uDrawM1   = true;             //  Draw M1
input bool  uDrawM5   = true;             //  Draw M5
input bool  uDrawM15  = true;             // Draw  M15
input bool  uDrawM30  = true;             // Draw  M30
input bool  uDrawH1   = true;             //  Draw H1
input bool  uDrawH4   = true;             //  Draw H4
input bool  uDrawD1   = true;             //  Draw D1
input bool  uDrawW1   = true;             //  Draw W1
input bool  uDrawMN   = true;             //  Draw MN
input color uColorM1  = Green;            // Line Color M1
input color uColorM5  = Blue;             // Line Color M5
input color uColorM15 = Black;            // Line Color M15
input color uColorM30 = Yellow;           // Line Color M30
input color uColorH1  = clrTeal;          // Line Color H1
input color uColorH4  = clrDimGray;       // Line Color H4
input color uColorD1  = clrRoyalBlue;     // Line Color D1
input color uColorW1  = clrDarkOrchid;    // Line Color W1
input color uColorMN  = clrMidnightBlue;  // Line Color MN

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   getHighsLows();
   refreshKeys();
   DrawKeyLevels();

   //---
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
   double vol = iVolume(Symbol(), Period(),0);
   if (vol > 1) return 0;
   Print(__FUNCTION__," ","vol"," ",vol);
   getHighsLows();
   refreshKeys();
   DrawKeyLevels();
   return (rates_total);
}

void OnDeinit(const int reason) { EraseLevels(); }
//+------------------------------------------------------------------+

void getHighsLows()
{
   for (int shift = 0; shift < 1000; shift++)
   {
      HiM1[shift]  = iHigh(_Symbol, PERIOD_M1, shift);
      LoM1[shift]  = iLow(_Symbol, PERIOD_M1, shift);
      HiM5[shift]  = iHigh(_Symbol, PERIOD_M5, shift);
      LoM5[shift]  = iLow(_Symbol, PERIOD_M5, shift);
      HiM15[shift] = iHigh(_Symbol, PERIOD_M15, shift);
      LoM15[shift] = iLow(_Symbol, PERIOD_M15, shift);
      HiM30[shift] = iHigh(_Symbol, PERIOD_M30, shift);
      LoM30[shift] = iLow(_Symbol, PERIOD_M30, shift);
      HiH1[shift]  = iHigh(_Symbol, PERIOD_H1, shift);
      LoH1[shift]  = iLow(_Symbol, PERIOD_H1, shift);
      HiH4[shift]  = iHigh(_Symbol, PERIOD_H4, shift);
      LoH4[shift]  = iLow(_Symbol, PERIOD_H4, shift);
      HiD1[shift]  = iHigh(_Symbol, PERIOD_D1, shift);
      LoD1[shift]  = iLow(_Symbol, PERIOD_D1, shift);
      HiW1[shift]  = iHigh(_Symbol, PERIOD_W1, shift);
      LoW1[shift]  = iLow(_Symbol, PERIOD_W1, shift);
      HiMN[shift]  = iHigh(_Symbol, PERIOD_MN1, shift);
      LoMN[shift]  = iLow(_Symbol, PERIOD_MN1, shift);
   }
}

void refreshKeys()
{
   findKeyLevels(KeyM1, HiM1);
   findKeyLevels(KeyM1, LoM1);
   findKeyLevels(KeyM5, HiM5);
   findKeyLevels(KeyM5, LoM5);
   findKeyLevels(KeyM15, HiM15);
   findKeyLevels(KeyM15, LoM15);
   findKeyLevels(KeyM30, HiM30);
   findKeyLevels(KeyM30, LoM30);
   findKeyLevels(KeyH1, HiH1);
   findKeyLevels(KeyH1, LoH1);
   findKeyLevels(KeyH4, HiH4);
   findKeyLevels(KeyH4, LoH4);
   findKeyLevels(KeyD1, HiD1);
   findKeyLevels(KeyD1, LoD1);
   findKeyLevels(KeyW1, HiW1);
   findKeyLevels(KeyW1, LoW1);
   findKeyLevels(KeyMN, HiMN);
   findKeyLevels(KeyMN, LoMN);
}

void findKeyLevels(double& receptor[], double& ArrayParaBuscar[])
{
   for (int i = 0; i < ArraySize(ArrayParaBuscar); i++)
   {
      double current = ArrayParaBuscar[i];
      int    matches = 0;
      for (int j = 0; j < ArraySize(ArrayParaBuscar); j++)
      {
         if (ArrayParaBuscar[j] == current)
         {
            matches++;
         }
      }

      if (matches >= uMatches)
      {
         int t = ArraySize(receptor);
         if (ArrayResize(receptor, t + 1))
         {
            receptor[t] = current;
         }
      }
   }
}

void DrawTF(double& array[], color clr = Black)
{
   for (int i = 0; i < ArraySize(array); i++)
   {
      double price    = array[i];
      string priceStr = (string)price;
      line            = new HLine("KeyLevel: " + priceStr, 0, price, clr);
      line.draw();
      delete line;
   }
}

void DrawKeyLevels()
{
   EraseLevels();
   if (uDrawM1) DrawTF(KeyM1,  uColorM1 );
   if (uDrawM5) DrawTF(KeyM5,  uColorM5 );
   if (uDrawM15) DrawTF(KeyM15,uColorM15 );
   if (uDrawM30) DrawTF(KeyM30,uColorM30 );
   if (uDrawH1) DrawTF(KeyH1,  uColorH1 );
   if (uDrawH4) DrawTF(KeyH4,  uColorH4 );
   if (uDrawD1) DrawTF(KeyD1,  uColorD1 );
   if (uDrawW1) DrawTF(KeyW1,  uColorW1 );
   if (uDrawMN) DrawTF(KeyMN,  uColorMN );
}

void EraseLevels()
{
   ObjectsDeleteAll(0, "KeyLevel");
}