// Id: 13756
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

    
	extern color PinBarUpColor = Lime;
	extern color PinBarDownColor = Red;
	
	extern color ShavedBarUpColor = Aqua;
	extern color ShavedBarDownColor = Fuchsia;
	
	extern color InsideBarColor = Yellow;
	extern color OutsideBarColor = Orange; 

    extern bool   ShowPinBars=true;
	extern bool   ShowShavedBars=true;
	extern bool   ShowInsideBars=true;
	extern bool   ShowOutsideBars=true;

	extern double   PercentageInputForPinBars=66;
	extern int  PinBarsLookBackPeriod=6;
	extern double  PercentageInputForShavedBars=5;

	extern bool   TurnRegularBarstoNeutral=true;
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
int init()
  {
   IndicatorName = GenerateIndicatorName("BARS_IDENTIFIER");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   int windowIndex=WindowFind(IndicatorName);
   if(windowIndex<0)
     {
      // if the subwindow number is -1, there is an error
      Print("Can\'t find window");
      return(0);
     }
//---- indicator buffers mapping  
   
//---- initialization done   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
	
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
 
	  if(Bars<=3) return(0);
	 int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(-1);
	 int pos;
	 int limit=Bars-2;
	 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
	 pos=limit;
	 
	 
	double PinBars=PercentageInputForPinBars*0.01;	 
	double ShavedBars=PercentageInputForShavedBars*0.01;
   
   while(pos>=0) 
     {
  
      double Range = High[pos] - Low[pos];
	  bool PinBarUp = false;
	  bool PinBarDown = false;
	  
	  bool ShavedBarUp = false;
	  bool ShavedBarDown = false;
	  
	   bool InsideBar = false; 	  
	   bool OutsideBar = false; 
	  
	  double Min, Max;
	  
	   Max=iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,PinBarsLookBackPeriod,pos));
       Min=iLow(Symbol(),Period(),iLowest(Symbol(),Period(),MODE_LOW,PinBarsLookBackPeriod,pos));
	  
	  if (ShowPinBars)
	  {
			if ((Open[pos] > High[pos] - (Range * PinBars)) && ( Close[pos] > High[pos] - (Range * PinBars)) && (Low[pos] <= Min)) 
			{
			PinBarUp=true;
			}
			
			if  ((Open[pos] < High[pos] - (Range *  PinBars)) &&  (Close[pos] < High[pos]-(Range * PinBars)) && (High[pos] >= Max))
			{
			PinBarDown=true;
			}
			
	  }
	  
	    if (ShowShavedBars)
	  {
              if (Close[pos] >= (High[pos] - (Range * ShavedBars)))  
			  {
			  ShavedBarUp=true;
			  }
			  if (Close[pos] <= (Low[pos] + (Range * ShavedBars))) 
			  {
			  ShavedBarDown=true;
			  }			
	  }
	  
	  
	 
	if (ShowInsideBars ) 
	{
	 if ( High[pos] <= High[pos+1] && Low[pos] >= Low[pos+1] )
	 {
	 InsideBar= true;
	 }
	}

 
	if (ShowOutsideBars ) 
	{
	  if (High[pos] > High[pos+1] && Low[pos] < Low[pos+1]  )
	  {
	  OutsideBar= true;
	  }
	  
	}
	
	  

    
		 if (PinBarUp)
		 {
		 objText(TimeToStr(Time[pos]), "PBU", Time[pos], Low[pos], 0, PinBarUpColor,  "Arial", 12);
		 }
         else if (PinBarDown) 
		 {
         objText(TimeToStr(Time[pos]), "PBD", Time[pos], High[pos], 0, PinBarDownColor,  "Arial", 12);
		 }
		 
		 
		 if (ShavedBarUp)
		 {
		  objText(TimeToStr(Time[pos]), "SBU", Time[pos], Low[pos], 0, ShavedBarUpColor,  "Arial", 12);
		 }
         else if (ShavedBarDown) 
		 {
         objText(TimeToStr(Time[pos]), "SBD", Time[pos], High[pos], 0, ShavedBarDownColor,  "Arial", 12);
		 }
		 
		 
		  if (InsideBar)
		 {
		 objText(TimeToStr(Time[pos]), "IB", Time[pos], Low[pos], 0, InsideBarColor,  "Arial", 12);
		 }
        
		 
		 
		 if (OutsideBar)
		 {
		  objText(TimeToStr(Time[pos]), "OB", Time[pos], Low[pos], 0, OutsideBarColor,  "Arial", 12);
		 }
       
		 
		 pos--;
		 
	 }
   return(0);
  }
  
 
void objText(string name, string tex, datetime time, double price, int window=0, color tex_color=White, string tex_font="Arial", int tex_size=12)
  {
    int windowIndex=WindowFind(IndicatorName);
   if(ObjectFind(IndicatorObjPrefix + name+windowIndex)==-1)
   {
      ObjectCreate(IndicatorObjPrefix + name+windowIndex, OBJ_TEXT, window, time, price);
   }
   ObjectSet(IndicatorObjPrefix + name+windowIndex, OBJPROP_TIME1, time);
   ObjectSet(IndicatorObjPrefix + name+windowIndex, OBJPROP_PRICE1, price);
   ObjectSetText(IndicatorObjPrefix + name+windowIndex, tex, tex_size, tex_font, tex_color);
  }