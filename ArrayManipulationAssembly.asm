.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

include <C:\Irvine\Irvine32.inc>
includelib <C:\Irvine\Irvine32.lib>
includelib <C:\Irvine\Kernel32.lib>

CreateFile PROTO,
    lpFileName:PTR BYTE,
    dwDesiredAccess:DWORD,
    dwShareMode:DWORD,
    lpSecurityAttributes:DWORD,
    dwCreationDisposition:DWORD,
    dwFlagsAndAttributes:DWORD,
    hTemplateFile:DWORD

GENERIC_WRITE    EQU 40000000h
FILE_SHARE_READ  EQU 1
CREATE_NEW       EQU 1
FILE_ATTRIBUTE_NORMAL EQU 80h
INVALID_HANDLE_VALUE EQU -1

.data
    message1 BYTE "Array Manipulation Project in Assembly Language", 0
    message2 BYTE "Author Info: Hannah Simon", 0
    message3 BYTE "https://github.com/hannahgsimon/ArrayManipulationAssembly", 0

    label1 BYTE "Original NUMS Table:", 0
    label2 BYTE "Sorted NUMS Table:", 0
    label3 BYTE "Changed NUMS Table:", 0
    label4 BYTE "NUMS Table with Switches:", 0

    NUMS WORD 09EEBh, 0B0CFh, 061E5h, 089EDh, 0AF17h, 0D8D1h, 06C1Dh, 0594Eh, 0CF55h
        WORD 03767h, 063C6h, 0AE84h, 0412Fh, 0B226h, 046C1h, 0879Bh, 076B6h, 093FFh
        WORD 0AFFFh, 05B8Fh, 06164h, 01CF7h, 09A41h, 0A525h, 0A5A1h, 08F05h, 07E4Ch
        WORD 0827Ah, 090B0h, 0722Dh, 0BCCFh, 033ABh, 0DC76h, 085B6h, 0AA5Fh, 03FB3h
        WORD 04BACh, 0B822h, 07768h, 0BF1Bh, 05783h, 07EEBh, 09F22h, 0B85Bh, 05312h
        WORD 05971h, 0B1B6h, 0B16Dh, 054B3h, 073C8h, 0586Bh, 08170h, 06F16h, 092A0h
        WORD 09680h, 0A23Bh, 0B45Dh, 01E91h, 0415Ah, 0B5D9h, 02D02h, 06748h, 03D39h

    CHANGES BYTE 4, 3, 00Ch, 0, 8, 013h, 3, 6, 0CAh, 5, 8, 09Fh, 4, 6, 04Ah
        BYTE 0, 3, 0B8h, 5, 2, 0B3h, 1, 3, 0E1h, 5, 5, 09Dh, 4, 1, 00Dh
        BYTE 3, 5, 0C1h, 2, 8, 0BFh, 3, 4, 020h, 1, 4, 00Ah, 4, 6, 01Ah
        BYTE 1, 5, 0F1h, 2, 3, 0FEh, 1, 5, 03Eh, 6, 3, 0FAh, 0, 5, 008h

    SWITCHES BYTE 4, 3, 1, 0, 2, 6, 3, 6, 4, 3, 5, 3, 4, 6, 0, 1, 2, 1, 5, 2
        BYTE 5, 4, 5, 6, 5, 5, 4, 6, 1, 4, 3, 5, 1, 3, 2, 7, 3, 4, 2, 2
        BYTE 6, 7, 4, 6, 1, 4, 1, 8, 2, 3, 2, 6, 5, 8, 6, 3, 3, 7, 6, 1
        BYTE 0, 3, 4, 2, 2, 5, 4, 4, 5, 5, 2, 0, 5, 7, 6, 6, 5, 6, 3, 3

    spaceStr db ' ', 0
    promptStr db 'Choose output (1 for screen, 2 for file): ', 0
    invalidChoiceStr db 'Invalid choice.', 0
    filePromptStr db 'Enter filename: ', 0
    fileExistsStr db 'File already exists. Do you want to overwrite it? (Y/N): ', 0
    fileErrorStr db 'Error opening file. Please try again.', 0
    newlineStr db 13, 10, 0
    choice db ?
    filename db 256 dup(0)
    fileHandle HANDLE ?
    bytesWritten DWORD ?
    buffer BYTE ?
    
.code
main PROC
    call ChooseOutput
    call AuthorInfo
    mov edx, OFFSET label1
    call PrintNums
    call BubbleSort
    mov edx, OFFSET label2
    call PrintNums
    call ProcessChanges
    mov edx, OFFSET label3
    call PrintNums
    call SwitchNums
    mov edx, OFFSET label4
    call PrintNums

    cmp choice, '2'
    jne exit_program
    call FlushFileBuffers
    mov eax, fileHandle
    call CloseFile

    exit_program:
        INVOKE ExitProcess, 0
main ENDP

ChooseOutput PROC
    choose_loop:
        mov edx, OFFSET promptStr
        call WriteString
        call ReadChar
        call WriteChar
        mov choice, al

        ; Wait for Enter key
        .REPEAT
            call ReadChar
        .UNTIL al == 13  ; 13 is the ASCII code for Enter

        call Crlf
    
        cmp choice, '1'
        je valid_choice
        cmp choice, '2'
        je file_choice

        mov edx, OFFSET invalidChoiceStr
        call WriteString
        call Crlf
        call Crlf
        jmp choose_loop

    file_choice:
        mov edx, OFFSET filePromptStr
        call WriteString
        mov edx, OFFSET filename
        mov ecx, SIZEOF filename
        call ReadString

    try_create_file:
        ; Try to create the file with CREATE_NEW flag
        INVOKE CreateFile,
            ADDR filename,
            GENERIC_WRITE,
            FILE_SHARE_READ,
            NULL,
            CREATE_NEW,
            FILE_ATTRIBUTE_NORMAL,
            NULL
        
        cmp eax, INVALID_HANDLE_VALUE
        jne file_created

        ; File already exists, ask if user wants to overwrite
        call AskOverwrite
        cmp al, 'Y'
        je overwrite_file
        cmp al, 'N'
        je file_choice
        ; If neither Y nor N, ask again
        jmp try_create_file

    overwrite_file:
        ; Create file with CREATE_ALWAYS flag to overwrite
        INVOKE CreateFile,
            ADDR filename,
            GENERIC_WRITE,
            FILE_SHARE_READ,
            NULL,
            CREATE_ALWAYS,
            FILE_ATTRIBUTE_NORMAL,
            NULL
        
        cmp eax, INVALID_HANDLE_VALUE
        je file_error

    file_created:
        mov fileHandle, eax
        jmp valid_choice

    file_error:
        mov edx, OFFSET fileErrorStr
        call WriteString
        call Crlf
        jmp file_choice

    valid_choice:
        call Crlf
    ret
ChooseOutput ENDP

AskOverwrite PROC
    push edx

    ask_loop:
        mov edx, OFFSET fileExistsStr
        call WriteString
        call ReadChar
        call WriteChar
        
        ; Store the user's choice
        mov bl, al

        ; Wait for Enter key
        .REPEAT
            call ReadChar
        .UNTIL al == 13  ; 13 is the ASCII code for Enter

        call Crlf

        ; Retrieve the user's choice
        mov al, bl

        cmp al, 'Y'
        je valid_choice
        cmp al, 'y'
        je uppercase_y
        cmp al, 'N'
        je valid_choice
        cmp al, 'n'
        je uppercase_n

        mov edx, OFFSET invalidChoiceStr
        call WriteString
        call Crlf
        call Crlf
        jmp ask_loop

    uppercase_y:
        mov al, 'Y'
        jmp valid_choice

    uppercase_n:
        mov al, 'N'

    valid_choice:
        pop edx
        ret
AskOverwrite ENDP

WriteStringToFile PROC
    push eax
    push ecx
    push edx

    mov ecx, 0
    count_loop:
        mov al, [edx + ecx]
        cmp al, 0
        je write_string
        inc ecx
        jmp count_loop

    write_string:
        mov eax, fileHandle
        call WriteToFile

    pop edx
    pop ecx
    pop eax
    ret
WriteStringToFile ENDP

WriteHexToFile PROC
    push eax
    push ecx

    mov ecx, 4
    mov ebx, 16

    convert_loop:
        xor edx, edx
        div ebx
        push edx
        loop convert_loop

        mov ecx, 4
    write_loop:
        pop eax
        add al, '0'
        cmp al, '9'
        jle write_digit
        add al, 7
    write_digit:
        mov buffer, al
        call WriteCharToFile
        loop write_loop

    pop ecx
    pop eax
    ret
WriteHexToFile ENDP

WriteSpaceToFile PROC
    push eax
    push ecx
    push edx

    mov eax, fileHandle
    mov edx, OFFSET spaceStr
    mov ecx, 1
    call WriteToFile

    pop edx
    pop ecx
    pop eax
    ret
WriteSpaceToFile ENDP

WriteNewlineToFile PROC
    push eax
    mov buffer, 13  ; Carriage return
    call WriteCharToFile
    mov buffer, 10  ; Line feed
    call WriteCharToFile
    pop eax
    ret
WriteNewlineToFile ENDP

WriteCharToFile PROC
    push eax
    push ecx
    push edx

    mov eax, fileHandle
    mov edx, OFFSET buffer
    mov ecx, 1
    call WriteToFile

    pop edx
    pop ecx
    pop eax
    ret
WriteCharToFile ENDP

FlushFileBuffers PROC
    push eax
    mov eax, fileHandle
    call FlushFileBuffers
    pop eax
    ret
FlushFileBuffers ENDP

AuthorInfo PROC
    cmp choice, '2'
    je write_to_file

    ; Write to console
    mov edx, OFFSET message1
    call WriteString
    call CrLf
    mov edx, OFFSET message2
    call WriteString
    call CrLf
    mov edx, OFFSET message3
    call WriteString
    call CrLf
    call CrLf
    jmp done

    write_to_file:
        mov edx, OFFSET message1
        call WriteStringToFile
        call WriteNewlineToFile
        mov edx, OFFSET message2
        call WriteStringToFile
        call WriteNewlineToFile
        mov edx, OFFSET message3
        call WriteStringToFile
        call WriteNewlineToFile
        call WriteNewlineToFile

    done:
        ret
AuthorInfo ENDP

PrintNums PROC
    push edx  ; Save the label address

    cmp choice, '2'
    je write_label_to_file

    ; Write label to console
    call WriteString
    call Crlf
    jmp print_table

    write_label_to_file:
        call WriteStringToFile
        call WriteNewlineToFile

    print_table:
        pop edx  ; Restore the stack

        mov ecx, 7
        mov esi, 0
        outer_loop:
            push ecx
            mov ecx, 9

    inner_loop:
        push ecx
        movzx eax, NUMS[esi * 2]
        cmp choice, '1'
        je print_to_screen
        call WriteHexToFile
        jmp print_space

    print_to_screen:
        call WriteHex

    print_space:
        cmp choice, '1'
        je print_space_to_screen
        push eax
        mov buffer, ' '
        call WriteSpaceToFile
        pop eax
        jmp continue_loop

    print_space_to_screen:
        mov edx, OFFSET spaceStr
        call WriteString

    continue_loop:
        pop ecx
        inc esi
        loop inner_loop

        cmp choice, '1'
        je print_newline_to_screen
        call WriteNewlineToFile
        jmp next_outer

    print_newline_to_screen:
        call Crlf

    next_outer:
        pop ecx
        loop outer_loop

    cmp choice, '1'
    je print_final_newline_to_screen
    call WriteNewlineToFile
    ret

    print_final_newline_to_screen:
        call Crlf
    ret
PrintNums ENDP

BubbleSort PROC
    mov ebx, 7          

    outer_pass:
        push ebx           
        mov ecx, 7          
        mov esi, 0          

    outer_loop:
        push ecx           
        mov ecx, 8         

    inner_loop:
        mov ax, NUMS[esi * 2]       
        cmp ax, NUMS[esi * 2 + 2] 
        jbe next_pair               

        ; Swap elements if out of order
        xchg ax, NUMS[esi * 2 + 2]
        mov NUMS[esi * 2], ax

    next_pair:
        inc esi             
        loop inner_loop    

        inc esi            
        pop ecx             
        loop outer_loop     

        pop ebx             
        dec ebx             
    jnz outer_pass     

    ret
BubbleSort ENDP

ProcessChanges PROC
    mov ecx, 20
    mov esi, 0
    process_loop:
        push ecx
        movzx eax, CHANGES[esi]
        movzx ebx, CHANGES[esi+1]
        call GetAddress
        movzx ecx, CHANGES[esi+2]
        add WORD PTR [edx], cx
        add esi, 3
        pop ecx
        loop process_loop
    ret
ProcessChanges ENDP

SwitchNums PROC
    mov ecx, 20
    mov esi, 0

    switch_loop:
        push ecx
        movzx eax, SWITCHES[esi]
        movzx ebx, SWITCHES[esi+1]
        call GetAddress
        mov edi, edx
        movzx eax, SWITCHES[esi+2]
        movzx ebx, SWITCHES[esi+3]
        call GetAddress
        mov ax, [edi]
        mov cx, [edx]
        mov [edi], cx
        mov [edx], ax
        add esi, 4
        pop ecx
        loop switch_loop
    ret
SwitchNums ENDP

GetAddress PROC
    imul eax, 18
    lea edx, [eax + ebx*2]
    add edx, OFFSET NUMS
    ret
GetAddress ENDP

END main
