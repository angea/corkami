
CHARACTERISTICS equ IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

%include '../../onesec.hdr'

EntryPoint:
    retn 3 * 4

;%EXPORT ExAcquireFastMutex
;%EXPORT ExReleaseFastMutex
;%EXPORT ExTryToAcquireFastMutex
;%EXPORT HalAcquireDisplayOwnership
;%EXPORT HalAdjustResourceList
;%EXPORT HalAllProcessorsStarted
;%EXPORT HalAllocateAdapterChannel
;%EXPORT HalAllocateCommonBuffer
;%EXPORT HalAllocateCrashDumpRegisters
;%EXPORT HalAssignSlotResources
;%EXPORT HalBeginSystemInterrupt
;%EXPORT HalCalibratePerformanceCounter
;%EXPORT HalClearSoftwareInterrupt
;%EXPORT HalDisableSystemInterrupt
;%EXPORT HalDisplayString
;%EXPORT HalEnableSystemInterrupt
;%EXPORT HalEndSystemInterrupt
;%EXPORT HalFlushCommonBuffer
;%EXPORT HalFreeCommonBuffer
;%EXPORT HalGetAdapter
;%EXPORT HalGetBusData
;%EXPORT HalGetBusDataByOffset
;%EXPORT HalGetEnvironmentVariable
;%EXPORT HalGetInterruptVector
;%EXPORT HalHandleNMI
;%EXPORT HalInitSystem
;%EXPORT HalInitializeProcessor
;%EXPORT HalMakeBeep
;%EXPORT HalProcessorIdle
;%EXPORT HalQueryDisplayParameters
;%EXPORT HalQueryRealTimeClock
;%EXPORT HalReadDmaCounter
;%EXPORT HalReportResourceUsage
;%EXPORT HalRequestIpi
;%EXPORT HalRequestSoftwareInterrupt
;%EXPORT HalReturnToFirmware
;%EXPORT HalSetBusData
;%EXPORT HalSetBusDataByOffset
;%EXPORT HalSetDisplayParameters
;%EXPORT HalSetEnvironmentVariable
;%EXPORT HalSetProfileInterval
;%EXPORT HalSetRealTimeClock
;%EXPORT HalSetTimeIncrement
;%EXPORT HalStartNextProcessor
;%EXPORT HalStartProfileInterrupt
;%EXPORT HalStopProfileInterrupt
;%EXPORT HalSystemVectorDispatchEntry
;%EXPORT HalTranslateBusAddress
;%EXPORT IoAssignDriveLetters
;%EXPORT IoFlushAdapterBuffers
;%EXPORT IoFreeAdapterChannel
;%EXPORT IoFreeMapRegisters
;%EXPORT IoMapTransfer
;%EXPORT IoReadPartitionTable
;%EXPORT IoSetPartitionInformation
;%EXPORT IoWritePartitionTable
;%EXPORT KdComPortInUse
;%EXPORT KeAcquireInStackQueuedSpinLock
;%EXPORT KeAcquireInStackQueuedSpinLockRaiseToSynch
;%EXPORT KeAcquireQueuedSpinLock
;%EXPORT KeAcquireQueuedSpinLockRaiseToSynch
;%EXPORT KeAcquireSpinLock
;%EXPORT KeAcquireSpinLockRaiseToSynch
;%EXPORT KeFlushWriteBuffer
;%EXPORT KeGetCurrentIrql
;%EXPORT KeLowerIrql
;%EXPORT KeQueryPerformanceCounter
;%EXPORT KeRaiseIrql
;%EXPORT KeRaiseIrqlToDpcLevel
;%EXPORT KeRaiseIrqlToSynchLevel
;%EXPORT KeReleaseInStackQueuedSpinLock
;%EXPORT KeReleaseQueuedSpinLock
;%EXPORT KeReleaseSpinLock
;%EXPORT KeStallExecutionProcessor
;%EXPORT KeTryToAcquireQueuedSpinLock
;%EXPORT KeTryToAcquireQueuedSpinLockRaiseToSynch
;%EXPORT KfAcquireSpinLock
;%EXPORT KfLowerIrql
;%EXPORT KfRaiseIrql
;%EXPORT KfReleaseSpinLock
;%EXPORT READ_PORT_BUFFER_UCHAR
;%EXPORT READ_PORT_BUFFER_ULONG
;%EXPORT READ_PORT_BUFFER_USHORT
;%EXPORT READ_PORT_UCHAR
;%EXPORT READ_PORT_ULONG
;%EXPORT READ_PORT_USHORT
;%EXPORT WRITE_PORT_BUFFER_UCHAR
;%EXPORT WRITE_PORT_BUFFER_ULONG
;%EXPORT WRITE_PORT_BUFFER_USHORT
;%EXPORT WRITE_PORT_UCHAR
;%EXPORT WRITE_PORT_ULONG
;%EXPORT WRITE_PORT_USHORT
    retn

;%reloc 2
;%IMPORT user32.dll!MessageBoxA
;%reloc 2
;%IMPORT kernel32.dll!VirtualAlloc
;%IMPORTS

;%EXPORTS hal.dll

;%relocs

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE


