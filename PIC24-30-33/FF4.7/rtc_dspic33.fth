\ *******************************************************************
\    Simple RTC for FlashForth PIC24 PIC33                          *
\    Filename:      rtc_33.fth                                      *
\    Date:          3.11.2010                                       *
\    FlashForth:    FF4.7                                           *
\    Copyright:     Mikael Nordman                                  *
\    Author:        Mikael Nordman                                  *
\ *******************************************************************
\ FlashForth is licensed according to the GNU General Public License*
\ *******************************************************************
\ EXAMPLE OF HOW TO SET UP AN INTERRUPT ROUTINE
\ Disable the alternate interrupts and switch back to IVT.
\ All user defined interrupts must be disabled
\ before the  switch to IVT is made.
\ Otherwise the device will reset because
\ the unused IVT vectors point to the reset instruction.

iec0 t2ie bclr ivt

-rtc
marker -rtc
hex ram

\ The registers and bit values differ between processors
$010c con pr2
$0106 con tmr2
$0110 con t2con

$0084 con ifs0 $0007 con t2if
$0094 con iec0 $0007 con t2ie

ram
variable hsec
variable sec
variable mins
variable hour

\ Interrupt routine
: T2RtcIrq
  [i
     1 hsec +! hsec @ #4 >
     if 
       0 hsec ! 1 sec +! sec @ #59 > 
       if
         0 sec ! 1 mins +! mins @ #59 >
         if
           0 mins ! 1 hour +! hour @ #23 >
           if
             0 hour !
           then
         then
       then
     then
     [ t2if ifs0 bclr, ]
  i]
;i

\ Store the interrupt word address in the
\ Alternate Interrupt Vector Table

' T2RtcIrq #15 int!

: T2RtcInit ( -- )
  \ Calculate one second counter value
  [ Fcy #200 #256 u*/mod nip literal ] pr2 !   
  %1000000000110000 t2con ! \ / 256 prescaler
  aivt
  [ t2ie iec0 bset, ]
;

\ Display the current time
: time ( -- )
  decimal hour @ u. mins @ u. sec  @ u. ;

\ Initialise the RTC
T2RtcInit
