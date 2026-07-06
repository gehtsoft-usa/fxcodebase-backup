// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72558

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

#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
input int InpDepth     = 12;  // Depth
input int InpDeviation = 5;   // Deviation
input int InpBackstep  = 3;   // Backstep
//---- indicator buffers

input string tHLines            = "== Lines Setup ==";  // == Lines Setup ==
input color  clrHigh            = Red;// Color High Line
input color  clrMedium          = Black;// Color Medium Line
input color  clrLow             = Green;// Color Low Line

double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
//--- globals
int ExtLevel = 3;  // recounting's depth of extremums


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
double price()
{
  return _price;
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
    ObjectCreate(0, _name, OBJ_TREND, 0, _iniTm, _price, TimeCurrent(), _price);
		ObjectSetInteger(0, _name, OBJPROP_WIDTH, 2); 
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);
    ObjectSetInteger(0, _name, OBJPROP_SELECTABLE, true);

    // draw label
    if (_txt != "") {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent(), _price);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
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
  
HLine* clr(color clr)
{
    _clr   = clr;
    return &this;
}

  void changeColor(color clr)
  {
     erase();
     _clr   = clr;
     draw();
  }

	double linePrice()
	{
		 return ObjectGetDouble(0, _name, OBJPROP_PRICE);
  }

	bool isSelected()
	{
  	return ObjectGetInteger(0, _name, OBJPROP_SELECTED);
	}

};
HLine* MediumLine;
HLine* LowLine;
HLine* HighLine;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  if (InpBackstep >= InpDepth)
  {
    Print("Backstep cannot be greater or equal to Depth");
    return (INIT_FAILED);
  }
  //--- 2 additional buffers
  IndicatorBuffers(3);
  //---- drawing settings
  SetIndexStyle(0, DRAW_SECTION);
  //---- indicator buffers
  SetIndexBuffer(0, ExtZigzagBuffer);
  SetIndexBuffer(1, ExtHighBuffer);
  SetIndexBuffer(2, ExtLowBuffer);
  SetIndexEmptyValue(0, 0.0);

  //---- indicator short name
  IndicatorShortName("ZigZag(" + string(InpDepth) + "," + string(InpDeviation) + "," + string(InpBackstep) + ")");

  HighLine = new HLine("High", 0, 0, clrHigh);
  MediumLine = new HLine("Median", 0, 0, clrMedium);
  LowLine = new HLine("Low", 0, 0, clrLow);

  //---- initialization done
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
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
  int    i, limit, counterZ, whatlookfor = 0;
  int    back, pos, lasthighpos = 0, lastlowpos = 0;
  double extremum;
  double curlow = 0.0, curhigh = 0.0, lasthigh = 0.0, lastlow = 0.0;
  //--- check for history and inputs
  if (rates_total < InpDepth || InpBackstep >= InpDepth)
    return (0);
  //--- first calculations
  if (prev_calculated == 0)
    limit = InitializeAll();
  else
  {
    //--- find first extremum in the depth ExtLevel or 100 last bars
    i = counterZ = 0;
    while (counterZ < ExtLevel && i < 100)
    {
      if (ExtZigzagBuffer[i] != 0.0)
        counterZ++;
      i++;
    }
    //--- no extremum found - recounting all from begin
    if (counterZ == 0)
      limit = InitializeAll();
    else
    {
      //--- set start position to found extremum position
      limit = i - 1;
      //--- what kind of extremum?
      if (ExtLowBuffer[i] != 0.0)
      {
        //--- low extremum
        curlow = ExtLowBuffer[i];
        //--- will look for the next high extremum
        whatlookfor = 1;
      } else
      {
        //--- high extremum
        curhigh = ExtHighBuffer[i];
        //--- will look for the next low extremum
        whatlookfor = -1;
      }
      //--- clear the rest data
      for (i = limit - 1; i >= 0; i--)
      {
        ExtZigzagBuffer[i] = 0.0;
        ExtLowBuffer[i]    = 0.0;
        ExtHighBuffer[i]   = 0.0;
      }
    }
  }
  //--- main loop
  for (i = limit; i >= 0; i--)
  {
    //--- find lowest low in depth of bars
    extremum = low[iLowest(NULL, 0, MODE_LOW, InpDepth, i)];
    //--- this lowest has been found previously
    if (extremum == lastlow)
      extremum = 0.0;
    else
    {
      //--- new last low
      lastlow = extremum;
      //--- discard extremum if current low is too high
      if (low[i] - extremum > InpDeviation * Point)
        extremum = 0.0;
      else
      {
        //--- clear previous extremums in backstep bars
        for (back = 1; back <= InpBackstep; back++)
        {
          pos = i + back;
          if (ExtLowBuffer[pos] != 0 && ExtLowBuffer[pos] > extremum)
            ExtLowBuffer[pos] = 0.0;
        }
      }
    }

    //--- found extremum is current low
    if (low[i] == extremum)
      ExtLowBuffer[i] = extremum;
    else
      ExtLowBuffer[i] = 0.0;
    //--- find highest high in depth of bars
    extremum = high[iHighest(NULL, 0, MODE_HIGH, InpDepth, i)];
    //--- this highest has been found previously
    if (extremum == lasthigh)
      extremum = 0.0;
    else
    {
      //--- new last high
      lasthigh = extremum;
      //--- discard extremum if current high is too low
      if (extremum - high[i] > InpDeviation * Point)
        extremum = 0.0;
      else
      {
        //--- clear previous extremums in backstep bars
        for (back = 1; back <= InpBackstep; back++)
        {
          pos = i + back;
          if (ExtHighBuffer[pos] != 0 && ExtHighBuffer[pos] < extremum)
            ExtHighBuffer[pos] = 0.0;
        }
      }
    }
    //--- found extremum is current high
    if (high[i] == extremum)
      ExtHighBuffer[i] = extremum;
    else
      ExtHighBuffer[i] = 0.0;
  }
  //--- final cutting
  if (whatlookfor == 0)
  {
    lastlow  = 0.0;
    lasthigh = 0.0;
  } else
  {
    lastlow  = curlow;
    lasthigh = curhigh;
  }
  for (i = limit; i >= 0; i--)
  {
    switch (whatlookfor)
    {
      case 0:  // look for peak or lawn
        if (lastlow == 0.0 && lasthigh == 0.0)
        {
          if (ExtHighBuffer[i] != 0.0)
          {
            lasthigh           = High[i];
            lasthighpos        = i;
            whatlookfor        = -1;
            ExtZigzagBuffer[i] = lasthigh;
          }
          if (ExtLowBuffer[i] != 0.0)
          {
            lastlow            = Low[i];
            lastlowpos         = i;
            whatlookfor        = 1;
            ExtZigzagBuffer[i] = lastlow;
          }
        }
        break;
      case 1:  // look for peak
        if (ExtLowBuffer[i] != 0.0 && ExtLowBuffer[i] < lastlow && ExtHighBuffer[i] == 0.0)
        {
          ExtZigzagBuffer[lastlowpos] = 0.0;
          lastlowpos                  = i;
          lastlow                     = ExtLowBuffer[i];
          ExtZigzagBuffer[i]          = lastlow;
        }
        if (ExtHighBuffer[i] != 0.0 && ExtLowBuffer[i] == 0.0)
        {
          lasthigh           = ExtHighBuffer[i];
          lasthighpos        = i;
          ExtZigzagBuffer[i] = lasthigh;
          whatlookfor        = -1;
        }
        break;
      case -1:  // look for lawn
        if (ExtHighBuffer[i] != 0.0 && ExtHighBuffer[i] > lasthigh && ExtLowBuffer[i] == 0.0)
        {
          ExtZigzagBuffer[lasthighpos] = 0.0;
          lasthighpos                  = i;
          lasthigh                     = ExtHighBuffer[i];
          ExtZigzagBuffer[i]           = lasthigh;
        }
        if (ExtLowBuffer[i] != 0.0 && ExtHighBuffer[i] == 0.0)
        {
          lastlow            = ExtLowBuffer[i];
          lastlowpos         = i;
          ExtZigzagBuffer[i] = lastlow;
          whatlookfor        = 1;
        }
        break;
    }
  }

  int n = 0;
  double firstValue, secondValue, mediumValue;
  
	// primer punto que saltéo:
  for (n = 0; n <= 100; n++)
  {
		if(ExtZigzagBuffer[n] != 0) break;
		if(ExtZigzagBuffer[n] != 0) break;
	}

	// busco primer pto con valor
  int m;
  for (m = n+1; m <= 100; m++)
  {
		if(ExtZigzagBuffer[m] != 0){ firstValue = ExtZigzagBuffer[m]; break; }
    if(ExtZigzagBuffer[m] != 0) { firstValue = ExtZigzagBuffer[m]; break; }
  }
	
	// busco segundo pto con valor
	int j;
  for (j = m+1; j <= 100; j++)
  {
		if(ExtZigzagBuffer[j] != 0){ secondValue = ExtZigzagBuffer[j]; break; }
    if(ExtZigzagBuffer[j] != 0) { secondValue = ExtZigzagBuffer[j]; break; }
  }	
		// calculo media // grafico
  mediumValue = NormalizeDouble((firstValue + secondValue) / 2, _Digits);
  MediumLine.price(mediumValue).fromCandle(j).redraw();
if(firstValue > secondValue)
{
  HighLine.price(firstValue).fromCandle(j).redraw();
  LowLine.price(secondValue).fromCandle(j).redraw();
}
if(secondValue > firstValue)
{
  HighLine.price(secondValue).fromCandle(j).redraw();
  LowLine.price(firstValue).fromCandle(j).redraw();
}

  //--- done
  return (rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll()
{
  ArrayInitialize(ExtZigzagBuffer, 0.0);
  ArrayInitialize(ExtHighBuffer, 0.0);
  ArrayInitialize(ExtLowBuffer, 0.0);
  //--- first counting position
  return (Bars - InpDepth);
}
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
  MediumLine.erase();
  LowLine.erase();
  HighLine.erase();
  delete MediumLine;
  delete HighLine;
  delete LowLine;
}