// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76217

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_separate_window
#property indicator_buffers    8
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

#define version            "v1.0.3.1"
#define EPSILON            0.00000001
#define CURRENCYCOUNT      8

//
//
//
//
//
extern int     BARS                 = 500;
extern string  gen                   = "----General inputs----";
extern bool    autoSymbols           = false;
extern string	symbolsToWeigh        = "GBPNZD,EURNZD,GBPAUD,GBPCAD,GBPJPY,GBPCHF,CADJPY,EURCAD,EURAUD,USDCHF,GBPUSD,EURJPY,NZDJPY,AUDCHF,AUDJPY,USDJPY,EURUSD,NZDCHF,CADCHF,AUDNZD,NZDUSD,CHFJPY,AUDCAD,USDCAD,NZDCAD,AUDUSD,EURCHF,EURGBP";
extern string  nonPropFont           = "Lucida Console";
extern bool    showOnlySymbolOnChart = true;

extern string  ind                   = "----Indicator inputs----";
extern double  HalfLength            = 20;
extern int     Price                 = PRICE_WEIGHTED;
extern bool    autoTimeFrame         = true;
extern string  ind_tf                = "timeFrame M1,M5,M15,M30,H1,H4,D1,W1,MN";
extern string  timeFrame             = "D1";
extern bool    ignoreFuture          = false;
extern bool    showCrossAlerts       = true;
extern double  differenceThreshold   = 0.8;

extern string  cur                   = "----Currency inputs----";
extern bool    USD                   = true;
extern bool    EUR                   = true;
extern bool    GBP                   = true;
extern bool    CHF                   = true;
extern bool    JPY                   = true;
extern bool    AUD                   = true;
extern bool    CAD                   = true;
extern bool    NZD                   = true;

extern string  col                   = "----Color inputs----";
extern color   Color_USD             = Green;
extern color   Color_EUR             = DeepSkyBlue;
extern color   Color_GBP             = Red;
extern color   Color_CHF             = Chocolate;
extern color   Color_JPY             = FireBrick;
extern color   Color_AUD             = DarkOrange;
extern color   Color_CAD             = Purple;
extern color   Color_NZD             = Teal;
extern color   colorWeakCross        = OrangeRed;
extern color   colorNormalCross      = Gold;
extern color   colorStrongCross      = LimeGreen;
extern color   colorDifference       = 0x303000;
extern int     Line_Thickness        = 2;

// 
//
//
//
//

string   indicatorName = "CurrencySlopeStrength";
string   shortName;
int      userTimeFrame;
string   almostUniqueIndex;

//
//
//
//
//

double   arrUSD[];
double   arrEUR[];
double   arrGBP[];
double   arrCHF[];
double   arrJPY[];
double   arrAUD[];
double   arrCAD[];
double   arrNZD[];

//
//
//
//
//

int      symbolCount;
string   symbolNames[];
string   currencyNames[CURRENCYCOUNT]        = { "USD", "EUR", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD" };
double   currencyValues[CURRENCYCOUNT];      // Currency slope strength
double   currencyValuesPrior[CURRENCYCOUNT]; // Currency slope strength prior bar
double   currencyOccurrences[CURRENCYCOUNT]; // Holds the number of occurrences of each currency in symbols
color    currencyColors[CURRENCYCOUNT];

//
//
//
//
//

int      verticalShift    = 14;
int      verticalOffset   = 30;
int      horizontalShift  = 100;
int      horizontalOffset = 10;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{
   HalfLength = MathMax(HalfLength,1);
   initSymbols();
   
   SetIndexBuffer(0,arrUSD); SetIndexLabel(0,"USD"); currencyColors[0] = Color_USD; 
   SetIndexBuffer(1,arrEUR); SetIndexLabel(1,"EUR"); currencyColors[1] = Color_EUR;
   SetIndexBuffer(2,arrGBP); SetIndexLabel(2,"GBP"); currencyColors[2] = Color_GBP; 
   SetIndexBuffer(3,arrCHF); SetIndexLabel(3,"CHF"); currencyColors[3] = Color_CHF;
   SetIndexBuffer(4,arrJPY); SetIndexLabel(4,"JPY"); currencyColors[4] = Color_JPY;
   SetIndexBuffer(5,arrAUD); SetIndexLabel(5,"AUD"); currencyColors[5] = Color_AUD; 
   SetIndexBuffer(6,arrCAD); SetIndexLabel(6,"CAD"); currencyColors[6] = Color_CAD;
   SetIndexBuffer(7,arrNZD); SetIndexLabel(7,"NZD"); currencyColors[7] = Color_NZD; 
   SetLevelValue(0,0);

   string now = TimeCurrent();
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3);
   
   shortName = indicatorName + " - " + version;
   IndicatorShortName(shortName);
   return(0);
}

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
//
//

int initSymbols()
{
   int i;
   string symbolExtraChars = StringSubstr(Symbol(),6,4);

   // 
   //
   //
   //
   //
   
   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

   // 
   //
   //
   //
   //
   
   if (StringSubstr(symbolsToWeigh, StringLen(symbolsToWeigh)-1) != ",")
   {
      symbolsToWeigh = StringConcatenate(symbolsToWeigh, ",");   
   }   

   //
   //
   //
   //
   //
   
   if (autoSymbols)
   {
      createSymbolNamesArray();
   }
   else
   {
    
      i = StringFind(symbolsToWeigh, ","); 
      while (i != -1)
      {
         int size = ArraySize(symbolNames);
        
         ArrayResize(symbolNames, size + 1);
    
         symbolNames[size] = StringConcatenate(StringSubstr(symbolsToWeigh, 0, i),symbolExtraChars);
         
         symbolsToWeigh = StringSubstr(symbolsToWeigh, i + 1);
         i = StringFind(symbolsToWeigh, ","); 
      }
   }
   
   // 
   //
   //
   //
   //
   
   if (showOnlySymbolOnChart)
   {
      symbolCount = ArraySize(symbolNames);
      string tempNames[];
      for (i = 0; i < symbolCount; i++)
      {
         for (int j = 0; j < CURRENCYCOUNT; j++)
         {
            if (StringFind( Symbol(), currencyNames[j] ) == -1)
            {
               break;
            }
            if (StringFind(symbolNames[i], currencyNames[j] ) != -1)
            {  
               size = ArraySize(tempNames);
               ArrayResize(tempNames, size + 1);
               tempNames[size] = symbolNames[i];
               break;
            }
         }
      }
      for (i = 0; i < ArraySize(tempNames); i++)
      {
         ArrayResize(symbolNames, i+1);
         symbolNames[i] = tempNames[i];
      }
   }
   
   symbolCount = ArraySize(symbolNames);

   for (i = 0; i < symbolCount; i++)
   {
      int currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i],0,3));
          currencyOccurrences[currencyIndex]++;
          
          currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i],3,3));
          currencyOccurrences[currencyIndex]++;
   }   
   
   //
   //
   //
   //
   //
   
   userTimeFrame = PERIOD_D1;
   if (autoTimeFrame)   {  userTimeFrame = Period();   }   
	else 
	{ 
	          if (timeFrame == "M1" ) userTimeFrame = PERIOD_M1;
		else   if (timeFrame == "M5" ) userTimeFrame = PERIOD_M5;
		else   if (timeFrame == "M15") userTimeFrame = PERIOD_M15;
		else   if (timeFrame == "M30") userTimeFrame = PERIOD_M30;
		else   if (timeFrame == "H1" ) userTimeFrame = PERIOD_H1;
		else   if (timeFrame == "H4" ) userTimeFrame = PERIOD_H4;
		else   if (timeFrame == "D1" ) userTimeFrame = PERIOD_D1;
		else   if (timeFrame == "W1" ) userTimeFrame = PERIOD_W1;
		else   if (timeFrame == "MN" ) userTimeFrame = PERIOD_MN1;
   } 
		
}

//+------------------------------------------------------------------+
//| GetCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
//
//

int GetCurrencyIndex(string currency)
{
   for (int i = 0; i < CURRENCYCOUNT; i++)
   {
      if (currencyNames[i] == currency)
      {
         return(i);
      }   
   }   
   return (-1);
}

//+------------------------------------------------------------------+
//| createSymbolNamesArray()                                         |
//+------------------------------------------------------------------+
//
//

void createSymbolNamesArray()
{
   int hFileName   = FileOpenHistory ("symbols.raw", FILE_BIN|FILE_READ);
   int recordCount = FileSize (hFileName) / 1936;
   int counter = 0;
   
   //
   //
   //
   //
   //
   
   for (int i = 0; i < recordCount; i++)
   {
      string tempSymbol = StringTrimLeft (StringTrimRight (FileReadString (hFileName, 12)));
      if (MarketInfo (tempSymbol, MODE_BID) > 0 && MarketInfo (tempSymbol, MODE_TRADEALLOWED))
      {
         ArrayResize(symbolNames, counter + 1);
         symbolNames[counter] = tempSymbol;
         counter++;
      }
      FileSeek(hFileName, 1924, SEEK_CUR);
   }
   FileClose(hFileName);
return (0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
//
//

int deinit()
{

   int windex = WindowFind (shortName);
   if (windex > 0)
   {
      ObjectsDeleteAll (windex);
   }   

   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,j,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);
    if(limit>BARS)limit=BARS;
   //
   //
   //
   //
   //
   
   for ( i = limit; i >= 0; i-- )
   { 
   
      for (j = 0; j < CURRENCYCOUNT; j++) { SetIndexStyle(j,DRAW_LINE,STYLE_SOLID,Line_Thickness,currencyColors[j]); }   

      int    index;
      double diff = 0.0;
      
      ArrayInitialize(currencyValues, 0.0); 
      CalculateCurrencySlopeStrength(userTimeFrame,i);
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"USD") != -1)) || (!showOnlySymbolOnChart && USD))        
      {
         arrUSD[i]           = currencyValues[0];
         if (diff ==0) diff += currencyValues[0]; 
         else          diff -= currencyValues[0];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"EUR") != -1)) || (!showOnlySymbolOnChart && EUR))        
      {
         arrEUR[i]            = currencyValues[1];
         if (diff == 0) diff += currencyValues[1]; 
         else           diff -= currencyValues[1];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"GBP") != -1)) || (!showOnlySymbolOnChart && GBP))        
      {
         arrGBP[i]            = currencyValues[2];
         if (diff == 0) diff += currencyValues[2]; 
         else           diff -= currencyValues[2];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"CHF")!= -1)) || (!showOnlySymbolOnChart && CHF))        
      {
         arrCHF[i]            = currencyValues[3];
         if (diff == 0) diff += currencyValues[3];
         else           diff -= currencyValues[3];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"JPY")!= -1)) || (!showOnlySymbolOnChart && JPY))        
      {
         arrJPY[i]            = currencyValues[4];
         if (diff == 0) diff += currencyValues[4]; 
         else           diff -= currencyValues[4];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"AUD" )!= -1)) || ( !showOnlySymbolOnChart && AUD ) )        
      {
         arrAUD[i]            = currencyValues[5];
         if (diff == 0) diff += currencyValues[5]; 
         else           diff -= currencyValues[5];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"CAD")!= -1)) || (!showOnlySymbolOnChart && CAD))        
      {
         arrCAD[i]            = currencyValues[6];
         if (diff == 0) diff += currencyValues[6]; 
         else           diff -= currencyValues[6];
      }
      
      //
      //
      //
      //
      //
      
      if ((showOnlySymbolOnChart && (StringFind(Symbol(),"NZD")!= -1)) || (!showOnlySymbolOnChart && NZD))        
      {
         arrNZD[i]            = currencyValues[7];
         if (diff == 0) diff += currencyValues[7]; 
         else           diff -= currencyValues[7];
      }
      
      //
      //
      //
      //
      //
      
      if ( i == 1 )
      {
         ArrayCopy(currencyValuesPrior,currencyValues);
      }
      if ( i == 0 )
      {
       
         ShowCurrencyTable();
      }
      
      //
      //
      //
      //
      //
      
      if (showOnlySymbolOnChart && MathAbs(diff) > differenceThreshold)
      {
         int windex = WindowFind (shortName);
         string objectName = almostUniqueIndex + "_diff_" + i;
         if ( ObjectFind (objectName) == -1)
         {
            if (ObjectCreate (objectName, OBJ_VLINE, windex, Time[i], 0))
            {
               ObjectSet (objectName, OBJPROP_COLOR, colorDifference);
               ObjectSet (objectName, OBJPROP_BACK, true);
               ObjectSet (objectName, OBJPROP_WIDTH, 8);
               
            }
         }
       
      }

   }
   
   return(0);
}

//+------------------------------------------------------------------+
//| GetSlope()                                                       |
//+------------------------------------------------------------------+
//
//

double GetSlope(string symbol, int tf, int shift)
{
   double dblTma, dblPrev;
   double gadblSlope = 0.0;
   
   //
   //
   //
   //
   //
   
   double atr = iATR(symbol,tf,100,shift+10) / 10;
   
   if (atr != 0)
   {
      if (ignoreFuture)
      {
         dblTma     = calcTmaTrue( symbol, tf, shift);
         dblPrev    = calcPrevTrue(symbol, tf, shift);
      }
      else
      {   
         dblTma     = calcTma(symbol,tf,shift);
         dblPrev    = calcTma(symbol,tf,shift+1);
      }   
         gadblSlope = (dblTma - dblPrev) / atr;
   }
   
return (gadblSlope);

}

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
//
//

double calcTma(string symbol, int tf,  int shift)
{
   int jnx, knx;
   
   //
   //
   //
   //
   //
   
   double dblSum  = (HalfLength+1) * iMA(symbol,tf,1,0,MODE_SMA,Price,shift);
   double dblSumw = (HalfLength+1);
   
         
   for (jnx = 1, knx = HalfLength; jnx <= HalfLength; jnx++, knx--)
   {
      dblSum  += iMA(symbol,tf,1,0,MODE_SMA,Price,shift+jnx)*knx;
      dblSumw += knx;

      if (jnx <= shift)
      {
         dblSum  += iMA(symbol,tf,1,0,MODE_SMA,Price,shift-jnx)*knx;
         dblSumw += knx;
      }
   }
   
return (dblSum/dblSumw);
}


//+------------------------------------------------------------------+
//| calcTmaTrue()                                                    |
//+------------------------------------------------------------------+
//
//

double calcTmaTrue(string symbol, int tf, int inx )
{
   return (iMA(symbol,tf,HalfLength,0, MODE_LWMA, PRICE_CLOSE,inx));
}

//+------------------------------------------------------------------+
//| calcPrevTrue()                                                   |
//+------------------------------------------------------------------+
//
//

double calcPrevTrue( string symbol, int tf, int inx )
{
   double dblSum  = (HalfLength+1) * iMA(symbol,tf,1,0,MODE_SMA,Price,inx+1);
   double dblSumw = (HalfLength+1);
   int jnx, knx;
   
   dblSum  += HalfLength * iMA(symbol,tf,1,0,MODE_SMA,Price,inx);
   dblSumw += HalfLength;
         
   for ( jnx = 1, knx = HalfLength; jnx <= HalfLength; jnx++, knx-- )
   {
      dblSum  += iMA(symbol,tf,1,0,MODE_SMA,Price,inx+1+jnx ) * knx;
      dblSumw += knx;
   }
   
return (dblSum/dblSumw);
}
 
//+------------------------------------------------------------------+
//| CalculateCurrencySlopeStrength(int tf, int shift                 |
//+------------------------------------------------------------------+
//
//

void CalculateCurrencySlopeStrength(int tf, int shift)
{
   int i;
   
   //
   //
   //
   //
   //
   
   for ( i = 0; i < symbolCount; i++)
   {
      double slope = GetSlope(symbolNames[i], tf, shift);
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i],0,3))] += slope;
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i],3,3))] -= slope;
   }
   for (i = 0; i < CURRENCYCOUNT; i++) {  currencyValues[i] /= currencyOccurrences[i]; }
}

//+------------------------------------------------------------------+
//| ShowCurrencyTable()                                              |
//+------------------------------------------------------------------+
//
//

void ShowCurrencyTable()
{
   int    i;
   int    tempValue;
   string objectName;
   string showText;
   color  showColor;
   int    windex = WindowFind (shortName);
   
   //
   //
   //
   //
   //
   
   if (showOnlySymbolOnChart)
   {
      for (i = 0; i < 2; i++)
      {
         int index  = GetCurrencyIndex(StringSubstr(Symbol(),3*i,3));
         objectName = almostUniqueIndex + "_css_obj_column_currency_" + i;
         
         if (ObjectFind (objectName) == -1)
         {
            if (ObjectCreate (objectName, OBJ_LABEL, windex, 0, 0))
            {
               ObjectSet (objectName, OBJPROP_CORNER,1);
               ObjectSet (objectName, OBJPROP_XDISTANCE,  horizontalShift * 0 + horizontalOffset + 70);
               ObjectSet (objectName, OBJPROP_YDISTANCE, (verticalShift + 6) * i + verticalOffset - 18);
            }
         }
         ObjectSetText (objectName, currencyNames[index], 14, nonPropFont, currencyColors[index]);

         objectName = almostUniqueIndex + "_css_obj_column_value_" + i;
         if (ObjectFind (objectName ) == -1)
         {
            if (ObjectCreate (objectName, OBJ_LABEL, windex, 0, 0))
            {
               ObjectSet (objectName, OBJPROP_CORNER, 1);
               ObjectSet (objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 65 + 70);
               ObjectSet (objectName, OBJPROP_YDISTANCE, (verticalShift + 6) * i + verticalOffset - 18);
            }
         }
         showText = RightAlign(DoubleToStr(currencyValues[index], 2), 5);
         ObjectSetText (objectName, showText, 14, nonPropFont, currencyColors[index]);
      }
      objectName = almostUniqueIndex + "_css_obj_column_currency_3";
      if (ObjectFind ( objectName ) == -1)
      {
         if (ObjectCreate (objectName, OBJ_LABEL, windex, 0, 0))
         {
            ObjectSet (objectName, OBJPROP_CORNER, 1);
            ObjectSet (objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 5);
            ObjectSet (objectName, OBJPROP_YDISTANCE, (verticalShift + 6) * 2 + verticalOffset - 10);
         }
      }
      showText = "threshold = " + DoubleToStr(differenceThreshold, 1);
      ObjectSetText (objectName, showText, 8, nonPropFont, Yellow);
   }
   else
   {
     
      double tempCurrencyValues[CURRENCYCOUNT][3];
   
      for (i = 0; i < CURRENCYCOUNT; i++)
      {
         tempCurrencyValues[i][0] = currencyValues[i];
         tempCurrencyValues[i][1] = NormalizeDouble(currencyValuesPrior[i], 2);
         tempCurrencyValues[i][2] = i;
      }
   
      ArraySort(tempCurrencyValues, WHOLE_ARRAY, 0, MODE_DESCEND);

      int horizontalOffsetCross = 0;
      for (i = 0; i < CURRENCYCOUNT; i++)
      {
         objectName = almostUniqueIndex + "_css_obj_column_currency_" + i;
         if (ObjectFind (objectName ) == -1)
         {
            if (ObjectCreate (objectName, OBJ_LABEL, windex, 0, 0))
            {
               ObjectSet (objectName, OBJPROP_CORNER, 1);
               ObjectSet (objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 150);
               ObjectSet (objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18);
            }
         }
         tempValue = tempCurrencyValues[i][2];
         showText = currencyNames[tempValue];
         ObjectSetText (objectName, showText, 12, nonPropFont, currencyColors[tempValue]);

         objectName = almostUniqueIndex + "_css_obj_column_value_" + i;
         if (ObjectFind ( objectName ) == -1)
         {
            if (ObjectCreate (objectName, OBJ_LABEL, windex, 0, 0))
            {
               ObjectSet (objectName, OBJPROP_CORNER, 1 );
               ObjectSet (objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 55 + 150);
               ObjectSet (objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18);
            }
         }
         showText = RightAlign(DoubleToStr(tempCurrencyValues[i][0], 2), 5);
         ObjectSetText (objectName, showText, 12, nonPropFont, currencyColors[tempValue]);
      
         // 
         //
         //
         //
         //
         
         objectName = almostUniqueIndex + "_css_obj_column_cross_" + i;
         if (showCrossAlerts && i < CURRENCYCOUNT-1 && NormalizeDouble(tempCurrencyValues[i][0],2) > NormalizeDouble(tempCurrencyValues[i+1][0],2)
              && tempCurrencyValues[i][1] < tempCurrencyValues[i+1][1])
         {
            showColor = colorStrongCross;
              if (tempCurrencyValues[i][0] > 0.8 || tempCurrencyValues[i+1][0] < -0.8 ) { showColor = colorWeakCross;   }
         else if (tempCurrencyValues[i][0] > 0.4 || tempCurrencyValues[i+1][0] < -0.4 ) { showColor = colorNormalCross; }
      
            //
            //
            //
            //
            //
            
            DrawCell(windex,objectName,horizontalShift*0 + horizontalOffset + 88 + horizontalOffsetCross, (verticalShift + 2) * i + verticalOffset - 20, 1, 27, showColor );
      
            if (horizontalOffsetCross == 0) { horizontalOffsetCross = -4; }
            else                            { horizontalOffsetCross = 0;  }
            }
            else                            { DeleteCell(objectName);
                                              horizontalOffsetCross = 0;  }
            }
      }
}

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
//
//

string RightAlign (string text, int length = 10, int trailing_spaces = 0)
{
   string text_aligned = text;
   for (int i = 0; i < length - StringLen (text) - trailing_spaces; i++)
   {
      text_aligned = " " + text_aligned;
   }
   return (text_aligned);
}

//+------------------------------------------------------------------+
//| DrawCell(), credits go to Alexandre A. B. Borela                 |
//+------------------------------------------------------------------+
//
//

void DrawCell (int nWindow, string nCellName, double nX, double nY, double nWidth, double nHeight, color nColor)
{
   double   iHeight, iWidth, iXSpace;
   int      iSquares, i;

   if (nWidth > nHeight)
   {
      iSquares = MathCeil (nWidth / nHeight); 
      iHeight  = MathRound((nHeight *100) / 77);
      iWidth   = MathRound((nWidth * 100) / 77); 
      iXSpace  = iWidth / iSquares - ((iHeight / (9 - (nHeight / 100))) * 2);

      for (i = 0; i < iSquares; i++)
      {
         ObjectCreate   (nCellName + i, OBJ_LABEL, nWindow, 0, 0);
         ObjectSetText  (nCellName + i, CharToStr ( 110 ), iHeight, "Wingdings", nColor);
         ObjectSet      (nCellName + i, OBJPROP_CORNER, 1);
         ObjectSet      (nCellName + i, OBJPROP_XDISTANCE, nX + iXSpace * i);
         ObjectSet      (nCellName + i, OBJPROP_YDISTANCE, nY);
         ObjectSet      (nCellName + i, OBJPROP_BACK, true);
      }
   }
   else
   {
      iSquares = MathCeil (nHeight / nWidth); 
      iHeight  = MathRound ((nHeight* 100) / 77); 
      iWidth   = MathRound ((nWidth * 100) / 77); 
      iXSpace  = iHeight / iSquares - ((iWidth / (9 - (nWidth / 100))) * 2);

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   (nCellName + i, OBJ_LABEL, nWindow, 0, 0);
         ObjectSetText  (nCellName + i, CharToStr (110), iWidth, "Wingdings", nColor);
         ObjectSet      (nCellName + i, OBJPROP_CORNER, 1);
         ObjectSet      (nCellName + i, OBJPROP_XDISTANCE, nX);
         ObjectSet      (nCellName + i, OBJPROP_YDISTANCE, nY + iXSpace * i);
         ObjectSet      (nCellName + i, OBJPROP_BACK, true);
      }
   }
}

//+------------------------------------------------------------------+
//| DeleteCell()                                                     |
//+------------------------------------------------------------------+
//
//

void DeleteCell(string name)
{
   int square = 0;
   while (ObjectFind(name + square) > -1)
   {
      ObjectDelete(name + square);
      square++;
   }   
}


// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76217

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+