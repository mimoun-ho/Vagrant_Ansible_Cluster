import tkinter as tk
from tkinter import ttk
import subprocess
import re
import os

def run_command(command):
    result = subprocess.run(command, capture_output=True, text=True, shell=True)
    if result.returncode != 0:
        print(f"Erreur lors de l'exécution de la commande {command}: {result.stderr}")
        return ""
    return result.stdout

def get_vms():
    command = "VBoxManage list vms"
    return re.findall(r'"(.+?)" {(.+?)}', run_command(command))

def get_all_disks():
    disk_path = "C:/Users/user/Documents/disks"
    return [f for f in os.listdir(disk_path) if f.endswith('.vdi')]

def shutdown_vm(vm_name):
    # Commande pour arrêter la VM
    run_command(f"VBoxManage controlvm {vm_name} poweroff")
    print(f"{vm_name} has been powered off.")

def launch_ui():
    root = tk.Tk()
    root.title("VM and Disk Configuration Tool")

    vm_data = get_vms()
    disks = get_all_disks()

    # Prepare storage for entries
    vm_entries = {}
    disk_entries = {}

    # Display VM settings
    for idx, (vm_name, _) in enumerate(vm_data):
        ttk.Label(root, text=f"VM {vm_name}:").grid(row=idx, column=0)
        cpu_entry = ttk.Entry(root)
        cpu_entry.grid(row=idx, column=2)
        ttk.Label(root, text="Nombre Processeur:").grid(column=1, row=idx)
        ttk.Label(root, text="Memory (GB):").grid(column=5, row=idx)
        memory_entry = ttk.Entry(root)
        memory_entry.grid(row=idx, column=4)
        vm_entries[vm_name] = (cpu_entry, memory_entry)

    # Display disk settings
    disk_row_start = len(vm_data) + 1
    for idx, disk_name in enumerate(disks):
        ttk.Label(root, text=f"Disk {disk_name} Size (GB):").grid(row=disk_row_start + idx, column=0)
        disk_size_entry = ttk.Entry(root)
        disk_size_entry.grid(row=disk_row_start + idx, column=1)
        disk_entries[disk_name] = disk_size_entry

    # Function to apply all changes
    def apply_changes():
        for vm_name, (cpu_entry, memory_entry) in vm_entries.items():
            cpus = cpu_entry.get()
            memory = memory_entry.get()
            # Vérifier si la VM est en cours d'exécution
            vm_info = run_command(f"VBoxManage showvminfo {vm_name} --machinereadable")
            if 'VMState="running"' in vm_info:
                shutdown_vm(vm_name)  # Arrêter la VM si elle est en cours d'exécution

            if cpus and memory:
                memory_mb = int(memory) * 1024  # Convertir Go en Mo
                run_command(f"VBoxManage modifyvm {vm_name} --cpus {cpus} --memory {memory_mb}")
                print(f"Configurations updated for {vm_name}: CPUs={cpus}, Memory={memory}GB")

        for disk_name, disk_size_entry in disk_entries.items():
            new_size = disk_size_entry.get()
            if new_size:
                new_size_mb = int(new_size) * 1024  # Convertir Go en Mo
                disk_path = f"C:/Users/user/Documents/disks/{disk_name}"
                run_command(f"VBoxManage modifymedium disk {disk_path} --resize {new_size_mb}")
                print(f"Disk {disk_name} resized to {new_size}GB")

    # Button to apply changes
    ttk.Button(root, text="Apply All Changes", command=apply_changes).grid(row=disk_row_start + len(disks), column=1)

    root.mainloop()

launch_ui()
