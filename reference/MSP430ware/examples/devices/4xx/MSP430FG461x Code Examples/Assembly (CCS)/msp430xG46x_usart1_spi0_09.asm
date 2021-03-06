;******************************************************************************
;   MSP430xG46x Demo - USART1, SPI 3-Wire Master Incremented Data
;
;   Description: SPI master talks to SPI slave using 3-wire mode. Incrementing
;   data is sent by the master starting at 0x01. Received data is expected to
;   be same as the previous transmission.  USART1 RX ISR is used to handle
;   communication with the CPU, normally in LPM0. If high, P5.1 indicates
;   valid data reception.  Because all execution after LPM0 is in ISRs,
;   initialization waits for DCO to stabilize against ACLK.
;   ACLK = 32.768kHz, MCLK = SMCLK = DCO ~ 1048kHz
;
;   Use with SPI Slave Data Echo code example.  If slave is in debug mode, P5.2
;   slave reset signal conflicts with slave's JTAG; to work around, control the master
;   device
;
;                    MSP430FG461x
;                 -----------------
;             /|\|              XIN|-
;              | |                 |  32kHz xtal
;              --|RST          XOUT|-
;                |                 |
;                |             P4.3|-> Data Out (SIMO1)
;                |                 |
;          LED <-|P5.1         P4.4|<- Data In (SOMI1)
;                |                 |
;  Slave reset <-|P5.2         P4.5|-> Serial Clock Out (UCLK1)
;
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430xG46x.h"

MST_Data	.equ   R6
SLV_Data	.equ   R7
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #900,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps

OFIFGcheck  bic.b   #OFIFG,&IFG1            ; Clear OFIFG
            mov.w   #047FFh,R15             ; Wait for OFIFG to set again if
OFIFGwait   dec.w   R15                     ; not stable yet
            jnz     OFIFGwait
            bit.b   #OFIFG,&IFG1            ; Has it set again?
            jnz     OFIFGcheck              ; If so, wait some more

            mov.w   #2100,R15               ; Now with stable ACLK, wait for
DCO_delay   dec.w   R15                     ; DCO to stabilize.
            jnz     DCO_delay               ;

SetupP5     mov.b   #04h,&P5OUT             ; P5 setup for LED and slave reset
            bis.b   #06h,&P5DIR             ;
SetupP4     bis.b   #038h,&P4SEL            ; P4.5,4,3 SPI option select
SetupSPI    mov.b   #CHAR+SYNC+MM+SWRST,&U1CTL ; 8-bit, SPI, Master
            bis.b   #CKPL+SSEL1+STC,&U1TCTL ; Polarity, SMCLK, 3-wire
            mov.b   #002h,&U1BR0            ; SPICLK = SMCLK/2
            mov.b   #000h,&U1BR1            ;
            mov.b   #000h,&U1MCTL           ;
            bis.b   #USPIE1,&ME2            ; Module enable
            bic.b   #SWRST,&U1CTL           ; SPI enable
            bis.b   #URXIE1,&IE2            ; Receive interrupt enable

            bic.b   #04h,&P5OUT             ; Now with SPI signals initialized,
            bis.b   #04h,&P5OUT             ; reset slave
            mov.w   #50,R15                 ; Wait for slave to initialize
waitForSlv  dec.w   R15                     ;
            jnz     waitForSlv

            mov.b   #001h,MST_Data          ; Initialize data values
            mov.b   #000h,SLV_Data          ;

Mainloop    mov.b   MST_Data,&U1TXBUF       ; Transmit first character
            bis.b   #LPM0+GIE,SR            ; CPU off, enable interrupts
            nop                             ; Required for debugger only
                                            ;
;------------------------------------------------------------------------------
USART1RX_ISR;       Test for valid RX and TX character
;------------------------------------------------------------------------------
TX1         bit.b   #UTXIFG1,&IFG2          ; USART1 TX buffer ready?
            jz      TX1                     ; Jump is TX buffer not ready

            cmp.b   SLV_Data,&U1RXBUF       ; Test for correct character RX'd
            jeq     PASS
FAIL        bic.b   #02h,&P5OUT             ; If incorrect, clear LED
            jmp     TX2
PASS        bis.b   #02h,&P5OUT             ; If correct, light LED
TX2         inc.b   MST_Data                ; Increment master value
            inc.b   SLV_Data                ; Increment expected slave value
            mov.b   MST_Data,&U1TXBUF       ; Send next value

            mov.w   #30,R15                 ; Add time between transmissions to
cycleDelay  dec.w   R15                     ; make sure slave can keep up
            jnz     cycleDelay

            reti                            ; Exit ISR

;------------------------------------------------------------------------------
;			Interrupt Vectors
;------------------------------------------------------------------------------
            .sect	".int19"
            .short   USART1RX_ISR
            .sect	".reset"            	;	RESET Vector
            .short   RESET					;
            .end

;