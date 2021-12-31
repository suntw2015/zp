RootDirSectors	equ	14
SectorNumOfRootDirStart	equ	19
SectorNumOfFAT1Start	equ	1

BS_OEMName	db	'MINEboot'
BPB_BytesPerSec	dw	512 ;每个扇区的字节数
BPB_SecPerClus	db	1	;给个簇对应的扇区数
BPB_RsvdSecCnt	dw	1	;保留扇区数
BPB_NumFATs	db	2		;fat表的数量
BPB_RootEntCnt	dw	224	;根目录可容纳的目录项数
BPB_TotSec16	dw	2880;总扇区数
BPB_Media	db	0xf0	;介质类型
BPB_FATSz16	dw	9		;每个fat占用的扇区数
BPB_SecPerTrk	dw	18	;每个磁道的扇区数
BPB_NumHeads	dw	2	;磁头数
BPB_HiddSec	dd	0		;隐藏扇区数
BPB_TotSec32	dd	0	;BPB_TotSec16为0话，记录总扇区数
BS_DrvNum	db	0		;int13的驱动器号
BS_Reserved1	db	0	;未使用
BS_BootSig	db	0x29	;扩展引导标记
BS_VolID	dd	0		;卷标序列
BS_VolLab	db	'boot loader'	;卷标
BS_FileSysType	db	'FAT12   '	;文件系统类型