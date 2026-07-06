// Id: 15997
//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property indicator_separate_window

//extern int Lookback=50;
extern int scaleX=30,// horizontal interval at which the squares are created
scaleY=30,           // vertical interval
offsetX=60,          // horizontal indent of all squares
offsetY=30,          // vertical indent
fontSize=30;         // font size

extern int MA_MODE1= 0;
extern int MA_MODE2= 0;
extern int MA_Period1= 50;
extern int MA_Period2= 200;
extern int MA_PRICE1= 0;
extern int MA_PRICE2= 0;


extern string Instrument1= "EURUSD";
extern string Instrument2= "USDJPY";
extern string Instrument3= "GBPUSD";
extern string Instrument4= "USDCHF";
extern string Instrument5= "AUSUSD";
extern string Instrument6= "USDCAD";
extern string Instrument7= "NZDUSD";
extern string Instrument8= "EURJPY";
extern string Instrument9= "EURGBP";
extern string Instrument10= "GBPJPY";
string PAIR[]={"1","2","3", "4", "5", "6", "7", "8", "9", "10"}; 
string TF[]={"m1", "m5", "m15","m30", "H1", "H4", "D1", "W1", "MN1"};
string iTF[]={1, 5, 15,30, 60, 240 , 1440, 10080, 43200};

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

int init()
  {
	PAIR[0]= Instrument1;
	PAIR[1]= Instrument2;
	PAIR[2]= Instrument3;
	PAIR[3]= Instrument4;
	PAIR[4]= Instrument5;
	PAIR[5]= Instrument6;
	PAIR[6]= Instrument7;
	PAIR[7]= Instrument8;
	PAIR[8]= Instrument9;
	PAIR[9]= Instrument10;


   IndicatorName = GenerateIndicatorName("MTF_MCP_MA_Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   int windowIndex=WindowFind(IndicatorName);

   if(windowIndex<0)
     {
      // if the subwindow number is -1, there is an error
      Print("Can\'t find window");
      return(0);
     }
 for(int x=0;x<ArraySize(TF);x++)
      for(int y=0;y<ArraySize(PAIR);y++)
        {
         ObjectCreate(IndicatorObjPrefix + "signal"+windowIndex+x+y,OBJ_LABEL,windowIndex,0,0,0,0);
         ObjectSet(IndicatorObjPrefix + "signal"+windowIndex+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
         ObjectSet(IndicatorObjPrefix + "signal"+windowIndex+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
         ObjectSetText(IndicatorObjPrefix + "signal"+windowIndex+x+y,CharToStr(110),fontSize,"Wingdings",Gold);
        }

   for(x=0;x<ArraySize(TF);x++)
     {
      ObjectCreate(IndicatorObjPrefix + "textPeriod"+windowIndex+x,OBJ_LABEL,windowIndex,0,0,0,0);
      ObjectSet(IndicatorObjPrefix + "textPeriod"+windowIndex+x,OBJPROP_XDISTANCE,x*scaleX+offsetX);
      ObjectSet(IndicatorObjPrefix + "textPeriod"+windowIndex+x,OBJPROP_YDISTANCE,offsetY-10);
      ObjectSetText(IndicatorObjPrefix + "textPeriod"+windowIndex+x,TF[x],8,"Tahoma",Blue);
     }

   for(y=0;y<ArraySize(PAIR);y++)
     {
      ObjectCreate(IndicatorObjPrefix + "textSignal"+windowIndex+y,OBJ_LABEL,windowIndex,0,0,0,0);
      ObjectSet(IndicatorObjPrefix + "textSignal"+windowIndex+y,OBJPROP_XDISTANCE,offsetX-50);
      ObjectSet(IndicatorObjPrefix + "textSignal"+windowIndex+y,OBJPROP_YDISTANCE,y*scaleY+offsetY+8);
      ObjectSetText(IndicatorObjPrefix + "textSignal"+windowIndex+y,PAIR[y],8,"Tahoma",Blue);
     }
//---- indicators
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
int windowIndex=WindowFind(IndicatorName); 
int Q;

  
   for(int x=0;x<ArraySize(TF);x++)
   {
      for(int y=0;y<ArraySize(PAIR);y++)
        { 
		
		    Q= Calculate ( x,  y );
			
		  if (Q== 1)		  
          {
		  ObjectSetText(IndicatorObjPrefix + "signal"+x+y,CharToStr(110),fontSize,"Wingdings",Blue);		  
		  }
		  else
		   {      if (Q== -1)		  
				  {
				  ObjectSetText(IndicatorObjPrefix + "signal"+windowIndex+x+y,CharToStr(110),fontSize,"Wingdings",Red);		  
				  }
				  else
				  {
				  ObjectSetText(IndicatorObjPrefix + "signal"+windowIndex+x+y,CharToStr(110),fontSize,"Wingdings",Silver);	
                  }				  
		  }
        }
	}
	

//----
   return(0);
}
  
  int Calculate (int x, int y )
  { 
   
	int Signal=0; 
	double MA1= iMA(PAIR[y],TF[x],MA_Period1,0,MA_MODE1, MA_PRICE1, 0);    
	double MA2= iMA(PAIR[y],TF[x],MA_Period2,0,MA_MODE2, MA_PRICE2, 0);   		 
    
	  if (MA1 >MA2)
	  {
	  Signal=1;
	  }
	  
	  if (MA1 <MA2)
	  {
	  Signal=-1;
	  }
       
      return (Signal);
  }
  
  