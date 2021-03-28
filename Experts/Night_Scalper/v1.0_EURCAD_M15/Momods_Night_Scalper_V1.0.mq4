////////////////////////////////////////////////////////
//        Momods_Night_Scalper_V1.0                   //
//        Coded by Momods @ worldwide-invest.org      //
//        March 10, 2013                              //
////////////////////////////////////////////////////////


extern string  EA_Name= "Momods_Night_Scalper_V1.0";      

extern int     Magic = 44565411;
extern bool    New_Trade=True;
extern double  lot = 0;

extern double  Risk=10.0;
extern double  StopLoss=40;
extern int     Slippage=3;
extern double  Max_Spread= 4.5;

extern int    Open_Hour    =19;
extern int    Close_Hour   =23;
extern bool   TradeOnFriday =False;
extern int    Friday_Hour   =15;


extern int    CCI_Period    =10;
extern double CCI_Entry     = 210;
extern double CCI_Exit      = 120;


bool Trade;
datetime Last_Time;
double Last_Lot, Lot,Profit$;
int    t1, total;
double Spread;
double Base_Price;
double First_Lot;


int init() {

   return (0);
}

int deinit() {
   return (0);
}

int start() {
 

//////////////////  Indicator(s) ////////////////////////
     

     double  CCI_0 = iCCI(NULL, 0, CCI_Period, PRICE_CLOSE, 0);

        
///////////////////// Close Bascket in Profit /////////////////////////


    for(int k=0; k<OrdersTotal(); k++)     
    {      
       OrderSelect(k, SELECT_BY_POS, MODE_TRADES);      
       if(OrderType()==OP_BUY &&   OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && CCI_0>CCI_Exit )
       {                 
         OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position 
          //CloseAll(Magic);                
                          
       } 
       
       if(OrderType()==OP_SELL &&   OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && CCI_0<-CCI_Exit )
       {                 
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
           //CloseAll(Magic);                 
                         
       }
   }  

  
       
     
//////////////////////////////////// First trade ///////////////////////////////////////////////     

   Trade = true;
   if (!TradeOnFriday && DayOfWeek() == 5) Trade = FALSE;
   if (TradeOnFriday && DayOfWeek() == 5 && TimeHour(TimeCurrent()) > Friday_Hour) Trade = FALSE;   
   if (Open_Hour==24)Open_Hour=0;
   if (Close_Hour==24)Close_Hour=0;     
   if (Open_Hour < Close_Hour && TimeHour(TimeCurrent()) < Open_Hour || TimeHour(TimeCurrent()) >= Close_Hour) Trade = FALSE;
   if (Open_Hour > Close_Hour && (TimeHour(TimeCurrent()) < Open_Hour && TimeHour(TimeCurrent()) >= Close_Hour)) Trade = FALSE; 
   if (Month()==12 && Day()>22)  Trade = FALSE; 
   if (Month()==1 && Day()<5)  Trade = FALSE;       

   Spread = Ask-Bid;
       
   if (New_Trade && Spread<Max_Spread*PointValue() && MyRealOrdersTotal(Magic)==0  && Trade && Time[0]!=Last_Time && CCI_0<-CCI_Entry) 
   {

        Lot=CalculateLots();


        int Ticket_1 = OrderSend(Symbol(), OP_BUY, Lot, Ask, Slippage, 0, 0, EA_Name, Magic, 0, Lime);
        if (Ticket_1>0)
         {
           Last_Time=iTime(NULL,0,0);
         }
   }
   
   if (New_Trade && Spread<Max_Spread*PointValue() && MyRealOrdersTotal(Magic)==0  && Trade && Time[0]!=Last_Time && CCI_0>CCI_Entry) 
   {

        Lot=CalculateLots();


        int Ticket_2 = OrderSend(Symbol(), OP_SELL, Lot, Bid, Slippage, 0, 0, EA_Name, Magic, 0, Red);
        if (Ticket_2>0)
         {
           Last_Time=iTime(NULL,0,0);
         }
   }   
            
   if (MyRealOrdersTotal(Magic)>0) ModifyAll();
   
   
   return (0);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////

int MyRealOrdersTotal(int Magic)
{
  int c=0;
  int total  = OrdersTotal();
 
  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && OrderType()<=OP_SELL)
    {
      c++;
    }
  }
  return(c);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

double CalculateLots() 
{
   int Lot_Dec;
   double l_minlot_0 = MarketInfo(Symbol(), MODE_MINLOT);
   double l_maxlot_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ld_ret_16 = 0.0;
   if (MarketInfo(Symbol(), MODE_MINLOT) < 1.0) Lot_Dec = 1;
   if (MarketInfo(Symbol(), MODE_MINLOT) < 0.1) Lot_Dec = 2;
   if (MarketInfo(Symbol(), MODE_MINLOT) < 0.01) Lot_Dec = 3;
   if (MarketInfo(Symbol(), MODE_MINLOT) < 0.001) Lot_Dec = 4;
   if (MarketInfo(Symbol(), MODE_MINLOT) < 0.0001) Lot_Dec = 5;
   if (lot > 0.0) {ld_ret_16 = lot;return (ld_ret_16);}
   if (ld_ret_16 == 0.0) 
   {
      ld_ret_16=NormalizeDouble(AccountBalance() / 100000.0 * Risk, Lot_Dec);
      if (ld_ret_16 < l_minlot_0) ld_ret_16 = l_minlot_0;
      if (ld_ret_16 > l_maxlot_8) ld_ret_16 = l_maxlot_8;
      return (ld_ret_16);
   }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

double PointValue() {
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void ModifyAll() 
{ 
   for (int cnt = OrdersTotal()-1 ; cnt >= 0; cnt--) 
   { 
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic ) 
      { 
         if (OrderStopLoss()==0)
         
            {
               if((OrderType()==OP_BUY)) 
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-PointValue()*StopLoss,0,0,Green); 
               if((OrderType()==OP_SELL)) 
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+PointValue()*StopLoss,0,0,Red);
            }
            
          
      } 
   } 
}