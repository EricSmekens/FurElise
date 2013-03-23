
; CC5X Version 3.1I, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  23. Nov 2004  23:48  *************

	processor  16F88
	radix  DEC

INDF        EQU   0x00
PCL         EQU   0x02
FSR         EQU   0x04
PORTA       EQU   0x05
TRISA       EQU   0x85
PORTB       EQU   0x06
TRISB       EQU   0x86
PCLATH      EQU   0x0A
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
IRP         EQU   7
GIE         EQU   7
OPTION_REG  EQU   0x81
RCSTA       EQU   0x18
TXREG       EQU   0x19
RCREG       EQU   0x1A
TXSTA       EQU   0x98
SPBRG       EQU   0x99
ANSEL       EQU   0x9B
EEDATA      EQU   0x10C
EEADR       EQU   0x10D
EEDATH      EQU   0x10E
EEADRH      EQU   0x10F
PEIE        EQU   6
TXIF        EQU   4
RCIF        EQU   5
CREN        EQU   4
SPEN        EQU   7
TXIE        EQU   4
RCIE        EQU   5
BRGH        EQU   2
SYNC        EQU   4
TXEN        EQU   5
RD          EQU   0
EEPGD       EQU   7
want_ints   EQU   0
want_ints_2 EQU   0
nate        EQU   0x3F
x           EQU   0x3F
nate_2      EQU   0x2E
my_byte     EQU   0x30
i           EQU   0x32
k           EQU   0x33
m           EQU   0x34
temp        EQU   0x35
high_byte   EQU   0x36
low_byte    EQU   0x37
C1cnt       EQU   0x3F
C2tmp       EQU   0x40
C3cnt       EQU   0x3F
C4tmp       EQU   0x40
C5rem       EQU   0x42
scl_IIC     EQU   0
sda_IIC     EQU   1
address     EQU   0x2C
thing       EQU   0x2E
address_2   EQU   0x2E
j           EQU   0x30
in_byte     EQU   0x31
nate_3      EQU   0x30
i_2         EQU   0x31
choice      EQU   0x20
x_2         EQU   0x2C
temp_2      EQU   0x2D
C6cnt       EQU   0x2E
C7tmp       EQU   0x2F
temp_3      EQU   0x21
cell        EQU   0x22
data_byte_in EQU   0x23
hours       EQU   0x24
minutes     EQU   0x25
seconds     EQU   0x26
am_pm       EQU   0
C8cnt       EQU   0x2C
C9tmp       EQU   0x2D
C10rem      EQU   0x2E
C11cnt      EQU   0x2C
C12tmp      EQU   0x2D
C13cnt      EQU   0x2C
C14tmp      EQU   0x2D
C15rem      EQU   0x2E
C16cnt      EQU   0x2C
C17tmp      EQU   0x2D
C18cnt      EQU   0x2C
C19tmp      EQU   0x2D
C20rem      EQU   0x2E
C21cnt      EQU   0x2C
C22tmp      EQU   0x2D
day         EQU   0x27
month       EQU   0x28
date        EQU   0x29
year        EQU   0x2A
C23cnt      EQU   0x2C
C24tmp      EQU   0x2D
C25rem      EQU   0x2E
C26cnt      EQU   0x2C
C27tmp      EQU   0x2D
C28cnt      EQU   0x2C
C29tmp      EQU   0x2D
C30rem      EQU   0x2E
C31cnt      EQU   0x2C
C32tmp      EQU   0x2D
C33cnt      EQU   0x2C
C34tmp      EQU   0x2D
C35rem      EQU   0x2E
C36cnt      EQU   0x2C
C37tmp      EQU   0x2D
ci          EQU   0x3F
TtmpA43     EQU   0x2B

	GOTO main

  ; FILE D:\Pics\code\16F88\RTC-Demo\rtc-demo.c
			;/*
			;    11-23-04
			;    Copyright Spark Fun Electronics 2004
			;
			;    Nathan Seidle
			;    spark@sparkfun.com    
			;
			;    This is the test bed firmware that we use to program the RTC Module using a PIC 16F88 at 20MHz. 
			;    It should give you some insight on how to deal with binary coded decimal as well as some software driven 
			;    I2C routines.
			;    
			;    Something interesting to note is that there is no external pull-up resistor on the SDA line (normally required
			;    for I2C communication). Instead, we turn on the internal pull-up resistors on the 16F88 PORTB pins every 
			;    time we do an I2C read. We don't use any hardware module on the 16F88, I just bit-bang I2C on any-ol port pins.
			;    
			;    This code is fairly bulky because of all the pretty-print menus. There is no checking during the programming routine.
			;    It is up to the user to select valid date ranges/month/times before hitting 'p' to program the RTC Module.
			;    
			;    We used Bloader/Screamer exclusively to design this code. That's why you won't see any config commands/bits.
			;    
			;*/
			;#define Clock_20MHz
			;#define Baud_9600
			;
			;#include "\Pics\c\16F88.h"  //Device dependent definitions
			;
			;#pragma origin 4
	ORG 0x0004

  ; FILE \Pics\code\stdio.c
			;/*
			;    5/21/02
			;    Nathan Seidle
			;    nathan.seidle@colorado.edu
			;    
			;    Serial Out Started on 5-21
			;    rs_out Perfected on 5-24
			;    
			;    1Wire Serial Comm works with 4MHz Xtal
			;    Connect Serial_Out to Pin2 on DB9 Serial Connector
			;    Connect Pin5 on DB9 Connector to Signal Ground
			;    9600 Baud 8-N-1
			;    
			;    5-21 My first real C and Pic program.
			;    5-24 Attempting 20MHz implementation
			;    5-25 20MHz works
			;    5-25 Serial In works at 4MHz
			;    5-25 Passing Strings 9:20
			;    5-25 Option Selection 9:45
			;
			;    6-9  'Stdio.c' created. Printf working with %d and %h
			;    7-20 Added a longer delay after rs_out
			;         Trying to get 20MHz on the 16F873 - I think the XTal is bad.
			;         20MHz also needs 5V Vdd. Something I dont have.
			;    2-9-03 Overhauled the 4MHz timing. Serial out works very well now.
			;    
			;    6-16-03 Discovered how to pass string in cc5x
			;        void test(const char *str);
			;        test("zbcdefghij"); TXREG = str[1];
			;        
			;        Moved to hardware UART. Old STDIO will be in goodworks.
			;        
			;        Works great! Even got the special print characters (\n, \r, \0) to work.
			;    
			;    4-25-04 Added new %d routine to print 16 bit signed decimal numbers without leading 0s.
			;        
			;
			;*/
			;
			;//Setup the hardware UART TX module
			;void enable_uart_TX(bit want_ints)
			;{
_const1
	RRF   ci+1,W
	ADDLW .0
	BSF   0x03,RP1
	MOVWF EEADRH
	BCF   0x03,RP1
	RRF   ci+1,W
	RRF   ci,W
	ADDLW .35
	BSF   0x03,RP1
	MOVWF EEADR
	BTFSC 0x03,Carry
	INCF  EEADRH,1
	BSF   0x03,RP0
	BSF   0x18C,EEPGD
	BSF   0x18C,RD
	NOP  
	NOP  
	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC ci,0
	GOTO  m001
	BSF   0x03,RP1
	MOVF  EEDATA,W
	ANDLW .127
	BCF   0x03,RP1
	RETURN
m001	BSF   0x03,RP1
	RLF   EEDATA,W
	RLF   EEDATH,W
	BCF   0x03,RP1
	RETURN
	DW    0x68A
	DW    0x68A
	DW    0x1EBD
	DW    0x1EBD
	DW    0x1EBD
	DW    0x1EBD
	DW    0x2A52
	DW    0x1043
	DW    0x22C4
	DW    0x27CD
	DW    0x1EBD
	DW    0x1EBD
	DW    0x1EBD
	DW    0x1EBD
	DW    0x68A
	DW    0x2680
	DW    0x34E1
	DW    0x106E
	DW    0x32CD
	DW    0x3AEE
	DW    0x53A
	DW    0xD
	DW    0x18A0
	DW    0x1029
	DW    0x3950
	DW    0x33EF
	DW    0x30F2
	DW    0x106D
	DW    0x2A52
	DW    0x1043
	DW    0x37CD
	DW    0x3AE4
	DW    0x32EC
	DW    0x68A
	DW    0x1000
	DW    0x14B2
	DW    0x21A0
	DW    0x32E8
	DW    0x35E3
	DW    0x2920
	DW    0x21D4
	DW    0x2A20
	DW    0x36E9
	DW    0x565
	DW    0xD
	DW    0x68A
	DW    0x1D20
	DW    0x20
	DW    0x3463
	DW    0x34EF
	DW    0x32E3
	DW    0x1EA0
	DW    0x12A0
	DW    0x64
	DW    0x50A
	DW    0x218D
	DW    0x3975
	DW    0x32F2
	DW    0x3A6E
	DW    0x2A20
	DW    0x36E9
	DW    0x1065
	DW    0x3761
	DW    0x1064
	DW    0x30C4
	DW    0x32F4
	DW    0x53A
	DW    0x68A
	DW    0x1020
	DW    0x1000
	DW    0x102D
	DW    0x1900
	DW    0x30
	DW    0x68A
	DW    0x1020
	DW    0x28D3
	DW    0x1057
	DW    0x32D3
	DW    0x3A74
	DW    0x3769
	DW    0x39E7
	DW    0x1D20
	DW    0x12A0
	DW    0x1068
	DW    0x1280
	DW    0x1D64
	DW    0x1280
	DW    0x1064
	DW    0x2800
	DW    0x4D
	DW    0x26C1
	DW    0x500
	DW    0x100D
	DW    0x17E1
	DW    0x1073
	DW    0x3463
	DW    0x3761
	DW    0x32E7
	DW    0x31A0
	DW    0x3665
	DW    0x106C
	DW    0x107C
	DW    0x17AB
	DW    0x102D
	DW    0x3769
	DW    0x3963
	DW    0x30E5
	DW    0x32F3
	DW    0x322F
	DW    0x31E5
	DW    0x32F2
	DW    0x39E1
	DW    0x1065
	DW    0x107C
	DW    0x1070
	DW    0x37F4
	DW    0x3820
	DW    0x37F2
	DW    0x3967
	DW    0x36E1
	DW    0x68A
	DW    0x2980
	DW    0x3775
	DW    0x30E4
	DW    0x79
	DW    0x37CD
	DW    0x326E
	DW    0x3CE1
	DW    0x2A00
	DW    0x32F5
	DW    0x3273
	DW    0x3CE1
	DW    0x2B80
	DW    0x3265
	DW    0x32EE
	DW    0x3273
	DW    0x3CE1
	DW    0x2A00
	DW    0x3AE8
	DW    0x39F2
	DW    0x30E4
	DW    0x79
	DW    0x3946
	DW    0x3269
	DW    0x3CE1
	DW    0x2980
	DW    0x3A61
	DW    0x3975
	DW    0x30E4
	DW    0x79
	DW    0x30CA
	DW    0x3AEE
	DW    0x3961
	DW    0x79
	DW    0x32C6
	DW    0x3962
	DW    0x30F5
	DW    0x3CF2
	DW    0x2680
	DW    0x3961
	DW    0x3463
	DW    0x2080
	DW    0x3970
	DW    0x3669
	DW    0x2680
	DW    0x3CE1
	DW    0x2500
	DW    0x3775
	DW    0x65
	DW    0x3ACA
	DW    0x3CEC
	DW    0x2080
	DW    0x33F5
	DW    0x39F5
	DW    0x74
	DW    0x32D3
	DW    0x3A70
	DW    0x36E5
	DW    0x32E2
	DW    0x72
	DW    0x31CF
	DW    0x37F4
	DW    0x32E2
	DW    0x72
	DW    0x37CE
	DW    0x32F6
	DW    0x316D
	DW    0x3965
	DW    0x2200
	DW    0x31E5
	DW    0x36E5
	DW    0x32E2
	DW    0x72
	DW    0x12A0
	DW    0x1664
	DW    0x1000
	DW    0x1832
	DW    0x12B0
	DW    0x1064
	DW    0x1020
	DW    0x20
	DW    0x16A0
	DW    0x12AD
	DW    0x16E8
	DW    0x102D
	DW    0x0
enable_uart_TX
			;    BRGH = 0; //Normal speed UART
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   0x98,BRGH
			;
			;    SYNC = 0;
	BCF   0x98,SYNC
			;    SPEN = 1;
	BCF   0x03,RP0
	BSF   0x18,SPEN
			;
			;#ifdef Clock_4MHz
			;    #ifdef Baud_9600
			;    SPBRG = 6; //4MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_8MHz
			;    #ifdef Baud_4800
			;    SPBRG = 25; //8MHz for 4800 Baud
			;    #endif
			;    #ifdef Baud_9600
			;    SPBRG = 12; //8MHz for 9600 Baud
			;    #endif
			;    #ifdef Baud_57600
			;    BRGH = 1; //High speed UART
			;    SPBRG = 7; //8MHz for 57600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Crazy_Osc
			;    #ifdef Baud_9600
			;    SPBRG = 32; //20MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_20MHz
			;    #ifdef Baud_9600
			;    SPBRG = 31; //20MHz for 9600 Baud
	MOVLW .31
	BSF   0x03,RP0
	MOVWF SPBRG
			;    #endif
			;
			;    #ifdef Baud_4800
			;    SPBRG = 64; //20MHz for 4800 Baud
			;    #endif
			;#endif
			;
			;    if(want_ints) //Check if we want to turn on interrupts
	BTFSS 0x7F,want_ints
	GOTO  m002
			;    {
			;        TXIE = 1;
	BSF   0x8C,TXIE
			;        PEIE = 1;
	BSF   0x0B,PEIE
			;        GIE = 1;
	BSF   0x0B,GIE
			;    }
			;
			;    TXEN = 1; //Enable transmission
m002	BSF   0x98,TXEN
			;}    
	RETURN
			;
			;//Setup the hardware UART RX module
			;void enable_uart_RX(bit want_ints)
			;{
enable_uart_RX
			;
			;    BRGH = 0; //Normal speed UART
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   0x98,BRGH
			;
			;    SYNC = 0;
	BCF   0x98,SYNC
			;    SPEN = 1;
	BCF   0x03,RP0
	BSF   0x18,SPEN
			;
			;#ifdef Clock_4MHz
			;    #ifdef Baud_9600
			;    SPBRG = 6; //4MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_8MHz
			;    #ifdef Baud_4800
			;    SPBRG = 25; //8MHz for 4800 Baud
			;    #endif
			;    #ifdef Baud_9600
			;    SPBRG = 12; //8MHz for 9600 Baud
			;    #endif
			;    #ifdef Baud_57600
			;    BRGH = 1; //High speed UART
			;    SPBRG = 8; //8MHz for 57600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Crazy_Osc
			;    #ifdef Baud_9600
			;    SPBRG = 32; //20MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_20MHz
			;    #ifdef Baud_9600
			;    SPBRG = 31; //20MHz for 9600 Baud
	MOVLW .31
	BSF   0x03,RP0
	MOVWF SPBRG
			;    #endif
			;
			;    #ifdef Baud_4800
			;    SPBRG = 64; //20MHz for 4800 Baud
			;    #endif
			;#endif
			;
			;    CREN = 1;
	BCF   0x03,RP0
	BSF   0x18,CREN
			;
			;    //WREN = 1;
			;
			;    if(want_ints) //Check if we want to turn on interrupts
	BTFSS 0x7F,want_ints_2
	GOTO  m003
			;    {
			;        RCIE = 1;
	BSF   0x03,RP0
	BSF   0x8C,RCIE
			;        PEIE = 1;
	BSF   0x0B,PEIE
			;        GIE = 1;
	BSF   0x0B,GIE
			;    }
			;
			;}    
m003	BSF   0x03,RP0
	RETURN
			;
			;//Sends nate to the Transmit Register
			;void putc(uns8 nate)
			;{
putc
	MOVWF nate
			;    while(TXIF == 0);
m004	BTFSS 0x0C,TXIF
	GOTO  m004
			;    TXREG = nate;
	MOVF  nate,W
	MOVWF TXREG
			;}
	RETURN
			;
			;uns8 getc(void)
			;{
getc
			;    while(RCIF == 0);
m005	BTFSS 0x0C,RCIF
	GOTO  m005
			;    return (RCREG);
	MOVF  RCREG,W
	RETURN
			;}    
			;
			;//Returns ASCII Decimal and Hex values
			;uns8 bin2Hex(char x)
			;{
bin2Hex
	MOVWF x
			;   skip(x);
	MOVLW .1
	MOVWF PCLATH
	MOVF  x,W
	ADDWF PCL,1
			;   #pragma return[16] = "0123456789ABCDEF"
	RETLW .48
	RETLW .49
	RETLW .50
	RETLW .51
	RETLW .52
	RETLW .53
	RETLW .54
	RETLW .55
	RETLW .56
	RETLW .57
	RETLW .65
	RETLW .66
	RETLW .67
	RETLW .68
	RETLW .69
	RETLW .70
			;}
			;
			;//Prints a string including variables
			;void printf(const char *nate, int16 my_byte)
			;{
printf
			;  
			;    uns8 i, k, m, temp;
			;    uns8 high_byte = 0, low_byte = 0;
	CLRF  high_byte
	CLRF  low_byte
			;    uns8 y, z;
			;    
			;    uns8 decimal_output[5];
			;    
			;    for(i = 0 ; ; i++)
	CLRF  i
			;    {
			;        k = nate[i];
m006	MOVF  nate_2+1,W
	MOVWF ci+1
	MOVF  i,W
	ADDWF nate_2,W
	MOVWF ci
	BTFSC 0x03,Carry
	INCF  ci+1,1
	CALL  _const1
	MOVWF k
			;
			;        if (k == '\0') 
	MOVF  k,1
	BTFSC 0x03,Zero_
			;            break;
	GOTO  m029
			;
			;        else if (k == '%') //Print var
	XORLW .37
	BTFSS 0x03,Zero_
	GOTO  m027
			;        {
			;            i++;
	INCF  i,1
			;            k = nate[i];
	MOVF  nate_2+1,W
	MOVWF ci+1
	MOVF  i,W
	ADDWF nate_2,W
	MOVWF ci
	BTFSC 0x03,Carry
	INCF  ci+1,1
	CALL  _const1
	MOVWF k
			;
			;            if (k == '\0') 
	MOVF  k,1
	BTFSC 0x03,Zero_
			;                break;
	GOTO  m029
			;            else if (k == '\\') //Print special characters
	XORLW .92
	BTFSS 0x03,Zero_
	GOTO  m007
			;            {
			;                i++;
	INCF  i,1
			;                k = nate[i];
	MOVF  nate_2+1,W
	MOVWF ci+1
	MOVF  i,W
	ADDWF nate_2,W
	MOVWF ci
	BTFSC 0x03,Carry
	INCF  ci+1,1
	CALL  _const1
	MOVWF k
			;                
			;                putc(k);
	CALL  putc
			;                
			;
			;            } //End Special Characters
			;            else if (k == 'b') //Print Binary
	GOTO  m028
m007	MOVF  k,W
	XORLW .98
	BTFSS 0x03,Zero_
	GOTO  m012
			;            {
			;                for( m = 0 ; m < 8 ; m++ )
	CLRF  m
m008	MOVLW .8
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m028
			;                {
			;                    if (my_byte.7 == 1) putc('1');
	BTFSS my_byte,7
	GOTO  m009
	MOVLW .49
	CALL  putc
			;                    if (my_byte.7 == 0) putc('0');
m009	BTFSC my_byte,7
	GOTO  m010
	MOVLW .48
	CALL  putc
			;                    if (m == 3) putc(' ');
m010	MOVF  m,W
	XORLW .3
	BTFSS 0x03,Zero_
	GOTO  m011
	MOVLW .32
	CALL  putc
			;                    
			;                    my_byte = my_byte << 1;
m011	BCF   0x03,Carry
	RLF   my_byte,1
	RLF   my_byte+1,1
			;                }
	INCF  m,1
	GOTO  m008
			;            } //End Binary               
			;            else if (k == 'd') //Print Decimal
m012	MOVF  k,W
	XORLW .100
	BTFSS 0x03,Zero_
	GOTO  m023
			;            {
			;                //Print negative sign and take 2's compliment
			;                /*
			;                if(my_byte < 0)
			;                {
			;                    putc('-');
			;                    my_byte ^= 0xFFFF;
			;                    my_byte++;
			;                }
			;                */
			;                
			;                if (my_byte == 0)
	MOVF  my_byte,W
	IORWF my_byte+1,W
	BTFSS 0x03,Zero_
	GOTO  m013
			;                    putc('0');
	MOVLW .48
	CALL  putc
			;                else
	GOTO  m028
			;                {
			;                    //Divide number by a series of 10s
			;                    for(m = 4 ; my_byte > 0 ; m--)
m013	MOVLW .4
	MOVWF m
m014	BTFSC my_byte+1,7
	GOTO  m021
	MOVF  my_byte,W
	IORWF my_byte+1,W
	BTFSC 0x03,Zero_
	GOTO  m021
			;                    {
			;                        temp = my_byte % (uns16)10;
	MOVF  my_byte,W
	MOVWF C2tmp
	MOVF  my_byte+1,W
	MOVWF C2tmp+1
	CLRF  temp
	MOVLW .16
	MOVWF C1cnt
m015	RLF   C2tmp,1
	RLF   C2tmp+1,1
	RLF   temp,1
	BTFSC 0x03,Carry
	GOTO  m016
	MOVLW .10
	SUBWF temp,W
	BTFSS 0x03,Carry
	GOTO  m017
m016	MOVLW .10
	SUBWF temp,1
m017	DECFSZ C1cnt,1
	GOTO  m015
			;                        decimal_output[m] = temp;
	MOVLW .58
	ADDWF m,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  temp,W
	MOVWF INDF
			;                        my_byte = my_byte / (uns16)10;               
	MOVF  my_byte,W
	MOVWF C4tmp
	MOVF  my_byte+1,W
	MOVWF C4tmp+1
	CLRF  C5rem
	MOVLW .16
	MOVWF C3cnt
m018	RLF   C4tmp,1
	RLF   C4tmp+1,1
	RLF   C5rem,1
	BTFSC 0x03,Carry
	GOTO  m019
	MOVLW .10
	SUBWF C5rem,W
	BTFSS 0x03,Carry
	GOTO  m020
m019	MOVLW .10
	SUBWF C5rem,1
	BSF   0x03,Carry
m020	RLF   my_byte,1
	RLF   my_byte+1,1
	DECFSZ C3cnt,1
	GOTO  m018
			;                    }
	DECF  m,1
	GOTO  m014
			;                
			;                    for(m++ ; m < 5 ; m++)
m021	INCF  m,1
m022	MOVLW .5
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m028
			;                        putc(bin2Hex(decimal_output[m]));
	MOVLW .58
	ADDWF m,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  INDF,W
	CALL  bin2Hex
	CALL  putc
	INCF  m,1
	GOTO  m022
			;                }
			;    
			;            } //End Decimal
			;            else if (k == 'h') //Print Hex
m023	MOVF  k,W
	XORLW .104
	BTFSS 0x03,Zero_
	GOTO  m025
			;            {
			;                //New trick 3-15-04
			;                putc('0');
	MOVLW .48
	CALL  putc
			;                putc('x');
	MOVLW .120
	CALL  putc
			;                
			;                if(my_byte > 0x00FF)
	BTFSC my_byte+1,7
	GOTO  m024
	MOVF  my_byte+1,1
	BTFSC 0x03,Zero_
	GOTO  m024
			;                {
			;                    putc(bin2Hex(my_byte.high8 >> 4));
	SWAPF my_byte+1,W
	ANDLW .15
	CALL  bin2Hex
	CALL  putc
			;                    putc(bin2Hex(my_byte.high8 & 0b.0000.1111));
	MOVLW .15
	ANDWF my_byte+1,W
	CALL  bin2Hex
	CALL  putc
			;                }
			;
			;                putc(bin2Hex(my_byte.low8 >> 4));
m024	SWAPF my_byte,W
	ANDLW .15
	CALL  bin2Hex
	CALL  putc
			;                putc(bin2Hex(my_byte.low8 & 0b.0000.1111));
	MOVLW .15
	ANDWF my_byte,W
	CALL  bin2Hex
	CALL  putc
			;
			;                /*high_byte.3 = my_byte.7;
			;                high_byte.2 = my_byte.6;
			;                high_byte.1 = my_byte.5;
			;                high_byte.0 = my_byte.4;
			;            
			;                low_byte.3 = my_byte.3;
			;                low_byte.2 = my_byte.2;
			;                low_byte.1 = my_byte.1;
			;                low_byte.0 = my_byte.0;
			;        
			;                putc('0');
			;                putc('x');
			;            
			;                putc(bin2Hex(high_byte));
			;                putc(bin2Hex(low_byte));*/
			;            } //End Hex
			;            else if (k == 'f') //Print Float
	GOTO  m028
m025	MOVF  k,W
	XORLW .102
	BTFSS 0x03,Zero_
	GOTO  m026
			;            {
			;                putc('!');
	MOVLW .33
	CALL  putc
			;            } //End Float
			;            else if (k == 'u') //Print Direct Character
	GOTO  m028
m026	MOVF  k,W
	XORLW .117
	BTFSS 0x03,Zero_
	GOTO  m028
			;            {
			;                //All ascii characters below 20 are special and screwy characters
			;                //if(my_byte > 20) 
			;                    putc(my_byte);
	MOVF  my_byte,W
	CALL  putc
			;            } //End Direct
			;                        
			;        } //End Special Chars           
			;
			;        else
	GOTO  m028
			;            putc(k);
m027	MOVF  k,W
	CALL  putc
			;    }    
m028	INCF  i,1
	GOTO  m006

  ; FILE D:\Pics\code\16F88\RTC-Demo\rtc-demo.c
			;
			;#include "\Pics\code\stdio.c"   //Software based Basic Serial IO
m029	RETURN

  ; FILE \Pics\code\16F88\RTC-Demo\I2c.c
			;/*
			;    5/29/02
			;    Copyright Spark Fun Electronics 2004
			;
			;    Nathan Seidle
			;    spark@sparkfun.com
			;    
			;    I2C Interface with 24LC04B
			;    Started on 5-19
			;    12:22am 5-29 First Working I2C - DAH! 10 $#@%ing days
			;    12:51am 5-29 Cleaned up - 4MHz Operation
			;    
			;    7-20 Added page selection
			;    
			;    9-23 Started working with SOIC 24LC16B - 16k baby!
			;         Need to increase page_num to full byte. 
			;         Bits 2 1 0 control up to 8 256byte pages.
			;         
			;     
			;    7-23-03 Touched up.
			;    
			;    8-7-03 Moved to 24LC32A - 4k bytes. But now we have to have three byte transmission
			;           for each read/write. The A0,A1,A2 must also be tied high/low.
			;    
			;    9-7-03 Added Ack_polling to both read and write routines. This fixed many small
			;           graphical errors on the display.
			;           
			;    11-23-04 Tweaked for use with the DS1307 RTC Module
			;             Can we use the internal pull-up resistors on the PIC for the required 
			;             resistors on the I2C bus? Yep - neat!
			;    
			;*/
			;
			;
			;//=================
			;//Make sure the bits agree with the TRISB statements
			;#pragma bit scl_IIC @ PORTB.0
			;#pragma bit sda_IIC @ PORTB.1
			;
			;#define  WRITE_sda() TRISB = TRISB & 0b.1111.1101 //SDA must be output when writing
			;#define  READ_sda() {TRISB = TRISB | 0b.0000.0010; OPTION.7 = 0;} //SDA must be input when reading - Enable pull-up resistor on SDA
			;
			;#define DEVICE_ADDRESS  0xD0
			;//=================
			;
			;void start(void);
			;void stop(void);
			;int  read_byte(void);
			;void send_byte(uns8);
			;int  read_eeprom(uns16);
			;void write_eeprom(uns16, uns8);
			;
			;void ack_polling(void)
			;{
ack_polling
			;    while(sda_IIC != 0)
m030	BTFSS 0x06,sda_IIC
	GOTO  stop
			;    {
			;        start();
	CALL  start
			;        send_byte(DEVICE_ADDRESS);
	MOVLW .208
	CALL  send_byte
			;    }
	GOTO  m030
			;    stop();
			;}
			;
			;void write_eeprom(uns16 address, uns8 thing)
			;{
write_eeprom
	MOVWF thing
			;    ack_polling();
	CALL  ack_polling
			;    
			;    start();
	CALL  start
			;    send_byte(DEVICE_ADDRESS);
	MOVLW .208
	CALL  send_byte
			;
			;    //send_byte(address.high8); //Uppder Address - Needed for >= 32k EEProms
			;    send_byte(address.low8);
	MOVF  address,W
	CALL  send_byte
			;    send_byte(thing);
	MOVF  thing,W
	CALL  send_byte
			;    stop();
	GOTO  stop
			;}
			;
			;int read_eeprom(uns16 address)
			;{
read_eeprom
			;    ack_polling();
	CALL  ack_polling
			;    
			;    start();
	CALL  start
			;    send_byte(DEVICE_ADDRESS);
	MOVLW .208
	CALL  send_byte
			;    //send_byte(address.high8); //Uppder Address - Needed for >= 32k EEProms
			;    send_byte(address.low8);
	MOVF  address_2,W
	CALL  send_byte
			;    stop();
	CALL  stop
			;
			;    start();
	CALL  start
			;    send_byte(DEVICE_ADDRESS | 0b.0000.0001); //Read bit must be set
	MOVLW .209
	CALL  send_byte
			;    address = read_byte();
	CALL  read_byte
	MOVWF address_2
	CLRF  address_2+1
	BTFSC address_2,7
	DECF  address_2+1,1
			;    stop();
	CALL  stop
			;    
			;    return(address);
	MOVF  address_2,W
	RETURN
			;}
			;
			;void start(void)
			;{
start
			;    WRITE_sda();
	BSF   0x03,RP0
	BCF   TRISB,1
			;    sda_IIC = 0;
	BCF   0x03,RP0
	BCF   0x06,sda_IIC
			;}
	RETURN
			;
			;void stop(void)
			;{
stop
			;    scl_IIC = 0;
	BCF   0x06,scl_IIC
			;
			;    WRITE_sda();
	BSF   0x03,RP0
	BCF   TRISB,1
			;
			;    sda_IIC = 0;
	BCF   0x03,RP0
	BCF   0x06,sda_IIC
			;    nop();
	NOP  
			;    nop();
	NOP  
			;    nop();
	NOP  
			;    nop();
	NOP  
			;    scl_IIC = 1;
	BSF   0x06,scl_IIC
			;    nop();
	NOP  
			;    nop();
	NOP  
			;    nop();
	NOP  
			;    sda_IIC = 1;
	BSF   0x06,sda_IIC
			;}
	RETURN
			;
			;int read_byte(void)
			;{
read_byte
			;    int j, in_byte;
			;
			;    scl_IIC = 0;
	BCF   0x06,scl_IIC
			;
			;    READ_sda();
	BSF   0x03,RP0
	BSF   TRISB,1
	BCF   OPTION_REG,7
			;
			;    for(j = 0 ; j < 8 ; j++)
	BCF   0x03,RP0
	CLRF  j
m031	BTFSC j,7
	GOTO  m032
	MOVLW .8
	SUBWF j,W
	BTFSC 0x03,Carry
	GOTO  m033
			;    {
			;        scl_IIC = 0;
m032	BCF   0x06,scl_IIC
			;        nop();
	NOP  
			;        nop();
	NOP  
			;        nop();
	NOP  
			;        nop();
	NOP  
			;        scl_IIC = 1;
	BSF   0x06,scl_IIC
			;
			;        in_byte = rl(in_byte);
	RLF   in_byte,1
			;        in_byte.0 = sda_IIC;
	BCF   in_byte,0
	BTFSC 0x06,sda_IIC
	BSF   in_byte,0
			;    }
	INCF  j,1
	GOTO  m031
			;
			;    return(in_byte);
m033	MOVF  in_byte,W
	RETURN
			;}
			;
			;void send_byte(uns8 nate)
			;{
send_byte
	MOVWF nate_3
			;    int i;
			;
			;    WRITE_sda();
	BSF   0x03,RP0
	BCF   TRISB,1
			;
			;    for( i = 0 ; i < 8 ; i++ )
	BCF   0x03,RP0
	CLRF  i_2
m034	BTFSC i_2,7
	GOTO  m035
	MOVLW .8
	SUBWF i_2,W
	BTFSC 0x03,Carry
	GOTO  m036
			;    {
			;        nate = rl(nate);
m035	RLF   nate_3,1
			;        scl_IIC = 0;
	BCF   0x06,scl_IIC
			;        sda_IIC = Carry;
	BTFSS 0x03,Carry
	BCF   0x06,sda_IIC
	BTFSC 0x03,Carry
	BSF   0x06,sda_IIC
			;        scl_IIC = 1;
	BSF   0x06,scl_IIC
			;        nop();
	NOP  
			;    }
	INCF  i_2,1
	GOTO  m034
			;
			;    //read ack.
			;    scl_IIC = 0;
m036	BCF   0x06,scl_IIC
			;    READ_sda();
	BSF   0x03,RP0
	BSF   TRISB,1
	BCF   OPTION_REG,7
			;    scl_IIC = 1;
	BCF   0x03,RP0
	BSF   0x06,scl_IIC

  ; FILE D:\Pics\code\16F88\RTC-Demo\rtc-demo.c
			;#include "\Pics\code\16F88\RTC-Demo\I2c.c"   //Software based I2C routines
	RETURN
			;
			;void boot_up(void);
			;void rtc_programming(void);
			;void read_rtc(void);
			;
			;void main(void)
			;{
main
			;    uns8 choice;
			;    
			;    boot_up();
	BSF   0x03,RP0
	BCF   0x03,RP1
	CALL  boot_up
			;        
			;    while(1)
			;    {
			;        printf("\n\r\n\r========RTC DEMO========\n\r", 0);
m037	CLRF  nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        printf("Main Menu:\n\r", 0);
	MOVLW .31
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        printf(" 1) Program RTC Module\n\r", 0);
	MOVLW .44
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        printf(" 2) Check RTC Time\n\r", 0);
	MOVLW .69
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        printf("\n\r : ", 0);
	MOVLW .90
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        
			;        choice = getc();
	CALL  getc
	MOVWF choice
			;        
			;        if (choice == '1')
	XORLW .49
	BTFSS 0x03,Zero_
	GOTO  m038
			;        {
			;            rtc_programming();
	CALL  rtc_programming
			;        }
			;        else if (choice == '2')
	GOTO  m037
m038	MOVF  choice,W
	XORLW .50
	BTFSS 0x03,Zero_
	GOTO  m039
			;        {
			;            read_rtc();
	CALL  read_rtc
			;        }
			;        else
	GOTO  m037
			;        {
			;            printf("choice = %d", choice);
m039	MOVLW .96
	MOVWF nate_2
	CLRF  nate_2+1
	MOVF  choice,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;        }
			;    }
	GOTO  m037
			;
			;    while(1);
m040	GOTO  m040
			;}//End Main
			;
			;//Read current RTC - Converts BCD bytes to printable numerals
			;void read_rtc(void)
			;{
read_rtc
			;    //SCL is connected to RB0
			;    //SDA is connected to RB1
			;    
			;    //All numbers are in BCD form
			;
			;    uns8 x, temp;
			;    
			;    printf("\n\n\rCurrent Time and Date:\n\n\r  ", 0);
	MOVLW .108
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;
			;    //=======================
			;    x = read_eeprom(2); //Read hours register
	MOVLW .2
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    temp = x & 0b.0001.0000; //Avoid the hour settings
	MOVLW .16
	ANDWF x_2,W
	MOVWF temp_2
			;    temp >>= 4;
	SWAPF temp_2,W
	ANDLW .15
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;
			;    temp = x & 0b.0000.1111; //Get hours - low number
	MOVLW .15
	ANDWF x_2,W
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;    //=======================
			;    
			;    putc(':');
	MOVLW .58
	CALL  putc
			;
			;    //=======================
			;    x = read_eeprom(1); //Minutes
	MOVLW .1
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    temp = x & 0b.1111.0000;
	MOVLW .240
	ANDWF x_2,W
	MOVWF temp_2
			;    temp >>= 4;
	SWAPF temp_2,W
	ANDLW .15
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;
			;    temp = x & 0b.0000.1111;
	MOVLW .15
	ANDWF x_2,W
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;    //=======================
			;    
			;    putc(':');
	MOVLW .58
	CALL  putc
			;
			;    //=======================
			;    x = read_eeprom(0); //Seconds
	CLRF  address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    temp = x & 0b.0111.0000; //Avoid the CH bit
	MOVLW .112
	ANDWF x_2,W
	MOVWF temp_2
			;    temp >>= 4;
	SWAPF temp_2,W
	ANDLW .15
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;    
			;    temp = x & 0b.0000.1111;
	MOVLW .15
	ANDWF x_2,W
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;    //=======================
			;    
			;    putc(' ');
	MOVLW .32
	CALL  putc
			;
			;    x = read_eeprom(2); //Read hours register for AM/PM
	MOVLW .2
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    if(x.5 == 1) printf("PM" , 0);
	BTFSS x_2,5
	GOTO  m041
	MOVLW .177
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    else printf("AM", 0);
	GOTO  m042
m041	MOVLW .180
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;
			;    //=======================
			;
			;    printf(" - ", 0);
m042	MOVLW .139
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;
			;    //=======================
			;    x = read_eeprom(3); //Read day
	MOVLW .3
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    if(x == 1) printf("Sunday", 0);
	DECFSZ x_2,W
	GOTO  m043
	MOVLW .243
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 2) printf("Monday", 0);
m043	MOVF  x_2,W
	XORLW .2
	BTFSS 0x03,Zero_
	GOTO  m044
	MOVLW .250
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 3) printf("Tuesday", 0);
m044	MOVF  x_2,W
	XORLW .3
	BTFSS 0x03,Zero_
	GOTO  m045
	MOVLW .1
	MOVWF nate_2
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 4) printf("Wednesday", 0);
m045	MOVF  x_2,W
	XORLW .4
	BTFSS 0x03,Zero_
	GOTO  m046
	MOVLW .9
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 5) printf("Thursday", 0);
m046	MOVF  x_2,W
	XORLW .5
	BTFSS 0x03,Zero_
	GOTO  m047
	MOVLW .19
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 6) printf("Friday", 0);
m047	MOVF  x_2,W
	XORLW .6
	BTFSS 0x03,Zero_
	GOTO  m048
	MOVLW .28
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 7) printf("Saturday", 0);
m048	MOVF  x_2,W
	XORLW .7
	BTFSS 0x03,Zero_
	GOTO  m049
	MOVLW .35
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    
			;    putc(' ');
m049	MOVLW .32
	CALL  putc
			;    //=======================
			;    x = read_eeprom(5); //Read month
	MOVLW .5
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    
			;    temp = x & 0b.1111.0000; //Decode to month number
	MOVLW .240
	ANDWF x_2,W
	MOVWF temp_2
			;    x = x & 0b.0000.1111;
	MOVLW .15
	ANDWF x_2,1
			;    temp >>= 4;
	SWAPF temp_2,W
	ANDLW .15
	MOVWF temp_2
			;    temp *= 10;
	BCF   0x03,Carry
	RLF   temp_2,W
	MOVWF C7tmp
	CLRF  temp_2
	MOVLW .5
	MOVWF C6cnt
m050	MOVF  C7tmp,W
	ADDWF temp_2,1
	DECFSZ C6cnt,1
	GOTO  m050
			;    x = x + temp; //We now have a month number in x
	MOVF  temp_2,W
	ADDWF x_2,1
			;    if(x == 1) printf("January", 0); 
	DECFSZ x_2,W
	GOTO  m051
	MOVLW .44
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 2) printf("February", 0); 
m051	MOVF  x_2,W
	XORLW .2
	BTFSS 0x03,Zero_
	GOTO  m052
	MOVLW .52
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 3) printf("March", 0); 
m052	MOVF  x_2,W
	XORLW .3
	BTFSS 0x03,Zero_
	GOTO  m053
	MOVLW .61
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 4) printf("April", 0); 
m053	MOVF  x_2,W
	XORLW .4
	BTFSS 0x03,Zero_
	GOTO  m054
	MOVLW .67
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 5) printf("May", 0); 
m054	MOVF  x_2,W
	XORLW .5
	BTFSS 0x03,Zero_
	GOTO  m055
	MOVLW .73
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 6) printf("June", 0); 
m055	MOVF  x_2,W
	XORLW .6
	BTFSS 0x03,Zero_
	GOTO  m056
	MOVLW .77
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 7) printf("July", 0); 
m056	MOVF  x_2,W
	XORLW .7
	BTFSS 0x03,Zero_
	GOTO  m057
	MOVLW .82
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 8) printf("August", 0); 
m057	MOVF  x_2,W
	XORLW .8
	BTFSS 0x03,Zero_
	GOTO  m058
	MOVLW .87
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 9) printf("September", 0); 
m058	MOVF  x_2,W
	XORLW .9
	BTFSS 0x03,Zero_
	GOTO  m059
	MOVLW .94
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 10) printf("October", 0); 
m059	MOVF  x_2,W
	XORLW .10
	BTFSS 0x03,Zero_
	GOTO  m060
	MOVLW .104
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 11) printf("November", 0); 
m060	MOVF  x_2,W
	XORLW .11
	BTFSS 0x03,Zero_
	GOTO  m061
	MOVLW .112
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    if(x == 12) printf("December", 0); 
m061	MOVF  x_2,W
	XORLW .12
	BTFSS 0x03,Zero_
	GOTO  m062
	MOVLW .121
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    
			;    putc(' ');
m062	MOVLW .32
	CALL  putc
			;    //=======================
			;    
			;    //=======================
			;    x = read_eeprom(4); //Read date
	MOVLW .4
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    
			;    temp = x & 0b.1111.0000; //Decode date to a number
	MOVLW .240
	ANDWF x_2,W
	MOVWF temp_2
			;    temp >>= 4;
	SWAPF temp_2,W
	ANDLW .15
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;
			;    temp = x & 0b.0000.1111;
	MOVLW .15
	ANDWF x_2,W
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;    
			;    putc(',');
	MOVLW .44
	CALL  putc
			;    putc(' ');
	MOVLW .32
	CALL  putc
			;    //=======================
			;
			;    //=======================
			;    x = read_eeprom(6); //Read year
	MOVLW .6
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;
			;    printf("20", 0);
	MOVLW .143
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    
			;    temp = x & 0b.1111.0000; //Decode year to a number
	MOVLW .240
	ANDWF x_2,W
	MOVWF temp_2
			;    temp >>= 4;
	SWAPF temp_2,W
	ANDLW .15
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;
			;    temp = x & 0b.0000.1111;
	MOVLW .15
	ANDWF x_2,W
	MOVWF temp_2
			;    temp += '0';
	MOVLW .48
	ADDWF temp_2,1
			;    putc(temp);
	MOVF  temp_2,W
	CALL  putc
			;    //=======================
			;
			;    x = read_eeprom(7);
	MOVLW .7
	MOVWF address_2
	CLRF  address_2+1
	CALL  read_eeprom
	MOVWF x_2
			;    printf("\n\r  SQW Settings : %h ", x);
	MOVLW .146
	MOVWF nate_2
	CLRF  nate_2+1
	MOVF  x_2,W
	MOVWF my_byte
	CLRF  my_byte+1
	GOTO  printf
			;}
			;
			;//Allow user to input the current Calendar data and time into the DS1307 RTC
			;void rtc_programming(void)
			;{
rtc_programming
			;    //SCL is connected to RB0
			;    //SDA is connected to RB1
			;    
			;    uns8 temp, cell = 1, data_byte_in;
	MOVLW .1
	MOVWF cell
			;    
			;    uns8 hours = 1, minutes = 1, seconds = 1;
	MOVWF hours
	MOVWF minutes
	MOVWF seconds
			;    bit am_pm;
			;    #define PM 1
			;    #define AM 0
			;    
			;    //Time configuration
			;    //=========================================================
			;    printf("\n\r a/s change cell | +/- increase/decrease | p to program\n\r", 0);
	MOVLW .183
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;
			;    //Display delay and adjust as we go...
			;    while(1)
			;    {
			;        printf("%d:", hours);
m063	MOVLW .169
	MOVWF nate_2
	CLRF  nate_2+1
	MOVF  hours,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;        printf("%d:", minutes);
	MOVLW .169
	MOVWF nate_2
	CLRF  nate_2+1
	MOVF  minutes,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;        printf("%d ", seconds);
	MOVLW .173
	MOVWF nate_2
	CLRF  nate_2+1
	MOVF  seconds,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;        
			;        if (am_pm == PM) printf("PM", 0);
	BTFSS 0x2B,am_pm
	GOTO  m064
	MOVLW .177
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if (am_pm == AM) printf("AM", 0);
m064	BTFSC 0x2B,am_pm
	GOTO  m065
	MOVLW .180
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;
			;        data_byte_in = getc();
m065	CALL  getc
	MOVWF data_byte_in
			;        if(data_byte_in == 'a' && cell > 1) cell--;
	XORLW .97
	BTFSS 0x03,Zero_
	GOTO  m066
	MOVLW .2
	SUBWF cell,W
	BTFSC 0x03,Carry
	DECF  cell,1
			;        if(data_byte_in == 's' && cell < 4) cell++;
m066	MOVF  data_byte_in,W
	XORLW .115
	BTFSS 0x03,Zero_
	GOTO  m067
	MOVLW .4
	SUBWF cell,W
	BTFSS 0x03,Carry
	INCF  cell,1
			;
			;        if(data_byte_in == '+')
m067	MOVF  data_byte_in,W
	XORLW .43
	BTFSS 0x03,Zero_
	GOTO  m068
			;        {
			;            if(cell == 1) hours++;
	DECF  cell,W
	BTFSC 0x03,Zero_
	INCF  hours,1
			;            if(cell == 2) minutes++;
	MOVF  cell,W
	XORLW .2
	BTFSC 0x03,Zero_
	INCF  minutes,1
			;            if(cell == 3) seconds++;
	MOVF  cell,W
	XORLW .3
	BTFSC 0x03,Zero_
	INCF  seconds,1
			;            if(cell == 4) am_pm ^= 1;
	MOVF  cell,W
	XORLW .4
	BTFSS 0x03,Zero_
	GOTO  m068
	MOVLW .1
	XORWF TtmpA43,1
			;        }
			;        if(data_byte_in == '-')
m068	MOVF  data_byte_in,W
	XORLW .45
	BTFSS 0x03,Zero_
	GOTO  m069
			;        {
			;            if(cell == 1) hours--;
	DECF  cell,W
	BTFSC 0x03,Zero_
	DECF  hours,1
			;            if(cell == 2) minutes--;
	MOVF  cell,W
	XORLW .2
	BTFSC 0x03,Zero_
	DECF  minutes,1
			;            if(cell == 3) seconds--;
	MOVF  cell,W
	XORLW .3
	BTFSC 0x03,Zero_
	DECF  seconds,1
			;            if(cell == 4) am_pm ^= 1;
	MOVF  cell,W
	XORLW .4
	BTFSS 0x03,Zero_
	GOTO  m069
	MOVLW .1
	XORWF TtmpA43,1
			;        }
			;        
			;        if(data_byte_in == 'p') break;
m069	MOVF  data_byte_in,W
	XORLW .112
	BTFSC 0x03,Zero_
	GOTO  m070
			;
			;        putc('\r');
	MOVLW .13
	CALL  putc
			;        
			;    }
	GOTO  m063
			;
			;    temp = seconds / 10; //Convert seconds into BCD
m070	MOVF  seconds,W
	MOVWF C9tmp
	CLRF  C10rem
	MOVLW .8
	MOVWF C8cnt
m071	RLF   C9tmp,1
	RLF   C10rem,1
	MOVLW .10
	SUBWF C10rem,W
	BTFSS 0x03,Carry
	GOTO  m072
	MOVLW .10
	SUBWF C10rem,1
	BSF   0x03,Carry
m072	RLF   temp_3,1
	DECFSZ C8cnt,1
	GOTO  m071
			;    temp <<= 4;
	SWAPF temp_3,W
	ANDLW .240
	MOVWF temp_3
			;    printf(" --%h-- ", seconds);
	MOVLW .146
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	MOVF  seconds,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;    seconds %= 10;
	MOVF  seconds,W
	MOVWF C12tmp
	CLRF  seconds
	MOVLW .8
	MOVWF C11cnt
m073	RLF   C12tmp,1
	RLF   seconds,1
	MOVLW .10
	SUBWF seconds,W
	BTFSS 0x03,Carry
	GOTO  m074
	MOVLW .10
	SUBWF seconds,1
m074	DECFSZ C11cnt,1
	GOTO  m073
			;    printf(" --%h-- ", seconds);
	MOVLW .146
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	MOVF  seconds,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;    seconds = temp | seconds;
	MOVF  temp_3,W
	IORWF seconds,1
			;    seconds &= 0b.0111.1111; //CH Bit is bit 7 - 0 to enable clock.
	BCF   seconds,7
			;    write_eeprom(0, seconds); //Load seconds register
	CLRF  address
	CLRF  address+1
	MOVF  seconds,W
	CALL  write_eeprom
			;
			;    temp = minutes / 10; //Convert minutes into BCD
	MOVF  minutes,W
	MOVWF C14tmp
	CLRF  C15rem
	MOVLW .8
	MOVWF C13cnt
m075	RLF   C14tmp,1
	RLF   C15rem,1
	MOVLW .10
	SUBWF C15rem,W
	BTFSS 0x03,Carry
	GOTO  m076
	MOVLW .10
	SUBWF C15rem,1
	BSF   0x03,Carry
m076	RLF   temp_3,1
	DECFSZ C13cnt,1
	GOTO  m075
			;    temp <<= 4;
	SWAPF temp_3,W
	ANDLW .240
	MOVWF temp_3
			;    minutes %= 10;
	MOVF  minutes,W
	MOVWF C17tmp
	CLRF  minutes
	MOVLW .8
	MOVWF C16cnt
m077	RLF   C17tmp,1
	RLF   minutes,1
	MOVLW .10
	SUBWF minutes,W
	BTFSS 0x03,Carry
	GOTO  m078
	MOVLW .10
	SUBWF minutes,1
m078	DECFSZ C16cnt,1
	GOTO  m077
			;    minutes = temp | minutes;
	MOVF  temp_3,W
	IORWF minutes,1
			;    write_eeprom(1, minutes); //Load minutes register
	MOVLW .1
	MOVWF address
	CLRF  address+1
	MOVF  minutes,W
	CALL  write_eeprom
			;
			;    /*
			;    Hour settings : 
			;    
			;    Bit # - Programmed Setting : Description
			;    7 - 0 : 
			;    6 - 1 : 12Hr or 24Hr Mode - High for AM/PM 12Hr. Mode
			;    5 - 1 : AM/PM bit - Set to PM
			;    4 - 0 : 
			;    
			;    3 - 1 : 
			;    2 - 0 :
			;    1 - 0 :
			;    0 - 0 : Set to 8 hours
			;    */
			;    temp = hours / 10; //Convert hours into BCD
	MOVF  hours,W
	MOVWF C19tmp
	CLRF  C20rem
	MOVLW .8
	MOVWF C18cnt
m079	RLF   C19tmp,1
	RLF   C20rem,1
	MOVLW .10
	SUBWF C20rem,W
	BTFSS 0x03,Carry
	GOTO  m080
	MOVLW .10
	SUBWF C20rem,1
	BSF   0x03,Carry
m080	RLF   temp_3,1
	DECFSZ C18cnt,1
	GOTO  m079
			;    temp <<= 4;
	SWAPF temp_3,W
	ANDLW .240
	MOVWF temp_3
			;    hours %= 10;
	MOVF  hours,W
	MOVWF C22tmp
	CLRF  hours
	MOVLW .8
	MOVWF C21cnt
m081	RLF   C22tmp,1
	RLF   hours,1
	MOVLW .10
	SUBWF hours,W
	BTFSS 0x03,Carry
	GOTO  m082
	MOVLW .10
	SUBWF hours,1
m082	DECFSZ C21cnt,1
	GOTO  m081
			;    hours = temp | hours;
	MOVF  temp_3,W
	IORWF hours,1
			;    hours |= 0b.0100.0000; //Force 12hr mode
	BSF   hours,6
			;    if(am_pm == PM) hours |= 0b.0010.0000; //Force AM/PM bit
	BTFSC 0x2B,am_pm
	BSF   hours,5
			;    if(am_pm == AM) hours &= 0b.1101.1111; //Force AM/PM bit
	BTFSS 0x2B,am_pm
	BCF   hours,5
			;    write_eeprom(2, hours); //Write hour configuration
	MOVLW .2
	MOVWF address
	CLRF  address+1
	MOVF  hours,W
	CALL  write_eeprom
			;    //=========================================================
			;
			;    //Date configuration
			;    //=========================================================
			;    cell = 1;
	MOVLW .1
	MOVWF cell
			;    uns8 day = 1, month = 1, date = 1, year = 4;
	MOVWF day
	MOVWF month
	MOVWF date
	MOVLW .4
	MOVWF year
			;
			;    printf("\n\r a/s change cell | +/- increase/decrease | p to program\n\r", 0);
	MOVLW .183
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;
			;    while(1)
			;    {
			;        if(day == 1) printf("Sunday", 0);
m083	DECFSZ day,W
	GOTO  m084
	MOVLW .243
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(day == 2) printf("Monday", 0);
m084	MOVF  day,W
	XORLW .2
	BTFSS 0x03,Zero_
	GOTO  m085
	MOVLW .250
	MOVWF nate_2
	CLRF  nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(day == 3) printf("Tuesday", 0);
m085	MOVF  day,W
	XORLW .3
	BTFSS 0x03,Zero_
	GOTO  m086
	MOVLW .1
	MOVWF nate_2
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(day == 4) printf("Wednesday", 0);
m086	MOVF  day,W
	XORLW .4
	BTFSS 0x03,Zero_
	GOTO  m087
	MOVLW .9
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(day == 5) printf("Thursday", 0);
m087	MOVF  day,W
	XORLW .5
	BTFSS 0x03,Zero_
	GOTO  m088
	MOVLW .19
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(day == 6) printf("Friday", 0);
m088	MOVF  day,W
	XORLW .6
	BTFSS 0x03,Zero_
	GOTO  m089
	MOVLW .28
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(day == 7) printf("Saturday", 0);
m089	MOVF  day,W
	XORLW .7
	BTFSS 0x03,Zero_
	GOTO  m090
	MOVLW .35
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        
			;        putc(' ');
m090	MOVLW .32
	CALL  putc
			;    
			;        if(month == 1) printf("January", 0); 
	DECFSZ month,W
	GOTO  m091
	MOVLW .44
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 2) printf("February", 0); 
m091	MOVF  month,W
	XORLW .2
	BTFSS 0x03,Zero_
	GOTO  m092
	MOVLW .52
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 3) printf("March", 0); 
m092	MOVF  month,W
	XORLW .3
	BTFSS 0x03,Zero_
	GOTO  m093
	MOVLW .61
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 4) printf("April", 0); 
m093	MOVF  month,W
	XORLW .4
	BTFSS 0x03,Zero_
	GOTO  m094
	MOVLW .67
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 5) printf("May", 0); 
m094	MOVF  month,W
	XORLW .5
	BTFSS 0x03,Zero_
	GOTO  m095
	MOVLW .73
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 6) printf("June", 0); 
m095	MOVF  month,W
	XORLW .6
	BTFSS 0x03,Zero_
	GOTO  m096
	MOVLW .77
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 7) printf("July", 0); 
m096	MOVF  month,W
	XORLW .7
	BTFSS 0x03,Zero_
	GOTO  m097
	MOVLW .82
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 8) printf("August", 0); 
m097	MOVF  month,W
	XORLW .8
	BTFSS 0x03,Zero_
	GOTO  m098
	MOVLW .87
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 9) printf("September", 0); 
m098	MOVF  month,W
	XORLW .9
	BTFSS 0x03,Zero_
	GOTO  m099
	MOVLW .94
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 10) printf("October", 0); 
m099	MOVF  month,W
	XORLW .10
	BTFSS 0x03,Zero_
	GOTO  m100
	MOVLW .104
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 11) printf("November", 0); 
m100	MOVF  month,W
	XORLW .11
	BTFSS 0x03,Zero_
	GOTO  m101
	MOVLW .112
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        if(month == 12) printf("December", 0); 
m101	MOVF  month,W
	XORLW .12
	BTFSS 0x03,Zero_
	GOTO  m102
	MOVLW .121
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;        
			;        printf(" %d,", date);
m102	MOVLW .130
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	MOVF  date,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;        
			;        printf(" 200%d    ", year);
	MOVLW .135
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	MOVF  year,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;        
			;        data_byte_in = getc();
	CALL  getc
	MOVWF data_byte_in
			;        if(data_byte_in == 'a' && cell > 1) cell--;
	XORLW .97
	BTFSS 0x03,Zero_
	GOTO  m103
	MOVLW .2
	SUBWF cell,W
	BTFSC 0x03,Carry
	DECF  cell,1
			;        if(data_byte_in == 's' && cell < 4) cell++;
m103	MOVF  data_byte_in,W
	XORLW .115
	BTFSS 0x03,Zero_
	GOTO  m104
	MOVLW .4
	SUBWF cell,W
	BTFSS 0x03,Carry
	INCF  cell,1
			;
			;        if(data_byte_in == '+')
m104	MOVF  data_byte_in,W
	XORLW .43
	BTFSS 0x03,Zero_
	GOTO  m105
			;        {
			;            if(cell == 1) day++;
	DECF  cell,W
	BTFSC 0x03,Zero_
	INCF  day,1
			;            if(cell == 2) month++;
	MOVF  cell,W
	XORLW .2
	BTFSC 0x03,Zero_
	INCF  month,1
			;            if(cell == 3) date++;
	MOVF  cell,W
	XORLW .3
	BTFSC 0x03,Zero_
	INCF  date,1
			;            if(cell == 4) year++;
	MOVF  cell,W
	XORLW .4
	BTFSC 0x03,Zero_
	INCF  year,1
			;        }
			;        if(data_byte_in == '-')
m105	MOVF  data_byte_in,W
	XORLW .45
	BTFSS 0x03,Zero_
	GOTO  m106
			;        {
			;            if(cell == 1) day--;
	DECF  cell,W
	BTFSC 0x03,Zero_
	DECF  day,1
			;            if(cell == 2) month--;
	MOVF  cell,W
	XORLW .2
	BTFSC 0x03,Zero_
	DECF  month,1
			;            if(cell == 3) date--;
	MOVF  cell,W
	XORLW .3
	BTFSC 0x03,Zero_
	DECF  date,1
			;            if(cell == 4) year--;
	MOVF  cell,W
	XORLW .4
	BTFSC 0x03,Zero_
	DECF  year,1
			;        }
			;        
			;        if(data_byte_in == 'p') break;
m106	MOVF  data_byte_in,W
	XORLW .112
	BTFSC 0x03,Zero_
	GOTO  m107
			;
			;        putc('\r');
	MOVLW .13
	CALL  putc
			;        
			;    }
	GOTO  m083
			;
			;    write_eeprom(3, day); //Load day register
m107	MOVLW .3
	MOVWF address
	CLRF  address+1
	MOVF  day,W
	CALL  write_eeprom
			;
			;    temp = month / 10; //Convert month into BCD
	MOVF  month,W
	MOVWF C24tmp
	CLRF  C25rem
	MOVLW .8
	MOVWF C23cnt
m108	RLF   C24tmp,1
	RLF   C25rem,1
	MOVLW .10
	SUBWF C25rem,W
	BTFSS 0x03,Carry
	GOTO  m109
	MOVLW .10
	SUBWF C25rem,1
	BSF   0x03,Carry
m109	RLF   temp_3,1
	DECFSZ C23cnt,1
	GOTO  m108
			;    temp <<= 4;
	SWAPF temp_3,W
	ANDLW .240
	MOVWF temp_3
			;    month %= 10;
	MOVF  month,W
	MOVWF C27tmp
	CLRF  month
	MOVLW .8
	MOVWF C26cnt
m110	RLF   C27tmp,1
	RLF   month,1
	MOVLW .10
	SUBWF month,W
	BTFSS 0x03,Carry
	GOTO  m111
	MOVLW .10
	SUBWF month,1
m111	DECFSZ C26cnt,1
	GOTO  m110
			;    month = temp | month;
	MOVF  temp_3,W
	IORWF month,1
			;    printf(" --%h-- ", month);
	MOVLW .146
	MOVWF nate_2
	MOVLW .1
	MOVWF nate_2+1
	MOVF  month,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;    write_eeprom(5, month); //Load month register
	MOVLW .5
	MOVWF address
	CLRF  address+1
	MOVF  month,W
	CALL  write_eeprom
			;
			;    temp = date / 10; //Convert date into BCD
	MOVF  date,W
	MOVWF C29tmp
	CLRF  C30rem
	MOVLW .8
	MOVWF C28cnt
m112	RLF   C29tmp,1
	RLF   C30rem,1
	MOVLW .10
	SUBWF C30rem,W
	BTFSS 0x03,Carry
	GOTO  m113
	MOVLW .10
	SUBWF C30rem,1
	BSF   0x03,Carry
m113	RLF   temp_3,1
	DECFSZ C28cnt,1
	GOTO  m112
			;    temp <<= 4;
	SWAPF temp_3,W
	ANDLW .240
	MOVWF temp_3
			;    date %= 10;
	MOVF  date,W
	MOVWF C32tmp
	CLRF  date
	MOVLW .8
	MOVWF C31cnt
m114	RLF   C32tmp,1
	RLF   date,1
	MOVLW .10
	SUBWF date,W
	BTFSS 0x03,Carry
	GOTO  m115
	MOVLW .10
	SUBWF date,1
m115	DECFSZ C31cnt,1
	GOTO  m114
			;    date = temp | date;
	MOVF  temp_3,W
	IORWF date,1
			;    write_eeprom(4, date); //Load date register
	MOVLW .4
	MOVWF address
	CLRF  address+1
	MOVF  date,W
	CALL  write_eeprom
			;
			;    temp = year / 10; //Convert year into BCD
	MOVF  year,W
	MOVWF C34tmp
	CLRF  C35rem
	MOVLW .8
	MOVWF C33cnt
m116	RLF   C34tmp,1
	RLF   C35rem,1
	MOVLW .10
	SUBWF C35rem,W
	BTFSS 0x03,Carry
	GOTO  m117
	MOVLW .10
	SUBWF C35rem,1
	BSF   0x03,Carry
m117	RLF   temp_3,1
	DECFSZ C33cnt,1
	GOTO  m116
			;    temp <<= 4;
	SWAPF temp_3,W
	ANDLW .240
	MOVWF temp_3
			;    year %= 10;
	MOVF  year,W
	MOVWF C37tmp
	CLRF  year
	MOVLW .8
	MOVWF C36cnt
m118	RLF   C37tmp,1
	RLF   year,1
	MOVLW .10
	SUBWF year,W
	BTFSS 0x03,Carry
	GOTO  m119
	MOVLW .10
	SUBWF year,1
m119	DECFSZ C36cnt,1
	GOTO  m118
			;    year = temp | year;
	MOVF  temp_3,W
	IORWF year,1
			;    write_eeprom(6, year); //Load year register
	MOVLW .6
	MOVWF address
	CLRF  address+1
	MOVF  year,W
	CALL  write_eeprom
			;    
			;    read_rtc(); //Print it out for double checking
	GOTO  read_rtc
			;
			;}
			;
			;void boot_up(void)
			;{
boot_up
			;    //Setup Ports
			;    ANSEL = 0b.0000.0000; //Turn off A/D
	CLRF  ANSEL
			;
			;    PORTA = 0b.0000.0000;
	BCF   0x03,RP0
	CLRF  PORTA
			;    TRISA = 0b.1111.1111;
	MOVLW .255
	BSF   0x03,RP0
	MOVWF TRISA
			;
			;    PORTB = 0b.0000.0000;
	BCF   0x03,RP0
	CLRF  PORTB
			;    TRISB = 0b.0000.0100;   //0 = Output, 1 = Input RX on RB2
	MOVLW .4
	BSF   0x03,RP0
	MOVWF TRISB
			;
			;    //Setup the hardware UART module
			;    //=============================================================
			;    //SPBRG = 51; //8MHz for 9600 inital communication baud rate
			;    SPBRG = 129; //20MHz for 9600 inital communication baud rate
	MOVLW .129
	MOVWF SPBRG
			;
			;    TXSTA = 0b.0010.0100; //8-bit asych mode, high speed uart enabled
	MOVLW .36
	MOVWF TXSTA
			;    RCSTA = 0b.1001.0000; //Serial port enable, 8-bit asych continous receive mode
	MOVLW .144
	BCF   0x03,RP0
	MOVWF RCSTA
			;    //=============================================================
			;
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x01BF P0   16 word(s)  0 % : enable_uart_TX
; 0x01CF P0   19 word(s)  0 % : enable_uart_RX
; 0x01E2 P0    6 word(s)  0 % : putc
; 0x01E8 P0    4 word(s)  0 % : getc
; 0x01EC P0   21 word(s)  1 % : bin2Hex
; 0x0201 P0  207 word(s) 10 % : printf
; 0x0004 P0  237 word(s) 11 % : _const1
; 0x02F2 P0    5 word(s)  0 % : start
; 0x02F7 P0   15 word(s)  0 % : stop
; 0x0306 P0   26 word(s)  1 % : read_byte
; 0x0320 P0   28 word(s)  1 % : send_byte
; 0x02E0 P0   18 word(s)  0 % : read_eeprom
; 0x02D6 P0   10 word(s)  0 % : write_eeprom
; 0x02D0 P0    6 word(s)  0 % : ack_polling
; 0x07BF P0   19 word(s)  0 % : boot_up
; 0x0507 P0  696 word(s) 33 % : rtc_programming
; 0x0372 P0  405 word(s) 19 % : read_rtc
; 0x033C P0   54 word(s)  2 % : main

; RAM usage: 36 bytes (36 local), 332 bytes free
; Maximum call level: 4
;  Codepage 0 has 1999 word(s) :  97 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 1793 code words (43 %)
