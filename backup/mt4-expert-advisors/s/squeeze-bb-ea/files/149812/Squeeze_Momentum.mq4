// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73430

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window

#property indicator_buffers 11
#property indicator_type1   DRAW_NONE



#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrLime
#property indicator_width2  2
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrGreen
#property indicator_width3  2
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrMaroon
#property indicator_width5  2

#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlue
#property indicator_width6  2
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrBlack
#property indicator_width7  2
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrGray
#property indicator_width8  2

#property indicator_type9   DRAW_NONE
#property indicator_type10   DRAW_NONE
#property indicator_type11   DRAW_NONE

input int    length       = 20; //BB Length
input double mult         = 2.0; //BB MultFactor
input int    lengthKC     = 20; //KC Length
input double multKC       = 1.5; //KC MultFactor
input bool   useTrueRange = true; //Use TrueRange (KC)

double range[], no[], On[], Off[], linregsrc[];
double upup[], updn[], dndn[], dnup[], linreg[];
string obj_prefix = "SQZMOM_LB_";

double sqon[];

int OnInit() 
{
   IndicatorDigits(Digits);
   
   SetIndexLabel(0, "range");
   SetIndexBuffer(0, range);
   
   SetIndexLabel(1, "upup (1)");
   SetIndexBuffer(1, upup);
   SetIndexLabel(2, "updn (2)");
   SetIndexBuffer(2, updn);
   SetIndexLabel(3, "dndn (3)");
   SetIndexBuffer(3, dndn);
   SetIndexLabel(4, "dnup (4)");
   SetIndexBuffer(4, dnup);
   
   SetIndexLabel(5, "noSqz (5)");
   SetIndexBuffer(5, no);
   SetIndexArrow(5, 167);
   SetIndexLabel(6, "sqzOn (6)");
   SetIndexBuffer(6, On);
   SetIndexArrow(6, 167);
   SetIndexLabel(7, "sqzOff (7)");
   SetIndexBuffer(7, Off);
   SetIndexArrow(7, 167);
   
   SetIndexLabel(8, "linregsrc");
   SetIndexBuffer(8, linregsrc);
   SetIndexLabel(9, "linreg");
   SetIndexBuffer(9, linreg);
   
	 SetIndexBuffer(10, sqon);

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {

   int startPos = rates_total-prev_calculated-lengthKC-2;
   if (startPos <= 1) { startPos = 1; }
   
   for(int pos=startPos; pos>=0; pos--) {
      // Calculate BB
      double basis   = iMA(NULL, 0, length, 0, MODE_SMA, PRICE_CLOSE, pos);
      double dev     = mult * iStdDev(NULL, 0, length, 0, MODE_SMA, PRICE_CLOSE, pos);
      double upperBB = basis + dev;
      double lowerBB = basis - dev;
      
      // Calculate KC
      double ma      = iMA(NULL, 0, lengthKC, 0, MODE_SMA, PRICE_CLOSE, pos);
      range[pos]     = useTrueRange ? tr(pos) : (high[pos] - low[pos]);
      double rangema = iMAOnArray(range, 0, lengthKC, 0, MODE_SMA, pos);
      double upperKC = ma + rangema * multKC;
      double lowerKC = ma - rangema * multKC;

      bool sqzOn  = (lowerBB > lowerKC) && (upperBB < upperKC);
      bool sqzOff = (lowerBB < lowerKC) && (upperBB > upperKC);
      bool noSqz  = (sqzOn == false) && (sqzOff == false);
      
      double highest = High[iHighest(NULL, 0, MODE_HIGH, lengthKC, pos)];
      double lowest  = Low[iLowest(NULL, 0, MODE_LOW, lengthKC, pos)];
      double sma     = iMA(NULL, 0, lengthKC, 0, MODE_SMA, PRICE_CLOSE, pos);
      
      linregsrc[pos] = Close[pos]-(((highest+lowest)/2)+sma)/2;
      linreg[pos]    = linreg(linregsrc, lengthKC, pos);
      
      //val = linreg(source  -  avg(avg(highest(high, lengthKC), lowest(low, lengthKC)),sma(close,lengthKC)), lengthKC,0);
      
      upup[pos] = linreg[pos] > 0 && linreg[pos] > nz(linreg[pos+1]) ? linreg[pos] : EMPTY_VALUE;
      updn[pos] = linreg[pos] > 0 && linreg[pos] < nz(linreg[pos+1]) ? linreg[pos] : EMPTY_VALUE;
      dndn[pos] = linreg[pos] < 0 && linreg[pos] < nz(linreg[pos+1]) ? linreg[pos] : EMPTY_VALUE;
      dnup[pos] = linreg[pos] < 0 && linreg[pos] > nz(linreg[pos+1]) ? linreg[pos] : EMPTY_VALUE;
      
      no[pos]  = (noSqz == true)  ? 0 : EMPTY_VALUE;
      On[pos]  = (sqzOn == true)  ? 0 : EMPTY_VALUE;
      Off[pos] = (sqzOff == true) ? 0 : EMPTY_VALUE;

      sqon[pos] = (lowerBB > lowerKC) && (upperBB < upperKC) ? 1 : 0;
   }

   return(rates_total);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, obj_prefix);
}

string TimeCleanStr(int pos) {
   string _time = TimeToStr(Time[pos], TIME_DATE|TIME_MINUTES);
   
   StringReplace(_time, ":", "");
   StringReplace(_time, ".", "");
   StringReplace(_time, " ", "");
   
   return _time;
}

double tr(int shift) {
   double t1 = High[shift] - Low[shift];
   double t2 = MathAbs(High[shift] - Close[shift+1]);
   double t3 = MathAbs(Low[shift] - Close[shift+1]);
   
   return MathMax(MathMax(t1, t2), t3);
}

double linreg(double &src[], int p, int i) {
   double SumY  = 0;
   double Sum1  = 0;
   double Slope = 0;
   double c;
   
   for (int x=0; x<=p-1;x++) {
      c = src[x+i];
      SumY += c;
      Sum1 += x*c;
   }
   
   double SumBars    = p*(p-1)*0.5;
   double SumSqrBars = (p-1)*p*(2*p-1)/6;
	double Sum2       = SumBars*SumY;
	double Num1       = p*Sum1-Sum2;
	double Num2       = SumBars*SumBars-p*SumSqrBars;
	if(Num2!=0) {
	   Slope = Num1/Num2;
   }
	else {
	   Slope = 0;
   }
   
	double Intercept = (SumY-Slope*SumBars)/p;
	double linregval = Intercept+Slope*(p-1);
	
	return(linregval);
}

double nz(double check, double val = 0) {
   if (check == EMPTY_VALUE) {
      return val;
   }
   else {
      return check;
   }
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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