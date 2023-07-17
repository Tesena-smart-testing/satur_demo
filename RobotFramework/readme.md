# Satur

# Prepare environment

- [Satur](#satur)
- [Prepare environment](#prepare-environment)
  - [1. Python installation](#1-python-installation)
    - [1.1. Windows](#11-windows)
    - [1.2. MacOS](#12-macos)
    - [1.3. Linux](#13-linux)
  - [2. Verify Python and Pip Installation](#2-verify-python-and-pip-installation)
    - [2.1. Command Line (Windows)](#21-command-line-windows)
    - [2.2. Command Line (MacOS)](#22-command-line-macos)
    - [2.3. Terminal (Linux)](#23-terminal-linux)
  - [3. Libraries](#3-libraries)
  - [4. MySql installation](#4-MySql-installation)

## 1. Python installation

### 1.1. Windows

1. Download Python Installer: Download the highest recommended version of the Python installer (64-bit) from [python.org/downloads](https://www.python.org/downloads/).
2. Run the Installer: Run the installer file with admin rights.
3. Configure Python Installation (Windows): Make sure to select the "Add Python to PATH" option during the installation process, then click "Install Now." It is recommended to choose the option to disable the path length limit.

### 1.2. MacOS

1. Download Python Installer: Download the latest version of the Python installer for your MacOS from [python.org/downloads](https://www.python.org/downloads/). Choose the appropriate version (32-bit or 64-bit) according to your MacOS.
2. Run the Installer: Run the installer file with admin rights.

### 1.3. Linux

1. In terminal write this commands:

> 1.1. $ sudo apt update

> 1.2. $ sudo apt install build-essential zlib1g-dev

> 1.3. $ sudo apt installlibncurses5-dev libgdbm-dev libnss3-dev

> 1.4. $ sudo apt installlibssl-dev libreadline-dev libffi-dev curl

2. Download Python Source Tarball: Download the Python source tarball that matches your needs from [python.org/downloads/source](https://www.python.org/downloads/source/).
3. Extract the downloaded tarball archive.
4. In terminal write this commands:

> 4.1 $ cd Python-3.*

> 4.2 $ ./configure --Configure the script for the Python installation

> 4.3 $ sudo make altinstall --Start the build process for Python

> 4.4 $ sudo apt install python3-pip

## 2. Verify Python and Pip Installation

### 2.1. Command Line (Windows)

Open the Command Line window and use the following commands:

> python -V

> pip -V

The command line should display your Python version and Pip version respectively.

### 2.2. Command Line (MacOS)

Open the terminal and use the following commands:

> % python3 --version

> % python3 -m pip --version

The terminal should display your Python version and Pip version respectively.

### 2.3. Terminal (Linux)

> $ python3 --version

or

> $ python --version

> $ python3 -m pip --version

If the output says Python 3.x, Python 3 has been successfully installed.

## 3. Libraries

In the Command Line or terminal, use the following commands:

> pip install robotframework

> pip install robotframework-requests

> pip install robotframework-jsonlibrary

> pip install robotframework-excel

> pip install json

> pip install mysql-connector-python
>
> pip install pandas

## 4.MySql installation

MacOs
1.Download MySQL Community from the official site https://www.mysql.com/downloads/ and install it on your laptop.
There is Youtube manual how to do it: https://www.youtube.com/watch?v=2cvH0HRjZF8&list=PLZDOU071E4v4S95kbGgRebjKYC5eqSGPM&index=2

Windows:
1.1.Download MySQL Community from the official site https://www.mysql.com/downloads/ and install it on your laptop.
There is Youtube manual how to do it: https://www.youtube.com/watch?v=2om3byn2lxs

2.Open MySql in your terminal and create DB: CREATE DATABASE Satur;
3.Run the SQL statements in your MySQL console to create the "Satur" table with the specified columns.

USE Satur;

CREATE TABLE Satur (
  id INT AUTO_INCREMENT PRIMARY KEY,
  Hotel VARCHAR(255),
  URL VARCHAR(255),
  termin_satur VARCHAR(255),
  terminovy_posun VARCHAR(255),
  pocet_noci INT,
  PAX VARCHAR(255),
  strava VARCHAR(255),
  odlet VARCHAR(255),
  tuzemske_ck VARCHAR(255),
  max_pocet_vysledkov INT,
  izba VARCHAR(255),
  CK VARCHAR(255),
  termin_ck VARCHAR(255),
  cena_za_osobu DECIMAL(10, 2),
  cena_za_zajezd DECIMAL(10, 2),
  timestamp VARCHAR(255)
);

 Once the table is created, you can run your Python script to insert data into the table.


## 5. Jenkins installation

You can use Jenkins for periodicaly run of this script. For each build you can archive XLS output file, RobotFramework HTML report and anything else.
For install open URL: https://www.jenkins.io/download/
Usually Jenkins runs on port 8080, you can choose other one.



