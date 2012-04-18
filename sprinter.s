#########################################################
#
#C-signature:   int sprinter(char *res, char *format, ...); %c %s
#
# edi == destination                (Must be stored)
# ecx == format                     (Must be stored)
# edx == temp storage               (Free for use)
# ebx == temp string pointer        (Free for use)
# eax == bytes counter return       (Must be stored)
# esi == temp para_offset holder    (Free for use)
# 
# ASCII:
# % = 37, c = 99, s = 115, d = 100, x = 120
#
# Arguments start at 16(%ebp), para_offset*4=16(%ebp)-> param1 ---> para_offset+=1*4=20-> param2 etc
# If anything else is altered we have to consider increasing/decreasing para_offset in accordance
#########################################################



.globl sprinter

.data
para_offset:    .long   4 #offset for argument/parameter
min_char:       .long   0 #for use when %<number><type> is used
num_bytes:      .long   0 #the number of bytes copied
hex_cpy:        .long   0

sprinter:
    #init
    pushl   %ebp
    movl    %esp, %ebp
    
    movl    8(%ebp), %edi   #the destination (res), where we want the format
    
    movl    12(%ebp), %ecx  #format, the "string" we are reading from
    

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
    incl    num_bytes       #

    jmp     main_loop       #return to main_loop for continiued check


# Når vi har et %-tegn les neste tegn (c, s, %, x og d) og switch til riktig handling
pros_loop:
    incl    %ecx            # increase sorce counter get next char...
#TODO: If we have %<number>, store in min_char for use in other function

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
    incl    num_bytes
    jmp     main_loop       # return to main_loop
 
#c, write char from args
c_handle:
    movl    para_offset, %esi
    movl    (%ebp, %esi, 4), %ebx #move the right number of bytes into stack to find next parameter
    incl    para_offset
    
    movb    %bl, (%edi)     # copy to destination
    incl    %ecx            #
    incl    %edi            # increase counters
    incl    num_bytes       #
    jmp     main_loop       # retrun to main_loop

#Prepare for string copyloop
s_handle:
    incl    %ecx            
    movl    para_offset, %esi       #move parameter offset into esi
    movl    (%ebp, %esi, 4), %ebx   #multiply parameter offset with 4 and copy content into ebx
    incl    para_offset             #increase para_offset with one (multiplied with 4 to get next parameter)
#    jmp     s_loop
#Copy each char into the new string    
s_loop:
    cmpb    $0, (%ebx)      #   end of string
    jz      main_loop       #   return to main_loop

    movb    (%ebx), %dl     #   copy char to
    movb    %dl, (%edi)     #   destination

    incl    %ebx            #
    incl    %edi            #   increase counters
    incl    num_bytes       #
    jmp     s_loop          #   __loop__
    

#Turn hex into string
x_handle:
   #(%eax:%eax/eBx,%edx:%eax%eBx)???

    movl    $0, %eax                #0 eax for use in division
    
    movl    para_offset, %esi
    movl    (%ebp, %esi, 4), %eax   #move parameter to %eax
    incl    para_offset             #increase para_offset so we are ready to recive next parameter
    
    movl    $0, %esi                #zero esi for temp storage
    
#devide hex, use esi as temp storage for remainder
#eax contains value, eax get result, edx gets remainder
x_div:
    #TODO Del eax på 16, lagre rest og del evt opp neste produkt
    divl    %ebx
    movl    %eax, %ebx      #move result into ebx for next division
    movl    %edx, %esi      #save remainder into temp register for writing into result-string
    
    incl    hex_cpy         #increase the number of chars/bytes needed for string->hexnumber
    incl    %esi            #make ready for next remainder
    
    
    #if edx (rest) <= 16 fin
    #if edx > 16 del mer
    #cmpl    $16, %edx       #if remainder is smaller than 16 we save eax/ebx into esi and start copy into destination
    ##jge     x_div
    
#else 
    
    

#Copy to destination
x_loop:

d_handle:


fault_handle:
    movl    $-1, %eax       #return -1...
    #clear edi?

ret_rou:
    incl    %edi
    movl    $0, %edi        #add zerobyte to the end of the string
    movl    num_bytes, %eax
    popl    %ebp
    ret

    


