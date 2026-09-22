# NVIDIA Driver and CUDA Toolkit Installation

## 0. Purge Previous NVIDIA and CUDA Installations

**These commands remove all installed NVIDIA and CUDA packages. Do not run them
if other applications on the system depend on the existing installation.**

Before installing a new driver or CUDA version, remove previous NVIDIA and CUDA
packages:

```
$sudo apt remove --purge \
  "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" \
  "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" \
  "nsight*" "*nvvm*"

$sudo apt remove --purge "*nvidia*"
$sudo apt autoremove
$sudo apt autoclean
```

Check whether any NVIDIA packages remain:

```
$dpkg -l | grep -i nvidia
```

If packages are listed, remove their remaining configuration files:

```
$sudo apt remove --purge "NAME_OF_THE_PACKAGE"
```


Reboot before continuing with the installation:

```
$sudo reboot
```

## 1. Install NVIDIA Driver

Follow the steps on the [documentation](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/latest/index.html), focusing mainly on the following steps

1. Pre-Installation Actions
2. The one corresponding to your OS
    - Prefer **Network Repository Enablement**

Once installed reboot the computer

```
$sudo reboot
```

After rebooting, to check that the driver is correctly installed you should see
a message like the one bellow:

```
$nvidia-smi
Tue Sep 22 09:09:56 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 610.57.04              KMD Version: 610.57.04     CUDA UMD Version: 13.3     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4060 ...    Off |   00000000:01:00.0  On |                  N/A |
| N/A   39C    P8              4W /   60W |      62MiB /   8188MiB |     34%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            2943      G   /usr/lib/xorg/Xorg                       43MiB |
+-----------------------------------------------------------------------------------------+
```

The driver vesion might differ depending on your OS and version selected

## 2. Install CUDA-toolkit

Follow the steps on the [documentation](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#pre-installation-actions), focusing mainly on the following steps

1. Pre-Installation Actions
2. Package Manager Installation (The one corresponding to your OS)
    - Prefer the method **4.X.X Network Repository Installation**
    - Install only the cuda-toolkit no gds or cuda-compat packages needed

After rebooting, to check that the cuda-toolkit is correctly installed you should see
a message like the one bellow:

```
$nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2026 NVIDIA Corporation
Built on Tue_Jun_09_02:43:40_PM_PDT_2026
Cuda compilation tools, release 13.3, V13.3.73
Build cuda_13.3.r13.3/compiler.38244171_0
```

## 3. Add nvcc to PATH

If nvcc is installed but the command is not found, add the CUDA bin directory to PATH.

Append the following lines to ~/.bashrc (file located in home/YOUR_USER_NAME/.bashrc):

```
export PATH=/usr/local/cuda-13.3/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-13.3/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
```

Apply the changes:

```
source ~/.bashrc
```

Verify that nvcc is available:

```
which nvcc
nvcc --version
```

