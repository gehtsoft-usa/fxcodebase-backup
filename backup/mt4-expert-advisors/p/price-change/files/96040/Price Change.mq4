//+------------------------------------------------------------------+
//|                                                Price Change.mq4  |
//|                               Copyright � 2014, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0

input int CalculationMode=1; 

input color  Up=clrGreen;
input color  Down=clrFireBrick;
input color  Label=16777215;
//input int SortBy =5;
  
int NumberOfInstrumnets;
int ShortNameIs;
int ObjectID;
string Font = "Tahoma";
string Instrument[];
 
int NumberofTimeFrames;
double PipSize[];
string TF[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
string ShortName;

//string gsa_188[];
//int gi_176;
int gi_248;
//string gs_232;

//+------------------------------------------------------------------+
//| Creates the array of pair symbols to check                       |
//+------------------------------------------------------------------+   
int CreateSymbolList()
  {
   int CurrencyCount;
    CurrencyCount= SymbolsTotal(true);
	string TempSymbol;
   int Loop;
   for(Loop = 0; Loop < CurrencyCount; Loop++)
          {
		  
		      TempSymbol=SymbolName(Loop, true);
               ArrayResize(Instrument, Loop + 1);
               Instrument[Loop] = TempSymbol;    
			    ArrayResize(PipSize, Loop + 1);
               PipSize[Loop] = MarketInfo(TempSymbol, MODE_POINT);			   
             
             
          
         }
   return(0);
  }

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


int init() {
 
  // string ls_24;
   gi_248 = 0;
   ShortName = "MLD";
  
  
  if(! (CalculationMode >= 1 && CalculationMode <= 2  )  ) 
   {
   Alert("Permitted CalculationMode are 1 and 2");

   return(-1);
   }
   
   IndicatorName = GenerateIndicatorName(ShortName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   ShortName = IndicatorName;
    CreateSymbolList();
   
   
   NumberofTimeFrames = ArraySize(TF);
   NumberOfInstrumnets = ArraySize(Instrument);
   
   return (0);
}

int deinit() {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

int start() {
   ObjectID=0;
   ShortNameIs = WindowFind(ShortName);
  
   int InstrumentNumber; 
   int TFNumber;
   for (  InstrumentNumber = 0; InstrumentNumber < NumberOfInstrumnets; InstrumentNumber += 1) {
   	  
	   setObject(next(),   Instrument[InstrumentNumber], 40, 40+ InstrumentNumber*20, Label, Font, 10);
	  
   }
   
   for ( TFNumber = 0; TFNumber < NumberofTimeFrames; TFNumber += 1) {
      setObject(next(),  TF[TFNumber] , 125+ TFNumber*75, 20, Label, Font, 10);
   
   }
;
	double Array[100][8];
   double OpenPrice;
   double ClosePrice;
   double value;
 
   int Count=0;
    for (  InstrumentNumber = 0; InstrumentNumber < NumberOfInstrumnets; InstrumentNumber += 1)  
	{
		for ( TFNumber = 0; TFNumber < NumberofTimeFrames; TFNumber += 1)  
		{ 
		
		   
		  ClosePrice= iClose(Instrument[InstrumentNumber], stringToTimeFrame(TF[TFNumber]), 0);
          OpenPrice = iOpen(Instrument[InstrumentNumber],stringToTimeFrame(TF[TFNumber]), 0);
		  
		  
		      
		     if (CalculationMode == 1 )
			 {
				 
				  if (OpenPrice!=0 ) 
				  {
				  value= (ClosePrice-OpenPrice)/(OpenPrice/100);
				  }
				  else
				  {
				  value=0;
				  }
			 
			 }
			 else if (CalculationMode == 2 )
			 {
			  value= (ClosePrice-OpenPrice)/PipSize[InstrumentNumber];			  
			 }
		 
			Count=Count+1;
		 
			 Array[InstrumentNumber ] [TFNumber]=value;
			
		}
	}
	int X;
	int Y;
	string Output;
	Count=0;
	
	  for (  InstrumentNumber = 0; InstrumentNumber < NumberOfInstrumnets; InstrumentNumber += 1)  
	{
		for ( TFNumber = 0; TFNumber < NumberofTimeFrames; TFNumber += 1)  
		{ 

		Count=Count+1;
		Output =DoubleToStr( Array[InstrumentNumber ] [TFNumber],4);
		
		X= 125+ TFNumber*75;
		Y=40+ InstrumentNumber*20;
		      
			  if (Array[InstrumentNumber ] [TFNumber] > 0)
			  {
		      setObject(next(), Output, X, Y, Up, Font, 10);
			  }
			  else
			  {
			  setObject(next(), Output, X, Y, Down, Font, 10);
			  }
		}
		
	}
   
   
   return (0);
}


string next() {
   ObjectID++;
   return (ObjectID);
}



void setObject(string as_0, string as_8, int ai_16, int ai_20, color ai_24, string as_28 = "Verdana", int ai_36 = 10, int ai_40 = 0 ) {
   string ls_44 = StringConcatenate(IndicatorObjPrefix, as_0);
   if (ObjectFind(ls_44) == -1) {
      ObjectCreate(ls_44, OBJ_LABEL, ShortNameIs, 0, 0);
      ObjectSet(ls_44, OBJPROP_CORNER, gi_248);
      if (ai_40 != 0) ObjectSet(ls_44, OBJPROP_ANGLE, ai_40);
   }
   ObjectSet(ls_44, OBJPROP_XDISTANCE, ai_16);
   ObjectSet(ls_44, OBJPROP_YDISTANCE, ai_20);
   ObjectSetText(ls_44, as_8, ai_36, as_28, ai_24);
}

int stringToTimeFrame(string as_0) {
   int li_8 = 0;
   //as_0 = StringTrimLeft(StringTrimRight(StringUpperCase(as_0)));
   
   if (as_0 == "M1" || as_0 == "1") li_8 = 1;
   if (as_0 == "M5" || as_0 == "5") li_8 = 5;
   if (as_0 == "M15" || as_0 == "15") li_8 = 15;
   if (as_0 == "M30" || as_0 == "30") li_8 = 30;
   if (as_0 == "H1" || as_0 == "60") li_8 = 60;
   if (as_0 == "H4" || as_0 == "240") li_8 = 240;
   if (as_0 == "D1" || as_0 == "1440") li_8 = 1440;
   if (as_0 == "W1" || as_0 == "10080") li_8 = 10080;
   if (as_0 == "MN1" || as_0 == "43200") li_8 = 43200;
   return (li_8);
}

string TimeFrameToString(int ai_0) {
   string ls_4;
   switch (ai_0) {
   case 1:
      ls_4 = "M1";
      break;
   case 5:
      ls_4 = "M5";
      break;
   case 15:
      ls_4 = "M15";
      break;
   case 30:
      ls_4 = "M30";
      break;
   case 60:
      ls_4 = "H1";
      break;
   case 240:
      ls_4 = "H4";
      break;
   case 1440:
      ls_4 = "D1";
      break;
   case 10080:
      ls_4 = "W1";
      break;
   case 43200:
      ls_4 = "MN1";
   }
   return (ls_4);
}

string StringUpperCase(string as_0) {
   int li_20;
   string ls_8 = as_0;
   for (int li_16 = StringLen(as_0) - 1; li_16 >= 0; li_16--) {
      li_20 = StringGetChar(ls_8, li_16);
      if ((li_20 > '`' && li_20 < '{') || (li_20 > '�' && li_20 < 256)) ls_8 = StringSetChar(ls_8, li_16, li_20 - 32);
      else
         if (li_20 > -33 && li_20 < 0) ls_8 = StringSetChar(ls_8, li_16, li_20 + 224);
   }
   return (ls_8);
}
