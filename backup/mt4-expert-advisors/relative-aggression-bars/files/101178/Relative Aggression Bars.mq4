//+------------------------------------------------------------------+
//|                                     Relative Aggression Bars.mq4 |
//|                               Copyright � 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
//#property indicator_buffers 1
#property indicator_chart_window
    
	extern color Moderate_Buying_Aggression = Lime;
	extern color Strong_Buying_Aggression = Green;	
	extern color Extrem_Buying_Aggression = DarkGreen;

	extern color Moderate_Selling_Aggression = Pink;
	extern color Strong_Selling_Aggression = Red;	
	extern color Extrem_Selling_Aggression = Maroon;
	
	extern int Method=0;
  
    extern double Period=14;
  
 	extern double Extrem_Level=5;
	extern double Strong_Level=10;
	extern double Moderate_Level=20;

    double DATA[];
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
   IndicatorName = GenerateIndicatorName(RelativeAggressionBars);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   int windowIndex=WindowFind(IndicatorName);
   IndicatorBuffers(1);   
   SetIndexBuffer(0,DATA);
   SetIndexStyle(0,DRAW_NONE);
   
     if(! (Method >= 0 && Method <= 4  )  ) 
   {
   Alert("Permitted Price_Modes are between 0 and 4");

   return(-1);
   }
   
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
	double max;
    double value;
    double ATR0;
	double ATR1;
	
   while(pos>=0) 
     { 
		
		// "AVolume";		
		if (Method== 0)
		{ 
		 DATA[pos]=Volume[pos];
		 value=Volume[pos]; 
		}
		
		 //"ATR"	
		if (Method== 1)
		{
        ATR0=iATR(NULL,0,Period,pos); 
		ATR1=iATR(NULL,0,Period,pos+1); 
		DATA[pos]=ATR0;  
		value =  MathAbs(ATR0 - ATR1); 
		}
		
	    // "Volume"	  
        if (Method== 2)
		{ 
        DATA[pos]=Volume[pos];  
        value= Volume[pos]-Volume[pos+1]; 		
		}
		
		// "AATR"
		if (Method== 3)
		{
		 ATR0=iATR(NULL,0,Period,pos); 
		 DATA[pos]=ATR0;  
		 value=ATR0; 
		}
		
		// "Percentage"		 
		if (Method== 4)
		{ 
		DATA[pos]=Open[pos];  	
		value=MathAbs(Close[pos] - Open[pos]); 
		}
      
	  
	   	max= GetMax(pos);		
		AddLabel(value ,max,  pos);
 
     pos--;
	 }
	 
 
	 
	  
   return(0);
  }
  
  
double GetMax(int pos)
{

int i;
double M=0;
int limit=Bars-2;
 
	 for(i=pos; i< limit; i++)  
    {	
 	    if(   M < MathAbs(DATA[i] -   DATA[i+1]))
		{
		M =MathAbs(DATA[i] -   DATA[i+1]);
		}
	}
	
	return (M);
}
  
  
 void AddLabel (double value,double max,  int pos) 
{
				   
 
    double Percentage=  ToPercentage(value,max);
 
 
       if (  Percentage >= (100 -Extrem_Level)	)
	   {
			  if  (Close[pos]>= Open[pos])
			 {
			  objText(TimeToStr(Time[pos]), "EBA", Time[pos], Low[pos], 0, Extrem_Buying_Aggression,  "Arial", 12);
			 }
			  else
			 {
			  objText(TimeToStr(Time[pos]), "ESA", Time[pos], High[pos], 0, Extrem_Selling_Aggression,  "Arial", 12);
			 }
		}
		else
		{
			   if (Percentage >= (100 -Strong_Level))
			   {
					 
					  	  if  (Close[pos]>= Open[pos])
						 {
						  objText(TimeToStr(Time[pos]), "SBA", Time[pos], Low[pos], 0, Strong_Buying_Aggression,  "Arial", 12);
						 }
						  else
						 {
						  objText(TimeToStr(Time[pos]), "SSA", Time[pos], High[pos], 0, Strong_Selling_Aggression,  "Arial", 12);
						 }
				}else
				{
					if  ( Percentage >= (100 -Moderate_Level))
					{	
						   if  (Close[pos]>= Open[pos])
						 {
						  objText(TimeToStr(Time[pos]), "MBA", Time[pos], Low[pos], 0, Moderate_Buying_Aggression,  "Arial", 12);
						 }
						  else
						 {
						  objText(TimeToStr(Time[pos]), "MSA", Time[pos], High[pos], 0, Moderate_Selling_Aggression,  "Arial", 12);
						 }
					}	 
	            }
	   }
	   	   		        
}

 double ToPercentage (double value, double max)
{

 
 double Rez = 0;
 
 if (max!= 0) 
 {
 Rez=MathAbs(value/(max/100));
 }
 
 return  (Rez);

}
 
void objText(string name, string tex, datetime time, double price, int window=0, color tex_color=White, string tex_font="Arial", int tex_size=12)
  {
    int windowIndex=WindowFind(IndicatorName);
   if(ObjectFind(IndicatorObjPrefix + name+windowIndex)==-1)
   {
      ObjectCreate(IndicatorObjPrefix + name+windowIndex, OBJ_TEXT, window, time, price);
   };
   ObjectSet(IndicatorObjPrefix + name+windowIndex, OBJPROP_TIME1, time);
   ObjectSet(IndicatorObjPrefix + name+windowIndex, OBJPROP_PRICE1, price);
   ObjectSetText(IndicatorObjPrefix + name+windowIndex, tex, tex_size, tex_font, tex_color);
  }