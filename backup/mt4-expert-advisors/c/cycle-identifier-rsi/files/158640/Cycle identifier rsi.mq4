//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75723

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Black

#property indicator_color2 Blue     //major bottom
#property indicator_color3 Red      //major top
#property indicator_color4 Black    //minor bottom
#property indicator_color5 Black    //minor top

#property indicator_color6 Black

#property indicator_width1 0
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 0

#property indicator_minimum -1.2
#property indicator_maximum 1.2

extern int       PriceActionFilter=1;
extern int       Length=3;
extern int       MajorCycleStrength=4;
extern bool      UseCycleFilter=false;
extern int       UseFilterSMAorRSI=1;
extern int       FilterStrengthSMA=12;
extern int       FilterStrengthRSI=21;
extern bool      SoundAlert = true;
extern bool      WaitForClose = true;
extern string    note1 = "alert all = 0",
                 note2 = "buy only = 1, sell only = 2";
extern int       alertsOption = 0;
double LineBuffer[];
double MajorCycleBuy[];
double MajorCycleSell[];
double MinorCycleBuy[];
double MinorCycleSell[];
double ZL1[];

double CyclePrice = 0.0, Strength =0.0, SweepA = 0.0, SweepB = 0.0;
int Switch = 0, Switch2 = 0,	SwitchA = 0, SwitchB = 0, SwitchC = 0, SwitchD = 0, SwitchE = 0, SwitchAA = 0, SwitchBB = 0;
double Price1BuyA = 0.0, Price2BuyA = 0.0;
int Price1BuyB = 1.0, Price2BuyB = 1.0;
double Price1SellA = 0.0, Price2SellA = 0.0;
int Price1SellB = 0.0, Price2SellB = 0.0;
bool ActiveSwitch = True, BuySwitchA = FALSE, BuySwitchB = FALSE, SellSwitchA = FALSE, SellSwitchB = FALSE;
int BuySellFac = 01;
bool Condition1, Condition2, Condition3, Condition6;

datetime TopAlertTime, BottomAlertTime;
int SignalIndex = 0;
int init()  {
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,LineBuffer);
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(1,MajorCycleBuy);
   
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(2,MajorCycleSell);
   
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(3,MinorCycleBuy);
   
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(4,MinorCycleSell);
   
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,ZL1);
   
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);  
   
   TopAlertTime = 0;
   BottomAlertTime = 0;
   if (WaitForClose)
   {
      SignalIndex = 1;
   }
   else
   {
      SignalIndex = 0;
   }
   return(0);
}

int deinit() {return(0);}

int start() {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
  // if(counted_bars>0) counted_bars--;
  // int position=Bars-1;
   int position=Bars-counted_bars;
   if (position<0) position=0;

   int rnglength = 250;
   double range = 0.0, srange = 0.0;
   for (int pos = position; pos >=0; pos--)
   {
      srange = 0.0;
      int j = 0;
      for (int i=0;i<rnglength;i++)
      {
         j++;
         int posr = pos + i;
         if (posr >= Bars)
            break;
            
         srange = srange + (High[posr] - Low[posr]);
      }
      range = srange / j * Length;
      int BarNumber = Bars-pos; //??????????
      if (BarNumber < 0)
            BarNumber = 0;
 
      CyclePrice = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos);
      
      if (UseFilterSMAorRSI == 1)
            ZL1[pos] = ZeroLag(CyclePrice,FilterStrengthSMA, pos);
      if (UseFilterSMAorRSI == 2)
            ZL1[pos] = ZeroLag( iRSI(NULL, 0, 14, CyclePrice, FilterStrengthRSI ), FilterStrengthRSI, pos);

      if (ZL1[pos] > ZL1[pos+1]) 
          SwitchC = 1;
      if (ZL1[pos] < ZL1[pos+1]) 
          SwitchC = 2;
          
      if (BarNumber <= 1)
      {
         if (Strength == 0)
     		  SweepA  = range;
     		else
     		  SweepA = Strength;
         Price1BuyA  = CyclePrice;
         Price1SellA  = CyclePrice;
      }
      
      /* ***************************************************************** */
      
      if (BarNumber > 1)
      {
         if (Switch > -1)
         {
            if (CyclePrice < Price1BuyA)
            {
               
                  if (UseCycleFilter && (SwitchC == 2) && BuySwitchA )
                  {
			           MinorCycleBuy[pos + BarNumber - Price1BuyB] = 0; //MinorBuySell
			           LineBuffer[pos + BarNumber - Price1BuyB ] = 0; //line
		            }
		      
		            if (!UseCycleFilter && BuySwitchA)
		            {
			           MinorCycleBuy[pos +BarNumber - Price1BuyB] = 0;
			           LineBuffer[pos +BarNumber - Price1BuyB] = 0;
		            }
		            Price1BuyA = CyclePrice;
                  Price1BuyB = BarNumber;
                  BuySwitchA = TRUE;
            }
            else if (CyclePrice > Price1BuyA)
            {
  
   			      SwitchA = BarNumber - Price1BuyB;
         
		            if (!UseCycleFilter)
		            {
			           MinorCycleBuy[pos +SwitchA] = -1;//MinorBuySell - DarkGreen
			           LineBuffer[pos +SwitchA] = -1;//line
		            }
		      
		            if (UseCycleFilter && SwitchC  == 1)
		            {
			           MinorCycleBuy[pos +SwitchA] = -1;  //MinorBuySell
			           LineBuffer[pos +SwitchA] = -1; //line
			           SwitchD = 1; 
		            }
		            else
		            {
			           SwitchD = 0;
			         }
			   
                  BuySwitchA = TRUE;
		
		            double cyclePrice1 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchA);
                  if (ActiveSwitch)
                  {  
                        Condition1 = CyclePrice - cyclePrice1 >= SweepA; 
                  }
                  else
                  {
                        Condition1 = CyclePrice >= cyclePrice1 * (1 + SweepA / 1000);
                  }
                  if (Condition1 && SwitchA >= BuySellFac) 
                  {
                        Switch =  - 1;
                        Price1SellA = CyclePrice;
                        Price1SellB = BarNumber;
                        SellSwitchA = FALSE;
                        BuySwitchA = FALSE;
                  }            
            }
         }
         if(Switch < 1)
         {
            if (CyclePrice > Price1SellA)
            {
               if (UseCycleFilter && SwitchC == 1 && SellSwitchA )
               {
				     MinorCycleSell[pos +BarNumber - Price1SellB] = 0; //MinorBuySell
				     LineBuffer[pos +BarNumber - Price1SellB ] = 0; //line
			      }
			      if (!UseCycleFilter && SellSwitchA )
			      {
                   MinorCycleSell[pos +BarNumber - Price1SellB] = 0;//MinorBuySell
                   LineBuffer[pos +BarNumber - Price1SellB] = 0;//line
               }
               Price1SellA = CyclePrice;
               Price1SellB = BarNumber;
               SellSwitchA = TRUE;   
		       }
		       else if (CyclePrice < Price1SellA)
		       {
			      SwitchA = BarNumber - Price1SellB;
               if (!UseCycleFilter)
               {
                  MinorCycleSell[pos +SwitchA] = 1; // MinorBuySell darkRed
                  LineBuffer[pos +SwitchA] = 1; //"CycleLine"
			      }
      			if (UseCycleFilter && (SwitchC == 2))
      			{
				     MinorCycleSell[pos +SwitchA] = 1;//MinorBuySell darkRed
				     LineBuffer[pos +SwitchA] = 1;//CycleLine
				     SwitchD  = 2;
			      } 
			      else
			         SwitchD  = 0;

               SellSwitchA = TRUE;
			      double cyclePrice2 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchA);
               
			      if (ActiveSwitch)
				     Condition1 = (cyclePrice2 - CyclePrice) >= SweepA;
			      else 
				     Condition1 = CyclePrice <= (cyclePrice2 * (1 - SweepA / 1000));

			      if (Condition1 && SwitchA >= BuySellFac)
			      {
				      Switch = 1;
                  Price1BuyA = CyclePrice;
                  Price1BuyB = BarNumber;
                  SellSwitchA = FALSE;
                  BuySwitchA = FALSE;
               }
            } 
         }
      }
      
      LineBuffer[pos] = 0;
      MinorCycleBuy[pos] = 0;
      MinorCycleSell[pos] = 0;

      if (BarNumber == 1)
      {
         if (Strength == 0)
            SweepB  = range *  MajorCycleStrength;
         else
            SweepB = Strength * MajorCycleStrength;
            
         Price2BuyA = CyclePrice;
         Price2SellA = CyclePrice;
      }     
            
      if (BarNumber > 1)
      {
         if (Switch2  >  - 1)
         {
            if (CyclePrice < Price2BuyA)
            {
               if (UseCycleFilter && SwitchC == 2 && BuySwitchB )
				   {
				      MajorCycleBuy [pos +BarNumber - Price2BuyB] = 0; //MajorBuySell,green
		//		      LineBuffer[pos + BarNumber - Price2BuyB ] = 0; //line -----
               }
               if (!UseCycleFilter && BuySwitchB )
               {
                  MajorCycleBuy [pos +BarNumber - Price2BuyB] = 0;//MajorBuySell,green
  	//			      LineBuffer[pos + BarNumber - Price2BuyB ] = 0; //line-----------
               }
			      Price2BuyA = CyclePrice;
               Price2BuyB = BarNumber;
               BuySwitchB = TRUE;
            } 
            else if (CyclePrice > Price2BuyA)
            {
			      SwitchB = BarNumber - Price2BuyB;

               if (!UseCycleFilter)
               {  
                     MajorCycleBuy [pos +SwitchB] = -1; //MajorBuySell green
      //               LineBuffer[pos + SwitchB] = -1; //line--------------
               }
               if (UseCycleFilter && SwitchC  == 1)
               {
                  MajorCycleBuy [pos +SwitchB] = -1; //MajorBuySell green
     //             LineBuffer[pos + SwitchB] = -1; //line-----------------
                  SwitchE  = 1;
               } 
               else
				     SwitchE  = 0;

               BuySwitchB = TRUE;
			      double cyclePrice3 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchB);
               if (ActiveSwitch) 
                  Condition6 = CyclePrice - cyclePrice3 >= SweepB;
               else
                  Condition6 = CyclePrice >= cyclePrice3 * (1 + SweepB / 1000);

			      if (Condition6 && SwitchB >= BuySellFac)
			      {
                     Switch2 =  - 1;
                     Price2SellA = CyclePrice;
                     Price2SellB = BarNumber;
                     SellSwitchB = FALSE;
                     BuySwitchB = FALSE;
               }
            }
         }

         if (Switch2  < 1)
         {
            if (CyclePrice  > Price2SellA )
            {
			      if (UseCycleFilter && SwitchC  == 1 && SellSwitchB )
				   { 
				         MajorCycleSell [pos +BarNumber - Price2SellB] = 0; //"MajorBuySell",red 
		//			      LineBuffer[pos + BarNumber - Price2SellB ] = 0; //line -----
			     }
			      if (!UseCycleFilter && SellSwitchB )
				   {
				       MajorCycleSell [pos +BarNumber - Price2SellB] = 0;//"MajorBuySell",red 
     //              LineBuffer[pos + BarNumber - Price2SellB ] = 0; //line -----
               }
			      Price2SellA = CyclePrice;
               Price2SellB = BarNumber;
               SellSwitchB = TRUE;
		       }
		       else if (CyclePrice < Price2SellA)
		       {
               SwitchB = BarNumber - Price2SellB ;

      			if (!UseCycleFilter) 
      			{
      			   MajorCycleSell[pos + SwitchB] = 1; //"MajorBuySell",red 
     // 		      LineBuffer[pos + SwitchB ] = 1; //line -----
			      }
		         if (UseCycleFilter && SwitchC  == 2)
		         {
      				MajorCycleSell [pos + SwitchB] = 1; //"MajorBuySell",red 
      //		      LineBuffer[pos + SwitchB ] = 1; //line -----
		       		SwitchE  = 2;
			      }
			      else
				     SwitchE  = 0;

               SellSwitchB = TRUE;
	            double cyclePrice4 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos + SwitchB);
			      if (ActiveSwitch)
                  Condition6 = cyclePrice4 - CyclePrice >= SweepB;
			      else
                  Condition6 = CyclePrice <= cyclePrice4 * (1.0 - SweepB / 1000.0);

			      if (Condition6 && SwitchB >= BuySellFac)
			      {
				        Switch2 = 1;
                     Price2BuyA = CyclePrice;
                     Price2BuyB = BarNumber;
                     SellSwitchB = FALSE;
                     BuySwitchB = FALSE;
               }
            }
         }
      }
      LineBuffer[pos] = 0;
      MajorCycleSell[pos] = 0;
      MajorCycleBuy[pos] = 0;
   }
   
   if (SoundAlert)
   {
     string TimePeriod;
   
     if (Period()== 1)       TimePeriod = "1 MIN";
     if (Period()== 5)       TimePeriod = "5 MIN";
     if (Period()== 15)      TimePeriod = "15 MIN";
     if (Period()== 30)      TimePeriod = "30 MIN";
     if (Period()== 60)      TimePeriod = "1 HR";
     if (Period()== 240)     TimePeriod = "4 HR";
     if (Period()== 1440)    TimePeriod = "DAILY";
     if (Period()== 10080)   TimePeriod = "WEEKLY";
     if (Period()== 43200)   TimePeriod = "MONTHLY";
     if (alertsOption == 0)
        if (LineBuffer[SignalIndex] == 1 && TopAlertTime < Time[SignalIndex])
        {
           Alert (Symbol(), TimePeriod, ", Cycle Top Detected");

// SendNotification by 160318           
           if(!SendNotification(Symbol()+TimePeriod+", Cycle Top Detected"))
            {
               Print("Error SendNotification :"+IntegerToString(GetLastError()));
            };
            
           TopAlertTime = Time[SignalIndex];
           //Alert (TimePeriod, Symbol(), " Cycle Top Detected at ",TimeToStr(Time[SignalIndex],TIME_DATE|TIME_MINUTES));
        }
        if (LineBuffer[SignalIndex] == -1 && BottomAlertTime < Time[SignalIndex])
        {
           Alert (Symbol(), TimePeriod, ", Cycle Bottom Detected");

// SendNotification by 160318                      
           if(!SendNotification(Symbol()+TimePeriod+", Cycle Bottom Detected"))
            {
               Print("Error SendNotification :"+IntegerToString(GetLastError()));
            };
                       
           BottomAlertTime = Time[SignalIndex];
        }
     if (alertsOption == 1)  //buy
        if (LineBuffer[SignalIndex] == -1 && BottomAlertTime < Time[SignalIndex])
        {
           Alert (Symbol(), TimePeriod, ", Cycle Bottom Detected");
           
// SendNotification by 160318                      
           if(!SendNotification(Symbol()+TimePeriod+", Cycle Bottom Detected"))
            {
               Print("Error SendNotification :"+IntegerToString(GetLastError()));
            };           
           
           BottomAlertTime = Time[SignalIndex];
        }
     if (alertsOption == 2)  //sell
         if (LineBuffer[SignalIndex] == 1 && TopAlertTime < Time[SignalIndex])
         {
            Alert (Symbol(), TimePeriod, ", Cycle Top Detected");
            
// SendNotification by 160318                      
           if(!SendNotification(Symbol()+TimePeriod+", Cycle Bottom Detected"))
            {
               Print("Error SendNotification :"+IntegerToString(GetLastError()));
            };            
            
            TopAlertTime = Time[SignalIndex];
         }
   }
   
   return(0);
}

double ZeroLag(double price, int length, int pos)
{   
   if (length < 3)
   {
      return(price);
   }
   double aa = MathExp(-1.414*3.14159 / length);
   double bb = 2*aa*MathCos(1.414*180 / length);
   double CB = bb;
   double CC = -aa*aa;
   double CA = 1 - CB - CC;
   double CD = CA*price + CB*ZL1[pos+1] + CC*ZL1[pos+2];
   return(CD);
}


//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75723

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
