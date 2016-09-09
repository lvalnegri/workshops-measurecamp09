---
title: "Setup a (not so) personal analytics server"
author: "Luca Valnegri (l.valnegri@datamaps.co.uk)"
date: "10/09/2016"
---

## Introduction 

*R* is one of the most popular programming language in the world, it's free to use, it has a vast and community, but its learning curve is quite steep. Here comes *RStudio*, as the most popular IDE for *R*, that offers a great productivity enhancement. *Shiny* and *RMarkdown* are then two *R* packages that allow users to easily convert *R* code into interactive webpages and dynamic documents online. Finally, *RStudio Server* and *Shiny Server* allow any researcher or analyst to share shiny apps and RMarkdown documents with their team members, colleagues and/or stakeholders in their organization or anyone in the world with access to the Internet. 

This relatively short doc explains how to set up *RStudio Server* and *Shiny Server* on an *Ubuntu* Machine in the Cloud using the *Google Compute Engine*, part of their quite complete IaaS offer called *Google Cloud Platform*. The current offer for a trial is $300 for 2 months, that allows anyone to learn how to build a powerful analytics machine in minutes without breaking the bank (actually, without even spending 1p). 


## Setting up the data-analytics framework

### Create a GCE Virtual Machine

- Go to the [GCE Home page](https://cloud.google.com/compute/) and click *Try it for free*. Enter the minimum needed (names, email, date of birth), then click *Create*. Click *Continue to Google Developers Console*. Click on the *Yes* radio buttons to agree with T&C, then click *Agree and continue*. Fill the information about the billing method and then Click *Start your free trial*.
- Go to the [Project console](https://console.cloud.google.com/iam-admin/projects) and click *CREATE PROJECT*. In the upcoming pop up enter a **suitable name**, then click *Show advanced options...*, and choose **europe-west**. Click *Create*. Give the system some time...
- Go to [VM Instances console](https://console.cloud.google.com/compute/instances), select the project you want to use from the top left arrow list.
- Click the *Create instance button*
    - Name your future VM correspondingly
- Choose one of the **europe-west1** zone
- Under *Machine type* choose *Customise*, and then **8 Cores + 8GB memory**. It is currently ~$199monthly, but you're going to downsizing it later. This is a configuration useful to install quickly all the subsequent software. After that, the hardware should be changed according to use.
- In the *Boot disk* section click *Change*, and then **Ubuntu 16.04 LTS** as OS, **SSD** as *disk type* with a **128GB* *size*.
- In the Firewall section, select **Allow HTTP traffic**.
- Finally, click the *Create* button to actually create the VM. It will take a few minutes... The process is complete when in the subsequent window a green tick appears near the name of your new machine. In future, you can always look at its details using a link like https://console.cloud.google.com/compute/instancesDetail/zones/<THE-NAME-OF-THE-ZONE-YOU-CHOOSE>/instances/<THE-NAME-OF-YOUR-INSTANCE>
- Now, click on the machine name's link, near the green tick, to open the configuration page. 
- Scroll down and click the link *default* under *Network*. In the following page, we are going to add at least two rules, each requires clicking the button *Add firewall rules*:
    
    - Enter the name **rstudio-server**, as *source filter* choose **Allow from any sources**, in the textbox marked *Allowed protocols and ports* enter **tcp:8787**
    - Enter the name **shiny-server**, as *source filter* choose **Allow from any sources**, in the textbox marked *Allowed protocols and ports* enter **tcp:3838**
    
### Working with a Virtual Machine
    
The way these machines usually work is by *SSHing*, or using a terminal window, to send commands, or *SFTPing* to transfer files. 
In both cases, it's possible to use either a browser window, or an application related to the specific OS and hardware at hand. 

We can't go through n both cases, it's useful and safer to commit some time to a few preliminary operations to secure the VM from potential hackers:

 - Create alternative user with public key + password, so no direct su power
 - Change SSH port & Disable SSH root access
 - Install a firewall (*fail2ban*)
 - Install an antivirus (ClamAV) 

## Installing the analytics software

### Install R

 - Create a user, home directory and set password:
   ```
   sudo useradd analytics
   sudo mkdir /home/analytics
   sudo passwd analytics
   sudo chmod -R 0777 /home/analytics
   ```

 - add the CRAN repository to the system file: 

   - open the system file containing a list of *unofficial repositories* to get extra software: 
   
     `sudo nano /etc/apt/sources.list`

     and add the following entry: 
   
     `deb http://cran.rstudio.com/bin/linux/ubuntu xenial/`

   - add the public key of Michael Rutter to secure apt: 
 
     ```
     gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
     gpg -a --export E084DAB9 | sudo apt-key add -
     ```

 - update and upgrade the system: 

    ```
    sudo apt-get update
    sudo apt-get upgrade
    ```
    
 - install *R*: `sudo apt-get install r-base`

### Install RStudio Server

 - install auxiliary Ubuntu libraries: 

   ```
   sudo apt-get install gdebi-core
   sudo apt-get install libapparmor1
   ```

 - download Rstudio Server: `wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-1.0.9-amd64.deb`

   It could be useful to visit [this page](http://www.rstudio.com/products/rstudio/download/preview/) to see if any newer version is available, and in that case copy the address for the link *RStudio Server x.yy.zzzz - Ubuntu 12.04+/Debian 8+ (64-bit)*

 - install Rstudio Server: `sudo gdebi rstudio-server-0.99.1246-amd64.deb`

Now, RStudio Server should be set up. To verify go to **http://your\_server\_ip:8787/** You should see the login form, enter the user and password you created earlier, and *happy R coding!*

### Install Shiny Server

 - Install first the *shiny* and *rmarkdown* packages from inside R
 
   ```
   sudo su
   R
   install.packages('shiny')
   install.packages('rmarkdown')
   q()
   exit
   ```
   
  - download Shiny Server: `wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.4.801-amd64.deb`

    It could be useful to visit [this page](https://www.rstudio.com/products/shiny/download-server/) to see if any newer version is available, and in that case copy the address 

 - install Shiny Server: `sudo gdebi shiny-server-1.4.4.801-amd64.deb`

At this point your newly built Ubuntu machine should have a complete working Shiny Server, that can host both Shiny applications and RMarkdown interactive documents. Try to go to **http://your_server_ip:3838/** and you should be greeted by a shiny app and a Rmarkdown document on the right of the home page.

By default, the server is configured to serve applications in the **/srv/shiny-server/** directory of the system using the *shiny* user, listening to port **3838**. This means that any Shiny application that is placed at **/srv/shiny-server/app\_name** will be available to EVERYONE at *http://your\_server_ip:3838/app\_name/*

To modify these and other default settings, the configuration file for Shiny Server is found at */etc/shiny-server/shiny-server.conf*. 
Other steps that should be surely taken are:
 - Adding https
 - Adding authentication
 - Changing address

### Install Packages

The power of the *R* system is its possibility to unlimited growth using *packages*. Some of them require additional software to be installed beforehand. The attached scripts require only the libraries needed for *devtools, but I thought useful to list some of the dependencies needed for the most used packages.

 - devtools: sudo apt-get install curl && sudo apt-get install libcurl4-gnutls-dev & sudo apt-get install libssl-dev
 - XML: sudo apt-get install libxml2-dev
 - rJava: sudo apt-get install openjdk-7-* && sudo R CMD javareconf
 - RMySQL: sudo apt-get install libmysqlclient-dev
 - rgdal: sudo aptitude install libproj-dev (sudo apt-get install aptitude if not working) 
 - rgeos: sudo aptitude install libgdal-dev
 - geojsonio (must be installed AFTER previous deps for rgdal & rgeos): sudo apt-get install libv8-dev
 - PostGRESql: sudo apt-get install libpq-dev

All packages should be installed as superuser **su** to ensure a unique shared library between users and the shiny user, so to avoid duplication and possible mismatches in versions:

```
sudo su
R
install.packages("pkg_name")
q()
exit
```

The single installation line could be replaced by the following snippet in case of multiple installations:

```
dep.pkg <- c(...) # list of packages
pkgs.not.installed <- dep.pkg[!sapply(dep.pkg, function(p) require(p, character.only = TRUE))]
if( length(pkgs.not.installed) > 0 ) install.packages(pkgs.not.installed, dependencies = TRUE)
```

For the purpose of this short demo, though, I advise you to only run the following single line of code:
```
lapply(c('devtools', 'data.table', 'DT', 'ggplot2', 'jsonlite', 'leaflet', 'shinythemes'), install.packages)
```

### Connect RStudio with Git

*GitHub* is an online repository hosting service based on the version control system *Git*, which has also become one of the most popular website where developers and resaearchers share (and backup!) their code and data. *RStudio* can link to *Git* on the machine and *GitHub* on the web, and provides a simple GUI that eases the hassle to deal with the *Git* shell.

Let's download the code and datasets that I prepared for you!

 - Open the Rstudio Server
 - Open **Tools** -> **Global Options** -> **Git/SVN**, and make sure that *Enable version control...* is checked. If not, check it and enter (or browse to) **/usr/bin/git** in *Git executable*
 - From the top right menu *Project: (None)* select **New project** -> **Version control** -> **Git**. 
 - In *Repository URL* enter the path of the my repository containing some datasets we will use with the scripts **https://github.com/lvalnegri/datasets** and then *Create*. 
 - From the same menu select again **New project** -> **Version control** -> **Git**. 
 - In Repository URL enter now the repository you're currently reading *https://github.com/lvalnegri/presentations-measurecamp09* and then *Create*. 
 - Now from **File** -> **Open** choose **packages.R**

