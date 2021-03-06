;******************************************************************************
;     MSP430x47xx Demo - USCI_A0, UART 9600 Full-Duplex Transceiver, 32K ACLK
;
;   Description: USCI_A0 communicates continously as fast as possible full-duplx
;   with another device. Normal mode is LPM3, with activity only during RX and
;   TX ISR's. The TX ISR indicates the UART is ready to send another character.
;   The RX ISR indicates the UART has received a character. At 9600 baud, a full
;   character is tranceived ~1ms.
;   The levels on P1.4/5 are TX'ed. RX'ed value is displayed on P1.0/1.
;   ACLK = BRCLK = LFXT1 = 32768, MCLK = SMCLK = DCO~ 1048k
;   Baud rate divider with 32768hz XTAL @9600 = 32768Hz/9600 = 3.41 (0003h 4Ah )
;   //* An external watch crystal is required on XIN XOUT for ACLK *//	
;
;                 MSP430x47xx                 MSP430x47xx 
;              -----------------            -----------------
;             |              XIN|-      /|\|              XIN|-
;             |                 | 32KHz  | |                 | 32KHz
;             |             XOUT|-       --|RST          XOUT|-
;             |                 | /|\      |                 |
;             |              RST|---       |                 |
;             |                 |          |                 |
;           ->|P1.4             |          |             P5.0|-> LED
;           ->|P1.5             |          |             P5.1|-> LED
;       LED <-|P5.0             |          |             P1.4|<-
;       LED <-|P5.1             |          |             P1.5|<-
;             |     UCA0TXD/P2.4|--------->|P2.5/UCA0RXD     |
;             |                 |   9600   |                 |
;             |     UCA0RXD/P2.5|<---------|P2.4//UCA0TXD    |
;
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x47x4.h"
;-------------------------------------------------------------------------------
			.text							; Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #900h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps
OFIFGcheck  bic.b   #OFIFG,&IFG1            ; Clear OFIFG
            mov.w   #047FFh,R15             ; Wait for OFIFG to set again if
OFIFGwait   dec.w   R15                     ; not stable yet
            jnz     OFIFGwait
            bit.b   #OFIFG,&IFG1            ; Has it set again?
            jnz     OFIFGcheck              ; If so, wait some more
			
SetupP1     mov.b   #000h,&P5OUT            ; P5.0/1 setup for LED output
            bis.b   #BIT0+BIT1,&P5DIR       ;
SetupP2     bis.b   #BIT4+BIT5,&P2SEL       ; P2.4,5 USCI option select
SetupUART   bis.b   #UCSSEL_1,&UCA0CTL1     ; CLK = A0CLK
            mov.b   #03h,&UCA0BR0           ; 32k/9600 - 3.41
            mov.b   #00h,&UCA0BR1           ;
            mov.b   #06h,&UCA0MCTL          ; Modulation
            bic.b   #UCSWRST,&UCA0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCA0RXIE+UCA0TXIE,&IE2 ; Enable USCI_A0 TX/RX interrupt
                                            ;
Mainloop    bis.b   #LPM3+GIE,SR            ; Enter LPM3 w/ interrupts enabled
            nop                             ; Required for debugger only
                                            ;
;------------------------------------------------------------------------------
USCIRX_ISR;
;------------------------------------------------------------------------------
            mov.b   &UCA0RXBUF,&P5OUT       ; Display RX'ed charater
            reti                            ; Exit ISR
                                            ;
;------------------------------------------------------------------------------
USCITX_ISR;
;------------------------------------------------------------------------------
            mov.b   &P1IN,R4                ;
            rrc.b   R4                      ; Justify 4x right
            rrc.b   R4                      ;
            rrc.b   R4                      ;
            rrc.b   R4                      ;
            and.b   #03h,R4                 ;
            mov.b   R4,&UCA0TXBUF           ; Transmit character
            reti                            ; Exit ISR

;------------------------------------------------------------------------------
;			Interrupt Vectors
;------------------------------------------------------------------------------
            .sect     ".int08"        		;
            .short   USCITX_ISR             ; USCI transmit
            .sect    ".int09"       		;
            .short   USCIRX_ISR             ; USCI receive
            .sect     ".reset"            	; POR, ext. Reset, Watchdog
            .short   RESET                  ;
            .end
               