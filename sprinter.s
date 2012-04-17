#########################################################
#
#C-signature:   int sprinter(char *res, char *format, ...); %c %s
#
# edi == destination
# ecx == format
# edx == temp storage
# ebx == temp string pointer
# eax == bytes counter for return
# esi == temp para_offset holder
# 
# ASCII:
# % = 37, c = 99, s = 115, d = 100, x = 120
#
# Arguments start at 16(%ebp), para_offset*4=16(%ebp)-> param1 ---> para_offset+=1*4=20-> param2 etc
# If anything else is altered we have to consider increasing/decreasing para_offset in accordance
#########################################################



.globl sprinter

.data
para_offset:     .long   4


sprinter:
#init
    pushl   %ebp
    movl    %esp, %ebp
    
    #the destination (res), where we want the format
    movl    8(%ebp), %edi
    
    #format, the "string" we are reading from
    movl    12(%ebp), %ecx
    
    #set counter (in this case eax since we are returning the number of bytes read)
    movl    $0, %eax

#Go through the pattern string and copy format (n(%ebp) to dest (%edi) 
main_loop:
    
    cmpb    $0, (%ecx) 
    jz      ret_rou         #end of string
    
    cmpb    $37, (%ecx)     #ascii 37 == %
                            
                            #if char == %
    je      pros_loop       #   jump to handling of %
    
                            #else 
    movb    (%ecx), %dl     #   copy char to dest
    movb    %dl, (%edi)     #

    incl    %ecx            # 
    incl    %edi            #increase all counters
    incl    %eax            #

    jmp     main_loop       #return to main_loop for continiued check


# Når vi har et %-tegn les neste tegn (c, s, %, x og d) og switch til riktig handling
pros_loop:
    incl    %ecx            # increase sorce counter get next char...

                            # switch-ish
    cmpb    $37, (%ecx)     #   case % (ascii == 37)
    je      pros_handle 
    
    cmpb    $99, (%ecx)     #   case c (ascii == 99)
    je      c_handle
    
    cmpb    $115, (%ecx)    #   case s (ascii == 115)
    je      s_handle

    cmpb    $100, (%ecx)    #   case d (ascii == 100)
    je      d_handle

    cmpb    $120, (%ecx)    #   case x (ascii == 120)
    je      x_handle      

    jmp     fault_handle    #   default fault_handle, return -1

#double %, write % into dest string
pros_handle:
    movb    (%ecx), %dl     # copy char (%)
    movb    %dl, (%edi)     # to destination
    incl    %ecx          
    incl    %edi            # increase all counters
    incl    %eax
    jmp     main_loop       # return to main_loop
 
#c, write char from args
c_handle:
    movl    para_offset, %esi
    movl    (%ebp, %esi, 4), %ebx #move the right number of bytes into stack to find next parameter
    incl    para_offset

    #movb    16(%ebp), %bl   #TODO get first arg pointer (after src & dest), but what if its the third?
    
    movb    %bl, (%edi)     # copy to destination
    incl    %ecx            #
    incl    %edi            # increase counters
    incl    %eax            #
    jmp     main_loop       # retrun to main_loop

s_handle:
    incl    %ecx            
    movl    para_offset, %esi       #move parameter offset into esi
    movl    (%ebp, %esi, 4), %ebx   #multiply parameter offset with 4 and copy content into ebx
    incl    para_offset             #increase para_offset with one (multiplied with 4 to get next parameter)
    
    
s_loop:
    cmpb    $0, (%ebx)      #end of string
    jz      main_loop       #return to main_loop

    movb    (%ebx), %dl     #copy char to
    movb    %dl, (%edi)     #destination

    incl    %ebx            #
    incl    %edi            #increase counters
    incl    %eax            #
    jmp     s_loop          #__loop__
    

#How to predict size of arg
x_handle:
    


d_handle:


fault_handle:
    movl    $-1, %eax       #return -1...
    #clear edi?

ret_rou:
    incl    %edi
    movl    $0, %edi        #add zerobyte to the end of the string
    popl    %ebp
    ret

    


