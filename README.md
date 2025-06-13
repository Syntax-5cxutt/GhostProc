# 👻 GhostProc

> **Driver kernel-mode per manipolazione avanzata dei processi su Windows**

![Platform](https://img.shields.io/badge/platform-Windows-blue?logo=windows)  
![Language](https://img.shields.io/badge/language-C%2FC%2B%2B-blue.svg)  
![License](https://img.shields.io/badge/license-NONE-lightgrey)  
![Status](https://img.shields.io/badge/status-POC-red)

---

## 🚀 Funzionalità

GhostProc è un **driver kernel-mode** per Windows in grado di:

- 🔑 **Rubare token di accesso (privilegi)** da un processo sorgente (es: `System`) verso un processo target (es: `cmd.exe`)
- 🫥 **Nascondere un processo attivo** dalla Active Process List per eludere Task Manager o strumenti di analisi
- 🛠️ Fornisce un semplice **client user-mode** per inviare comandi al driver tramite `DeviceIoControl`

---

## 🧠 Come funziona

GhostProc crea un device `\\.\TokenStealer` e offre due comandi IOCTL principali:

- `IOCTL_STEAL_TOKEN`: clona il token da un processo sorgente a uno target
- `IOCTL_HIDE_PROCESS`: rimuove un processo dalla lista attiva dei processi

Entrambe le funzionalità richiedono esecuzione da **amministratore**.

---

## 🧩 Struttura del Progetto

