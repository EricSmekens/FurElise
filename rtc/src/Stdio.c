/*
    5/21/02
    Nathan Seidle
    nathan.seidle@colorado.edu
    
    Serial Out Started on 5-21
    rs_out Perfected on 5-24
    
    1Wire Serial Comm works with 4MHz Xtal
    Connect Serial_Out to Pin2 on DB9 Serial Connector
    Connect Pin5 on DB9 Connector to Signal Ground
    9600 Baud 8-N-1
    
    5-21 My first real C and Pic program.
    5-24 Attempting 20MHz implementation
    5-25 20MHz works
    5-25 Serial In works at 4MHz
    5-25 Passing Strings 9:20
    5-25 Option Selection 9:45

    6-9  'Stdio.c' created. Printf working with %d and %h
    7-20 Added a longer delay after rs_out
         Trying to get 20MHz on the 16F873 - I think the XTal is bad.
         20MHz also needs 5V Vdd. Something I dont have.
    2-9-03 Overhauled the 4MHz timing. Serial out works very well now.
    
    6-16-03 Discovered how to pass string in cc5x
        void test(const char *str);
        test("zbcdefghij"); TXREG = str[1];
        
        Moved to hardware UART. Old STDIO will be in goodworks.
        
        Works great! Even got the special print characters (\n, \r, \0) to work.
    
    4-25-04 Added new %d routine to print 16 bit signed decimal numbers without leading 0s.
        

*/

//Setup the hardware UART TX module
void enable_uart_TX(bit want_ints)
{
    BRGH = 0; //Normal speed UART

    SYNC = 0;
    SPEN = 1;

#ifdef Clock_4MHz
    #ifdef Baud_9600
    SPBRG = 6; //4MHz for 9600 Baud
    #endif
#endif

#ifdef Clock_8MHz
    #ifdef Baud_4800
    SPBRG = 25; //8MHz for 4800 Baud
    #endif
    #ifdef Baud_9600
    SPBRG = 12; //8MHz for 9600 Baud
    #endif
    #ifdef Baud_57600
    BRGH = 1; //High speed UART
    SPBRG = 7; //8MHz for 57600 Baud
    #endif
#endif

#ifdef Crazy_Osc
    #ifdef Baud_9600
    SPBRG = 32; //20MHz for 9600 Baud
    #endif
#endif

#ifdef Clock_20MHz
    #ifdef Baud_9600
    SPBRG = 31; //20MHz for 9600 Baud
    #endif

    #ifdef Baud_4800
    SPBRG = 64; //20MHz for 4800 Baud
    #endif
#endif

    if(want_ints) //Check if we want to turn on interrupts
    {
        TXIE = 1;
        PEIE = 1;
        GIE = 1;
    }

    TXEN = 1; //Enable transmission
}    

//Setup the hardware UART RX module
void enable_uart_RX(bit want_ints)
{

    BRGH = 0; //Normal speed UART

    SYNC = 0;
    SPEN = 1;

#ifdef Clock_4MHz
    #ifdef Baud_9600
    SPBRG = 6; //4MHz for 9600 Baud
    #endif
#endif

#ifdef Clock_8MHz
    #ifdef Baud_4800
    SPBRG = 25; //8MHz for 4800 Baud
    #endif
    #ifdef Baud_9600
    SPBRG = 12; //8MHz for 9600 Baud
    #endif
    #ifdef Baud_57600
    BRGH = 1; //High speed UART
    SPBRG = 8; //8MHz for 57600 Baud
    #endif
#endif

#ifdef Crazy_Osc
    #ifdef Baud_9600
    SPBRG = 32; //20MHz for 9600 Baud
    #endif
#endif

#ifdef Clock_20MHz
    #ifdef Baud_9600
    SPBRG = 31; //20MHz for 9600 Baud
    #endif

    #ifdef Baud_4800
    SPBRG = 64; //20MHz for 4800 Baud
    #endif
#endif

    CREN = 1;

    //WREN = 1;

    if(want_ints) //Check if we want to turn on interrupts
    {
        RCIE = 1;
        PEIE = 1;
        GIE = 1;
    }

}    

//Sends nate to the Transmit Register
void putc(uns8 nate)
{
    while(TXIF == 0);
    TXREG = nate;
}

uns8 getc(void)
{
    while(RCIF == 0);
    return (RCREG);
}    

//Returns ASCII Decimal and Hex values
uns8 bin2Hex(char x)
{
   skip(x);
   #pragma return[16] = "0123456789ABCDEF"
}

//Prints a string including variables
void printf(const char *nate, int16 my_byte)
{
  
    uns8 i, k, m, temp;
    uns8 high_byte = 0, low_byte = 0;
    uns8 y, z;
    
    uns8 decimal_output[5];
    
    for(i = 0 ; ; i++)
    {
        k = nate[i];

        if (k == '\0') 
            break;

        else if (k == '%') //Print var
        {
            i++;
            k = nate[i];

            if (k == '\0') 
                break;
            else if (k == '\\') //Print special characters
            {
                i++;
                k = nate[i];
                
                putc(k);
                

            } //End Special Characters
            else if (k == 'b') //Print Binary
            {
                for( m = 0 ; m < 8 ; m++ )
                {
                    if (my_byte.7 == 1) putc('1');
                    if (my_byte.7 == 0) putc('0');
                    if (m == 3) putc(' ');
                    
                    my_byte = my_byte << 1;
                }
            } //End Binary               
            else if (k == 'd') //Print Decimal
            {
                //Print negative sign and take 2's compliment
                /*
                if(my_byte < 0)
                {
                    putc('-');
                    my_byte ^= 0xFFFF;
                    my_byte++;
                }
                */
                
                if (my_byte == 0)
                    putc('0');
                else
                {
                    //Divide number by a series of 10s
                    for(m = 4 ; my_byte > 0 ; m--)
                    {
                        temp = my_byte % (uns16)10;
                        decimal_output[m] = temp;
                        my_byte = my_byte / (uns16)10;               
                    }
                
                    for(m++ ; m < 5 ; m++)
                        putc(bin2Hex(decimal_output[m]));
                }
    
            } //End Decimal
            else if (k == 'h') //Print Hex
            {
                //New trick 3-15-04
                putc('0');
                putc('x');
                
                if(my_byte > 0x00FF)
                {
                    putc(bin2Hex(my_byte.high8 >> 4));
                    putc(bin2Hex(my_byte.high8 & 0b.0000.1111));
                }

                putc(bin2Hex(my_byte.low8 >> 4));
                putc(bin2Hex(my_byte.low8 & 0b.0000.1111));

                /*high_byte.3 = my_byte.7;
                high_byte.2 = my_byte.6;
                high_byte.1 = my_byte.5;
                high_byte.0 = my_byte.4;
            
                low_byte.3 = my_byte.3;
                low_byte.2 = my_byte.2;
                low_byte.1 = my_byte.1;
                low_byte.0 = my_byte.0;
        
                putc('0');
                putc('x');
            
                putc(bin2Hex(high_byte));
                putc(bin2Hex(low_byte));*/
            } //End Hex
            else if (k == 'f') //Print Float
            {
                putc('!');
            } //End Float
            else if (k == 'u') //Print Direct Character
            {
                //All ascii characters below 20 are special and screwy characters
                //if(my_byte > 20) 
                    putc(my_byte);
            } //End Direct
                        
        } //End Special Chars           

        else
            putc(k);
    }    
}