
CHARACTERISTICS equ IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

%include '../../onesec.hdr'

EntryPoint:
    retn 3 * 4

;%EXPORT ClassAcquireChildLock
;%EXPORT ClassAcquireRemoveLockEx
;%EXPORT ClassAsynchronousCompletion
;%EXPORT ClassBuildRequest
;%EXPORT ClassCheckMediaState
;%EXPORT ClassClaimDevice
;%EXPORT ClassCleanupMediaChangeDetection
;%EXPORT ClassCompleteRequest
;%EXPORT ClassCreateDeviceObject
;%EXPORT ClassDebugPrint
;%EXPORT ClassDeleteSrbLookasideList
;%EXPORT ClassDeviceControl
;%EXPORT ClassDisableMediaChangeDetection
;%EXPORT ClassEnableMediaChangeDetection
;%EXPORT ClassFindModePage
;%EXPORT ClassForwardIrpSynchronous
;%EXPORT ClassGetDescriptor
;%EXPORT ClassGetDeviceParameter
;%EXPORT ClassGetDriverExtension
;%EXPORT ClassGetVpb
;%EXPORT ClassInitialize
;%EXPORT ClassInitializeEx
;%EXPORT ClassInitializeMediaChangeDetection
;%EXPORT ClassInitializeSrbLookasideList
;%EXPORT ClassInitializeTestUnitPolling
;%EXPORT ClassInternalIoControl
;%EXPORT ClassInterpretSenseInfo
;%EXPORT ClassInvalidateBusRelations
;%EXPORT ClassIoComplete
;%EXPORT ClassIoCompleteAssociated
;%EXPORT ClassMarkChildMissing
;%EXPORT ClassMarkChildrenMissing
;%EXPORT ClassModeSense
;%EXPORT ClassNotifyFailurePredicted
;%EXPORT ClassQueryTimeOutRegistryValue
;%EXPORT ClassReadDriveCapacity
;%EXPORT ClassReleaseChildLock
;%EXPORT ClassReleaseQueue
;%EXPORT ClassReleaseRemoveLock
;%EXPORT ClassRemoveDevice
;%EXPORT ClassResetMediaChangeTimer
;%EXPORT ClassScanForSpecial
;%EXPORT ClassSendDeviceIoControlSynchronous
;%EXPORT ClassSendIrpSynchronous
;%EXPORT ClassSendSrbAsynchronous
;%EXPORT ClassSendSrbSynchronous
;%EXPORT ClassSendStartUnit
;%EXPORT ClassSetDeviceParameter
;%EXPORT ClassSetFailurePredictionPoll
;%EXPORT ClassSetMediaChangeState
;%EXPORT ClassSignalCompletion
;%EXPORT ClassSpinDownPowerHandler
;%EXPORT ClassSplitRequest
;%EXPORT ClassStopUnitPowerHandler
;%EXPORT ClassUpdateInformationInRegistry
;%EXPORT ClassWmiCompleteRequest
;%EXPORT ClassWmiFireEvent
    retn

;%reloc 2
;%IMPORT user32.dll!MessageBoxA
;%reloc 2
;%IMPORT kernel32.dll!VirtualAlloc
;%IMPORTS

;%EXPORTS classpnp.sys

;%relocs

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE


