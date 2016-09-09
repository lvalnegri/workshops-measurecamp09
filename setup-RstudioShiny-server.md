---
title: "Setup a (not so) personal analytics server"
author: "Luca Valnegri (l.valnegri@datamaps.co.uk)"
date: "10/09/2016"
output: 
    html_document: 
    toc: yes
toc_depth: 3
---
    
    
## Introduction 
    
*R* is one of the most . RStudio is the most popular IDE for *R*. *Shiny* and *RMarkdown* are two *R* packages that allows users to convert *R* code into an interactive webpage and documents online. 
*RStudio* and *Shiny Servers* allows any researcher or analyst to share shiny apps and RMarkdown documents with your colleagues, stakeholders in your organization or anyone in the world with access to the Internet. 
This relatively short doc explains how to set up Shiny Server on an Ubuntu Machine in the Cloud using the Google IaaS (Infrasctructure as a Service) Compute Engine (*GCE*).

 - *IaaS*, or how anyone can learn how to use his own cloud server without breaking the bank (actually, without even spending 1p)
 - *Ubuntu Linux*, 
 - *R*, 
 - *RStudio*, 
 - *Shiny*,
 - *RStudio Server* + *Shiny Server*, or how anyone can build a powerful analytics machine in minutes
 - *Git* + *GitHub*, or how anyone can share his/her own projects with anyone (and having a backup as well)
 - *GA Demo Account*, or how anyone can learn GA by experimenting with *real* data from the Google Merchandise Store


## Setting up the data-analytics framework

### Create a GCE Virtual Machine

- Go to the [GCE Home page](https://cloud.google.com/compute/) and click *Try it for free*. Enter the minimum needed (names, email, date of birth), then click *Create*. Click *Continue to Google Developers Console*. Click on the *Yes* radio buttons to agree with T&C, then click *Agree and continue*. Fill the information about the and then Click *Start your free trial*.
- Go to the [Project console](https://console.cloud.google.com/iam-admin/projects) and click *CREATE PROJECT*. In the upcoming pop up enter a **suitable name**, then click *Show advanced options...*, and choose **europe-west**. Click *Create*. Give the system some time...
- Go to [VM Instances console](https://console.cloud.google.com/compute/instances), select the project you want to use from the top left arrow list.
- Click the *Create instance button*
    - Name your future VM correspondingly
- Choose one of the **europe-west1** zone
- Under *Machine type* choose *Customise*, and then **8 Cores + 8GB memory**. It is currently ~$199monthly, but you're going to downsizing it later. This is a configuration useful to install quickly all the subsequent software. After that, the hardware should be changed according to use.
- In the *Boot disk* section click *Change*, and then **Ubuntu 16.04 LTS** as OS, **SSD** as *disk type* with a **128GB* *size*.
- In the Firewall section, select **Allow HTTP traffic**.
- Finally, click the *Create* button to actually create the VM. It will take a few minutes... The process is complete when in the subsequent window a green tick appears near the name of your new machine. In future, you can always look at its details using a link like [https://console.cloud.google.com/compute/instancesDetail/zones/<THE-NAME-OF-THE-ZONE-YOU-CHOOSE>/instances/<THE-NAME-OF-YOUR-INSTANCE>](https://console.cloud.google.com/compute/instancesDetail/zones/europe-west1-d/instances/mc-demo)
- Now, click on the machine's name link, near the green tick, to open the configuration page. 
- Scroll down and click the link *default* under *Network*. In the following page, we are going to add at least two rules, each requires clicking the button *Add firewall rules*:
    
    - Enter the name **rstudio-server**, as *source filter* choose **Allow from any sources**, in the textbox marked *Allowed protocols and ports* enter **tcp:8787**
    - Enter the name **shiny-server**, as *source filter* choose **Allow from any sources**, in the textbox marked *Allowed protocols and ports* enter **tcp:3838**
    
    
    ### Working with a Virtual Machine
    
    The way these machines usually work is by *SSHing*, or using a terminal window, to commands, or *SFTPing* to transfer files. 
In both cases, it's possible to use either a browser window, which is possibly limited as we have to login into GCE beforehand, or a specific application from whichever OS and hardware. 

In both cases, it's useful and safer to commit some time to a few preliminary operations to secure the VM from potential hackers.



 - Create alternative user with public key
 - Change SSH port & Disable SSH root access
 - Install a firewall (*fail2ban*)
 - Install an antivirus (ClamAV) 
 - Install [Webmin](http://www.webmin.com/)
 - Install APACHE + PHP7
 - Install MySQL (with [DB Ninja](http://dbninja.com/) web interface)
 - Install Neo4j


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

  - open the file containing a list of *unofficial repositories* to get extra software: `sudo nano /etc/apt/sources.list`
  - add following entry (linux 16.04): `deb http://cran.rstudio.com/bin/linux/ubuntu xenial/` (change **xenial** with **trusty** if using Ubuntu 14.04).
  - add the public key of Michael Rutter to secure apt: 
    ```
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
    gpg -a --export E084DAB9 | sudo apt-key add -
    ```

If the above does not work (mostly because of firewall issues) try the following: 
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

- update & upgrade apt-get: 
sudo apt-get update
sudo apt-get upgrade

- install *R*: sudo apt-get install r-base

- install *R tools* to be able to compile packages from source: sudo apt-get install r-base-dev

#### Uninstalling previous R versions

- remove all packages from inside R B4 uninstalling
sudo su
R

pkgList <- installed.packages(priority = 'NA') 
remove.packages(pkgList) 
.libPaths()  # check libraries directories to be cancelled after exiting R 
q() 
exit

- delete directories: 
sudo rm -rf /usr/local/lib/R
sudo rm -rf /usr/lib/R

- remove all R related packages and libraries:
sudo apt-get remove --purge r-base r-cran
sudo apt-get remove --purge r-studio
sudo apt-get autoremove

- just as a final control, list all the installed packages starting with r: dpkg -l | grep ^ii | grep -E "\Wr-"


### Install RStudio Server

- install auxiliary Ubuntu libraries: 
sudo apt-get install gdebi-core
sudo apt-get install libapparmor1

- download Rstudio Server visiting [this page](http://www.rstudio.com/products/rstudio/download/preview/ '') and copying the address for the link *RStudio Server x.yy.zzzz - Ubuntu 12.04+/Debian 8+ (64-bit)*: 
wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-1.0.9-amd64.deb

- install Rstudio Server: sudo gdebi rstudio-server-0.99.1246-amd64.deb

Now, RStudio Server should be set up. To verify go to **http://your\_server\_ip:8787/** You should see the login form, enter the user and password you earlier, and *happy R coding!*


### Install Shiny Server

- Install first the *shiny* and *rmarkdown* packages from inside R
sudo su
R
install.packages('shiny')
install.packages('rmarkdown')
q()
exit

- download Shiny Server visiting [this page](https://www.rstudio.com/products/shiny/download-server/ '') and copying the address of the current version: 
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.4.801-amd64.deb

- install Shiny Server: sudo gdebi shiny-server-1.4.4.801-amd64.deb


At this point your newly built Ubuntu machine should have a complete working Shiny Server that can host Shiny applications and RMarkdown interactive documents. Try to go to **http://your_server_ip:3838/** and you should be greeted by a shiny app and a Rmarkdown document on the right of the home page.

By default, the server is configured to serve applications in the **/srv/shiny-server/** directory listening to port **3838**. This means that any Shiny application that is placed at **/srv/shiny-server/app\_name** will be available to EVERYONE at *http://your\_server_ip:3838/app\_name/*

To modify these and other default settings, the configuration file for Shiny Server is at **/etc/shiny-server/shiny-server.conf**. 





### Additional Packages


#### Install dependencies

- devtools: sudo apt-get install curl && sudo apt-get install libcurl4-gnutls-dev & sudo apt-get install libssl-dev
- RMySQL: sudo apt-get install libmysqlclient-dev
- RODBC (MSSQL Server): *see related comment*
- rgdal: sudo aptitude install libproj-dev (sudo apt-get install aptitude if not working)
- rgeos: sudo aptitude install libgdal-dev
- geojsonio (must be installed AFTER previous deps for rgdal & rgeos): sudo apt-get install libv8-dev
- XML: sudo apt-get install libxml2-dev
- rJava: sudo apt-get install openjdk-7-* && sudo R CMD javareconf
- PostGRESql: sudo apt-get install libpq-dev
- rgl: sudo apt-get build-dep r-cran-rgl
- EBImage: sudo apt-get install libfftw3-dev


- Connect RStudio with Git: Tools -> Global Options -> Git/SVN

- From the top right menu Project: (None) select New project -> Version control -> Git. In Repository URL enter https://github.com/lvalnegri/datasets and then Create. From the same menu select again New project -> Version control -> Git. In Repository URL enter https://github.com/lvalnegri/presentations-measurecamp09 and then Create. Now from File -> Open choose packages.R

- All packages should be installed as superuser **su** to ensure a unique shared library between users and the shiny user, and avoid duplication and possible mismatches in versions:
sudo su
R
install.packages("pkg_name")
q()
exit

The single installation line could be replaced by the following in case of multiple installations:
dep.pkg <- c(...) # list of packages
pkgs.not.installed <- dep.pkg[!sapply(dep.pkg, function(p) require(p, character.only = TRUE))]
if( length(pkgs.not.installed) > 0 ) install.packages(pkgs.not.installed, dependencies = TRUE)

- Even if not directly needed for installing packages from CRAN, it's important to install *devtools* alone as the first package because some packages need to install packages dependencies that need to be compiled from source. 

- For the purpose of this demo, I advise to only run the following code:
    
    
    #### Install GitHub Packages (devtools)
    
    
    ### Install Git
    
    
    
## Install Additional Services
    

 - Windows file sharing protocol: *Samba*
 - Personal cloud storage: *OwnCloud*
 - Personal e-books Cloud library: *Calibre*
 - Installing a GUI (Lubuntu)
 - Remote Desktop