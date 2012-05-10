#########################################################
#   C-signature:   int sprinter(char *res, char *format, ...); %c %s
#
# %eax == used in s_handle       (Free for use)
# %ebx == temp string pointer        (Free for use) used in c/x - handle, x-div 
# %ecx == format                     (Must be stored)
# %edx == temp storage               (Free for use)
#
# %esi == para_offset holder    (LOCKED)
# %edi == destination                (Must be stored)
# 
# ASCII:
# % = 37, c = 99, s = 115, d = 100, x = 120
#
# Arguments start at 16(%ebp), para_offset*4=16(%ebp)-> param1 ---> para_offset+=1*4=20-> param2 etc
# If anything else is altered we have to consider increasing/decreasing para_offset in accordance?
#
# 
# 
# All routines should increase edi (index) at the end so that edi i at the right place at the beginning of each routine
#
# If % is followed by invalid char the routine returns -1, else it will return number of bytes copied
#
#########################################################



.globl sprinter

.data       #NTS This will not be reset for each run of sprinter
#para_offset:    .long   4 #offset for argument/parameter
min_char:       .long   0           #   for use when %<number><type> is used
num_bytes:      .long   0           #   the number of bytes copied
div_push:       .long   0           #   number of values pushed onto stack in hex division
ten:            .long   10          #   devide %d by ten to find char
#sixteen:        .long   16
width:          .long   0           #   stores the width when defined
length:         .long   0           #   the length of string or number of digits
bool_hack:      .long   0           #   boolean so we know if we have a negative digit. Does extra write ('-') after padding and before writing the string/digits

sprinter:
    pushl   %ebp                    #init
    movl    %esp, %ebp

    pushl   %edi                    #save bonded registerys?
    pushl   %esi
    pushl   %ebx


    movl    8(%ebp), %edi           #the destination (result), where we want the format to be copied
    
    movl    12(%ebp), %ecx          #format, the "string" we are reading from
    
    #movl   $4, para_offset         #use %esi instead, problem when sprinter is call multiple times
    movl    $4, %esi                #this instead of global para_offset (offset is always 4 unless we add something to the stack?)
    movl    $0, num_bytes           #another solution, zero each counter, but they are still global and a threat
    movl    $0, div_push            #number of pushes made during division
    movl    $0, width               #set to zero, but if a part of %-parameter (ex: %4s) it will be set
    
#Go through the pattern string and copy format (n(%ebp) to dest (%edi) 
main_loop:
    
    cmpb    $0, (%ecx) 
    jz      ret_rou                 #end of string
    
    cmpb    $37, (%ecx)             #ascii 37 == %
                                    #if char == %
    je      pros_loop               #   jump to handling of %
                                    #else
    xor     %eax, %eax
    movb    (%ecx), %dl             #   copy char to dest
    movb    %dl, (%edi)             #

    incl    %ecx                    # 
    incl    %edi                    #increase all counters
    incl    num_bytes               #

    jmp     main_loop               #return to main_loop for continiued read



# Når vi har et %-tegn les neste tegn (c, s, %, x og d) og switch til riktig handling
pros_loop:
    movl    $0, width               #   zero width, is_a_number uses pros_switch, all other routines returns to pros_loop
    incl    %ecx                    #   increase sorce counter get next char after %
    

pros_switch:
                                    # switch-ish
    cmpb    $'%', (%ecx)            #   case % (ascii == 37)
    je      pros_handle 
    
    cmpb    $'c', (%ecx)            #   case c (ascii == 99)
    je      c_handle
    
    cmpb    $'s', (%ecx)            #   case s (ascii == 115)
    je      s_handle

    cmpb    $'d', (%ecx)            #   case d (ascii == 100)
    je      d_handle

    cmpb    $'x', (%ecx)            #   case x (ascii == 120)
    je      x_handle      

    jmp     is_it_a_number
    
    #jmp     fault_handle    #   default fault_handle, return -1

is_it_a_number:

    cmpb    $48, (%ecx)     #0
    je      it_is

    cmpb    $49, (%ecx)     #1
    je      it_is

    cmpb    $50, (%ecx)     #2
    je      it_is

    cmpb    $51, (%ecx)     #3
    je      it_is

    cmpb    $52, (%ecx)     #4
    je      it_is

    cmpb    $53, (%ecx)     #5
    je      it_is

    cmpb    $54, (%ecx)     #6
    je      it_is

    cmpb    $55, (%ecx)     #7
    je      it_is

    cmpb    $56, (%ecx)     #8
    je      it_is

    cmpb    $57, (%ecx)     #9
    je      it_is

    jmp     fault_handle            #   the next char is not a valid char, and not a number, fault_handling. Return -1

it_is:
    
    movl    $0, %eax                #   If we have a number we need to multiply the previous number with ten...
    movl    width, %eax             #   put current value of width in eax
    mull    ten                     #   multiply
    movl    %eax, width             #   put the result in width
    
    movl    $0, %eax                #   zero eax,
    movb    (%ecx), %al             #   get the char from source
    subl    $48, %eax               #   subtract 48 to get the right numerical value

    addl    %eax, width             #   add the new value with old
    
    incl    %ecx
    jmp     pros_switch             #   go back to pros_loop to check if the next char is %,c,s,d,x or another number


    #put the value in variable, register or stack, after we have read (and thus know the size of the sorce) we can add n whitespace first...

#double %, write % into dest string
pros_handle:
    movb    (%ecx), %dl             #   copy char (%)
    movb    %dl, (%edi)             #   to destination
    incl    %ecx                    # 
    incl    %edi                    #   increase all counters
    incl    num_bytes
    jmp     main_loop               #   return to main_loop
 
#c, write char from n-th parameter
c_handle:
    incl    %ecx                    #   not to read char after % (c in this case)
    
    movl    (%ebp, %esi, 4), %ebx   #   move the right number of bytes into stack to find next parameter
    incl    %esi
    
c_pad:
    cmpl    $1, width
    jle      c_finish               #   when width and is equal to 1 or width is less than 1 we can start copying the char itself
    
    movb    $' ', (%edi)            #   insert space and increase edi
    incl    %edi
    incl    num_bytes               #
    
    decl    width                   #   decrease width (it has to be bigger than counter (bytes to be inserted) for this to happend)
    jmp     c_pad


c_finish:
    
    movb    %bl, (%edi)             #   copy to destination

    incl    %edi                    #   increase counters
    incl    num_bytes               #
    
    jmp     main_loop               #   retrun to main_loop

    

#Prepare for string copyloop
#   
#   
s_handle:
    incl    %ecx                    #   not to read char after % (s in this case)
    
    movl    $0, %edx
    movl    (%ebp, %esi, 4), %edx   #   multiply parameter offset with 4 and copy content into edx (pointer to string)
    #incl    %esi                    #   increase para_offset with one (multiplied with 4 to get next parameter)
    movl    $0, length              #   not in use TODO, use ebx instead, for comparrison
    movl    $0, %ebx                #   number of chars copied set to zero in %edx and use as counter

s_length:
      
    cmpb    $0, (%edx)              #   get parameter
    je      s_pad                   #   if we reach zero-byte, go to padding
    incl    %ebx                    #   increase counter
    incl    %edx                    #   go to next char in parameter
    jmp     s_length

s_pad:
    cmpl    %ebx, width     
    jle     s_pre_loop              #   when width and %edx (number of chars to copy) is equal or width is less than %edx we can start copying the string itself
    
    movb    $' ', (%edi)            #   insert space and increase edi
    incl    %edi
    incl    num_bytes
    decl    width                   #   decrease width (it has to be bigger than counter (bytes to be inserted) for this to happend)
    jmp     s_pad

#Copy each char into the new string    
s_pre_loop:
    #xor     %edx, %edx
    movl    (%ebp, %esi, 4), %edx   #   multiply parameter offset with 4 and copy content into edx (pointer to string)
    incl    %esi                    #   increase para_offset with one (multiplied with 4 to get next parameter)
    
s_loop:
    
    cmpb    $0, (%edx)              #   end of string
    je      main_loop               #   everything that we want has been stored on stack, check if we need padding and start cpy
    
    movb    (%edx), %al             #   push the current %edx into %al
    movb    %al, (%edi)             #   move the byte to destination
    incl    %edx
    incl    %edi                    #   increase counters
    incl    num_bytes               #   increase number of bytes read
    
    jmp     s_loop                  #   __loop__

#s_cpy_loop:        #discarded
    
    #popl    %eax            #   get next char  ALT
    
    #pushl   %ecx

    #movb    (%eax), %cl     # TODO!!!! NOOB!! REVERSERT!
    #movb    %al, (%edi)     #   move the byte to destination

    #popl    %ecx
    #decl    %eax
    #incl    %edi            #   increase counters
    #incl    num_bytes       #   increase number of bytes read
    #decl    %ebx            #   decrease number of bytes to copy
    #cmpl    $0, %ebx        #   if edx is larger than 0 continue
    #jg      s_cpy_loop
    
    #jmp     main_loop

#Turn hex into string
x_handle:
    movl    $0, div_push            #   set push counter to 0

                                    #   division rule: (%eax:%eax/eBx,%edx:%eax%eBx) chose eBx as holder for 16
    incl    %ecx                    #   not to read char after % (x in this case)
    movl    $0, %eax                #   0 eax for storange of result and value in division
    
    movl    (%ebp, %esi, 4), %eax   #   move parameter to %eax, should be hexadecimal
    incl    %esi                    #   increase para_offset so we are ready to recive next parameter

    movl    $16, %ebx               #   get ebx ready for division (eax(test_hex)/ebx(16)), could use variable
    jmp     x_div

#devide hex, use ecx as temp storage for remainder
#eax contains value, eax get result, edx gets remainder
x_div:
    movl    $0, %edx                #   zero edx for each division
    
    divl    %ebx                    #   devide eax with 16
       
    pushl   %edx                    #   push remainder into stack until we can write
    
    incl    div_push                #   increase the number of push's needed for string->hexnumber
    
                                    #   if eax (result) <= 16 
    cmpl    %ebx, %eax              #   if result is smaller than 16 we save eax/ebx into esi and start copy into destination
    jge     x_div                   #   eax is grater or jump to x_div and continiue
    
    #movl    width, %ebx             #   make ebx ready for test if we need to add whitespace (pad) the string
    
    xor     %ebx, %ebx              #clear %ebx
    movl    div_push, %ebx

    
    cmpl    $0, %eax                #   if %eax == 0
    je      x_pad         #       don't push

    pushl   %eax                    #   else: 
                                    #       we want to store eax as well (last char in hex)
    incl    div_push                #   n+1 push
    incl    %ebx                    #   need to increase ebx as well... 
    jmp     x_pad

#prepare each element from the stack for copy
x_prep_cpy_loop:

    movl    $0, %eax                #zero out eax for use in next loop
    popl    %eax                    #n+1 pop the value stored in stack

    cmpb    $10, %al                #if greater than 10, add 87 (x_char), else add 48
    jge     x_char
    
    addl    $48, %eax               #add 48 to get the right ASCII char for digit
    jmp     x_cpy_loop
    
x_char:
    addl    $87, %eax               #add 87 for lowercase letter
    jmp     x_cpy_loop

#Copy to destination, splitted to be able to choose add-op
x_cpy_loop:
    movb    %al, (%edi)             #copy to destination
    
    incl    %edi                    #increase destination counter
    incl    num_bytes               #increase number of bytes copied

    decl    div_push                #decrease number of elements
    cmpl    $0, div_push            #count down to 0
    
    jne     x_prep_cpy_loop         #if 0...continiue to copy

    jmp     main_loop               #else return to main_loop


x_pad:
    cmpl    %ebx, width
    jle     x_prep_cpy_loop     #   when width and %edx (number of chars to copy) is equal or width is less than %edx we can start copying the string itself
    
    movb    $' ', (%edi)        #   insert space and increase edi and num_bytes
    incl    %edi                
    incl    num_bytes
    decl    width               #   decrease width (it has to be bigger than counter (bytes to be inserted) for this to happend)
    jmp     x_pad               #   loop




#Handle integer
d_handle:
    movl    $0, bool_hack
    incl    %ecx                    #not to read char after % (d)
    
    movl    $0, div_push            #set push counter to 0
    movl    (%ebp, %esi, 4), %eax   #move parameter to %eax, should be int
    incl    %esi                    #increase para_offset so we are ready to recive next parameter

    testl   %eax, %eax              #test if eax is negative
    js      d_neg                   #if: add '-'
    jmp     d_div                   #else: divide pr usual

d_neg:  #TODO move after division so the - does not end up int front of whitespace
    neg     %eax                    #negate %eax
    movl    $1, bool_hack
#    movl    $45, (%edi)             #add a '-' to string
#    incl    %edi                    #increase destination pointer          MOVED TO d_prep_cpy
#    incl    num_bytes               #increase number of bytes copied
    decl    width


#Devide by ten to split the integer up into chars, remainder of division is char
d_div:      
    movl    $0, %edx                #zero %edx (remainder) for each loop
    
    divl    ten                     #devide %eax with ten
     
    addl    $48, %edx               #+48 to value to get right ascii char POOR with negative

    pushl   %edx                    #save to stack

    incl    div_push                #increase num push

    cmpl    ten, %eax               #save remaining value (result) if less than 10
    jge     d_div                   #__loop__

    cmpl    $0, %eax                #if %eax == 0
    je      d_prep_cpy              #   don't push, we don't need 0 infront of numerical char

    addl    $48, %eax               # else
    pushl   %eax                    #   push remaining value
    incl    div_push                #   increase num push

    movl    div_push, %ebx

    cmpl    %ebx, width             # if (width>digits)      insert whitespace until width is the same size
    jg      d_pad
    je      d_prep_cpy              # else -    start copy to destination


d_pad:
    
    cmpl    %ebx, width
    jle     d_prep_cpy      #   when width and %edx (number of chars to copy) is equal or width is less than %edx we can start copying the string itself
    
    movb    $' ', (%edi)    #   insert space and increase edi
    incl    %edi
    incl    num_bytes
    decl    width           #   decrease width (it has to be bigger than counter (bytes to be inserted) for this to happend)
    jmp     d_pad
 



d_prep_cpy:
    
    cmpl    $0, bool_hack
    je      d_cpy
    movl    $45, (%edi)             #add a '-' to string
    incl    %edi                    #increase destination pointer
    incl    num_bytes               #increase number of bytes copied


d_cpy:
    movl    $0, %eax                #zero %eax
    popl    %eax                    #pop next value
    
    movb    %al, (%edi)             #copy to destination
    
    incl    %edi                    #increase destination index
    incl    num_bytes               #increase number of bytes copied
    decl    div_push                #decrease division remainders left

    cmpl    $0, div_push            #check if we have any more numbers
    je      main_loop               #if: jump to main loop
    jmp     d_cpy              #else: copy next int -> char

   
fault_handle:
    movl    $-1, %eax       #return -1...
    #! clear edi and return? Not according to sprintf, moved 0-byte extension to return: so we don't get segfault
    jmp     return

ret_rou:
    movl    num_bytes, %eax     #move number of bytes copied to eax for return 
    jmp     return

return:
    #incl    %edi            
    movl    $0, (%edi)            #add zerobyte to the end of the string
    
    
    popl    %ebx
    popl    %esi
   
    popl    %edi
    popl    %ebp
    
    ret

