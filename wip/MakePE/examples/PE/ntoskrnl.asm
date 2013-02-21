; DLL mimicking basic ntoskrnl functionalities for execution of drivers in user mode

CHARACTERISTICS equ IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

%include '..\..\onesec.hdr'

%macro _service 2
    mov eax, %1
    mov edx, 7ffe0300h
    call [edx]
    retn %2
%endmacro

EntryPoint:
    retn 3 * 4

;%EXPORT DbgPrint
    mov ebx, [esp+4]        ; DbgPrint doesn't clear arguments from the stack
    push MB_ICONINFORMATION ; UINT uType
;%reloc 1
    push Driver             ; LPCTSTR lpCaption
    push ebx                ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn                    ; doesn't pop out parameters
;%reloc 2
;%IMPORT user32.dll!MessageBoxA
Driver db "User mode Ntoskrnl", 0

;%EXPORT ExAllocatePool
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push dword [esp + 8]    ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    retn 2 * 4

;%EXPORT ExAllocatePoolWithTag
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push dword [esp + 8]    ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    retn 3 * 4

;%reloc 2
;%IMPORT kernel32.dll!VirtualAlloc

;%EXPORT ExFreePool
    mov ecx, dword [esp + 4]

    push MEM_RELEASE        ; DWORD dwFreeType
    push 0                  ; SIZE_T dwSize
    push ecx                ; LPVOID lpAddress
    call VirtualFree

    ret

;%EXPORT ExFreePoolWithTag
    ret

;%reloc 2
;%IMPORT kernel32.dll!VirtualFree


;%EXPORT ZwQuerySystemInformation
    _service 0adh, 010h

;%EXPORT toupper
    ret

;%EXPORT ZwOpenFile
    _service 74h, 18h

;%EXPORT ZwCreateSection
    _service 32h, 01ch

;%EXPORT ZwMapViewOfSection
    _service 6ch, 28h

;%EXPORT RtlInitUnicodeString
    push    edi
    mov     edi, [esp+0Ch]
    mov     edx, [esp+8]
    mov     dword [edx], 0
    mov     [edx+4], edi
    or      edi, edi
    jz      rtl_end

    or      ecx, -1
    xor     eax, eax
    repne scasw
    not     ecx
    shl     ecx, 1
    cmp     ecx, 0FFFEh
    jbe     rtl_notinit

    mov     ecx, 0FFFEh
rtl_notinit:
    mov     [edx+2], cx
    dec     ecx
    dec     ecx
    mov     [edx], cx
rtl_end:
    pop     edi
    retn 2 * 4

;%EXPORT KeCancelTimer
    retn 1 * 4

;%EXPORT KeInitializeTimer
    push ebp
    mov ebp, esp
    push 0
    push dword [ebp + 8]
    call __exp__KeInitializeTimerEx
    pop ebp
    retn 4

;%EXPORT KeInitializeTimerEx
    mov edi, edi
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov cl, [ebp + 0Ch]
    add cl, 8
    xor edx, edx
    mov [eax], cl
    lea ecx, [eax + 8]
    mov [eax + 3], dl
    mov byte [eax + 2], 0Ah
    mov [eax + 4], edx
    mov [ecx + 4], ecx
    mov [ecx], ecx
    mov [eax + 10h], edx
    mov [eax + 14h], edx
    mov [eax + 24h], edx
    pop ebp
    retn 8

;%EXPORT KeInitializeEvent
    mov edi, edi
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov cl, [ebp + 0Ch]
    mov [eax], cl
    movzx ecx, byte [ebp + 10h]
    mov byte [eax + 2], 4
    mov [eax + 4], ecx
    add eax, 8
    mov [eax + 4], eax
    mov [eax], eax
    pop ebp
    retn 0Ch

;%EXPORT KeInitializeSpinLock
    mov eax, [esp + 4]
    mov dword [eax], 0
    retn 4

;%EXPORT KeInitializeMutex
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    lea ecx, [eax + 8]
    mov byte [eax], 2
    mov byte [eax + 2], 8
    mov dword [eax + 4], 1
    mov [ecx + 4], ecx
    mov [ecx], ecx
    and dword [eax + 018h], 0
    mov byte [eax + 01Ch], 0
    mov byte [eax + 01Dh], 1
    pop ebp
    retn 8

;%EXPORT PsGetCurrentProcess
;%EXPORT PsGetCurrentProcessId
;%EXPORT PsGetCurrentProcessSessionId
;%EXPORT PsGetCurrentThread
;%EXPORT PsGetCurrentThreadId
;%EXPORT IoGetCurrentProcess
    push edx
    rdtsc
    pop edx
    and eax, 0000ffffh
    ret

;%EXPORT MmPageEntireDriver
    retn 2 * 4

;%EXPORT KeDelayExecutionThread
    ret

;%EXPORT KeInitializeDpc
    retn 3 * 4

;%EXPORT KeSetTimerEx
    retn 4 * 4

;%EXPORT IoCreateDevice
    retn 7 * 4

;%EXPORT RtlImageNtHeader
;%reloc 2
;%IMPORT ntdll.dll!RtlImageNtHeader

;%EXPORT memcpy
;%reloc 2
;%IMPORT msvcrt.dll!memcpy

;%EXPORT memmove
;%reloc 2
;%IMPORT msvcrt.dll!memmove

;%EXPORT memset
;%reloc 2
;%IMPORT msvcrt.dll!memset


; not handling their parameters correctly yet
;*************************************************************
;%EXPORT CcCanIWrite
ret

;%EXPORT CcCopyRead
ret

;%EXPORT CcCopyWrite
ret

;%EXPORT CcDeferWrite
ret

;%EXPORT CcFastCopyRead
ret

;%EXPORT CcFastCopyWrite
ret

;%EXPORT CcFastMdlReadWait
ret

;%EXPORT CcFastReadNotPossible
ret

;%EXPORT CcFastReadWait
ret

;%EXPORT CcFlushCache
ret

;%EXPORT CcGetDirtyPages
ret

;%EXPORT CcGetFileObjectFromBcb
ret

;%EXPORT CcGetFileObjectFromSectionPtrs
ret

;%EXPORT CcGetFlushedValidData
ret

;%EXPORT CcGetLsnForFileObject
ret

;%EXPORT CcInitializeCacheMap
ret

;%EXPORT CcIsThereDirtyData
ret

;%EXPORT CcMapData
ret

;%EXPORT CcMdlRead
ret

;%EXPORT CcMdlReadComplete
ret

;%EXPORT CcMdlWriteAbort
ret

;%EXPORT CcMdlWriteComplete
ret

;%EXPORT CcPinMappedData
ret

;%EXPORT CcPinRead
ret

;%EXPORT CcPrepareMdlWrite
ret

;%EXPORT CcPreparePinWrite
ret

;%EXPORT CcPurgeCacheSection
ret

;%EXPORT CcRemapBcb
ret

;%EXPORT CcRepinBcb
ret

;%EXPORT CcScheduleReadAhead
ret

;%EXPORT CcSetAdditionalCacheAttributes
ret

;%EXPORT CcSetBcbOwnerPointer
ret

;%EXPORT CcSetDirtyPageThreshold
ret

;%EXPORT CcSetDirtyPinnedData
ret

;%EXPORT CcSetFileSizes
ret

;%EXPORT CcSetLogHandleForFile
ret

;%EXPORT CcSetReadAheadGranularity
ret

;%EXPORT CcUninitializeCacheMap
ret

;%EXPORT CcUnpinData
ret

;%EXPORT CcUnpinDataForThread
ret

;%EXPORT CcUnpinRepinnedBcb
ret

;%EXPORT CcWaitForCurrentLazyWriterActivity
ret

;%EXPORT CcZeroData
ret

;%EXPORT CmRegisterCallback
ret

;%EXPORT CmUnRegisterCallback
ret

;%EXPORT DbgBreakPoint
ret

;%EXPORT DbgBreakPointWithStatus
ret

;%EXPORT DbgLoadImageSymbols
ret

;%EXPORT DbgPrintEx
ret

;%EXPORT DbgPrintReturnControlC
ret

;%EXPORT DbgPrompt
ret

;%EXPORT DbgQueryDebugFilterState
ret

;%EXPORT DbgSetDebugFilterState
ret

;%EXPORT ExAcquireFastMutexUnsafe
ret

;%EXPORT ExAcquireResourceExclusiveLite
ret

;%EXPORT ExAcquireResourceSharedLite
ret

;%EXPORT ExAcquireRundownProtection
ret

;%EXPORT ExAcquireRundownProtectionEx
ret

;%EXPORT ExAcquireSharedStarveExclusive
ret

;%EXPORT ExAcquireSharedWaitForExclusive
ret

;%EXPORT ExAllocateFromPagedLookasideList
ret

;%EXPORT ExAllocatePoolWithQuota
ret

;%EXPORT ExAllocatePoolWithQuotaTag
ret

;%EXPORT ExAllocatePoolWithTagPriority
ret

;%EXPORT ExConvertExclusiveToSharedLite
ret

;%EXPORT ExCreateCallback
ret

;%EXPORT ExDeleteNPagedLookasideList
ret

;%EXPORT ExDeletePagedLookasideList
ret

;%EXPORT ExDeleteResourceLite
ret

;%EXPORT ExDesktopObjectType
ret

;%EXPORT ExDisableResourceBoostLite
ret

;%EXPORT ExEnumHandleTable
ret

;%EXPORT ExEventObjectType
ret

;%EXPORT ExExtendZone
ret

;%EXPORT ExFreeToPagedLookasideList
ret

;%EXPORT ExGetCurrentProcessorCounts
ret

;%EXPORT ExGetCurrentProcessorCpuUsage
ret

;%EXPORT ExGetExclusiveWaiterCount
ret

;%EXPORT ExGetPreviousMode
ret

;%EXPORT ExGetSharedWaiterCount
ret

;%EXPORT ExInitializeNPagedLookasideList
ret

;%EXPORT ExInitializePagedLookasideList
ret

;%EXPORT ExInitializeResourceLite
ret

;%EXPORT ExInitializeRundownProtection
ret

;%EXPORT ExInitializeZone
ret

;%EXPORT ExInterlockedAddLargeInteger
ret

;%EXPORT ExInterlockedAddLargeStatistic
ret

;%EXPORT ExInterlockedAddUlong
ret

;%EXPORT ExInterlockedCompareExchange64
ret

;%EXPORT ExInterlockedDecrementLong
ret

;%EXPORT ExInterlockedExchangeUlong
ret

;%EXPORT ExInterlockedExtendZone
ret

;%EXPORT ExInterlockedFlushSList
ret

;%EXPORT ExInterlockedIncrementLong
ret

;%EXPORT ExInterlockedInsertHeadList
ret

;%EXPORT ExInterlockedInsertTailList
ret

;%EXPORT ExInterlockedPopEntryList
ret

;%EXPORT ExInterlockedPopEntrySList
ret

;%EXPORT ExInterlockedPushEntryList
ret

;%EXPORT ExInterlockedPushEntrySList
ret

;%EXPORT ExInterlockedRemoveHeadList
ret

;%EXPORT ExIsProcessorFeaturePresent
ret

;%EXPORT ExIsResourceAcquiredExclusiveLite
ret

;%EXPORT ExIsResourceAcquiredSharedLite
ret

;%EXPORT ExLocalTimeToSystemTime
ret

;%EXPORT ExNotifyCallback
ret

;%EXPORT ExQueryPoolBlockSize
ret

;%EXPORT ExQueueWorkItem
ret

;%EXPORT ExRaiseAccessViolation
ret

;%EXPORT ExRaiseDatatypeMisalignment
ret

;%EXPORT ExRaiseException
ret

;%EXPORT ExRaiseHardError
ret

;%EXPORT ExRaiseStatus
ret

;%EXPORT ExReInitializeRundownProtection
ret

;%EXPORT ExRegisterCallback
ret

;%EXPORT ExReinitializeResourceLite
ret

;%EXPORT ExReleaseFastMutexUnsafe
ret

;%EXPORT ExReleaseResourceForThreadLite
ret

;%EXPORT ExReleaseResourceLite
ret

;%EXPORT ExReleaseRundownProtection
ret

;%EXPORT ExReleaseRundownProtectionEx
ret

;%EXPORT ExRundownCompleted
ret

;%EXPORT ExSemaphoreObjectType
ret

;%EXPORT ExSetResourceOwnerPointer
ret

;%EXPORT ExSetTimerResolution
ret

;%EXPORT ExSystemExceptionFilter
ret

;%EXPORT ExSystemTimeToLocalTime
ret

;%EXPORT ExUnregisterCallback
ret

;%EXPORT ExUuidCreate
ret

;%EXPORT ExVerifySuite
ret

;%EXPORT ExWaitForRundownProtectionRelease
ret

;%EXPORT ExWindowStationObjectType
ret

;%EXPORT ExfAcquirePushLockExclusive
ret

;%EXPORT ExfAcquirePushLockShared
ret

;%EXPORT ExfInterlockedAddUlong
ret

;%EXPORT ExfInterlockedCompareExchange64
ret

;%EXPORT ExfInterlockedInsertHeadList
ret

;%EXPORT ExfInterlockedInsertTailList
ret

;%EXPORT ExfInterlockedPopEntryList
ret

;%EXPORT ExfInterlockedPushEntryList
ret

;%EXPORT ExfInterlockedRemoveHeadList
ret

;%EXPORT ExfReleasePushLock
ret

;%EXPORT Exfi386InterlockedDecrementLong
ret

;%EXPORT Exfi386InterlockedExchangeUlong
ret

;%EXPORT Exfi386InterlockedIncrementLong
ret

;%EXPORT Exi386InterlockedDecrementLong
ret

;%EXPORT Exi386InterlockedExchangeUlong
ret

;%EXPORT Exi386InterlockedIncrementLong
ret

;%EXPORT FsRtlAcquireFileExclusive
ret

;%EXPORT FsRtlAddLargeMcbEntry
ret

;%EXPORT FsRtlAddMcbEntry
ret

;%EXPORT FsRtlAddToTunnelCache
ret

;%EXPORT FsRtlAllocateFileLock
ret

;%EXPORT FsRtlAllocatePool
ret

;%EXPORT FsRtlAllocatePoolWithQuota
ret

;%EXPORT FsRtlAllocatePoolWithQuotaTag
ret

;%EXPORT FsRtlAllocatePoolWithTag
ret

;%EXPORT FsRtlAllocateResource
ret

;%EXPORT FsRtlAreNamesEqual
ret

;%EXPORT FsRtlBalanceReads
ret

;%EXPORT FsRtlCheckLockForReadAccess
ret

;%EXPORT FsRtlCheckLockForWriteAccess
ret

;%EXPORT FsRtlCheckOplock
ret

;%EXPORT FsRtlCopyRead
ret

;%EXPORT FsRtlCopyWrite
ret

;%EXPORT FsRtlCurrentBatchOplock
ret

;%EXPORT FsRtlDeleteKeyFromTunnelCache
ret

;%EXPORT FsRtlDeleteTunnelCache
ret

;%EXPORT FsRtlDeregisterUncProvider
ret

;%EXPORT FsRtlDissectDbcs
ret

;%EXPORT FsRtlDissectName
ret

;%EXPORT FsRtlDoesDbcsContainWildCards
ret

;%EXPORT FsRtlDoesNameContainWildCards
ret

;%EXPORT FsRtlFastCheckLockForRead
ret

;%EXPORT FsRtlFastCheckLockForWrite
ret

;%EXPORT FsRtlFastUnlockAll
ret

;%EXPORT FsRtlFastUnlockAllByKey
ret

;%EXPORT FsRtlFastUnlockSingle
ret

;%EXPORT FsRtlFindInTunnelCache
ret

;%EXPORT FsRtlFreeFileLock
ret

;%EXPORT FsRtlGetFileSize
ret

;%EXPORT FsRtlGetNextFileLock
ret

;%EXPORT FsRtlGetNextLargeMcbEntry
ret

;%EXPORT FsRtlGetNextMcbEntry
ret

;%EXPORT FsRtlIncrementCcFastReadNoWait
ret

;%EXPORT FsRtlIncrementCcFastReadNotPossible
ret

;%EXPORT FsRtlIncrementCcFastReadResourceMiss
ret

;%EXPORT FsRtlIncrementCcFastReadWait
ret

;%EXPORT FsRtlInitializeFileLock
ret

;%EXPORT FsRtlInitializeLargeMcb
ret

;%EXPORT FsRtlInitializeMcb
ret

;%EXPORT FsRtlInitializeOplock
ret

;%EXPORT FsRtlInitializeTunnelCache
ret

;%EXPORT FsRtlInsertPerFileObjectContext
ret

;%EXPORT FsRtlInsertPerStreamContext
ret

;%EXPORT FsRtlIsDbcsInExpression
ret

;%EXPORT FsRtlIsFatDbcsLegal
ret

;%EXPORT FsRtlIsHpfsDbcsLegal
ret

;%EXPORT FsRtlIsNameInExpression
ret

;%EXPORT FsRtlIsNtstatusExpected
ret

;%EXPORT FsRtlIsPagingFile
ret

;%EXPORT FsRtlIsTotalDeviceFailure
ret

;%EXPORT FsRtlLegalAnsiCharacterArray
ret

;%EXPORT FsRtlLookupLargeMcbEntry
ret

;%EXPORT FsRtlLookupLastLargeMcbEntry
ret

;%EXPORT FsRtlLookupLastLargeMcbEntryAndIndex
ret

;%EXPORT FsRtlLookupLastMcbEntry
ret

;%EXPORT FsRtlLookupMcbEntry
ret

;%EXPORT FsRtlLookupPerFileObjectContext
ret

;%EXPORT FsRtlLookupPerStreamContextInternal
ret

;%EXPORT FsRtlMdlRead
ret

;%EXPORT FsRtlMdlReadComplete
ret

;%EXPORT FsRtlMdlReadCompleteDev
ret

;%EXPORT FsRtlMdlReadDev
ret

;%EXPORT FsRtlMdlWriteComplete
ret

;%EXPORT FsRtlMdlWriteCompleteDev
ret

;%EXPORT FsRtlNormalizeNtstatus
ret

;%EXPORT FsRtlNotifyChangeDirectory
ret

;%EXPORT FsRtlNotifyCleanup
ret

;%EXPORT FsRtlNotifyFilterChangeDirectory
ret

;%EXPORT FsRtlNotifyFilterReportChange
ret

;%EXPORT FsRtlNotifyFullChangeDirectory
ret

;%EXPORT FsRtlNotifyFullReportChange
ret

;%EXPORT FsRtlNotifyInitializeSync
ret

;%EXPORT FsRtlNotifyReportChange
ret

;%EXPORT FsRtlNotifyUninitializeSync
ret

;%EXPORT FsRtlNotifyVolumeEvent
ret

;%EXPORT FsRtlNumberOfRunsInLargeMcb
ret

;%EXPORT FsRtlNumberOfRunsInMcb
ret

;%EXPORT FsRtlOplockFsctrl
ret

;%EXPORT FsRtlOplockIsFastIoPossible
ret

;%EXPORT FsRtlPostPagingFileStackOverflow
ret

;%EXPORT FsRtlPostStackOverflow
ret

;%EXPORT FsRtlPrepareMdlWrite
ret

;%EXPORT FsRtlPrepareMdlWriteDev
ret

;%EXPORT FsRtlPrivateLock
ret

;%EXPORT FsRtlProcessFileLock
ret

;%EXPORT FsRtlRegisterFileSystemFilterCallbacks
ret

;%EXPORT FsRtlRegisterUncProvider
ret

;%EXPORT FsRtlReleaseFile
ret

;%EXPORT FsRtlRemoveLargeMcbEntry
ret

;%EXPORT FsRtlRemoveMcbEntry
ret

;%EXPORT FsRtlRemovePerFileObjectContext
ret

;%EXPORT FsRtlRemovePerStreamContext
ret

;%EXPORT FsRtlResetLargeMcb
ret

;%EXPORT FsRtlSplitLargeMcb
ret

;%EXPORT FsRtlSyncVolumes
ret

;%EXPORT FsRtlTeardownPerStreamContexts
ret

;%EXPORT FsRtlTruncateLargeMcb
ret

;%EXPORT FsRtlTruncateMcb
ret

;%EXPORT FsRtlUninitializeFileLock
ret

;%EXPORT FsRtlUninitializeLargeMcb
ret

;%EXPORT FsRtlUninitializeMcb
ret

;%EXPORT FsRtlUninitializeOplock
ret

;%EXPORT HalDispatchTable
ret

;%EXPORT HalExamineMBR
ret

;%EXPORT HalPrivateDispatchTable
ret

;%EXPORT HeadlessDispatch
ret

;%EXPORT InbvAcquireDisplayOwnership
ret

;%EXPORT InbvCheckDisplayOwnership
ret

;%EXPORT InbvDisplayString
ret

;%EXPORT InbvEnableBootDriver
ret

;%EXPORT InbvEnableDisplayString
ret

;%EXPORT InbvInstallDisplayStringFilter
ret

;%EXPORT InbvIsBootDriverInstalled
ret

;%EXPORT InbvNotifyDisplayOwnershipLost
ret

;%EXPORT InbvResetDisplay
ret

;%EXPORT InbvSetScrollRegion
ret

;%EXPORT InbvSetTextColor
ret

;%EXPORT InbvSolidColorFill
ret

;%EXPORT InitSafeBootMode
ret

;%EXPORT InterlockedCompareExchange
ret

;%EXPORT InterlockedDecrement
ret

;%EXPORT InterlockedExchange
ret

;%EXPORT InterlockedExchangeAdd
ret

;%EXPORT InterlockedIncrement
ret

;%EXPORT InterlockedPopEntrySList
ret

;%EXPORT InterlockedPushEntrySList
ret

;%EXPORT IoAcquireCancelSpinLock
ret

;%EXPORT IoAcquireRemoveLockEx
ret

;%EXPORT IoAcquireVpbSpinLock
ret

;%EXPORT IoAdapterObjectType
ret

;%EXPORT IoAllocateAdapterChannel
ret

;%EXPORT IoAllocateController
ret

;%EXPORT IoAllocateDriverObjectExtension
ret

;%EXPORT IoAllocateErrorLogEntry
ret

;%EXPORT IoAllocateIrp
ret

;%EXPORT IoAllocateMdl
ret

;%EXPORT IoAllocateWorkItem
ret

;%EXPORT IoAssignDriveLetters
ret

;%EXPORT IoAssignResources
ret

;%EXPORT IoAttachDevice
ret

;%EXPORT IoAttachDeviceByPointer
ret

;%EXPORT IoAttachDeviceToDeviceStack
ret

;%EXPORT IoAttachDeviceToDeviceStackSafe
ret

;%EXPORT IoBuildAsynchronousFsdRequest
ret

;%EXPORT IoBuildDeviceIoControlRequest
ret

;%EXPORT IoBuildPartialMdl
ret

;%EXPORT IoBuildSynchronousFsdRequest
ret

;%EXPORT IoCallDriver
ret

;%EXPORT IoCancelFileOpen
ret

;%EXPORT IoCancelIrp
ret

;%EXPORT IoCheckDesiredAccess
ret

;%EXPORT IoCheckEaBufferValidity
ret

;%EXPORT IoCheckFunctionAccess
ret

;%EXPORT IoCheckQuerySetFileInformation
ret

;%EXPORT IoCheckQuerySetVolumeInformation
ret

;%EXPORT IoCheckQuotaBufferValidity
ret

;%EXPORT IoCheckShareAccess
ret

;%EXPORT IoCompleteRequest
ret

;%EXPORT IoConnectInterrupt
ret

;%EXPORT IoCreateController
ret

;%EXPORT IoCreateDisk
ret

;%EXPORT IoCreateDriver
ret

;%EXPORT IoCreateFile
ret

;%EXPORT IoCreateFileSpecifyDeviceObjectHint
ret

;%EXPORT IoCreateNotificationEvent
ret

;%EXPORT IoCreateStreamFileObject
ret

;%EXPORT IoCreateStreamFileObjectEx
ret

;%EXPORT IoCreateStreamFileObjectLite
ret

;%EXPORT IoCreateSymbolicLink
ret

;%EXPORT IoCreateSynchronizationEvent
ret

;%EXPORT IoCreateUnprotectedSymbolicLink
ret

;%EXPORT IoCsqInitialize
ret

;%EXPORT IoCsqInsertIrp
ret

;%EXPORT IoCsqRemoveIrp
ret

;%EXPORT IoCsqRemoveNextIrp
ret

;%EXPORT IoDeleteController
ret

;%EXPORT IoDeleteDevice
ret

;%EXPORT IoDeleteDriver
ret

;%EXPORT IoDeleteSymbolicLink
ret

;%EXPORT IoDetachDevice
ret

;%EXPORT IoDeviceHandlerObjectSize
ret

;%EXPORT IoDeviceHandlerObjectType
ret

;%EXPORT IoDeviceObjectType
ret

;%EXPORT IoDisconnectInterrupt
ret

;%EXPORT IoDriverObjectType
ret

;%EXPORT IoEnqueueIrp
ret

;%EXPORT IoEnumerateDeviceObjectList
ret

;%EXPORT IoFastQueryNetworkAttributes
ret

;%EXPORT IoFileObjectType
ret

;%EXPORT IoForwardAndCatchIrp
ret

;%EXPORT IoForwardIrpSynchronously
ret

;%EXPORT IoFreeController
ret

;%EXPORT IoFreeErrorLogEntry
ret

;%EXPORT IoFreeIrp
ret

;%EXPORT IoFreeMdl
ret

;%EXPORT IoFreeWorkItem
ret

;%EXPORT IoGetAttachedDevice
ret

;%EXPORT IoGetAttachedDeviceReference
ret

;%EXPORT IoGetBaseFileSystemDeviceObject
ret

;%EXPORT IoGetBootDiskInformation
ret

;%EXPORT IoGetConfigurationInformation
ret

;%EXPORT IoGetDeviceAttachmentBaseRef
ret

;%EXPORT IoGetDeviceInterfaceAlias
ret

;%EXPORT IoGetDeviceInterfaces
ret

;%EXPORT IoGetDeviceObjectPointer
ret

;%EXPORT IoGetDeviceProperty
ret

;%EXPORT IoGetDeviceToVerify
ret

;%EXPORT IoGetDiskDeviceObject
ret

;%EXPORT IoGetDmaAdapter
ret

;%EXPORT IoGetDriverObjectExtension
ret

;%EXPORT IoGetFileObjectGenericMapping
ret

;%EXPORT IoGetInitialStack
ret

;%EXPORT IoGetLowerDeviceObject
ret

;%EXPORT IoGetRelatedDeviceObject
ret

;%EXPORT IoGetRequestorProcess
ret

;%EXPORT IoGetRequestorProcessId
ret

;%EXPORT IoGetRequestorSessionId
ret

;%EXPORT IoGetStackLimits
ret

;%EXPORT IoGetTopLevelIrp
ret

;%EXPORT IoInitializeIrp
ret

;%EXPORT IoInitializeRemoveLockEx
ret

;%EXPORT IoInitializeTimer
ret

;%EXPORT IoInvalidateDeviceRelations
ret

;%EXPORT IoInvalidateDeviceState
ret

;%EXPORT IoIsFileOriginRemote
ret

;%EXPORT IoIsOperationSynchronous
ret

;%EXPORT IoIsSystemThread
ret

;%EXPORT IoIsValidNameGraftingBuffer
ret

;%EXPORT IoIsWdmVersionAvailable
ret

;%EXPORT IoMakeAssociatedIrp
ret

;%EXPORT IoOpenDeviceInterfaceRegistryKey
ret

;%EXPORT IoOpenDeviceRegistryKey
ret

;%EXPORT IoPageRead
ret

;%EXPORT IoPnPDeliverServicePowerNotification
ret

;%EXPORT IoQueryDeviceDescription
ret

;%EXPORT IoQueryFileDosDeviceName
ret

;%EXPORT IoQueryFileInformation
ret

;%EXPORT IoQueryVolumeInformation
ret

;%EXPORT IoQueueThreadIrp
ret

;%EXPORT IoQueueWorkItem
ret

;%EXPORT IoRaiseHardError
ret

;%EXPORT IoRaiseInformationalHardError
ret

;%EXPORT IoReadDiskSignature
ret

;%EXPORT IoReadOperationCount
ret

;%EXPORT IoReadPartitionTable
ret

;%EXPORT IoReadPartitionTableEx
ret

;%EXPORT IoReadTransferCount
ret

;%EXPORT IoRegisterBootDriverReinitialization
ret

;%EXPORT IoRegisterDeviceInterface
ret

;%EXPORT IoRegisterDriverReinitialization
ret

;%EXPORT IoRegisterFileSystem
ret

;%EXPORT IoRegisterFsRegistrationChange
ret

;%EXPORT IoRegisterLastChanceShutdownNotification
ret

;%EXPORT IoRegisterPlugPlayNotification
ret

;%EXPORT IoRegisterShutdownNotification
ret

;%EXPORT IoReleaseCancelSpinLock
ret

;%EXPORT IoReleaseRemoveLockAndWaitEx
ret

;%EXPORT IoReleaseRemoveLockEx
ret

;%EXPORT IoReleaseVpbSpinLock
ret

;%EXPORT IoRemoveShareAccess
ret

;%EXPORT IoReportDetectedDevice
ret

;%EXPORT IoReportHalResourceUsage
ret

;%EXPORT IoReportResourceForDetection
ret

;%EXPORT IoReportResourceUsage
ret

;%EXPORT IoReportTargetDeviceChange
ret

;%EXPORT IoReportTargetDeviceChangeAsynchronous
ret

;%EXPORT IoRequestDeviceEject
ret

;%EXPORT IoReuseIrp
ret

;%EXPORT IoSetCompletionRoutineEx
ret

;%EXPORT IoSetDeviceInterfaceState
ret

;%EXPORT IoSetDeviceToVerify
ret

;%EXPORT IoSetFileOrigin
ret

;%EXPORT IoSetHardErrorOrVerifyDevice
ret

;%EXPORT IoSetInformation
ret

;%EXPORT IoSetIoCompletion
ret

;%EXPORT IoSetPartitionInformation
ret

;%EXPORT IoSetPartitionInformationEx
ret

;%EXPORT IoSetShareAccess
ret

;%EXPORT IoSetStartIoAttributes
ret

;%EXPORT IoSetSystemPartition
ret

;%EXPORT IoSetThreadHardErrorMode
ret

;%EXPORT IoSetTopLevelIrp
ret

;%EXPORT IoStartNextPacket
ret

;%EXPORT IoStartNextPacketByKey
ret

;%EXPORT IoStartPacket
ret

;%EXPORT IoStartTimer
ret

;%EXPORT IoStatisticsLock
ret

;%EXPORT IoStopTimer
ret

;%EXPORT IoSynchronousInvalidateDeviceRelations
ret

;%EXPORT IoSynchronousPageWrite
ret

;%EXPORT IoThreadToProcess
ret

;%EXPORT IoUnregisterFileSystem
ret

;%EXPORT IoUnregisterFsRegistrationChange
ret

;%EXPORT IoUnregisterPlugPlayNotification
ret

;%EXPORT IoUnregisterShutdownNotification
ret

;%EXPORT IoUpdateShareAccess
ret

;%EXPORT IoValidateDeviceIoControlAccess
ret

;%EXPORT IoVerifyPartitionTable
ret

;%EXPORT IoVerifyVolume
ret

;%EXPORT IoVolumeDeviceToDosName
ret

;%EXPORT IoWMIAllocateInstanceIds
ret

;%EXPORT IoWMIDeviceObjectToInstanceName
ret

;%EXPORT IoWMIExecuteMethod
ret

;%EXPORT IoWMIHandleToInstanceName
ret

;%EXPORT IoWMIOpenBlock
ret

;%EXPORT IoWMIQueryAllData
ret

;%EXPORT IoWMIQueryAllDataMultiple
ret

;%EXPORT IoWMIQuerySingleInstance
ret

;%EXPORT IoWMIQuerySingleInstanceMultiple
ret

;%EXPORT IoWMIRegistrationControl
ret

;%EXPORT IoWMISetNotificationCallback
ret

;%EXPORT IoWMISetSingleInstance
ret

;%EXPORT IoWMISetSingleItem
ret

;%EXPORT IoWMISuggestInstanceName
ret

;%EXPORT IoWMIWriteEvent
ret

;%EXPORT IoWriteErrorLogEntry
ret

;%EXPORT IoWriteOperationCount
ret

;%EXPORT IoWritePartitionTable
ret

;%EXPORT IoWritePartitionTableEx
ret

;%EXPORT IoWriteTransferCount
ret

;%EXPORT IofCallDriver
ret

;%EXPORT IofCompleteRequest
ret

;%EXPORT KdDebuggerEnabled
ret

;%EXPORT KdDebuggerNotPresent
ret

;%EXPORT KdDisableDebugger
ret

;%EXPORT KdEnableDebugger
ret

;%EXPORT KdEnteredDebugger
ret

;%EXPORT KdPollBreakIn
ret

;%EXPORT KdPowerTransition
ret

;%EXPORT Ke386CallBios
ret

;%EXPORT Ke386IoSetAccessProcess
ret

;%EXPORT Ke386QueryIoAccessMap
ret

;%EXPORT Ke386SetIoAccessMap
ret

;%EXPORT KeAcquireInStackQueuedSpinLockAtDpcLevel
ret

;%EXPORT KeAcquireInterruptSpinLock
ret

;%EXPORT KeAcquireSpinLockAtDpcLevel
ret

;%EXPORT KeAddSystemServiceTable
ret

;%EXPORT KeAreApcsDisabled
ret

;%EXPORT KeAttachProcess
ret

;%EXPORT KeBugCheck
ret

;%EXPORT KeBugCheckEx
ret

;%EXPORT KeCapturePersistentThreadState
ret

;%EXPORT KeClearEvent
ret

;%EXPORT KeConnectInterrupt
ret

;%EXPORT KeDcacheFlushCount
ret

;%EXPORT KeDeregisterBugCheckCallback
ret

;%EXPORT KeDeregisterBugCheckReasonCallback
ret

;%EXPORT KeDetachProcess
ret

;%EXPORT KeDisconnectInterrupt
ret

;%EXPORT KeEnterCriticalRegion
ret

;%EXPORT KeEnterKernelDebugger
ret

;%EXPORT KeFindConfigurationEntry
ret

;%EXPORT KeFindConfigurationNextEntry
ret

;%EXPORT KeFlushEntireTb
ret

;%EXPORT KeFlushQueuedDpcs
ret

;%EXPORT KeGetCurrentThread
ret

;%EXPORT KeGetPreviousMode
ret

;%EXPORT KeGetRecommendedSharedDataAlignment
ret

;%EXPORT KeI386AbiosCall
ret

;%EXPORT KeI386AllocateGdtSelectors
ret

;%EXPORT KeI386Call16BitCStyleFunction
ret

;%EXPORT KeI386Call16BitFunction
ret

;%EXPORT KeI386FlatToGdtSelector
ret

;%EXPORT KeI386GetLid
ret

;%EXPORT KeI386MachineType
ret

;%EXPORT KeI386ReleaseGdtSelectors
ret

;%EXPORT KeI386ReleaseLid
ret

;%EXPORT KeI386SetGdtSelector
ret

;%EXPORT KeIcacheFlushCount
ret

;%EXPORT KeInitializeApc
ret

;%EXPORT KeInitializeDeviceQueue
ret


;%EXPORT KeInitializeInterrupt
ret

;%EXPORT KeInitializeMutant
ret

;%EXPORT KeInitializeQueue
ret

;%EXPORT KeInitializeSemaphore
ret

;%EXPORT KeInsertByKeyDeviceQueue
ret

;%EXPORT KeInsertDeviceQueue
ret

;%EXPORT KeInsertHeadQueue
ret

;%EXPORT KeInsertQueue
ret

;%EXPORT KeInsertQueueApc
ret

;%EXPORT KeInsertQueueDpc
ret

;%EXPORT KeIsAttachedProcess
ret

;%EXPORT KeIsExecutingDpc
ret

;%EXPORT KeLeaveCriticalRegion
ret

;%EXPORT KeLoaderBlock
ret

;%EXPORT KeNumberProcessors
ret

;%EXPORT KeProfileInterrupt
ret

;%EXPORT KeProfileInterruptWithSource
ret

;%EXPORT KePulseEvent
ret

;%EXPORT KeQueryActiveProcessors
ret

;%EXPORT KeQueryInterruptTime
ret

;%EXPORT KeQueryPriorityThread
ret

;%EXPORT KeQueryRuntimeThread
ret

;%EXPORT KeQuerySystemTime
ret

;%EXPORT KeQueryTickCount
ret

;%EXPORT KeQueryTimeIncrement
ret

;%EXPORT KeRaiseUserException
ret

;%EXPORT KeReadStateEvent
ret

;%EXPORT KeReadStateMutant
ret

;%EXPORT KeReadStateMutex
ret

;%EXPORT KeReadStateQueue
ret

;%EXPORT KeReadStateSemaphore
ret

;%EXPORT KeReadStateTimer
ret

;%EXPORT KeRegisterBugCheckCallback
ret

;%EXPORT KeRegisterBugCheckReasonCallback
ret

;%EXPORT KeReleaseInStackQueuedSpinLockFromDpcLevel
ret

;%EXPORT KeReleaseInterruptSpinLock
ret

;%EXPORT KeReleaseMutant
ret

;%EXPORT KeReleaseMutex
ret

;%EXPORT KeReleaseSemaphore
ret

;%EXPORT KeReleaseSpinLockFromDpcLevel
ret

;%EXPORT KeRemoveByKeyDeviceQueue
ret

;%EXPORT KeRemoveByKeyDeviceQueueIfBusy
ret

;%EXPORT KeRemoveDeviceQueue
ret

;%EXPORT KeRemoveEntryDeviceQueue
ret

;%EXPORT KeRemoveQueue
ret

;%EXPORT KeRemoveQueueDpc
ret

;%EXPORT KeRemoveSystemServiceTable
ret

;%EXPORT KeResetEvent
ret

;%EXPORT KeRestoreFloatingPointState
ret

;%EXPORT KeRevertToUserAffinityThread
ret

;%EXPORT KeRundownQueue
ret

;%EXPORT KeSaveFloatingPointState
ret

;%EXPORT KeSaveStateForHibernate
ret

;%EXPORT KeServiceDescriptorTable
ret

;%EXPORT KeSetAffinityThread
ret

;%EXPORT KeSetBasePriorityThread
ret

;%EXPORT KeSetDmaIoCoherency
ret

;%EXPORT KeSetEvent
ret

;%EXPORT KeSetEventBoostPriority
ret

;%EXPORT KeSetIdealProcessorThread
ret

;%EXPORT KeSetImportanceDpc
ret

;%EXPORT KeSetKernelStackSwapEnable
ret

;%EXPORT KeSetPriorityThread
ret

;%EXPORT KeSetProfileIrql
ret

;%EXPORT KeSetSystemAffinityThread
ret

;%EXPORT KeSetTargetProcessorDpc
ret

;%EXPORT KeSetTimeIncrement
ret

;%EXPORT KeSetTimeUpdateNotifyRoutine
ret

;%EXPORT KeSetTimer
ret

;%EXPORT KeStackAttachProcess
ret

;%EXPORT KeSynchronizeExecution
ret

;%EXPORT KeTerminateThread
ret

;%EXPORT KeTickCount
ret

;%EXPORT KeUnstackDetachProcess
ret

;%EXPORT KeUpdateRunTime
ret

;%EXPORT KeUpdateSystemTime
ret

;%EXPORT KeUserModeCallback
ret

;%EXPORT KeWaitForMultipleObjects
ret

;%EXPORT KeWaitForMutexObject
ret

;%EXPORT KeWaitForSingleObject
ret

;%EXPORT KefAcquireSpinLockAtDpcLevel
ret

;%EXPORT KefReleaseSpinLockFromDpcLevel
ret

;%EXPORT Kei386EoiHelper
ret

;%EXPORT KiAcquireSpinLock
ret

;%EXPORT KiBugCheckData
ret

;%EXPORT KiCoprocessorError
ret

;%EXPORT KiDeliverApc
ret

;%EXPORT KiDispatchInterrupt
ret

;%EXPORT KiEnableTimerWatchdog
ret

;%EXPORT KiIpiServiceRoutine
ret

;%EXPORT KiReleaseSpinLock
ret

;%EXPORT KiUnexpectedInterrupt
ret

;%EXPORT Kii386SpinOnSpinLock
ret

;%EXPORT LdrAccessResource
ret

;%EXPORT LdrEnumResources
ret

;%EXPORT LdrFindResourceDirectory_U
ret

;%EXPORT LdrFindResource_U
ret

;%EXPORT LpcPortObjectType
ret

;%EXPORT LpcRequestPort
ret

;%EXPORT LpcRequestWaitReplyPort
ret

;%EXPORT LsaCallAuthenticationPackage
ret

;%EXPORT LsaDeregisterLogonProcess
ret

;%EXPORT LsaFreeReturnBuffer
ret

;%EXPORT LsaLogonUser
ret

;%EXPORT LsaLookupAuthenticationPackage
ret

;%EXPORT LsaRegisterLogonProcess
ret

;%EXPORT Mm64BitPhysicalAddress
ret

;%EXPORT MmAddPhysicalMemory
ret

;%EXPORT MmAddVerifierThunks
ret

;%EXPORT MmAdjustWorkingSetSize
ret

;%EXPORT MmAdvanceMdl
ret

;%EXPORT MmAllocateContiguousMemory
ret

;%EXPORT MmAllocateContiguousMemorySpecifyCache
ret

;%EXPORT MmAllocateMappingAddress
ret

;%EXPORT MmAllocateNonCachedMemory
ret

;%EXPORT MmAllocatePagesForMdl
ret

;%EXPORT MmBuildMdlForNonPagedPool
ret

;%EXPORT MmCanFileBeTruncated
ret

;%EXPORT MmCommitSessionMappedView
ret

;%EXPORT MmCreateMdl
ret

;%EXPORT MmCreateSection
ret

;%EXPORT MmDisableModifiedWriteOfSection
ret

;%EXPORT MmFlushImageSection
ret

;%EXPORT MmForceSectionClosed
ret

;%EXPORT MmFreeContiguousMemory
ret

;%EXPORT MmFreeContiguousMemorySpecifyCache
ret

;%EXPORT MmFreeMappingAddress
ret

;%EXPORT MmFreeNonCachedMemory
ret

;%EXPORT MmFreePagesFromMdl
ret

;%EXPORT MmGetPhysicalAddress
ret

;%EXPORT MmGetPhysicalMemoryRanges
ret

;%EXPORT MmGetSystemRoutineAddress
ret

;%EXPORT MmGetVirtualForPhysical
ret

;%EXPORT MmGrowKernelStack
ret

;%EXPORT MmHighestUserAddress
ret

;%EXPORT MmIsAddressValid
ret

;%EXPORT MmIsDriverVerifying
ret

;%EXPORT MmIsNonPagedSystemAddressValid
ret

;%EXPORT MmIsRecursiveIoFault
ret

;%EXPORT MmIsThisAnNtAsSystem
ret

;%EXPORT MmIsVerifierEnabled
ret

;%EXPORT MmLockPagableDataSection
ret

;%EXPORT MmLockPagableImageSection
ret

;%EXPORT MmLockPagableSectionByHandle
ret

;%EXPORT MmMapIoSpace
ret

;%EXPORT MmMapLockedPages
ret

;%EXPORT MmMapLockedPagesSpecifyCache
ret

;%EXPORT MmMapLockedPagesWithReservedMapping
ret

;%EXPORT MmMapMemoryDumpMdl
ret

;%EXPORT MmMapUserAddressesToPage
ret

;%EXPORT MmMapVideoDisplay
ret

;%EXPORT MmMapViewInSessionSpace
ret

;%EXPORT MmMapViewInSystemSpace
ret

;%EXPORT MmMapViewOfSection
ret

;%EXPORT MmMarkPhysicalMemoryAsBad
ret

;%EXPORT MmMarkPhysicalMemoryAsGood
ret

;%EXPORT MmPrefetchPages
ret

;%EXPORT MmProbeAndLockPages
ret

;%EXPORT MmProbeAndLockProcessPages
ret

;%EXPORT MmProbeAndLockSelectedPages
ret

;%EXPORT MmProtectMdlSystemAddress
ret

;%EXPORT MmQuerySystemSize
ret

;%EXPORT MmRemovePhysicalMemory
ret

;%EXPORT MmResetDriverPaging
ret

;%EXPORT MmSectionObjectType
ret

;%EXPORT MmSecureVirtualMemory
ret

;%EXPORT MmSetAddressRangeModified
ret

;%EXPORT MmSetBankedSection
ret

;%EXPORT MmSizeOfMdl
ret

;%EXPORT MmSystemRangeStart
ret

;%EXPORT MmTrimAllSystemPagableMemory
ret

;%EXPORT MmUnlockPagableImageSection
ret

;%EXPORT MmUnlockPages
ret

;%EXPORT MmUnmapIoSpace
ret

;%EXPORT MmUnmapLockedPages
ret

;%EXPORT MmUnmapReservedMapping
ret

;%EXPORT MmUnmapVideoDisplay
ret

;%EXPORT MmUnmapViewInSessionSpace
ret

;%EXPORT MmUnmapViewInSystemSpace
ret

;%EXPORT MmUnmapViewOfSection
ret

;%EXPORT MmUnsecureVirtualMemory
ret

;%EXPORT MmUserProbeAddress
ret

;%EXPORT NlsAnsiCodePage
ret

;%EXPORT NlsLeadByteInfo
ret

;%EXPORT NlsMbCodePageTag
ret

;%EXPORT NlsMbOemCodePageTag
ret

;%EXPORT NlsOemCodePage
ret

;%EXPORT NlsOemLeadByteInfo
ret

;%EXPORT NtAddAtom
ret

;%EXPORT NtAdjustPrivilegesToken
ret

;%EXPORT NtAllocateLocallyUniqueId
ret

;%EXPORT NtAllocateUuids
ret

;%EXPORT NtAllocateVirtualMemory
ret

;%EXPORT NtBuildNumber
ret

;%EXPORT NtClose
ret

;%EXPORT NtConnectPort
ret

;%EXPORT NtCreateEvent
ret

;%EXPORT NtCreateFile
ret

;%EXPORT NtCreateSection
ret

;%EXPORT NtDeleteAtom
ret

;%EXPORT NtDeleteFile
ret

;%EXPORT NtDeviceIoControlFile
ret

;%EXPORT NtDuplicateObject
ret

;%EXPORT NtDuplicateToken
ret

;%EXPORT NtFindAtom
ret

;%EXPORT NtFreeVirtualMemory
ret

;%EXPORT NtFsControlFile
ret

;%EXPORT NtGlobalFlag
ret

;%EXPORT NtLockFile
ret

;%EXPORT NtMakePermanentObject
ret

;%EXPORT NtMapViewOfSection
ret

;%EXPORT NtNotifyChangeDirectoryFile
ret

;%EXPORT NtOpenFile
ret

;%EXPORT NtOpenProcess
ret

;%EXPORT NtOpenProcessToken
ret

;%EXPORT NtOpenProcessTokenEx
ret

;%EXPORT NtOpenThread
ret

;%EXPORT NtOpenThreadToken
ret

;%EXPORT NtOpenThreadTokenEx
ret

;%EXPORT NtQueryDirectoryFile
ret

;%EXPORT NtQueryEaFile
ret

;%EXPORT NtQueryInformationAtom
ret

;%EXPORT NtQueryInformationFile
ret

;%EXPORT NtQueryInformationProcess
ret

;%EXPORT NtQueryInformationThread
ret

;%EXPORT NtQueryInformationToken
ret

;%EXPORT NtQueryQuotaInformationFile
ret

;%EXPORT NtQuerySecurityObject
ret

;%EXPORT NtQuerySystemInformation
ret

;%EXPORT NtQueryVolumeInformationFile
ret

;%EXPORT NtReadFile
ret

;%EXPORT NtRequestPort
ret

;%EXPORT NtRequestWaitReplyPort
ret

;%EXPORT NtSetEaFile
ret

;%EXPORT NtSetEvent
ret

;%EXPORT NtSetInformationFile
ret

;%EXPORT NtSetInformationProcess
ret

;%EXPORT NtSetInformationThread
ret

;%EXPORT NtSetQuotaInformationFile
ret

;%EXPORT NtSetSecurityObject
ret

;%EXPORT NtSetVolumeInformationFile
ret

;%EXPORT NtShutdownSystem
ret

;%EXPORT NtTraceEvent
ret

;%EXPORT NtUnlockFile
ret

;%EXPORT NtVdmControl
ret

;%EXPORT NtWaitForSingleObject
ret

;%EXPORT NtWriteFile
ret

;%EXPORT ObAssignSecurity
ret

;%EXPORT ObCheckCreateObjectAccess
ret

;%EXPORT ObCheckObjectAccess
ret

;%EXPORT ObCloseHandle
ret

;%EXPORT ObCreateObject
ret

;%EXPORT ObCreateObjectType
ret

;%EXPORT ObDereferenceObject
ret

;%EXPORT ObDereferenceSecurityDescriptor
ret

;%EXPORT ObFindHandleForObject
ret

;%EXPORT ObGetObjectSecurity
ret

;%EXPORT ObInsertObject
ret

;%EXPORT ObLogSecurityDescriptor
ret

;%EXPORT ObMakeTemporaryObject
ret

;%EXPORT ObOpenObjectByName
ret

;%EXPORT ObOpenObjectByPointer
ret

;%EXPORT ObQueryNameString
ret

;%EXPORT ObQueryObjectAuditingByHandle
ret

;%EXPORT ObReferenceObjectByHandle
ret

;%EXPORT ObReferenceObjectByName
ret

;%EXPORT ObReferenceObjectByPointer
ret

;%EXPORT ObReferenceSecurityDescriptor
ret

;%EXPORT ObReleaseObjectSecurity
ret

;%EXPORT ObSetHandleAttributes
ret

;%EXPORT ObSetSecurityDescriptorInfo
ret

;%EXPORT ObSetSecurityObjectByPointer
ret

;%EXPORT ObfDereferenceObject
ret

;%EXPORT ObfReferenceObject
ret

;%EXPORT PfxFindPrefix
ret

;%EXPORT PfxInitialize
ret

;%EXPORT PfxInsertPrefix
ret

;%EXPORT PfxRemovePrefix
ret

;%EXPORT PoCallDriver
ret

;%EXPORT PoCancelDeviceNotify
ret

;%EXPORT PoQueueShutdownWorkItem
ret

;%EXPORT PoRegisterDeviceForIdleDetection
ret

;%EXPORT PoRegisterDeviceNotify
ret

;%EXPORT PoRegisterSystemState
ret

;%EXPORT PoRequestPowerIrp
ret

;%EXPORT PoRequestShutdownEvent
ret

;%EXPORT PoSetHiberRange
ret

;%EXPORT PoSetPowerState
ret

;%EXPORT PoSetSystemState
ret

;%EXPORT PoShutdownBugCheck
ret

;%EXPORT PoStartNextPowerIrp
ret

;%EXPORT PoUnregisterSystemState
ret

;%EXPORT ProbeForRead
ret

;%EXPORT ProbeForWrite
ret

;%EXPORT PsAssignImpersonationToken
ret

;%EXPORT PsChargePoolQuota
ret

;%EXPORT PsChargeProcessNonPagedPoolQuota
ret

;%EXPORT PsChargeProcessPagedPoolQuota
ret

;%EXPORT PsChargeProcessPoolQuota
ret

;%EXPORT PsCreateSystemProcess
ret

;%EXPORT PsCreateSystemThread
ret

;%EXPORT PsDereferenceImpersonationToken
ret

;%EXPORT PsDereferencePrimaryToken
ret

;%EXPORT PsDisableImpersonation
ret

;%EXPORT PsEstablishWin32Callouts
ret

;%EXPORT PsGetContextThread
ret

;%EXPORT PsGetCurrentThreadPreviousMode
ret

;%EXPORT PsGetCurrentThreadStackBase
ret

;%EXPORT PsGetCurrentThreadStackLimit
ret

;%EXPORT PsGetJobLock
ret

;%EXPORT PsGetJobSessionId
ret

;%EXPORT PsGetJobUIRestrictionsClass
ret

;%EXPORT PsGetProcessCreateTimeQuadPart
ret

;%EXPORT PsGetProcessDebugPort
ret

;%EXPORT PsGetProcessExitProcessCalled
ret

;%EXPORT PsGetProcessExitStatus
ret

;%EXPORT PsGetProcessExitTime
ret

;%EXPORT PsGetProcessId
ret

;%EXPORT PsGetProcessImageFileName
ret

;%EXPORT PsGetProcessInheritedFromUniqueProcessId
ret

;%EXPORT PsGetProcessJob
ret

;%EXPORT PsGetProcessPeb
ret

;%EXPORT PsGetProcessPriorityClass
ret

;%EXPORT PsGetProcessSectionBaseAddress
ret

;%EXPORT PsGetProcessSecurityPort
ret

;%EXPORT PsGetProcessSessionId
ret

;%EXPORT PsGetProcessWin32Process
ret

;%EXPORT PsGetProcessWin32WindowStation
ret

;%EXPORT PsGetThreadFreezeCount
ret

;%EXPORT PsGetThreadHardErrorsAreDisabled
ret

;%EXPORT PsGetThreadId
ret

;%EXPORT PsGetThreadProcess
ret

;%EXPORT PsGetThreadProcessId
ret

;%EXPORT PsGetThreadSessionId
ret

;%EXPORT PsGetThreadTeb
ret

;%EXPORT PsGetThreadWin32Thread
ret

;%EXPORT PsGetVersion
ret

;%EXPORT PsImpersonateClient
ret

;%EXPORT PsInitialSystemProcess
ret

;%EXPORT PsIsProcessBeingDebugged
ret

;%EXPORT PsIsSystemThread
ret

;%EXPORT PsIsThreadImpersonating
ret

;%EXPORT PsIsThreadTerminating
ret

;%EXPORT PsJobType
ret

;%EXPORT PsLookupProcessByProcessId
ret

;%EXPORT PsLookupProcessThreadByCid
ret

;%EXPORT PsLookupThreadByThreadId
ret

;%EXPORT PsProcessType
ret

;%EXPORT PsReferenceImpersonationToken
ret

;%EXPORT PsReferencePrimaryToken
ret

;%EXPORT PsRemoveCreateThreadNotifyRoutine
ret

;%EXPORT PsRemoveLoadImageNotifyRoutine
ret

;%EXPORT PsRestoreImpersonation
ret

;%EXPORT PsReturnPoolQuota
ret

;%EXPORT PsReturnProcessNonPagedPoolQuota
ret

;%EXPORT PsReturnProcessPagedPoolQuota
ret

;%EXPORT PsRevertThreadToSelf
ret

;%EXPORT PsRevertToSelf
ret

;%EXPORT PsSetContextThread
ret

;%EXPORT PsSetCreateProcessNotifyRoutine
ret

;%EXPORT PsSetCreateThreadNotifyRoutine
ret

;%EXPORT PsSetJobUIRestrictionsClass
ret

;%EXPORT PsSetLegoNotifyRoutine
ret

;%EXPORT PsSetLoadImageNotifyRoutine
ret

;%EXPORT PsSetProcessPriorityByClass
ret

;%EXPORT PsSetProcessPriorityClass
ret

;%EXPORT PsSetProcessSecurityPort
ret

;%EXPORT PsSetProcessWin32Process
ret

;%EXPORT PsSetProcessWindowStation
ret

;%EXPORT PsSetThreadHardErrorsAreDisabled
ret

;%EXPORT PsSetThreadWin32Thread
ret

;%EXPORT PsTerminateSystemThread
ret

;%EXPORT PsThreadType
ret

;%EXPORT READ_REGISTER_BUFFER_UCHAR
ret

;%EXPORT READ_REGISTER_BUFFER_ULONG
ret

;%EXPORT READ_REGISTER_BUFFER_USHORT
ret

;%EXPORT READ_REGISTER_UCHAR
ret

;%EXPORT READ_REGISTER_ULONG
ret

;%EXPORT READ_REGISTER_USHORT
ret

;%EXPORT RtlAbsoluteToSelfRelativeSD
ret

;%EXPORT RtlAddAccessAllowedAce
ret

;%EXPORT RtlAddAccessAllowedAceEx
ret

;%EXPORT RtlAddAce
ret

;%EXPORT RtlAddAtomToAtomTable
ret

;%EXPORT RtlAddRange
ret

;%EXPORT RtlAllocateHeap
ret

;%EXPORT RtlAnsiCharToUnicodeChar
ret

;%EXPORT RtlAnsiStringToUnicodeSize
ret

;%EXPORT RtlAnsiStringToUnicodeString
ret

;%EXPORT RtlAppendAsciizToString
ret

;%EXPORT RtlAppendStringToString
ret

;%EXPORT RtlAppendUnicodeStringToString
ret

;%EXPORT RtlAppendUnicodeToString
ret

;%EXPORT RtlAreAllAccessesGranted
ret

;%EXPORT RtlAreAnyAccessesGranted
ret

;%EXPORT RtlAreBitsClear
ret

;%EXPORT RtlAreBitsSet
ret

;%EXPORT RtlAssert
ret

;%EXPORT RtlCaptureContext
ret

;%EXPORT RtlCaptureStackBackTrace
ret

;%EXPORT RtlCharToInteger
ret

;%EXPORT RtlCheckRegistryKey
ret

;%EXPORT RtlClearAllBits
ret

;%EXPORT RtlClearBit
ret

;%EXPORT RtlClearBits
ret

;%EXPORT RtlCompareMemory
ret

;%EXPORT RtlCompareMemoryUlong
ret

;%EXPORT RtlCompareString
ret

;%EXPORT RtlCompareUnicodeString
ret

;%EXPORT RtlCompressBuffer
ret

;%EXPORT RtlCompressChunks
ret

;%EXPORT RtlConvertLongToLargeInteger
ret

;%EXPORT RtlConvertSidToUnicodeString
ret

;%EXPORT RtlConvertUlongToLargeInteger
ret

;%EXPORT RtlCopyLuid
ret

;%EXPORT RtlCopyRangeList
ret

;%EXPORT RtlCopySid
ret

;%EXPORT RtlCopyString
ret

;%EXPORT RtlCopyUnicodeString
ret

;%EXPORT RtlCreateAcl
ret

;%EXPORT RtlCreateAtomTable
ret

;%EXPORT RtlCreateHeap
ret

;%EXPORT RtlCreateRegistryKey
ret

;%EXPORT RtlCreateSecurityDescriptor
ret

;%EXPORT RtlCreateSystemVolumeInformationFolder
ret

;%EXPORT RtlCreateUnicodeString
ret

;%EXPORT RtlCustomCPToUnicodeN
ret

;%EXPORT RtlDecompressBuffer
ret

;%EXPORT RtlDecompressChunks
ret

;%EXPORT RtlDecompressFragment
ret

;%EXPORT RtlDelete
ret

;%EXPORT RtlDeleteAce
ret

;%EXPORT RtlDeleteAtomFromAtomTable
ret

;%EXPORT RtlDeleteElementGenericTable
ret

;%EXPORT RtlDeleteElementGenericTableAvl
ret

;%EXPORT RtlDeleteNoSplay
ret

;%EXPORT RtlDeleteOwnersRanges
ret

;%EXPORT RtlDeleteRange
ret

;%EXPORT RtlDeleteRegistryValue
ret

;%EXPORT RtlDescribeChunk
ret

;%EXPORT RtlDestroyAtomTable
ret

;%EXPORT RtlDestroyHeap
ret

;%EXPORT RtlDowncaseUnicodeString
ret

;%EXPORT RtlEmptyAtomTable
ret

;%EXPORT RtlEnlargedIntegerMultiply
ret

;%EXPORT RtlEnlargedUnsignedDivide
ret

;%EXPORT RtlEnlargedUnsignedMultiply
ret

;%EXPORT RtlEnumerateGenericTable
ret

;%EXPORT RtlEnumerateGenericTableAvl
ret

;%EXPORT RtlEnumerateGenericTableLikeADirectory
ret

;%EXPORT RtlEnumerateGenericTableWithoutSplaying
ret

;%EXPORT RtlEnumerateGenericTableWithoutSplayingAvl
ret

;%EXPORT RtlEqualLuid
ret

;%EXPORT RtlEqualSid
ret

;%EXPORT RtlEqualString
ret

;%EXPORT RtlEqualUnicodeString
ret

;%EXPORT RtlExtendedIntegerMultiply
ret

;%EXPORT RtlExtendedLargeIntegerDivide
ret

;%EXPORT RtlExtendedMagicDivide
ret

;%EXPORT RtlFillMemory
ret

;%EXPORT RtlFillMemoryUlong
ret

;%EXPORT RtlFindClearBits
ret

;%EXPORT RtlFindClearBitsAndSet
ret

;%EXPORT RtlFindClearRuns
ret

;%EXPORT RtlFindFirstRunClear
ret

;%EXPORT RtlFindLastBackwardRunClear
ret

;%EXPORT RtlFindLeastSignificantBit
ret

;%EXPORT RtlFindLongestRunClear
ret

;%EXPORT RtlFindMessage
ret

;%EXPORT RtlFindMostSignificantBit
ret

;%EXPORT RtlFindNextForwardRunClear
ret

;%EXPORT RtlFindRange
ret

;%EXPORT RtlFindSetBits
ret

;%EXPORT RtlFindSetBitsAndClear
ret

;%EXPORT RtlFindUnicodePrefix
ret

;%EXPORT RtlFormatCurrentUserKeyPath
ret

;%EXPORT RtlFreeAnsiString
ret

;%EXPORT RtlFreeHeap
ret

;%EXPORT RtlFreeOemString
ret

;%EXPORT RtlFreeRangeList
ret

;%EXPORT RtlFreeUnicodeString
ret

;%EXPORT RtlGUIDFromString
ret

;%EXPORT RtlGenerate8dot3Name
ret

;%EXPORT RtlGetAce
ret

;%EXPORT RtlGetCallersAddress
ret

;%EXPORT RtlGetCompressionWorkSpaceSize
ret

;%EXPORT RtlGetDaclSecurityDescriptor
ret

;%EXPORT RtlGetDefaultCodePage
ret

;%EXPORT RtlGetElementGenericTable
ret

;%EXPORT RtlGetElementGenericTableAvl
ret

;%EXPORT RtlGetFirstRange
ret

;%EXPORT RtlGetGroupSecurityDescriptor
ret

;%EXPORT RtlGetNextRange
ret

;%EXPORT RtlGetNtGlobalFlags
ret

;%EXPORT RtlGetOwnerSecurityDescriptor
ret

;%EXPORT RtlGetSaclSecurityDescriptor
ret

;%EXPORT RtlGetSetBootStatusData
ret

;%EXPORT RtlGetVersion
ret

;%EXPORT RtlHashUnicodeString
ret

;%EXPORT RtlImageDirectoryEntryToData
ret

;%EXPORT RtlInitAnsiString
ret

;%EXPORT RtlInitCodePageTable
ret

;%EXPORT RtlInitString
ret

;%EXPORT RtlInitializeBitMap
ret

;%EXPORT RtlInitializeGenericTable
ret

;%EXPORT RtlInitializeGenericTableAvl
ret

;%EXPORT RtlInitializeRangeList
ret

;%EXPORT RtlInitializeSid
ret

;%EXPORT RtlInitializeUnicodePrefix
ret

;%EXPORT RtlInsertElementGenericTable
ret

;%EXPORT RtlInsertElementGenericTableAvl
ret

;%EXPORT RtlInsertElementGenericTableFull
ret

;%EXPORT RtlInsertElementGenericTableFullAvl
ret

;%EXPORT RtlInsertUnicodePrefix
ret

;%EXPORT RtlInt64ToUnicodeString
ret

;%EXPORT RtlIntegerToChar
ret

;%EXPORT RtlIntegerToUnicode
ret

;%EXPORT RtlIntegerToUnicodeString
ret

;%EXPORT RtlInvertRangeList
ret

;%EXPORT RtlIpv4AddressToStringA
ret

;%EXPORT RtlIpv4AddressToStringExA
ret

;%EXPORT RtlIpv4AddressToStringExW
ret

;%EXPORT RtlIpv4AddressToStringW
ret

;%EXPORT RtlIpv4StringToAddressA
ret

;%EXPORT RtlIpv4StringToAddressExA
ret

;%EXPORT RtlIpv4StringToAddressExW
ret

;%EXPORT RtlIpv4StringToAddressW
ret

;%EXPORT RtlIpv6AddressToStringA
ret

;%EXPORT RtlIpv6AddressToStringExA
ret

;%EXPORT RtlIpv6AddressToStringExW
ret

;%EXPORT RtlIpv6AddressToStringW
ret

;%EXPORT RtlIpv6StringToAddressA
ret

;%EXPORT RtlIpv6StringToAddressExA
ret

;%EXPORT RtlIpv6StringToAddressExW
ret

;%EXPORT RtlIpv6StringToAddressW
ret

;%EXPORT RtlIsGenericTableEmpty
ret

;%EXPORT RtlIsGenericTableEmptyAvl
ret

;%EXPORT RtlIsNameLegalDOS8Dot3
ret

;%EXPORT RtlIsRangeAvailable
ret

;%EXPORT RtlIsValidOemCharacter
ret

;%EXPORT RtlLargeIntegerAdd
ret

;%EXPORT RtlLargeIntegerArithmeticShift
ret

;%EXPORT RtlLargeIntegerDivide
ret

;%EXPORT RtlLargeIntegerNegate
ret

;%EXPORT RtlLargeIntegerShiftLeft
ret

;%EXPORT RtlLargeIntegerShiftRight
ret

;%EXPORT RtlLargeIntegerSubtract
ret

;%EXPORT RtlLengthRequiredSid
ret

;%EXPORT RtlLengthSecurityDescriptor
ret

;%EXPORT RtlLengthSid
ret

;%EXPORT RtlLockBootStatusData
ret

;%EXPORT RtlLookupAtomInAtomTable
ret

;%EXPORT RtlLookupElementGenericTable
ret

;%EXPORT RtlLookupElementGenericTableAvl
ret

;%EXPORT RtlLookupElementGenericTableFull
ret

;%EXPORT RtlLookupElementGenericTableFullAvl
ret

;%EXPORT RtlMapGenericMask
ret

;%EXPORT RtlMapSecurityErrorToNtStatus
ret

;%EXPORT RtlMergeRangeLists
ret

;%EXPORT RtlMoveMemory
ret

;%EXPORT RtlMultiByteToUnicodeN
ret

;%EXPORT RtlMultiByteToUnicodeSize
ret

;%EXPORT RtlNextUnicodePrefix
ret

;%EXPORT RtlNtStatusToDosError
ret

;%EXPORT RtlNtStatusToDosErrorNoTeb
ret

;%EXPORT RtlNumberGenericTableElements
ret

;%EXPORT RtlNumberGenericTableElementsAvl
ret

;%EXPORT RtlNumberOfClearBits
ret

;%EXPORT RtlNumberOfSetBits
ret

;%EXPORT RtlOemStringToCountedUnicodeString
ret

;%EXPORT RtlOemStringToUnicodeSize
ret

;%EXPORT RtlOemStringToUnicodeString
ret

;%EXPORT RtlOemToUnicodeN
ret

;%EXPORT RtlPinAtomInAtomTable
ret

;%EXPORT RtlPrefetchMemoryNonTemporal
ret

;%EXPORT RtlPrefixString
ret

;%EXPORT RtlPrefixUnicodeString
ret

;%EXPORT RtlQueryAtomInAtomTable
ret

;%EXPORT RtlQueryRegistryValues
ret

;%EXPORT RtlQueryTimeZoneInformation
ret

;%EXPORT RtlRaiseException
ret

;%EXPORT RtlRandom
ret

;%EXPORT RtlRandomEx
ret

;%EXPORT RtlRealPredecessor
ret

;%EXPORT RtlRealSuccessor
ret

;%EXPORT RtlRemoveUnicodePrefix
ret

;%EXPORT RtlReserveChunk
ret

;%EXPORT RtlSecondsSince1970ToTime
ret

;%EXPORT RtlSecondsSince1980ToTime
ret

;%EXPORT RtlSelfRelativeToAbsoluteSD
ret

;%EXPORT RtlSelfRelativeToAbsoluteSD2
ret

;%EXPORT RtlSetAllBits
ret

;%EXPORT RtlSetBit
ret

;%EXPORT RtlSetBits
ret

;%EXPORT RtlSetDaclSecurityDescriptor
ret

;%EXPORT RtlSetGroupSecurityDescriptor
ret

;%EXPORT RtlSetOwnerSecurityDescriptor
ret

;%EXPORT RtlSetSaclSecurityDescriptor
ret

;%EXPORT RtlSetTimeZoneInformation
ret

;%EXPORT RtlSizeHeap
ret

;%EXPORT RtlSplay
ret

;%EXPORT RtlStringFromGUID
ret

;%EXPORT RtlSubAuthorityCountSid
ret

;%EXPORT RtlSubAuthoritySid
ret

;%EXPORT RtlSubtreePredecessor
ret

;%EXPORT RtlSubtreeSuccessor
ret

;%EXPORT RtlTestBit
ret

;%EXPORT RtlTimeFieldsToTime
ret

;%EXPORT RtlTimeToElapsedTimeFields
ret

;%EXPORT RtlTimeToSecondsSince1970
ret

;%EXPORT RtlTimeToSecondsSince1980
ret

;%EXPORT RtlTimeToTimeFields
ret

;%EXPORT RtlTraceDatabaseAdd
ret

;%EXPORT RtlTraceDatabaseCreate
ret

;%EXPORT RtlTraceDatabaseDestroy
ret

;%EXPORT RtlTraceDatabaseEnumerate
ret

;%EXPORT RtlTraceDatabaseFind
ret

;%EXPORT RtlTraceDatabaseLock
ret

;%EXPORT RtlTraceDatabaseUnlock
ret

;%EXPORT RtlTraceDatabaseValidate
ret

;%EXPORT RtlUlongByteSwap
ret

;%EXPORT RtlUlonglongByteSwap
ret

;%EXPORT RtlUnicodeStringToAnsiSize
ret

;%EXPORT RtlUnicodeStringToAnsiString
ret

;%EXPORT RtlUnicodeStringToCountedOemString
ret

;%EXPORT RtlUnicodeStringToInteger
ret

;%EXPORT RtlUnicodeStringToOemSize
ret

;%EXPORT RtlUnicodeStringToOemString
ret

;%EXPORT RtlUnicodeToCustomCPN
ret

;%EXPORT RtlUnicodeToMultiByteN
ret

;%EXPORT RtlUnicodeToMultiByteSize
ret

;%EXPORT RtlUnicodeToOemN
ret

;%EXPORT RtlUnlockBootStatusData
ret

;%EXPORT RtlUnwind
ret

;%EXPORT RtlUpcaseUnicodeChar
ret

;%EXPORT RtlUpcaseUnicodeString
ret

;%EXPORT RtlUpcaseUnicodeStringToAnsiString
ret

;%EXPORT RtlUpcaseUnicodeStringToCountedOemString
ret

;%EXPORT RtlUpcaseUnicodeStringToOemString
ret

;%EXPORT RtlUpcaseUnicodeToCustomCPN
ret

;%EXPORT RtlUpcaseUnicodeToMultiByteN
ret

;%EXPORT RtlUpcaseUnicodeToOemN
ret

;%EXPORT RtlUpperChar
ret

;%EXPORT RtlUpperString
ret

;%EXPORT RtlUshortByteSwap
ret

;%EXPORT RtlValidRelativeSecurityDescriptor
ret

;%EXPORT RtlValidSecurityDescriptor
ret

;%EXPORT RtlValidSid
ret

;%EXPORT RtlVerifyVersionInfo
ret

;%EXPORT RtlVolumeDeviceToDosName
ret

;%EXPORT RtlWalkFrameChain
ret

;%EXPORT RtlWriteRegistryValue
ret

;%EXPORT RtlZeroHeap
ret

;%EXPORT RtlZeroMemory
ret

;%EXPORT RtlxAnsiStringToUnicodeSize
ret

;%EXPORT RtlxOemStringToUnicodeSize
ret

;%EXPORT RtlxUnicodeStringToAnsiSize
ret

;%EXPORT RtlxUnicodeStringToOemSize
ret

;%EXPORT SeAccessCheck
ret

;%EXPORT SeAppendPrivileges
ret

;%EXPORT SeAssignSecurity
ret

;%EXPORT SeAssignSecurityEx
ret

;%EXPORT SeAuditHardLinkCreation
ret

;%EXPORT SeAuditingFileEvents
ret

;%EXPORT SeAuditingFileEventsWithContext
ret

;%EXPORT SeAuditingFileOrGlobalEvents
ret

;%EXPORT SeAuditingHardLinkEvents
ret

;%EXPORT SeAuditingHardLinkEventsWithContext
ret

;%EXPORT SeCaptureSecurityDescriptor
ret

;%EXPORT SeCaptureSubjectContext
ret

;%EXPORT SeCloseObjectAuditAlarm
ret

;%EXPORT SeCreateAccessState
ret

;%EXPORT SeCreateClientSecurity
ret

;%EXPORT SeCreateClientSecurityFromSubjectContext
ret

;%EXPORT SeDeassignSecurity
ret

;%EXPORT SeDeleteAccessState
ret

;%EXPORT SeDeleteObjectAuditAlarm
ret

;%EXPORT SeExports
ret

;%EXPORT SeFilterToken
ret

;%EXPORT SeFreePrivileges
ret

;%EXPORT SeImpersonateClient
ret

;%EXPORT SeImpersonateClientEx
ret

;%EXPORT SeLockSubjectContext
ret

;%EXPORT SeMarkLogonSessionForTerminationNotification
ret

;%EXPORT SeOpenObjectAuditAlarm
ret

;%EXPORT SeOpenObjectForDeleteAuditAlarm
ret

;%EXPORT SePrivilegeCheck
ret

;%EXPORT SePrivilegeObjectAuditAlarm
ret

;%EXPORT SePublicDefaultDacl
ret

;%EXPORT SeQueryAuthenticationIdToken
ret

;%EXPORT SeQueryInformationToken
ret

;%EXPORT SeQuerySecurityDescriptorInfo
ret

;%EXPORT SeQuerySessionIdToken
ret

;%EXPORT SeRegisterLogonSessionTerminatedRoutine
ret

;%EXPORT SeReleaseSecurityDescriptor
ret

;%EXPORT SeReleaseSubjectContext
ret

;%EXPORT SeSetAccessStateGenericMapping
ret

;%EXPORT SeSetSecurityDescriptorInfo
ret

;%EXPORT SeSetSecurityDescriptorInfoEx
ret

;%EXPORT SeSinglePrivilegeCheck
ret

;%EXPORT SeSystemDefaultDacl
ret

;%EXPORT SeTokenImpersonationLevel
ret

;%EXPORT SeTokenIsAdmin
ret

;%EXPORT SeTokenIsRestricted
ret

;%EXPORT SeTokenIsWriteRestricted
ret

;%EXPORT SeTokenObjectType
ret

;%EXPORT SeTokenType
ret

;%EXPORT SeUnlockSubjectContext
ret

;%EXPORT SeUnregisterLogonSessionTerminatedRoutine
ret

;%EXPORT SeValidSecurityDescriptor
ret

;%EXPORT VerSetConditionMask
ret

;%EXPORT VfFailDeviceNode
ret

;%EXPORT VfFailDriver
ret

;%EXPORT VfFailSystemBIOS
ret

;%EXPORT VfIsVerificationEnabled
ret

;%EXPORT WRITE_REGISTER_BUFFER_UCHAR
ret

;%EXPORT WRITE_REGISTER_BUFFER_ULONG
ret

;%EXPORT WRITE_REGISTER_BUFFER_USHORT
ret

;%EXPORT WRITE_REGISTER_UCHAR
ret

;%EXPORT WRITE_REGISTER_ULONG
ret

;%EXPORT WRITE_REGISTER_USHORT
ret

;%EXPORT WmiFlushTrace
ret

;%EXPORT WmiGetClock
ret

;%EXPORT WmiQueryTrace
ret

;%EXPORT WmiQueryTraceInformation
ret

;%EXPORT WmiStartTrace
ret

;%EXPORT WmiStopTrace
ret

;%EXPORT WmiTraceMessage
ret

;%EXPORT WmiTraceMessageVa
ret

;%EXPORT WmiUpdateTrace
ret

;%EXPORT XIPDispatch
ret

;%EXPORT ZwAccessCheckAndAuditAlarm
ret

;%EXPORT ZwAddBootEntry
ret

;%EXPORT ZwAdjustPrivilegesToken
ret

;%EXPORT ZwAlertThread
ret

;%EXPORT ZwAllocateVirtualMemory
ret

;%EXPORT ZwAssignProcessToJobObject
ret

;%EXPORT ZwCancelIoFile
ret

;%EXPORT ZwCancelTimer
ret

;%EXPORT ZwClearEvent
ret

;%EXPORT ZwClose
ret

;%EXPORT ZwCloseObjectAuditAlarm
ret

;%EXPORT ZwConnectPort
ret

;%EXPORT ZwCreateDirectoryObject
ret

;%EXPORT ZwCreateEvent
ret

;%EXPORT ZwCreateFile
ret

;%EXPORT ZwCreateJobObject
ret

;%EXPORT ZwCreateKey
ret

;%EXPORT ZwCreateSymbolicLinkObject
ret

;%EXPORT ZwCreateTimer
ret

;%EXPORT ZwDeleteBootEntry
ret

;%EXPORT ZwDeleteFile
ret

;%EXPORT ZwDeleteKey
ret

;%EXPORT ZwDeleteValueKey
ret

;%EXPORT ZwDeviceIoControlFile
ret

;%EXPORT ZwDisplayString
ret

;%EXPORT ZwDuplicateObject
ret

;%EXPORT ZwDuplicateToken
ret

;%EXPORT ZwEnumerateBootEntries
ret

;%EXPORT ZwEnumerateKey
ret

;%EXPORT ZwEnumerateValueKey
ret

;%EXPORT ZwFlushInstructionCache
ret

;%EXPORT ZwFlushKey
ret

;%EXPORT ZwFlushVirtualMemory
ret

;%EXPORT ZwFreeVirtualMemory
ret

;%EXPORT ZwFsControlFile
ret

;%EXPORT ZwInitiatePowerAction
ret

;%EXPORT ZwIsProcessInJob
ret

;%EXPORT ZwLoadDriver
ret

;%EXPORT ZwLoadKey
ret

;%EXPORT ZwMakeTemporaryObject
ret

;%EXPORT ZwNotifyChangeKey
ret

;%EXPORT ZwOpenDirectoryObject
ret

;%EXPORT ZwOpenEvent
ret

;%EXPORT ZwOpenJobObject
ret

;%EXPORT ZwOpenKey
ret

;%EXPORT ZwOpenProcess
ret

;%EXPORT ZwOpenProcessToken
ret

;%EXPORT ZwOpenProcessTokenEx
ret

;%EXPORT ZwOpenSection
ret

;%EXPORT ZwOpenSymbolicLinkObject
ret

;%EXPORT ZwOpenThread
ret

;%EXPORT ZwOpenThreadToken
ret

;%EXPORT ZwOpenThreadTokenEx
ret

;%EXPORT ZwOpenTimer
ret

;%EXPORT ZwPowerInformation
ret

;%EXPORT ZwPulseEvent
ret

;%EXPORT ZwQueryBootEntryOrder
ret

;%EXPORT ZwQueryBootOptions
ret

;%EXPORT ZwQueryDefaultLocale
ret

;%EXPORT ZwQueryDefaultUILanguage
ret

;%EXPORT ZwQueryDirectoryFile
ret

;%EXPORT ZwQueryDirectoryObject
ret

;%EXPORT ZwQueryEaFile
ret

;%EXPORT ZwQueryFullAttributesFile
ret

;%EXPORT ZwQueryInformationFile
ret

;%EXPORT ZwQueryInformationJobObject
ret

;%EXPORT ZwQueryInformationProcess
ret

;%EXPORT ZwQueryInformationThread
ret

;%EXPORT ZwQueryInformationToken
ret

;%EXPORT ZwQueryInstallUILanguage
ret

;%EXPORT ZwQueryKey
ret

;%EXPORT ZwQueryObject
ret

;%EXPORT ZwQuerySection
ret

;%EXPORT ZwQuerySecurityObject
ret

;%EXPORT ZwQuerySymbolicLinkObject
ret


;%EXPORT ZwQueryValueKey
ret

;%EXPORT ZwQueryVolumeInformationFile
ret

;%EXPORT ZwReadFile
ret

;%EXPORT ZwReplaceKey
ret

;%EXPORT ZwRequestWaitReplyPort
ret

;%EXPORT ZwResetEvent
ret

;%EXPORT ZwRestoreKey
ret

;%EXPORT ZwSaveKey
ret

;%EXPORT ZwSaveKeyEx
ret

;%EXPORT ZwSetBootEntryOrder
ret

;%EXPORT ZwSetBootOptions
ret

;%EXPORT ZwSetDefaultLocale
ret

;%EXPORT ZwSetDefaultUILanguage
ret

;%EXPORT ZwSetEaFile
ret

;%EXPORT ZwSetEvent
ret

;%EXPORT ZwSetInformationFile
ret

;%EXPORT ZwSetInformationJobObject
ret

;%EXPORT ZwSetInformationObject
ret

;%EXPORT ZwSetInformationProcess
ret

;%EXPORT ZwSetInformationThread
ret

;%EXPORT ZwSetSecurityObject
ret

;%EXPORT ZwSetSystemInformation
ret

;%EXPORT ZwSetSystemTime
ret

;%EXPORT ZwSetTimer
ret

;%EXPORT ZwSetValueKey
ret

;%EXPORT ZwSetVolumeInformationFile
ret

;%EXPORT ZwTerminateJobObject
ret

;%EXPORT ZwTerminateProcess
ret

;%EXPORT ZwTranslateFilePath
ret

;%EXPORT ZwUnloadDriver
ret

;%EXPORT ZwUnloadKey
ret

;%EXPORT ZwUnmapViewOfSection
ret

;%EXPORT ZwWaitForMultipleObjects
ret

;%EXPORT ZwWaitForSingleObject
ret

;%EXPORT ZwWriteFile
ret

;%EXPORT ZwYieldExecution
ret

;%EXPORT _CIcos
ret

;%EXPORT _CIsin
ret

;%EXPORT _CIsqrt
ret

;%EXPORT _abnormal_termination
ret

;%EXPORT _alldiv
ret

;%EXPORT _alldvrm
ret

;%EXPORT _allmul
ret

;%EXPORT _alloca_probe
ret

;%EXPORT _allrem
ret

;%EXPORT _allshl
ret

;%EXPORT _allshr
ret

;%EXPORT _aulldiv
ret

;%EXPORT _aulldvrm
ret

;%EXPORT _aullrem
ret

;%EXPORT _aullshr
ret

;%EXPORT _except_handler2
ret

;%EXPORT _except_handler3
ret

;%EXPORT _global_unwind2
ret

;%EXPORT _itoa
ret

;%EXPORT _itow
ret

;%EXPORT _local_unwind2
ret

;%EXPORT _purecall
ret

;%EXPORT _snprintf
ret

;%EXPORT _snwprintf
ret

;%EXPORT _stricmp
ret

;%EXPORT _strlwr
ret

;%EXPORT _strnicmp
ret

;%EXPORT _strnset
ret

;%EXPORT _strrev
ret

;%EXPORT _strset
ret

;%EXPORT _strupr
ret

;%EXPORT _vsnprintf
ret

;%EXPORT _vsnwprintf
ret

;%EXPORT _wcsicmp
ret

;%EXPORT _wcslwr
ret

;%EXPORT _wcsnicmp
ret

;%EXPORT _wcsnset
ret

;%EXPORT _wcsrev
ret

;%EXPORT _wcsupr
ret

;%EXPORT atoi
ret

;%EXPORT atol
ret

;%EXPORT isdigit
ret

;%EXPORT islower
ret

;%EXPORT isprint
ret

;%EXPORT isspace
ret

;%EXPORT isupper
ret

;%EXPORT isxdigit
ret

;%EXPORT mbstowcs
ret

;%EXPORT mbtowc
ret

;%EXPORT memchr
ret

;%EXPORT qsort
ret

;%EXPORT rand
ret

;%EXPORT sprintf
ret
ret

;%EXPORT srand
ret

;%EXPORT strcat
ret

;%EXPORT strchr
ret

;%EXPORT strcmp
ret

;%EXPORT strcpy
ret

;%EXPORT strlen
ret

;%EXPORT strncat
ret

;%EXPORT strncmp
ret

;%EXPORT strncpy
ret

;%EXPORT strrchr
ret

;%EXPORT strspn
ret

;%EXPORT strstr
ret

;%EXPORT swprintf
ret

;%EXPORT tolower
ret

;%EXPORT towlower
ret

;%EXPORT towupper
ret

;%EXPORT vDbgPrintEx
ret

;%EXPORT vDbgPrintExWithPrefix
ret

;%EXPORT vsprintf
ret

;%EXPORT wcscat
ret

;%EXPORT wcschr
ret

;%EXPORT wcscmp
ret

;%EXPORT wcscpy
ret

;%EXPORT wcscspn
ret

;%EXPORT wcslen
ret

;%EXPORT wcsncat
ret

;%EXPORT wcsncmp
ret

;%EXPORT wcsncpy
ret

;%EXPORT wcsrchr
ret

;%EXPORT wcsspn
ret

;%EXPORT wcsstr
ret

;%EXPORT wcstombs
ret

;%EXPORT wctomb
ret

;%IMPORTS

;%EXPORTS ntoskrnl.exe

;%relocs

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010